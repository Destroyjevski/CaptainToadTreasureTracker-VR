#pragma once
#include "cemuvr/diag.h"
#include "cemuvr/interop.h"
#include <array>
#include <cstdint>

namespace cemuvr {

// GPU timestamps at the eye markers.
//
// Everything the layer measures on the CPU is command-recording time: Cemu
// records ahead of the GPU, so those numbers cannot say what a second rendered
// pair would cost. This writes a timestamp into the guest's own command buffer
// at each eye marker, so the delta between the two markers of one pair is the
// GPU time that the second eye actually took. That single number decides
// whether four eye views can fit into one simulation step at this resolution.
//
// Bounded and read-only with respect to the guest: one reset and one write per
// marker, results harvested without ever waiting. If anything is missing the
// whole thing disables itself and the rest of the layer is unaffected.
struct GpuClock {
    static constexpr uint32_t capacity = 128;   // ~32 frames of history

    VkQueryPool pool{};
    double nsPerTick{};
    uint32_t next{};
    bool ready{}, failed{}, reported{};

    struct Pending { uint64_t serial{}; unsigned eye{}, slot{}; bool live{}; };
    std::array<Pending, capacity> pending{};

    struct Sample { uint64_t serial{}; unsigned eye{}; double ns{}; bool valid{}; };
    std::array<Sample, 8> recent{};   // newest first
    uint64_t harvested{}, dropped{};

    // Accumulated GPU intervals, in milliseconds.
    double secondEyeSum{}, secondEyeMax{}, pairSum{}, pairMax{};
    uint64_t secondEyeCount{}, pairCount{};

    PFN_vkCreateQueryPool create{};
    PFN_vkDestroyQueryPool destroy{};
    PFN_vkCmdResetQueryPool resetQueries{};
    PFN_vkCmdWriteTimestamp writeStamp{};
    PFN_vkGetQueryPoolResults readResults{};

    bool initialize(const VulkanCtx& vk) {
        if (ready || failed) return ready;
        auto get = [&](const char* name) { return vk.fn.GetDeviceProcAddr(vk.device, name); };
        create = (PFN_vkCreateQueryPool)get("vkCreateQueryPool");
        destroy = (PFN_vkDestroyQueryPool)get("vkDestroyQueryPool");
        resetQueries = (PFN_vkCmdResetQueryPool)get("vkCmdResetQueryPool");
        writeStamp = (PFN_vkCmdWriteTimestamp)get("vkCmdWriteTimestamp");
        readResults = (PFN_vkGetQueryPoolResults)get("vkGetQueryPoolResults");
        if (!create || !destroy || !resetQueries || !writeStamp || !readResults ||
            !vk.fn.GetPhysicalDeviceProperties2) {
            failed = true;
            CVR_ERR("gpu.clock", "entry_points_missing=1");
            return false;
        }
        VkPhysicalDeviceProperties2 props{VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PROPERTIES_2};
        vk.fn.GetPhysicalDeviceProperties2(vk.phys, &props);
        nsPerTick = props.properties.limits.timestampPeriod;
        // A queue family without timestamp bits silently returns zeroes.
        if (nsPerTick <= 0.0) {
            failed = true;
            CVR_ERR("gpu.clock", "timestamp_period_invalid=%.3f", nsPerTick);
            return false;
        }
        VkQueryPoolCreateInfo ci{VK_STRUCTURE_TYPE_QUERY_POOL_CREATE_INFO};
        ci.queryType = VK_QUERY_TYPE_TIMESTAMP;
        ci.queryCount = capacity;
        if (create(vk.device, &ci, nullptr, &pool) != VK_SUCCESS) {
            failed = true;
            CVR_ERR("gpu.clock", "query_pool_failed=1");
            return false;
        }
        ready = true;
        CVR_INFO("gpu.clock", "ready=1 queries=%u ns_per_tick=%.4f", capacity, nsPerTick);
        return true;
    }

    // Called where the guest marks a finished eye, in the guest's own command
    // buffer. Reset and write are recorded together so no separate pass is
    // needed; both are legal outside a render pass, which a clear command is.
    void stamp(const VulkanCtx& vk, VkCommandBuffer cb, const ReferenceMarker& marker,
               uint64_t serial) {
        if (!initialize(vk)) return;
        const uint32_t index = next;
        next = (next + 1) % capacity;
        if (pending[index].live) ++dropped;   // wrapped before it was read
        resetQueries(cb, pool, index, 1);
        writeStamp(cb, VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT, pool, index);
        pending[index] = {serial, marker.eye, marker.slot, true};
    }

    // Never waits. Whatever the GPU has finished is converted and folded into
    // the running intervals; the rest stays pending for the next call.
    void harvest(const VulkanCtx& vk) {
        if (!ready) return;
        for (uint32_t i = 0; i < capacity; ++i) {
            if (!pending[i].live) continue;
            uint64_t ticks = 0;
            if (readResults(vk.device, pool, i, 1, sizeof(ticks), &ticks, sizeof(ticks),
                            VK_QUERY_RESULT_64_BIT) != VK_SUCCESS)
                continue;                      // VK_NOT_READY: try again later
            const Pending tag = pending[i];
            pending[i].live = false;
            ++harvested;
            const double ns = double(ticks) * nsPerTick;
            // Second eye of the same pair, and pair-to-pair, both in GPU time.
            for (const auto& s : recent) {
                if (!s.valid) continue;
                if (s.serial == tag.serial && tag.eye == 1 && s.eye == 0 && ns > s.ns) {
                    const double ms = (ns - s.ns) / 1e6;
                    secondEyeSum += ms; ++secondEyeCount;
                    if (ms > secondEyeMax) secondEyeMax = ms;
                } else if (tag.eye == 0 && s.eye == 0 && s.serial + 1 == tag.serial && ns > s.ns) {
                    const double ms = (ns - s.ns) / 1e6;
                    pairSum += ms; ++pairCount;
                    if (ms > pairMax) pairMax = ms;
                }
            }
            for (size_t k = recent.size() - 1; k > 0; --k) recent[k] = recent[k - 1];
            recent[0] = {tag.serial, tag.eye, ns, true};
        }
    }

    void report() {
        if (!ready) return;
        CVR_INFO("gpu.clock",
                 "second_eye_ms_mean=%.3f max=%.3f n=%llu | pair_period_ms_mean=%.3f max=%.3f n=%llu "
                 "| harvested=%llu dropped=%llu -- GPU marker-to-marker, includes idle",
                 secondEyeCount ? secondEyeSum / double(secondEyeCount) : 0.0, secondEyeMax,
                 (unsigned long long)secondEyeCount,
                 pairCount ? pairSum / double(pairCount) : 0.0, pairMax,
                 (unsigned long long)pairCount,
                 (unsigned long long)harvested, (unsigned long long)dropped);
        secondEyeSum = pairSum = 0; secondEyeCount = pairCount = 0;
    }

    void destroyPool(const VulkanCtx& vk) {
        if (pool && destroy) destroy(vk.device, pool, nullptr);
        pool = VK_NULL_HANDLE; ready = false;
    }
};

}  // namespace cemuvr
