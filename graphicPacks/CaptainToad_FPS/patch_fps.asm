[CaptainToadFPS_V16]
moduleMatches = 0x1B377483
.origin = codecave
ctTelemetry:
.int 0x43544650
.int 1
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
; Guest bus/4 clock: 62,156,250 ticks/s. Twice ticks gives exact 60 Hz.
; One step maximum per rendered frame. Rebase after >= 33.333 ms stalls.
ctClock:
stwu r1, -0x20(r1)
mflr r0
stw r0, 0x24(r1)
stw r3, 8(r1)
.int 0x7C000026 ; mfcr r0 (not supported by Cemu's text assembler)
stw r0, 12(r1)
bl import.coreinit.OSGetSystemTime
lis r12, ctTelemetry@ha
addi r12, r12, ctTelemetry@l
lwz r10, 32(r12)
stw r4, 32(r12)
subf r9, r10, r4
lis r8, 31
ori r8, r8, 40259
cmpwi r10, 0
beq ctClockReset
cmplw r9, r8
bge ctClockReset
slwi r9, r9, 1
lwz r10, 36(r12)
add r9, r9, r10
b ctClockCompare
ctClockReset:
mr r9, r8
ctClockCompare:
li r11, 0
cmplw r9, r8
blt ctClockStore
li r11, 1
subf r9, r8, r9
cmplw r9, r8
blt ctClockStore
li r9, 0
ctClockStore:
stw r9, 36(r12)
stw r11, 152(r12)
lwz r3, 8(r1)
lwz r0, 12(r1)
.int 0x7C0FF120 ; mtcrf 0xFF, r0
lwz r0, 0x24(r1)
mtlr r0
addi r1, r1, 0x20
blr

; Poll and advance controller state only on the same ticks as gameplay.
ctInput:
lis r12, ctTelemetry@ha
addi r12, r12, ctTelemetry@l
lwz r11, 152(r12)
cmpwi r11, 0
beqlr
lwz r11, 156(r12)
addi r11, r11, 1
stw r11, 156(r12)
mflr r0
b ctInputContinue
0x022C19CC = ba ctInput
0x022C19D0 = ctInputContinue:

; Frame entry: count, read the clock once, decide the 60 Hz step, then the
; displaced mflr r0 runs last so LR is exactly what the original expects.
ctFrame:
lis r12, ctTelemetry@ha
addi r12, r12, ctTelemetry@l
lwz r11, 8(r12)
addi r11, r11, 1
stw r11, 8(r12)
stwu r1, -0x10(r1)
mflr r0
stw r0, 0x14(r1)
bl ctClock
lwz r0, 0x14(r1)
mtlr r0
addi r1, r1, 0x10
mflr r0
b ctFrameContinue
0x02420F10 = ba ctFrame
0x02420F14 = ctFrameContinue:

; RootState FSM only on step frames. On a render-only frame release the two
; temporary render textures for every owner observed in the preceding native
; step. Death/respawn and scene transitions can have more than one owner;
; remembering only the last one eventually exhausts the render-texture pool.
ctCalc:
lis r12, ctTelemetry@ha
addi r12, r12, ctTelemetry@l
stw r3, 96(r12)
lwz r11, 152(r12)
cmpwi r11, 0
bne ctDoCalc
lwz r11, 40(r12)
addi r11, r11, 1
stw r11, 40(r12)
lwz r11, 184(r12)
cmpwi r11, 0
beq ctSkipDone
cmpwi r11, 12
bgt ctUnsafeOverflow
lwz r10, 8(r3)
cmpwi r10, 0
beq ctUnsafeContext
lwz r9, 88(r12)
cmpw r9, r10
bne ctUnsafeContext
stwu r1, -0x20(r1)
mflr r0
stw r0, 0x24(r1)
li r11, 0
stw r11, 8(r1)
ctReplayLoop:
lis r12, ctTelemetry@ha
addi r12, r12, ctTelemetry@l
lwz r11, 8(r1)
lwz r10, 184(r12)
cmpw r11, r10
bge ctReplayDone
slwi r10, r11, 2
add r10, r12, r10
lwz r3, 188(r10)
cmpwi r3, 0
beq ctReplayNext
bl ctCleanup
ctReplayNext:
lwz r11, 8(r1)
addi r11, r11, 1
stw r11, 8(r1)
b ctReplayLoop
ctReplayDone:
lwz r0, 0x24(r1)
mtlr r0
addi r1, r1, 0x20
ctSkipDone:
blr
; A stale cleanup owner is unsafe. Run one complete Calc on this transition
; frame instead of leaking the finite render-texture pool.
ctUnsafeOverflow:
lis r12, ctTelemetry@ha
addi r12, r12, ctTelemetry@l
lwz r11, 244(r12)
addi r11, r11, 1
stw r11, 244(r12)
b ctUnsafeCalc
ctUnsafeContext:
lis r12, ctTelemetry@ha
addi r12, r12, ctTelemetry@l
lwz r11, 240(r12)
addi r11, r11, 1
stw r11, 240(r12)
ctUnsafeCalc:
lwz r11, 236(r12)
addi r11, r11, 1
stw r11, 236(r12)
ctDoCalc:
lis r12, ctTelemetry@ha
li r11, 0
stw r11, ctTelemetry@l+184(r12)
lis r12, ctTelemetry@ha
addi r12, r12, ctTelemetry@l
lwz r11, 12(r12)
addi r11, r11, 1
stw r11, 12(r12)
b ctNativeFsm
0x0236E560 = ctNativeFsm:
0x022A6CA8 = bla ctCalc

; Native per-step release of the temporary textures: preserve every argument
; for render-only frames, then run the original chain. Replayed calls have a
; zero step flag and therefore do not append themselves to the list.
ctCleanup:
lis r12, ctTelemetry@ha
addi r12, r12, ctTelemetry@l
lwz r10, 152(r12)
cmpwi r10, 0
beq ctCleanupNative
lwz r11, 84(r12)
addi r11, r11, 1
stw r11, 84(r12)
lwz r11, 184(r12)
cmpwi r11, 12
bge ctCleanupOverflow
slwi r10, r11, 2
add r10, r12, r10
stw r3, 188(r10)
addi r11, r11, 1
stw r11, 184(r12)
b ctRememberContext
ctCleanupOverflow:
li r11, 13
stw r11, 184(r12)
ctRememberContext:
lwz r11, 96(r12)
cmpwi r11, 0
beq ctNoCleanupOwner
lwz r11, 8(r11)
cmpwi r11, 0
beq ctNoCleanupOwner
stw r11, 88(r12)
b ctCleanupNative
ctNoCleanupOwner:
li r11, 0
stw r11, 184(r12)
ctCleanupNative:
b ctNativeRelease
0x0245C510 = ctNativeRelease:
0x02383F38 = bla ctCleanup
