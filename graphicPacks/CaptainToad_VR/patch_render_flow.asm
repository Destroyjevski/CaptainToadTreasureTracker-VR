[CaptainToad_VR_V16]
moduleMatches = 0x1B377483, 0x9E0461E7, 0x0576A725
.origin = codecave
; Stereo render flow: two drawings from one calculated simulation state.
rrFlowHeader:
.int 0x4354464C
.int 1
rrEnabled:
.int 1
rrExtraDraws:
.int 0
rrSkipped:
.int 0
rrMarkerMagic:
.int 0x43544D31
rrMarkerAck:
.int 0
rrEye:
.int 0
rrSlot:
.int 0
rrCopyCalls:
.int 0
rrCopyBuffer:
.int 0
rrCopyTarget:
.int 0
rrEmitCount:
.int 0
rrValueTV:
.int 0x3D000000
rrValueDRC:
.int 0x3E000000
rrValueA:
.int 0x3DFCD6EA
rrValueB:
.int 0x3F7CD6EA
rrValueZero:
.int 0
rrValueOne:
.int 0x3F800000
0x02420F7C = rrAfterSecondDraw:
0x02421478 = rrPresent:
0x02421264 = rrDraw:
0x024215C0 = rrRecord:
rrSecondDraw:
mflr r0
stwu r1, -0x20(r1)
stw r0, 0x24(r1)
bl tpViewRestore
lis r12, rrEnabled@ha
addi r12, r12, rrEnabled@l
lwz r11, 0(r12)
cmpwi r11, 1
bne rrSkip
; Display-list preparation has to exist before an additional draw is possible.
lbz r11, 0x380(r31)
cmpwi r11, 0
beq rrSkip
lwz r11, 0x388(r31)
cmpwi r11, 0
blt rrSkip
; Complete the previous draw without adding a second scan-buffer swap.
mr r3, r31
bl import.gx2.GX2DrawDone
; Draw the just-prepared list; procDraw flips the list-buffer index itself.
mr r3, r31
bl rrDraw
; Conservative GPU barrier between eye renders.
bl import.gx2.GX2DrawDone
; Prepare the other list from the same calculated state, without another calc.
lis r12, rrEye@ha
addi r12, r12, rrEye@l
li r11, 1
stw r11, 0(r12)
lis r12, rrSecondRecord@ha
addi r12, r12, rrSecondRecord@l
li r11, 1
stw r11, 0(r12)
mr r3, r31
bl rrRecord
lis r12, rrSecondRecord@ha
addi r12, r12, rrSecondRecord@l
li r11, 0
stw r11, 0(r12)
lis r12, rrExtraDraws@ha
addi r12, r12, rrExtraDraws@l
lwz r11, 0(r12)
addi r11, r11, 1
stw r11, 0(r12)
b rrFinish
rrSkip:
lis r12, rrSkipped@ha
addi r12, r12, rrSkipped@l
lwz r11, 0(r12)
addi r11, r11, 1
stw r11, 0(r12)
rrFinish:
lwz r0, 0x24(r1)
mtlr r0
addi r1, r1, 0x20
lwz r8, 0x24(r31)
b rrAfterSecondDraw
0x02420F78 = ba rrSecondDraw

0x02420F54 = rrAfterBeforeCalc:
rrBeforeCalc:
; Complete the submitted second eye BEFORE game calc reuses effect data.
; Ported from the SM3DW stereo pack (rrBeforeCalc at 024DB300): without it
; the second eye of the previous frame is still on the GPU while calc
; rewrites per-actor data, and moving objects land at wrong positions in
; that eye. Static geometry has no such data and was never affected.
stwu r1, -0x20(r1)
stw r0, 8(r1)
mflr r0
stw r0, 0x24(r1)
bl import.gx2.GX2DrawDone
bl tpViewRestore
lwz r0, 0x24(r1)
mtlr r0
lwz r0, 8(r1)
addi r1, r1, 0x20
lis r12, rrEye@ha
addi r12, r12, rrEye@l
li r11, 0
stw r11, 0(r12)
lwz r11, 4(r12)
addi r11, r11, 1
andi. r11, r11, 1
stw r11, 4(r12)
; Pose packet, published by the host; sequence is even when complete.
lis r12, rrSlot@ha
addi r12, r12, rrSlot@l
lwz r11, 0(r12)
mulli r11, r11, 196
lis r12, rrPoseLatch0@ha
addi r12, r12, rrPoseLatch0@l
add r12, r12, r11
li r11, 0
stw r11, 0(r12)
lis r8, rrPoseHeader@ha
addi r8, r8, rrPoseHeader@l
lwz r7, 8(r8)
andi. r11, r7, 1
bne rrPoseLatchDone
cmpwi r7, 0
beq rrPoseLatchDone
lwz r11, 12(r8)
cmpwi r11, 1
bne rrPoseLatchDone
.int 0x7C2004AC ; lwsync
lwz r11, 24(r8)
stw r11, 4(r12)
lwz r11, 28(r8)
stw r11, 8(r12)
lwz r11, 32(r8)
stw r11, 12(r12)
lwz r11, 36(r8)
stw r11, 16(r12)
lwz r11, 40(r8)
stw r11, 20(r12)
lwz r11, 44(r8)
stw r11, 24(r12)
lwz r11, 48(r8)
stw r11, 28(r12)
lwz r11, 52(r8)
stw r11, 32(r12)
lwz r11, 56(r8)
stw r11, 36(r12)
lwz r11, 60(r8)
stw r11, 40(r12)
lwz r11, 64(r8)
stw r11, 44(r12)
lwz r11, 68(r8)
stw r11, 48(r12)
lwz r11, 72(r8)
stw r11, 52(r12)
lwz r11, 76(r8)
stw r11, 56(r12)
lwz r11, 80(r8)
stw r11, 60(r12)
lwz r11, 84(r8)
stw r11, 64(r12)
lwz r11, 88(r8)
stw r11, 68(r12)
lwz r11, 92(r8)
stw r11, 72(r12)
lwz r11, 96(r8)
stw r11, 76(r12)
lwz r11, 100(r8)
stw r11, 80(r12)
lwz r11, 104(r8)
stw r11, 84(r12)
lwz r11, 108(r8)
stw r11, 88(r12)
lwz r11, 112(r8)
stw r11, 92(r12)
lwz r11, 116(r8)
stw r11, 96(r12)
lwz r11, 120(r8)
stw r11, 100(r12)
lwz r11, 124(r8)
stw r11, 104(r12)
lwz r11, 128(r8)
stw r11, 108(r12)
lwz r11, 132(r8)
stw r11, 112(r12)
lwz r11, 136(r8)
stw r11, 116(r12)
lwz r11, 140(r8)
stw r11, 120(r12)
lwz r11, 144(r8)
stw r11, 124(r12)
lwz r11, 148(r8)
stw r11, 128(r12)
lwz r11, 152(r8)
stw r11, 132(r12)
lwz r11, 156(r8)
stw r11, 136(r12)
lwz r11, 160(r8)
stw r11, 140(r12)
lwz r11, 164(r8)
stw r11, 144(r12)
lwz r11, 168(r8)
stw r11, 148(r12)
lwz r11, 172(r8)
stw r11, 152(r12)
lwz r11, 176(r8)
stw r11, 156(r12)
lwz r11, 180(r8)
stw r11, 160(r12)
lwz r11, 184(r8)
stw r11, 164(r12)
lwz r11, 188(r8)
stw r11, 168(r12)
lwz r11, 192(r8)
stw r11, 172(r12)
lwz r11, 196(r8)
stw r11, 176(r12)
lwz r11, 200(r8)
stw r11, 180(r12)
lwz r11, 204(r8)
stw r11, 184(r12)
lwz r11, 208(r8)
stw r11, 188(r12)
lwz r11, 212(r8)
stw r11, 192(r12)
; The controllers, copied under the same sequence guard as the pose.
lis r10, mtPad@ha
addi r10, r10, mtPad@l
lwz r11, 216(r8)
stw r11, 0(r10)
lwz r11, 220(r8)
stw r11, 4(r10)
lwz r11, 224(r8)
stw r11, 8(r10)
lwz r11, 228(r8)
stw r11, 12(r10)
lwz r11, 232(r8)
stw r11, 16(r10)
lwz r11, 236(r8)
stw r11, 20(r10)
lwz r11, 240(r8)
stw r11, 24(r10)
lwz r11, 244(r8)
stw r11, 28(r10)
lwz r11, 248(r8)
stw r11, 32(r10)
lwz r11, 252(r8)
stw r11, 36(r10)
lwz r11, 256(r8)
stw r11, 40(r10)
lwz r11, 260(r8)
stw r11, 44(r10)
lwz r11, 264(r8)
stw r11, 48(r10)
lwz r11, 268(r8)
stw r11, 52(r10)
lwz r11, 272(r8)
stw r11, 56(r10)
lwz r11, 276(r8)
stw r11, 60(r10)
lwz r11, 280(r8)
stw r11, 64(r10)
lwz r11, 284(r8)
stw r11, 68(r10)
lwz r11, 288(r8)
stw r11, 72(r10)
lwz r11, 292(r8)
stw r11, 76(r10)
lwz r11, 296(r8)
stw r11, 80(r10)
lwz r11, 300(r8)
stw r11, 84(r10)
lwz r11, 304(r8)
stw r11, 88(r10)
lwz r11, 308(r8)
stw r11, 92(r10)
lwz r11, 312(r8)
stw r11, 96(r10)
lwz r11, 316(r8)
stw r11, 100(r10)
lwz r11, 320(r8)
stw r11, 104(r10)
lwz r11, 324(r8)
stw r11, 108(r10)
lwz r11, 328(r8)
stw r11, 112(r10)
lwz r11, 332(r8)
stw r11, 116(r10)
lwz r11, 336(r8)
stw r11, 120(r10)
lwz r11, 340(r8)
stw r11, 124(r10)
lwz r11, 344(r8)
stw r11, 128(r10)
lwz r11, 348(r8)
stw r11, 132(r10)
lwz r11, 352(r8)
stw r11, 136(r10)
lwz r11, 356(r8)
stw r11, 140(r10)
lwz r11, 360(r8)
stw r11, 144(r10)
lwz r11, 364(r8)
stw r11, 148(r10)
lwz r11, 368(r8)
stw r11, 152(r10)
lwz r11, 372(r8)
stw r11, 156(r10)
.int 0x7C2004AC ; lwsync
lwz r11, 8(r8)
cmpw r7, r11
bne rrPoseLatchDone
stw r7, 0(r12)
rrPoseLatchDone:
lis r9, rrSlot@ha
addi r9, r9, rrSlot@l
lwz r10, 0(r9)
mulli r10, r10, 8
lis r9, rrMenuCameraUsed@ha
addi r9, r9, rrMenuCameraUsed@l
add r9, r9, r10
li r10, 0
stw r10, 0(r9)
stw r10, 4(r9)
mr r3, r31
b rrAfterBeforeCalc
0x02420F50 = ba rrBeforeCalc

rrCopyMarker:
mflr r0
stwu r1, -0x20(r1)
stw r0, 0x24(r1)
stw r3, 0x1C(r1)
stw r4, 0x18(r1)
lis r12, rrCopyCalls@ha
addi r12, r12, rrCopyCalls@l
lwz r11, 0(r12)
addi r11, r11, 1
stw r11, 0(r12)
stw r3, 4(r12)
stw r4, 8(r12)
bl import.gx2.GX2CopyColorBufferToScanBuffer
; Only emit protocol clear commands after this process's core acknowledges support.
lis r12, rrMarkerAck@ha
addi r12, r12, rrMarkerAck@l
lwz r11, 0(r12)
lis r10, 0x4354
addi r10, r10, 0x4D31
cmpw r11, r10
bne rrCopyExit
lwz r4, 0x18(r1)
cmpwi r4, 1
beq rrCopyTV
cmpwi r4, 4
bne rrCopyExit
lis r12, rrValueDRC@ha
addi r12, r12, rrValueDRC@l
lfs f1, 0(r12)
b rrCopyEye
rrCopyTV:
lis r12, rrValueTV@ha
addi r12, r12, rrValueTV@l
lfs f1, 0(r12)
rrCopyEye:
lis r12, rrEye@ha
addi r12, r12, rrEye@l
lwz r11, 0(r12)
cmpwi r11, 0
lis r12, rrValueA@ha
addi r12, r12, rrValueA@l
bne rrCopyRight
lfs f2, 0(r12)
lfs f3, 4(r12)
b rrCopySlot
rrCopyRight:
lfs f3, 0(r12)
lfs f2, 4(r12)
rrCopySlot:
lis r12, rrSlot@ha
addi r12, r12, rrSlot@l
lwz r11, 0(r12)
cmpwi r11, 0
lis r12, rrValueZero@ha
addi r12, r12, rrValueZero@l
bne rrCopySlotOne
lfs f4, 0(r12)
b rrEmitMarker
rrCopySlotOne:
lfs f4, 4(r12)
rrEmitMarker:
lis r12, rrEmitCount@ha
addi r12, r12, rrEmitCount@l
lwz r11, 0(r12)
addi r11, r11, 1
stw r11, 0(r12)
; Preserve the ordinary eye marker across the metadata clear call.
stwu r1, -0x20(r1)
stfs f1, 8(r1)
stfs f2, 12(r1)
stfs f3, 16(r1)
stfs f4, 20(r1)
lis r12, rrSlot@ha
addi r12, r12, rrSlot@l
lwz r11, 0(r12)
mulli r11, r11, 196
lis r12, rrPoseLatch0@ha
addi r12, r12, rrPoseLatch0@l
add r12, r12, r11
lfs f3, 164(r12)
lfs f4, 168(r12)
lwz r11, 0(r12)
cmpwi r11, 0
beq rrPoseMarkerInvalid
mr r10, r11
lis r12, rrEye@ha
addi r12, r12, rrEye@l
lwz r11, 4(r12)
lwz r12, 0(r12)
mulli r11, r11, 2
add r11, r11, r12
mulli r11, r11, 4
lis r12, rrProjectionPoseSequence@ha
addi r12, r12, rrProjectionPoseSequence@l
add r12, r12, r11
lwz r11, 0(r12)
cmpw r10, r11
beq rrPoseMarkerValid
rrPoseMarkerInvalid:
lis r12, rrValueZero@ha
addi r12, r12, rrValueZero@l
lfs f3, 0(r12)
lfs f4, 0(r12)
rrPoseMarkerValid:
lis r12, rrPoseMarkerMagic@ha
addi r12, r12, rrPoseMarkerMagic@l
lfs f1, 0(r12)
lfs f2, 4(r12)
rrMenuMetadataSelect:
lis r12, rrEye@ha
addi r12, r12, rrEye@l
lwz r11, 0(r12)
lwz r12, 4(r12)
mulli r12, r12, 2
add r11, r11, r12
mulli r11, r11, 4
lis r12, rrMenuCameraUsed@ha
addi r12, r12, rrMenuCameraUsed@l
add r12, r12, r11
lwz r11, 0(r12)
cmpwi r11, 0
bne rrMenuMetadataDone
lis r12, rrMenuMetadataMagic@ha
addi r12, r12, rrMenuMetadataMagic@l
lfs f1, 0(r12)
rrMenuMetadataDone:
lwz r3, 0x3C(r1)
bl import.gx2.GX2ClearColor
lfs f1, 8(r1)
lfs f2, 12(r1)
lfs f3, 16(r1)
lfs f4, 20(r1)
addi r1, r1, 0x20
lwz r3, 0x1C(r1)
bl import.gx2.GX2ClearColor
rrCopyExit:
lwz r0, 0x24(r1)
mtlr r0
addi r1, r1, 0x20
blr
0x022CF15C = bla rrCopyMarker
0x022E4CD0 = bla rrCopyMarker
0x022E4CF0 = bla rrCopyMarker

rrCameraHeader:
.int 0x43544341
.int 1
rrCameraEnabled:
.int 1
rrCameraCalls:
.int 0
rrCameraLeft:
.int 0
rrCameraRight:
.int 0
rrCameraSource:
.int 0
rrCameraCaller:
.int 0
rrCamera0:
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
rrCamera1:
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
rrCamera2:
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
rrCamera3:
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
rrCameraFactorLeft:
.int 0x3CA3D70A
rrCameraFactorRight:
.int 0xBCA3D70A
rrCameraMinusOne:
.int 0xBF800000
rrCameraHook:
; The original epilogue restored LR and SP. Only ABI-volatile registers follow.
cmpwi r3, 0
beq rrCameraExit
mflr r10
lis r11, 0x0229
addi r11, r11, 0x0ADC
cmpw r10, r11
bne rrCameraExit
lis r12, rrCameraEnabled@ha
addi r12, r12, rrCameraEnabled@l
lwz r11, 0(r12)
cmpwi r11, 1
bne rrCameraExit
stw r3, 16(r12)
stw r10, 20(r12)
lwz r11, 4(r12)
addi r11, r11, 1
stw r11, 4(r12)
lis r9, rrEye@ha
addi r9, r9, rrEye@l
lwz r10, 0(r9)
lwz r9, 4(r9)
mulli r9, r9, 2
add r9, r9, r10
mulli r9, r9, 4
lis r10, rrMenuCameraUsed@ha
addi r10, r10, rrMenuCameraUsed@l
add r9, r9, r10
li r10, 1
stw r10, 0(r9)
lis r12, rrEye@ha
addi r12, r12, rrEye@l
lwz r10, 0(r12)
lwz r11, 4(r12)
mulli r11, r11, 2
add r11, r11, r10
mulli r11, r11, 88
lis r9, rrCamera0@ha
addi r9, r9, rrCamera0@l
add r9, r9, r11
lwz r11, 0(r3)
stw r11, 0(r9)
lwz r11, 4(r3)
stw r11, 4(r9)
lwz r11, 8(r3)
stw r11, 8(r9)
lwz r11, 12(r3)
stw r11, 12(r9)
lwz r11, 16(r3)
stw r11, 16(r9)
lwz r11, 20(r3)
stw r11, 20(r9)
lwz r11, 24(r3)
stw r11, 24(r9)
lwz r11, 28(r3)
stw r11, 28(r9)
lwz r11, 32(r3)
stw r11, 32(r9)
lwz r11, 36(r3)
stw r11, 36(r9)
lwz r11, 40(r3)
stw r11, 40(r9)
lwz r11, 44(r3)
stw r11, 44(r9)
lwz r11, 48(r3)
stw r11, 48(r9)
lwz r11, 52(r3)
stw r11, 52(r9)
lwz r11, 56(r3)
stw r11, 56(r9)
lwz r11, 60(r3)
stw r11, 60(r9)
lwz r11, 64(r3)
stw r11, 64(r9)
lwz r11, 68(r3)
stw r11, 68(r9)
lwz r11, 72(r3)
stw r11, 72(r9)
lwz r11, 76(r3)
stw r11, 76(r9)
lwz r11, 80(r3)
stw r11, 80(r9)
lwz r11, 84(r3)
stw r11, 84(r9)
lis r12, rrCameraLeft@ha
addi r12, r12, rrCameraLeft@l
cmpwi r10, 0
beq rrCameraChooseLeft
addi r12, r12, 4
rrCameraChooseLeft:
lwz r11, 0(r12)
addi r11, r11, 1
stw r11, 0(r12)
lis r12, rrSlot@ha
addi r12, r12, rrSlot@l
lwz r11, 0(r12)
mulli r11, r11, 196
lis r12, rrPoseLatch0@ha
addi r12, r12, rrPoseLatch0@l
add r12, r12, r11
lwz r11, 0(r12)
cmpwi r11, 0
beq rrPoseFallback
lis r8, rrValueOne@ha
addi r8, r8, rrValueOne@l
lfs f3, 0(r8)
; Same diagnostic eye numbering: eye0 uses physical right, eye1 left.
addi r12, r12, 4
cmpwi r10, 1
beq rrPoseEyeReady
addi r12, r12, 48
rrPoseEyeReady:
; Copy player position while the native camera owns a valid actor.
lis r8, xtData@ha
addi r8, r8, xtData@l
lwz r0, -24(r3)
lis r7, 0x100A
ori r7, r7, 0x1788
cmpw r0, r7
bne xtSnapshotDone
lwz r11, -16(r3)
lis r7, 0x1000
cmplw r11, r7
blt xtSnapshotDone
lis r7, 0x5000
cmplw r11, r7
bge xtSnapshotDone
andi. r0, r11, 3
bne xtSnapshotDone
lwz r11, 44(r11)
lis r7, 0x1000
cmplw r11, r7
blt xtSnapshotDone
lis r7, 0x5000
cmplw r11, r7
bge xtSnapshotDone
andi. r0, r11, 3
bne xtSnapshotDone

lwz r0, 0(r11)
lis r7, 0x1007
ori r7, r7, 0x4B74
cmpw r0, r7
bne xtSnapshotDone
lwz r0, 1576(r11)
stw r0, 40(r8)
lwz r0, 1580(r11)
stw r0, 44(r8)
lwz r0, 1584(r11)
stw r0, 48(r8)
lwz r0, 8(r8)
stw r0, 0x24(r8)
li r0, 1
stw r0, 0x20(r8)
lwz r0, 0(r3)
stw r0, 128(r8)
lwz r0, 4(r3)
stw r0, 132(r8)
lwz r0, 8(r3)
stw r0, 136(r8)
xtSnapshotDone:

; VR-owned Y state, independent of the native zoom FOV and camera angle.
lis r8, tfEyeAnchor@ha
addi r8, r8, tfEyeAnchor@l
li r0, 0
stw r0, 12(r8)
lis r7, xtData@ha
addi r7, r7, xtData@l
lwz r0, 0x90(r7)
cmpwi r0, 1
bne tfSelectDone
lis r11, rrProjectionSource@ha
lwz r11, rrProjectionSource@l(r11)
addi r7, r3, 88
cmpw r11, r7
bne tfSelectDone
lwz r0, 144(r11)
lis r7, rrProjectionVtable@ha
lwz r7, rrProjectionVtable@l(r7)
cmpw r0, r7
bne tfSelectDone
; Live-verified camera container (-24) -> manager (-16) -> primary actor +44.
lwz r0, -24(r3)
lis r7, 0x100A
ori r7, r7, 0x1788
cmpw r0, r7
bne tfSelectDone
lwz r11, -16(r3)
lis r7, 0x1000
cmplw r11, r7
blt tfSelectDone
lis r7, 0x5000
cmplw r11, r7
bge tfSelectDone
andi. r0, r11, 3
bne tfSelectDone
lwz r11, 44(r11)
lis r7, 0x1000
cmplw r11, r7
blt tfSelectDone
lis r7, 0x5000
cmplw r11, r7
bge tfSelectDone
andi. r0, r11, 3
bne tfSelectDone
lwz r0, 0(r11)
lis r7, 0x1007
ori r7, r7, 0x4B74
cmpw r0, r7
bne tfSelectDone
; Reject invalid head coordinates; do not depend on the native look-at target.
lfs f0, 1576(r11)
fcmpu cr0, f0, f0
bne tfSelectDone
fmr f1, f0
.int 0xFC200A10 ; fabs f1, f1 (Cemu does not accept the mnemonic)
lfs f2, 32(r8)
fcmpu cr0, f1, f2
bgt tfSelectDone
stfs f0, 0(r8)
lfs f0, 1580(r11)
fcmpu cr0, f0, f0
bne tfSelectDone
fmr f1, f0
.int 0xFC200A10 ; fabs f1, f1 (Cemu does not accept the mnemonic)
lfs f2, 32(r8)
fcmpu cr0, f1, f2
bgt tfSelectDone
stfs f0, 4(r8)
lfs f0, 1584(r11)
fcmpu cr0, f0, f0
bne tfSelectDone
fmr f1, f0
.int 0xFC200A10 ; fabs f1, f1 (Cemu does not accept the mnemonic)
lfs f2, 32(r8)
fcmpu cr0, f1, f2
bgt tfSelectDone
stfs f0, 8(r8)
li r0, 1
stw r0, 12(r8)
stw r11, 20(r8)
lwz r7, 36(r8)
addi r7, r7, 1
stw r7, 36(r8)
tfSelectDone:
; Anchor the HEAD CENTRE once when entering first person. Use both eyes from the
; same pose latch, preserving IPD. Store in pre-head-rotation coordinates:
; centre = -transpose(headRotation) * mean(eyeTranslations).
lwz r0, 12(r8)
cmpwi r0, 1
beq tfAnchorActive
li r0, 0
stw r0, 52(r8)
b tfAnchorDone
tfAnchorActive:
lis r7, xtData@ha
addi r7, r7, xtData@l
lwz r0, 0x98(r7)
cmpwi r0, 1
beq tfAnchorCapture
lwz r0, 52(r8)
cmpwi r0, 1
bne tfAnchorCapture
lwz r7, 56(r8)
lwz r11, 20(r8)
cmpw r7, r11
beq tfAnchorDone
tfAnchorCapture:
lis r7, tfRecenter@ha
addi r7, r7, tfRecenter@l
li r0, 0
stw r0, 4(r7)
addi r11, r12, 48
cmpwi r10, 1
beq tfAnchorOtherEye
addi r11, r12, -48
tfAnchorOtherEye:
lfs f1, 12(r12)
lfs f2, 12(r11)
fadds f1, f1, f2
lfs f2, 60(r8)
fmuls f1, f1, f2
lfs f2, 0(r12)
fmuls f1, f1, f2
fmr f0, f1
lfs f1, 28(r12)
lfs f2, 28(r11)
fadds f1, f1, f2
lfs f2, 60(r8)
fmuls f1, f1, f2
lfs f2, 16(r12)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 44(r12)
lfs f2, 44(r11)
fadds f1, f1, f2
lfs f2, 60(r8)
fmuls f1, f1, f2
lfs f2, 32(r12)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 40(r8)
lfs f1, 12(r12)
lfs f2, 12(r11)
fadds f1, f1, f2
lfs f2, 60(r8)
fmuls f1, f1, f2
lfs f2, 4(r12)
fmuls f1, f1, f2
fmr f0, f1
lfs f1, 28(r12)
lfs f2, 28(r11)
fadds f1, f1, f2
lfs f2, 60(r8)
fmuls f1, f1, f2
lfs f2, 20(r12)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 44(r12)
lfs f2, 44(r11)
fadds f1, f1, f2
lfs f2, 60(r8)
fmuls f1, f1, f2
lfs f2, 36(r12)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 44(r8)
lfs f1, 12(r12)
lfs f2, 12(r11)
fadds f1, f1, f2
lfs f2, 60(r8)
fmuls f1, f1, f2
lfs f2, 8(r12)
fmuls f1, f1, f2
fmr f0, f1
lfs f1, 28(r12)
lfs f2, 28(r11)
fadds f1, f1, f2
lfs f2, 60(r8)
fmuls f1, f1, f2
lfs f2, 24(r12)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 44(r12)
lfs f2, 44(r11)
fadds f1, f1, f2
lfs f2, 60(r8)
fmuls f1, f1, f2
lfs f2, 40(r12)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 48(r8)
li r0, 1
stw r0, 52(r8)
lwz r7, 20(r8)
stw r7, 56(r8)
tfAnchorDone:
; Cache the drawn models only from the validated player-head camera.
; Other cameras must not clear this identity during the same rendered frame.
lwz r0, 12(r8)
cmpwi r0, 1
bne tfHideCaptureDone
stwu r1, -0x40(r1)
stw r4, 8(r1)
stw r5, 12(r1)
stw r6, 16(r1)
stw r9, 20(r1)
stw r10, 24(r1)
stw r12, 28(r1)
mflr r0
stw r0, 32(r1)
lis r10, tfHideModel@ha
addi r10, r10, tfHideModel@l
lis r12, tfHideQueue@ha
addi r12, r12, tfHideQueue@l
li r0, 0
stw r0, 16(r10)
stw r0, 0(r12)
; The root and the character actors start the walk: root +F4 -> container
; +14 -> array[0..1].
lwz r7, 20(r8)
lwz r11, 0(r12)
cmplwi r11, 64
bge tfHidePushSkip0
mulli r11, r11, 4
add r11, r12, r11
stw r7, 8(r11)
lwz r11, 0(r12)
addi r11, r11, 1
stw r11, 0(r12)
tfHidePushSkip0:
lwz r7, 244(r7)
lis r11, 0x1000
cmplw r7, r11
blt tfHideWalk
lis r11, 0x5000
cmplw r7, r11
bge tfHideWalk
andi. r0, r7, 3
bne tfHideWalk
lwz r5, 20(r7)
lis r11, 0x1000
cmplw r5, r11
blt tfHideWalk
lis r11, 0x5000
cmplw r5, r11
bge tfHideWalk
andi. r0, r5, 3
bne tfHideWalk
li r6, 0
tfHideCharacterLoop:
add r7, r5, r6
lwz r7, 0(r7)
lis r11, 0x1000
cmplw r7, r11
blt tfHideCharacterNext
lis r11, 0x5000
cmplw r7, r11
bge tfHideCharacterNext
andi. r0, r7, 3
bne tfHideCharacterNext
lwz r11, 0(r12)
cmplwi r11, 64
bge tfHidePushSkip1
mulli r11, r11, 4
add r11, r12, r11
stw r7, 8(r11)
lwz r11, 0(r12)
addi r11, r11, 1
stw r11, 0(r12)
tfHidePushSkip1:
tfHideCharacterNext:
addi r6, r6, 4
cmpwi r6, 8
blt tfHideCharacterLoop
tfHideWalk:
li r6, 0
tfHideQueueLoop:
lwz r0, 0(r12)
cmpw r6, r0
bge tfHideCaptureStamp
mulli r11, r6, 4
add r11, r12, r11
lwz r9, 8(r11)
addi r6, r6, 1
; The actor's own model: +44 -> +0 -> +8.
mr r7, r9
lwz r7, 68(r7)
lis r11, 0x1000
cmplw r7, r11
blt tfHideChildren
lis r11, 0x5000
cmplw r7, r11
bge tfHideChildren
andi. r0, r7, 3
bne tfHideChildren
lwz r7, 0(r7)
lis r11, 0x1000
cmplw r7, r11
blt tfHideChildren
lis r11, 0x5000
cmplw r7, r11
bge tfHideChildren
andi. r0, r7, 3
bne tfHideChildren
lwz r7, 8(r7)
lis r11, 0x1000
cmplw r7, r11
blt tfHideChildren
lis r11, 0x5000
cmplw r7, r11
bge tfHideChildren
andi. r0, r7, 3
bne tfHideChildren
lwz r11, 16(r10)
cmplwi r11, 64
bge tfHideAppendSkip0
mulli r11, r11, 4
add r11, r10, r11
stw r7, 20(r11)
lwz r11, 16(r10)
addi r11, r11, 1
stw r11, 16(r10)
tfHideAppendSkip0:
tfHideChildren:
; Its children: the parts list core behind +74, owner word first. The core
; taken is kept in the frame, because the subroutine walks r5 on.
li r5, 0
stw r5, 36(r1)
lwz r7, 116(r9)
lis r11, 0x1000
cmplw r7, r11
blt tfHideChildrenKeeper
lis r11, 0x5000
cmplw r7, r11
bge tfHideChildrenKeeper
andi. r0, r7, 3
bne tfHideChildrenKeeper
lwz r0, 0(r7)
cmpw r0, r9
bne tfHideChildrenKeeper
stw r7, 36(r1)
mr r5, r7
bl tfHideCore
tfHideChildrenKeeper:
; The same core sits at +28 of the keeper behind +30; take it only when it
; is a different one (the root keeps its parts keeper there alone).
lwz r7, 48(r9)
lis r11, 0x1000
cmplw r7, r11
blt tfHideQueueLoop
lis r11, 0x5000
cmplw r7, r11
bge tfHideQueueLoop
andi. r0, r7, 3
bne tfHideQueueLoop
addi r7, r7, 40
lwz r0, 0(r7)
cmpw r0, r9
bne tfHideQueueLoop
lwz r0, 36(r1)
cmpw r7, r0
beq tfHideQueueLoop
mr r5, r7
bl tfHideCore
b tfHideQueueLoop
tfHideCaptureStamp:
lwz r0, 20(r10)
stw r0, 0(r10)
lis r7, xtData@ha
addi r7, r7, xtData@l
lwz r0, 8(r7)
stw r0, 4(r10)
lwz r0, 32(r1)
mtlr r0
lwz r4, 8(r1)
lwz r5, 12(r1)
lwz r6, 16(r1)
lwz r9, 20(r1)
lwz r10, 24(r1)
lwz r12, 28(r1)
addi r1, r1, 0x40
b tfHideCaptureDone
tfHideCore:
lwz r4, 8(r5)
cmplwi r4, 16
ble tfHideCoreCount
li r4, 16
tfHideCoreCount:
lwz r5, 12(r5)
lis r11, 0x1000
cmplw r5, r11
blt tfHideCoreDone
lis r11, 0x5000
cmplw r5, r11
bge tfHideCoreDone
andi. r0, r5, 3
bne tfHideCoreDone
tfHideCoreLoop:
cmpwi r4, 0
ble tfHideCoreDone
addi r4, r4, -1
lwz r7, 0(r5)
addi r5, r5, 4
lis r11, 0x1000
cmplw r7, r11
blt tfHideCoreLoop
lis r11, 0x5000
cmplw r7, r11
bge tfHideCoreLoop
andi. r0, r7, 3
bne tfHideCoreLoop
lwz r7, 0(r7)
lis r11, 0x1000
cmplw r7, r11
blt tfHideCoreLoop
lis r11, 0x5000
cmplw r7, r11
bge tfHideCoreLoop
andi. r0, r7, 3
bne tfHideCoreLoop
lwz r11, 0(r12)
cmplwi r11, 64
bge tfHidePushSkip2
mulli r11, r11, 4
add r11, r12, r11
stw r7, 8(r11)
lwz r11, 0(r12)
addi r11, r11, 1
stw r11, 0(r12)
tfHidePushSkip2:
b tfHideCoreLoop
tfHideCoreDone:
blr
tfHideCaptureDone:
; Latch the validated FP mode alongside this camera's slot/eye.
lis r7, rrSlot@ha
lwz r7, rrSlot@l(r7)
mulli r7, r7, 2
add r7, r7, r10
mulli r7, r7, 4
lis r11, tfNearState@ha
addi r11, r11, tfNearState@l
add r11, r11, r7
lwz r0, 12(r8)
stw r0, 0(r11)
; Horizon: take the game camera's pitch out of the prepared pose, so the
; horizon stays level and only the head can look up or down (Mario 1.2).
lwz r0, 12(r8)
cmpwi r0, 1
bne tfLevelDone
lis r11, tfLevel@ha
addi r11, r11, tfLevel@l
stw r12, 48(r11)
lwz r7, 0(r12)
stw r7, 0(r11)
lwz r7, 4(r12)
stw r7, 4(r11)
lwz r7, 8(r12)
stw r7, 8(r11)
lwz r7, 12(r12)
stw r7, 12(r11)
lwz r7, 16(r12)
stw r7, 16(r11)
lwz r7, 20(r12)
stw r7, 20(r11)
lwz r7, 24(r12)
stw r7, 24(r11)
lwz r7, 28(r12)
stw r7, 28(r11)
lwz r7, 32(r12)
stw r7, 32(r11)
lwz r7, 36(r12)
stw r7, 36(r11)
lwz r7, 40(r12)
stw r7, 40(r11)
lwz r7, 44(r12)
stw r7, 44(r11)
lfs f5, 20(r3)
lfs f6, 36(r3)
; Unit length for the (cos, sin) pair; a rolled camera would otherwise scale.
fmuls f0, f5, f5
fmuls f1, f6, f6
fadds f0, f0, f1
lfs f2, 60(r11)
fcmpu cr0, f0, f2
blt tfLevelDone
.int 0xFC200034 ; frsqrte f1, f0, followed by two Newton refinements
fmuls f2, f1, f1
fmuls f2, f2, f0
lfs f7, 56(r11)
fsubs f2, f7, f2
fmuls f1, f1, f2
lfs f7, 52(r11)
fmuls f1, f1, f7
fmuls f2, f1, f1
fmuls f2, f2, f0
lfs f7, 56(r11)
fsubs f2, f7, f2
fmuls f1, f1, f2
lfs f7, 52(r11)
fmuls f1, f1, f7
fmuls f5, f5, f1
fmuls f6, f6, f1
lfs f1, 4(r11)
lfs f2, 8(r11)
fmuls f0, f1, f5
fmuls f7, f2, f6
fsubs f0, f0, f7
fmuls f8, f1, f6
fmuls f9, f2, f5
fadds f8, f8, f9
stfs f0, 4(r11)
stfs f8, 8(r11)
lfs f1, 20(r11)
lfs f2, 24(r11)
fmuls f0, f1, f5
fmuls f7, f2, f6
fsubs f0, f0, f7
fmuls f8, f1, f6
fmuls f9, f2, f5
fadds f8, f8, f9
stfs f0, 20(r11)
stfs f8, 24(r11)
lfs f1, 36(r11)
lfs f2, 40(r11)
fmuls f0, f1, f5
fmuls f7, f2, f6
fsubs f0, f0, f7
fmuls f8, f1, f6
fmuls f9, f2, f5
fadds f8, f8, f9
stfs f0, 36(r11)
stfs f8, 40(r11)
mr r12, r11
tfLevelDone:
lis r8, rrCameraMinusOne@ha
addi r8, r8, rrCameraMinusOne@l
lfs f4, 0(r8)
lfs f1, 52(r3)
lfs f2, 64(r3)
fmuls f2, f2, f4
fadds f1, f1, f2
lfs f2, 32(r3)
fmuls f1, f1, f2
fmuls f5, f1, f3
lfs f1, 56(r3)
lfs f2, 68(r3)
fmuls f2, f2, f4
fadds f1, f1, f2
lfs f2, 36(r3)
fmuls f1, f1, f2
fadds f5, f5, f1
lfs f1, 60(r3)
lfs f2, 72(r3)
fmuls f2, f2, f4
fadds f1, f1, f2
lfs f2, 40(r3)
fmuls f1, f1, f2
fadds f5, f5, f1
; f7 keeps the effective distance factor through the private-view math.
lis r8, rrDioramaDistance@ha
addi r8, r8, rrDioramaDistance@l
lfs f7, 0(r8)
; Middle camera: the diorama at half distance, main camera only. Before the
; minimum distance and the follow zoom, which both still apply.
lis r8, xtData@ha
addi r8, r8, xtData@l
lwz r0, 0x90(r8)
cmpwi r0, 2
bne tfMiddleDone
lis r8, rrProjectionSource@ha
addi r8, r8, rrProjectionSource@l
lwz r8, 0(r8)
addi r11, r3, 88
cmpw r8, r11
bne tfMiddleDone
lis r8, tfMiddle@ha
addi r8, r8, tfMiddle@l
lfs f1, 0(r8)
fmuls f7, f7, f1
lwz r11, 4(r8)
addi r11, r11, 1
stw r11, 4(r8)
tfMiddleDone:
; Minimum eye distance (2026-09-21): the game's close-up cameras (level
; complete) put the eye a few centimetres from Toad at this world scale.
; f5 is the camera-target distance d, f7 the kept fraction: never let f7*d
; fall below rrMinDistance game units (750 = 0.5 m at the final world scale 2x,
; 1500 units per metre). Applied to the
; game's own camera distance only -- BEFORE the follow-zoom below, which
; turns the trigger zoom's narrower field of view into a shorter distance;
; that zoom must keep working (user, 2026-09-21). In the diorama (d
; 4600-5900, 65 % kept) the clamp never triggers; the transition is smooth.
lis r8, rrMinDistance@ha
addi r8, r8, rrMinDistance@l
lfs f1, 0(r8)
lfs f2, 4(r8)
fcmpu cr0, f5, f2
ble rrMinDistanceReady
fmuls f2, f5, f7
fcmpu cr0, f2, f1
bge rrMinDistanceReady
fdivs f7, f1, f5
rrMinDistanceReady:
lis r8, rrProjectionSource@ha
addi r8, r8, rrProjectionSource@l
lwz r8, 0(r8)
addi r11, r3, 88
cmpw r8, r11
bne rrFollowZoomReady
lwz r11, 144(r8)
; r10 remains the eye index: the later camera pose stamp still consumes it.
lis r7, rrProjectionVtable@ha
addi r7, r7, rrProjectionVtable@l
lwz r7, 0(r7)
cmpw r11, r7
bne rrFollowZoomReady
; Positive IEEE floats have integer ordering. Reject zero, negative, NaN,
; infinity and excessively narrow FOV; do not enlarge a >30 degree view.
lwz r11, 168(r8)
lis r7, rrFollowZoomConstants@ha
addi r7, r7, rrFollowZoomConstants@l
lwz r0, 0(r7)
cmpw r11, r0
blt rrFollowZoomReady
lwz r0, 4(r7)
cmpw r11, r0
blt rrFollowZoomApply
b rrFollowZoomReady
rrFollowZoomApply:
lfs f1, 168(r8)
lfs f2, 8(r7)
fmuls f1, f1, f2
fmuls f7, f7, f1
rrFollowZoomReady:
; Pointer ray in eye space, and the cursor point in the world.
lis r7, tpPointer@ha
addi r7, r7, tpPointer@l
li r0, 0
stw r0, 80(r7)
lwz r0, 48(r7)
cmpwi r0, 0
beq tpRayEyeDone
lfs f1, 0(r12)
lfs f2, 36(r7)
fmuls f1, f1, f2
fmr f0, f1
lfs f1, 4(r12)
lfs f2, 40(r7)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 8(r12)
lfs f2, 44(r7)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 52(r7)
lfs f1, 16(r12)
lfs f2, 36(r7)
fmuls f1, f1, f2
fmr f0, f1
lfs f1, 20(r12)
lfs f2, 40(r7)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 24(r12)
lfs f2, 44(r7)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 56(r7)
lfs f1, 32(r12)
lfs f2, 36(r7)
fmuls f1, f1, f2
fmr f0, f1
lfs f1, 36(r12)
lfs f2, 40(r7)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 40(r12)
lfs f2, 44(r7)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 60(r7)
stfs f5, 64(r7)
lfs f1, 0(r3)
lfs f2, 36(r7)
fmuls f1, f1, f2
fmr f0, f1
lfs f1, 16(r3)
lfs f2, 40(r7)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 32(r3)
lfs f2, 44(r7)
fmuls f1, f1, f2
fadds f0, f0, f1
fmuls f0, f0, f5
lfs f1, 52(r3)
fadds f0, f0, f1
stfs f0, 68(r7)
lfs f1, 4(r3)
lfs f2, 36(r7)
fmuls f1, f1, f2
fmr f0, f1
lfs f1, 20(r3)
lfs f2, 40(r7)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 36(r3)
lfs f2, 44(r7)
fmuls f1, f1, f2
fadds f0, f0, f1
fmuls f0, f0, f5
lfs f1, 56(r3)
fadds f0, f0, f1
stfs f0, 72(r7)
lfs f1, 8(r3)
lfs f2, 36(r7)
fmuls f1, f1, f2
fmr f0, f1
lfs f1, 24(r3)
lfs f2, 40(r7)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 40(r3)
lfs f2, 44(r7)
fmuls f1, f1, f2
fadds f0, f0, f1
fmuls f0, f0, f5
lfs f1, 60(r3)
fadds f0, f0, f1
stfs f0, 76(r7)
lwz r0, 12(r7)
stw r0, 80(r7)
lis r11, xtData@ha
addi r11, r11, xtData@l
lwz r0, 8(r11)
stw r0, 84(r7)
tpRayEyeDone:
fsubs f6, f3, f7
fmuls f6, f6, f5
lfs f1, 0(r12)
lfs f2, 0(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 4(r12)
lfs f2, 16(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 8(r12)
lfs f2, 32(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 0(r9)
lfs f1, 0(r12)
lfs f2, 4(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 4(r12)
lfs f2, 20(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 8(r12)
lfs f2, 36(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 4(r9)
lfs f1, 0(r12)
lfs f2, 8(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 4(r12)
lfs f2, 24(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 8(r12)
lfs f2, 40(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 8(r9)
lfs f1, 0(r12)
lfs f2, 12(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 4(r12)
lfs f2, 28(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 8(r12)
lfs f2, 44(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 8(r12)
fmuls f1, f1, f6
fadds f0, f0, f1
lfs f1, 12(r12)
fadds f0, f0, f1
stfs f0, 12(r9)
lfs f1, 16(r12)
lfs f2, 0(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 20(r12)
lfs f2, 16(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 24(r12)
lfs f2, 32(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 16(r9)
lfs f1, 16(r12)
lfs f2, 4(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 20(r12)
lfs f2, 20(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 24(r12)
lfs f2, 36(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 20(r9)
lfs f1, 16(r12)
lfs f2, 8(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 20(r12)
lfs f2, 24(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 24(r12)
lfs f2, 40(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 24(r9)
lfs f1, 16(r12)
lfs f2, 12(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 20(r12)
lfs f2, 28(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 24(r12)
lfs f2, 44(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 24(r12)
fmuls f1, f1, f6
fadds f0, f0, f1
lfs f1, 28(r12)
fadds f0, f0, f1
stfs f0, 28(r9)
lfs f1, 32(r12)
lfs f2, 0(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 36(r12)
lfs f2, 16(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 40(r12)
lfs f2, 32(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 32(r9)
lfs f1, 32(r12)
lfs f2, 4(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 36(r12)
lfs f2, 20(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 40(r12)
lfs f2, 36(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 36(r9)
lfs f1, 32(r12)
lfs f2, 8(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 36(r12)
lfs f2, 24(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 40(r12)
lfs f2, 40(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 40(r9)
lfs f1, 32(r12)
lfs f2, 12(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 36(r12)
lfs f2, 28(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 40(r12)
lfs f2, 44(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 40(r12)
fmuls f1, f1, f6
fadds f0, f0, f1
lfs f1, 44(r12)
fadds f0, f0, f1
stfs f0, 44(r9)
lis r8, tfEyeAnchor@ha
addi r8, r8, tfEyeAnchor@l
lwz r0, 12(r8)
cmpwi r0, 1
bne tfCameraSeatDone
lis r7, tfRecenter@ha
addi r7, r7, tfRecenter@l
lis r11, xtData@ha
addi r11, r11, xtData@l
lwz r0, 0x98(r11)
cmpwi r0, 1
bne tfRecenterApply
li r0, 0
stw r0, 0x98(r11)
; Use the horizontal backward vector; at a vertical look use the right vector.
lfs f4, 32(r9)
lfs f5, 40(r9)
fmuls f0, f4, f4
fmuls f1, f5, f5
fadds f0, f0, f1
lfs f2, 88(r7)
fcmpu cr0, f0, f2
bgt tfRecenterNormalize
lfs f4, 8(r9)
fneg f4, f4
lfs f5, 0(r9)
fmuls f0, f4, f4
fmuls f1, f5, f5
fadds f0, f0, f1
fcmpu cr0, f0, f2
ble tfRecenterApply
tfRecenterNormalize:
.int 0xFC200034 ; frsqrte f1, f0, followed by two Newton refinements
fmuls f2, f1, f1
fmuls f2, f2, f0
lfs f6, 84(r7)
fsubs f2, f6, f2
fmuls f1, f1, f2
lfs f6, 80(r7)
fmuls f1, f1, f6
fmuls f2, f1, f1
fmuls f2, f2, f0
lfs f6, 84(r7)
fsubs f2, f6, f2
fmuls f1, f1, f2
lfs f6, 80(r7)
fmuls f1, f1, f6
fmuls f4, f4, f1
fmuls f5, f5, f1
; Desired yaw rows: (z,0,-x), (0,1,0), (x,0,z).
lfs f0, 0(r9)
lfs f1, 32(r9)
fmuls f2, f0, f5
fmuls f6, f1, f4
fadds f2, f2, f6
stfs f2, 8(r7)
lfs f2, 16(r9)
stfs f2, 12(r7)
fmuls f2, f1, f5
fmuls f6, f0, f4
fsubs f2, f2, f6
stfs f2, 16(r7)
lfs f0, 4(r9)
lfs f1, 36(r9)
fmuls f2, f0, f5
fmuls f6, f1, f4
fadds f2, f2, f6
stfs f2, 20(r7)
lfs f2, 20(r9)
stfs f2, 24(r7)
fmuls f2, f1, f5
fmuls f6, f0, f4
fsubs f2, f2, f6
stfs f2, 28(r7)
lfs f0, 8(r9)
lfs f1, 40(r9)
fmuls f2, f0, f5
fmuls f6, f1, f4
fadds f2, f2, f6
stfs f2, 32(r7)
lfs f2, 24(r9)
stfs f2, 36(r7)
fmuls f2, f1, f5
fmuls f6, f0, f4
fsubs f2, f2, f6
stfs f2, 40(r7)
li r0, 1
stw r0, 4(r7)
lwz r11, 0(r7)
addi r11, r11, 1 ; not via r0: addi reads r0 as the number zero
stw r11, 0(r7)
tfRecenterApply:
lwz r0, 4(r7)
cmpwi r0, 1
bne tfRecenterDone
lfs f1, 0(r9)
lfs f2, 8(r7)
fmuls f1, f1, f2
fmr f0, f1
lfs f1, 4(r9)
lfs f2, 20(r7)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 8(r9)
lfs f2, 32(r7)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 44(r7)
lfs f1, 0(r9)
lfs f2, 12(r7)
fmuls f1, f1, f2
fmr f0, f1
lfs f1, 4(r9)
lfs f2, 24(r7)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 8(r9)
lfs f2, 36(r7)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 48(r7)
lfs f1, 0(r9)
lfs f2, 16(r7)
fmuls f1, f1, f2
fmr f0, f1
lfs f1, 4(r9)
lfs f2, 28(r7)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 8(r9)
lfs f2, 40(r7)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 52(r7)
lfs f1, 16(r9)
lfs f2, 8(r7)
fmuls f1, f1, f2
fmr f0, f1
lfs f1, 20(r9)
lfs f2, 20(r7)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 24(r9)
lfs f2, 32(r7)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 56(r7)
lfs f1, 16(r9)
lfs f2, 12(r7)
fmuls f1, f1, f2
fmr f0, f1
lfs f1, 20(r9)
lfs f2, 24(r7)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 24(r9)
lfs f2, 36(r7)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 60(r7)
lfs f1, 16(r9)
lfs f2, 16(r7)
fmuls f1, f1, f2
fmr f0, f1
lfs f1, 20(r9)
lfs f2, 28(r7)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 24(r9)
lfs f2, 40(r7)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 64(r7)
lfs f1, 32(r9)
lfs f2, 8(r7)
fmuls f1, f1, f2
fmr f0, f1
lfs f1, 36(r9)
lfs f2, 20(r7)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 40(r9)
lfs f2, 32(r7)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 68(r7)
lfs f1, 32(r9)
lfs f2, 12(r7)
fmuls f1, f1, f2
fmr f0, f1
lfs f1, 36(r9)
lfs f2, 24(r7)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 40(r9)
lfs f2, 36(r7)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 72(r7)
lfs f1, 32(r9)
lfs f2, 16(r7)
fmuls f1, f1, f2
fmr f0, f1
lfs f1, 36(r9)
lfs f2, 28(r7)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 40(r9)
lfs f2, 40(r7)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 76(r7)
lfs f0, 44(r7)
stfs f0, 0(r9)
lfs f0, 48(r7)
stfs f0, 4(r9)
lfs f0, 52(r7)
stfs f0, 8(r9)
lfs f0, 56(r7)
stfs f0, 16(r9)
lfs f0, 60(r7)
stfs f0, 20(r9)
lfs f0, 64(r7)
stfs f0, 24(r9)
lfs f0, 68(r7)
stfs f0, 32(r9)
lfs f0, 72(r7)
stfs f0, 36(r9)
lfs f0, 76(r7)
stfs f0, 40(r9)
tfRecenterDone:
lis r7, tfLook@ha
addi r7, r7, tfLook@l
lfs f0, 20(r9)
lfs f1, 40(r9)
fmuls f0, f0, f1
lfs f1, 24(r9)
lfs f2, 36(r9)
fmuls f1, f1, f2
fsubs f0, f0, f1
lfs f1, 0(r9)
fmuls f4, f0, f1
lfs f0, 16(r9)
lfs f1, 40(r9)
fmuls f0, f0, f1
lfs f1, 24(r9)
lfs f2, 32(r9)
fmuls f1, f1, f2
fsubs f0, f0, f1
lfs f1, 4(r9)
fmuls f0, f0, f1
fsubs f4, f4, f0
lfs f0, 16(r9)
lfs f1, 36(r9)
fmuls f0, f0, f1
lfs f1, 20(r9)
lfs f2, 32(r9)
fmuls f1, f1, f2
fsubs f0, f0, f1
lfs f1, 8(r9)
fmuls f0, f0, f1
fadds f4, f4, f0
lfs f5, 4(r7)
lfs f0, 28(r7)
fcmpu cr0, f4, f0
bge tfLookHanded
fneg f5, f5
tfLookHanded:
lfs f4, 0(r7)
lfs f1, 0(r9)
lfs f2, 8(r9)
fmuls f0, f1, f4
fmuls f6, f2, f5
fsubs f0, f0, f6
fmuls f6, f1, f5
fmuls f2, f2, f4
fadds f6, f6, f2
stfs f0, 0(r9)
stfs f6, 8(r9)
lfs f1, 16(r9)
lfs f2, 24(r9)
fmuls f0, f1, f4
fmuls f6, f2, f5
fsubs f0, f0, f6
fmuls f6, f1, f5
fmuls f2, f2, f4
fadds f6, f6, f2
stfs f0, 16(r9)
stfs f6, 24(r9)
lfs f1, 32(r9)
lfs f2, 40(r9)
fmuls f0, f1, f4
fmuls f6, f2, f5
fsubs f0, f0, f6
fmuls f6, f1, f5
fmuls f2, f2, f4
fadds f6, f6, f2
stfs f0, 32(r9)
stfs f6, 40(r9)
lis r11, tfLevel@ha
addi r11, r11, tfLevel@l
lwz r11, 48(r11)
lfs f1, 0(r9)
lfs f2, 0(r8)
fmuls f1, f1, f2
fmr f0, f1
lfs f1, 4(r9)
lfs f2, 4(r8)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 8(r9)
lfs f2, 8(r8)
fmuls f1, f1, f2
fadds f0, f0, f1
fneg f0, f0
lfs f4, 12(r12)
lfs f1, 0(r11)
lfs f2, 40(r8)
fmuls f1, f1, f2
fadds f4, f4, f1
lfs f1, 4(r11)
lfs f2, 44(r8)
fmuls f1, f1, f2
fadds f4, f4, f1
lfs f1, 8(r11)
lfs f2, 48(r8)
fmuls f1, f1, f2
fadds f4, f4, f1
lfs f1, 64(r8)
fmuls f4, f4, f1
fadds f0, f0, f4
stfs f0, 12(r9)
lfs f1, 16(r9)
lfs f2, 0(r8)
fmuls f1, f1, f2
fmr f0, f1
lfs f1, 20(r9)
lfs f2, 4(r8)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 24(r9)
lfs f2, 8(r8)
fmuls f1, f1, f2
fadds f0, f0, f1
fneg f0, f0
lfs f4, 28(r12)
lfs f1, 16(r11)
lfs f2, 40(r8)
fmuls f1, f1, f2
fadds f4, f4, f1
lfs f1, 20(r11)
lfs f2, 44(r8)
fmuls f1, f1, f2
fadds f4, f4, f1
lfs f1, 24(r11)
lfs f2, 48(r8)
fmuls f1, f1, f2
fadds f4, f4, f1
lfs f1, 64(r8)
fmuls f4, f4, f1
fadds f0, f0, f4
stfs f0, 28(r9)
lfs f1, 32(r9)
lfs f2, 0(r8)
fmuls f1, f1, f2
fmr f0, f1
lfs f1, 36(r9)
lfs f2, 4(r8)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 40(r9)
lfs f2, 8(r8)
fmuls f1, f1, f2
fadds f0, f0, f1
fneg f0, f0
lfs f4, 44(r12)
lfs f1, 32(r11)
lfs f2, 40(r8)
fmuls f1, f1, f2
fadds f4, f4, f1
lfs f1, 36(r11)
lfs f2, 44(r8)
fmuls f1, f1, f2
fadds f4, f4, f1
lfs f1, 40(r11)
lfs f2, 48(r8)
fmuls f1, f1, f2
fadds f4, f4, f1
lfs f1, 64(r8)
fmuls f4, f4, f1
fadds f0, f0, f4
stfs f0, 44(r9)
lis r11, tfLevel@ha
addi r11, r11, tfLevel@l
lwz r12, 48(r11)
tfCameraSeatDone:
lis r8, rrCameraMinusOne@ha
addi r8, r8, rrCameraMinusOne@l
lfs f4, 0(r8)
lfs f1, 52(r3)
lfs f2, 64(r3)
fmuls f2, f2, f4
fadds f1, f1, f2
lfs f2, 32(r3)
fmuls f1, f1, f2
fmuls f5, f1, f3
lfs f1, 56(r3)
lfs f2, 68(r3)
fmuls f2, f2, f4
fadds f1, f1, f2
lfs f2, 36(r3)
fmuls f1, f1, f2
fadds f5, f5, f1
lfs f1, 60(r3)
lfs f2, 72(r3)
fmuls f2, f2, f4
fadds f1, f1, f2
lfs f2, 40(r3)
fmuls f1, f1, f2
fadds f5, f5, f1
fmuls f5, f5, f7
lis r8, tfEyeAnchor@ha
addi r8, r8, tfEyeAnchor@l
lwz r0, 12(r8)
cmpwi r0, 1
bne tfKeepTargetDistance
lfs f5, 16(r8)
tfKeepTargetDistance:
lfs f1, 0(r9)
lfs f2, 12(r9)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 16(r9)
lfs f2, 28(r9)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 32(r9)
lfs f2, 44(r9)
fmuls f1, f1, f2
fadds f0, f0, f1
fmuls f0, f0, f4
stfs f0, 52(r9)
lfs f1, 32(r9)
fmuls f1, f1, f5
fmuls f1, f1, f4
fadds f1, f0, f1
stfs f1, 64(r9)
lfs f1, 16(r9)
stfs f1, 76(r9)
lfs f1, 4(r9)
lfs f2, 12(r9)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 20(r9)
lfs f2, 28(r9)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 36(r9)
lfs f2, 44(r9)
fmuls f1, f1, f2
fadds f0, f0, f1
fmuls f0, f0, f4
stfs f0, 56(r9)
lfs f1, 36(r9)
fmuls f1, f1, f5
fmuls f1, f1, f4
fadds f1, f0, f1
stfs f1, 68(r9)
lfs f1, 20(r9)
stfs f1, 80(r9)
lfs f1, 8(r9)
lfs f2, 12(r9)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 24(r9)
lfs f2, 28(r9)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 40(r9)
lfs f2, 44(r9)
fmuls f1, f1, f2
fadds f0, f0, f1
fmuls f0, f0, f4
stfs f0, 60(r9)
lfs f1, 40(r9)
fmuls f1, f1, f5
fmuls f1, f1, f4
fadds f1, f0, f1
stfs f1, 72(r9)
lfs f1, 24(r9)
stfs f1, 84(r9)
; The ray in the world, back through the finished eye view.
lis r7, tpPointer@ha
addi r7, r7, tpPointer@l
li r0, 0
stw r0, 104(r7)
lis r11, tpFpRay@ha
addi r11, r11, tpFpRay@l
lwz r0, 48(r7)
cmpwi r0, 0
bne tpFpTrackingPresent
stw r0, 0(r11)
tpFpTrackingPresent:
lwz r0, 48(r7)
cmpwi r0, 0
beq tpRayWorldDone
lfs f1, 0(r9)
lfs f2, 52(r7)
fmuls f1, f1, f2
fmr f0, f1
lfs f1, 16(r9)
lfs f2, 56(r7)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 32(r9)
lfs f2, 60(r7)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 88(r7)
lfs f1, 4(r9)
lfs f2, 52(r7)
fmuls f1, f1, f2
fmr f0, f1
lfs f1, 20(r9)
lfs f2, 56(r7)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 36(r9)
lfs f2, 60(r7)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 92(r7)
lfs f1, 8(r9)
lfs f2, 52(r7)
fmuls f1, f1, f2
fmr f0, f1
lfs f1, 24(r9)
lfs f2, 56(r7)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 40(r9)
lfs f2, 60(r7)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 96(r7)
lis r11, xtData@ha
addi r11, r11, xtData@l
lwz r0, 8(r11)
stw r0, 100(r7)
li r0, 1
stw r0, 104(r7)
; First-person pen uses the same finished rotation as the cart ray.
lis r11, tfEyeAnchor@ha
addi r11, r11, tfEyeAnchor@l
lwz r0, 12(r11)
cmpwi r0, 1
bne tpFpRenderOff
lis r11, mtPad@ha
addi r11, r11, mtPad@l
lwz r0, 0(r11)
cmpwi r0, 0
beq tpFpRenderInvalid
lwz r0, 88(r11)
cmpwi r0, 0
beq tpFpRenderInvalid
lis r11, rrEye@ha
lwz r0, rrEye@l(r11)
cmpwi r0, 0
bne tpFpRenderCursor
lis r11, tpFpRay@ha
addi r11, r11, tpFpRay@l
li r0, 0
stw r0, 0(r11)
lfs f0, 128(r7)
lfs f1, 88(r7)
fmuls f1, f1, f1
fadds f0, f0, f1
lfs f1, 92(r7)
fmuls f1, f1, f1
fadds f0, f0, f1
lfs f1, 96(r7)
fmuls f1, f1, f1
fadds f0, f0, f1
fcmpu cr0, f0, f0
bne tpFpRenderInvalid
lfs f1, 68(r11)
fcmpu cr0, f0, f1
blt tpFpRenderInvalid
lfs f1, 72(r11)
fcmpu cr0, f0, f1
bgt tpFpRenderInvalid
lfs f0, 52(r9)
stfs f0, 8(r11)
lfs f1, 88(r7)
lfs f2, 56(r11)
fmuls f2, f1, f2
fadds f2, f0, f2
stfs f2, 20(r11)
lfs f2, 64(r11)
fmuls f2, f1, f2
fadds f2, f0, f2
stfs f2, 32(r11)
lfs f2, 60(r11)
fmuls f2, f1, f2
stfs f2, 44(r11)
lfs f0, 56(r9)
stfs f0, 12(r11)
lfs f1, 92(r7)
lfs f2, 56(r11)
fmuls f2, f1, f2
fadds f2, f0, f2
stfs f2, 24(r11)
lfs f2, 64(r11)
fmuls f2, f1, f2
fadds f2, f0, f2
stfs f2, 36(r11)
lfs f2, 60(r11)
fmuls f2, f1, f2
stfs f2, 48(r11)
lfs f0, 60(r9)
stfs f0, 16(r11)
lfs f1, 96(r7)
lfs f2, 56(r11)
fmuls f2, f1, f2
fadds f2, f0, f2
stfs f2, 28(r11)
lfs f2, 64(r11)
fmuls f2, f1, f2
fadds f2, f0, f2
stfs f2, 40(r11)
lfs f2, 60(r11)
fmuls f2, f1, f2
stfs f2, 52(r11)
lwz r0, 100(r7)
stw r0, 4(r11)
li r0, 1
stw r0, 0(r11)
tpFpRenderCursor:
lis r11, tpFpRay@ha
addi r11, r11, tpFpRay@l
lwz r0, 0(r11)
cmpwi r0, 1
bne tpFpRenderInvalid
lwz r0, 20(r11)
stw r0, 68(r7)
lwz r0, 24(r11)
stw r0, 72(r7)
lwz r0, 28(r11)
stw r0, 76(r7)
lwz r0, 8(r7)
stw r0, 80(r7)
lwz r0, 100(r7)
stw r0, 84(r7)
b tpFpRenderDone
tpFpRenderInvalid:
li r0, 0
stw r0, 80(r7)
tpFpRenderOff:
lis r11, tpFpRay@ha
addi r11, r11, tpFpRay@l
li r0, 0
stw r0, 0(r11)
tpFpRenderDone:
tpRayWorldDone:
lis r11, rrEye@ha
lwz r0, rrEye@l(r11)
cmpwi r0, 0
bne smEyeDone
lis r11, smEye@ha
addi r11, r11, smEye@l
li r0, 1
stw r0, 0(r11)
lis r12, xtData@ha
addi r12, r12, xtData@l
lwz r0, 8(r12)
stw r0, 4(r11)
lwz r0, 0x90(r12)
stw r0, 8(r11)
lwz r0, 52(r9)
stw r0, 12(r11)
lwz r0, 56(r9)
stw r0, 16(r11)
lwz r0, 60(r9)
stw r0, 20(r11)
smEyeDone:
lis r12, rrSlot@ha
lwz r11, rrSlot@l(r12)
mulli r11, r11, 2
add r11, r11, r10
mulli r11, r11, 32
lis r12, xtMarker@ha
addi r12, r12, xtMarker@l
addi r12, r12, 8
add r12, r12, r11
li r0, 0
stw r0, 0(r12)
stw r0, 4(r12)
lis r8, xtData@ha
addi r8, r8, xtData@l
; Prefer the live cart direction marker to lift selection.
stw r0, 24(r12) ; style 0 = touch hand
lis r7, ctAim@ha
addi r7, r7, ctAim@l
lwz r0, 0x0C(r7)
cmpwi r0, 0
beq ctAimMarkerFallback
lwz r11, 8(r8)
lwz r0, 8(r7)
subf r11, r0, r11
cmplwi r11, 1
bgt ctAimMarkerFallback
lwz r0, 0x0C(r7)
stw r0, 4(r12)
li r0, 1
stw r0, 24(r12)
lis r11, smHit@ha
addi r11, r11, smHit@l
lwz r0, 4(r11)
cmpwi r0, 1
bne smCartFallback
lwz r0, 16(r11)
cmpwi r0, 1
bne smCartFallback
lwz r0, 12(r11)
lwz r11, 0x90(r8)
cmpw r0, r11
bne smCartFallback
lis r11, smHit@ha
addi r11, r11, smHit@l
lwz r0, 8(r11)
lwz r11, 8(r8)
subf r11, r0, r11
cmplwi r11, 1
bgt smCartFallback
lis r11, smHit@ha
addi r11, r11, smHit@l

lis r8, smHit@ha
addi r8, r8, smHit@l
addi r8, r8, -64 ; point read at +96 is smHit+32
b xtMarkerHaveTarget
smCartFallback:
addi r8, r7, -0x34 ; existing point read at +60 now refers to ctAim+2C
b xtMarkerHaveTarget
ctAimMarkerFallback:
; Tablet pointer cursor: the touch hand where the ray meets the level.
; A held lift selection keeps its own hand; the pointer yields to it.
lwz r0, 0x54(r8)
cmpwi r0, 0
bne tpMarkerFallback
lis r7, tpPointer@ha
addi r7, r7, tpPointer@l
lwz r0, 80(r7)
cmpwi r0, 0
beq tpMarkerFallback
lwz r11, 8(r8)
lwz r0, 84(r7)
subf r11, r0, r11
cmplwi r11, 1
bgt tpMarkerFallback
li r0, 2
stw r0, 4(r12)
li r0, 0
stw r0, 24(r12)
lwz r11, 168(r7)
addi r11, r11, 1
stw r11, 168(r7)
lis r11, smHit@ha
addi r11, r11, smHit@l
lwz r0, 4(r11)
cmpwi r0, 1
bne smHandFallback
lwz r0, 16(r11)
cmpwi r0, 0
bne smHandFallback
lwz r0, 12(r11)
lwz r11, 0x90(r8)
cmpw r0, r11
bne smHandFallback
lis r11, smHit@ha
addi r11, r11, smHit@l
lwz r0, 8(r11)
lwz r11, 8(r8)
subf r11, r0, r11
cmplwi r11, 1
bgt smHandFallback
lis r11, smHit@ha
addi r11, r11, smHit@l
lwz r0, 116(r11)
cmpwi r0, 1
bne smDirectHand
li r0, 3
stw r0, 4(r12)
smDirectHand:

lis r8, smHit@ha
addi r8, r8, smHit@l
addi r8, r8, -64 ; point read at +96 is smHit+32
b xtMarkerHaveTarget
smHandFallback:
addi r8, r7, -28
b xtMarkerHaveTarget
tpMarkerFallback:
lwz r0, 0x54(r8)
cmpwi r0, 0
beq xtMarkerDone
lwz r7, 8(r8)
lwz r11, 0x58(r8)
subf r11, r11, r7
cmplwi r11, 1
bgt xtMarkerDone
stw r0, 4(r12)
lis r11, smHit@ha
addi r11, r11, smHit@l
lwz r0, 4(r11)
cmpwi r0, 1
bne smSelectionMiss
lwz r0, 16(r11)
cmpwi r0, 2
bne smSelectionMiss
lwz r0, 100(r11)
lwz r11, 0x54(r8)
cmpw r0, r11
bne smSelectionMiss
lis r11, smHit@ha
addi r11, r11, smHit@l
lwz r0, 12(r11)
lwz r11, 0x90(r8)
cmpw r0, r11
bne smSelectionMiss
lis r11, smHit@ha
addi r11, r11, smHit@l
lwz r0, 8(r11)
lwz r11, 8(r8)
subf r11, r0, r11
cmplwi r11, 1
bgt smSelectionMiss
lis r11, smHit@ha
addi r11, r11, smHit@l

lis r8, smHit@ha
addi r8, r8, smHit@l
addi r8, r8, -64 ; point read at +96 is smHit+32
b xtMarkerHaveTarget
smSelectionMiss:
b xtMarkerDone
xtMarkerHaveTarget:
lfs f0, 12(r9)
lfs f1, 0(r9)
lfs f2, 96(r8)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 4(r9)
lfs f2, 100(r8)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 8(r9)
lfs f2, 104(r8)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 8(r12)
lfs f0, 28(r9)
lfs f1, 16(r9)
lfs f2, 96(r8)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 20(r9)
lfs f2, 100(r8)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 24(r9)
lfs f2, 104(r8)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 12(r12)
lfs f0, 44(r9)
lfs f1, 32(r9)
lfs f2, 96(r8)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 36(r9)
lfs f2, 100(r8)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 40(r9)
lfs f2, 104(r8)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 16(r12)
lis r8, tfEyeAnchor@ha
addi r8, r8, tfEyeAnchor@l
lwz r0, 12(r8)
stw r0, 20(r12)
lis r8, rrSlot@ha
lwz r11, rrSlot@l(r8)
mulli r11, r11, 196
lis r8, rrPoseLatch0@ha
addi r8, r8, rrPoseLatch0@l
add r8, r8, r11
lwz r0, 0(r8)
.int 0x7C2004AC ; lwsync: publish coordinates before the completed pose sequence
stw r0, 0(r12) ; publish token last
xtMarkerDone:
lis r12, rrSlot@ha
addi r12, r12, rrSlot@l
lwz r11, 0(r12)
mulli r11, r11, 196
lis r12, rrPoseLatch0@ha
addi r12, r12, rrPoseLatch0@l
add r12, r12, r11
lwz r8, 0(r12)
lis r12, rrSlot@ha
addi r12, r12, rrSlot@l
lwz r11, 0(r12)
mulli r11, r11, 2
add r11, r11, r10
mulli r11, r11, 4
lis r12, rrCameraPoseSequence@ha
addi r12, r12, rrCameraPoseSequence@l
add r12, r12, r11
stw r8, 0(r12)
lis r12, rrPoseUsed@ha
addi r12, r12, rrPoseUsed@l
lwz r11, 0(r12)
addi r11, r11, 1
stw r11, 0(r12)
mr r3, r3 ; retain original getter result; private copy is ready
blr
rrPoseFallback:
lis r12, rrCameraFactorLeft@ha
addi r12, r12, rrCameraFactorLeft@l
cmpwi r10, 0
beq rrCameraOffset
addi r12, r12, 4
rrCameraOffset:
; Diagnostic offset is 2% of view Z translation, preserving scene scale.
lfs f0, 44(r3)
lfs f1, 0(r12)
fmuls f0, f0, f1
lfs f1, 12(r3)
fadds f1, f1, f0
stfs f1, 12(r9)
lis r12, rrCameraMinusOne@ha
addi r12, r12, rrCameraMinusOne@l
lfs f1, 0(r12)
fmuls f0, f0, f1
; Keep position and target consistent with the changed rigid view matrix.
lfs f1, 0(r3)
fmuls f1, f1, f0
lfs f2, 52(r3)
fadds f2, f2, f1
stfs f2, 52(r9)
lfs f2, 64(r3)
fadds f2, f2, f1
stfs f2, 64(r9)
lfs f1, 4(r3)
fmuls f1, f1, f0
lfs f2, 56(r3)
fadds f2, f2, f1
stfs f2, 56(r9)
lfs f2, 68(r3)
fadds f2, f2, f1
stfs f2, 68(r9)
lfs f1, 8(r3)
fmuls f1, f1, f0
lfs f2, 60(r3)
fadds f2, f2, f1
stfs f2, 60(r9)
lfs f2, 72(r3)
fadds f2, f2, f1
stfs f2, 72(r9)
mr r3, r3 ; retain original getter result; private copy is ready
rrCameraExit:
blr
0x0235AD14 = ba rrCameraHook

rrSecondRecord:
.int 0
rrShadowSkipped:
.int 0

0x0255FB30 = rrShadowOriginalAlloc:
rrShadowAlloc:
lis r12, rrSecondRecord@ha
addi r12, r12, rrSecondRecord@l
lwz r11, 0(r12)
cmpwi r11, 1
beq rrShadowSkipAlloc
b rrShadowOriginalAlloc
rrShadowSkipAlloc:
lwz r11, 4(r12)
addi r11, r11, 1
stw r11, 4(r12)
blr
0x0245C708 = bla rrShadowAlloc

0x0255FB58 = rrShadowOriginalDraw:
rrShadowDraw:
lis r12, rrSecondRecord@ha
addi r12, r12, rrSecondRecord@l
lwz r11, 0(r12)
cmpwi r11, 1
beq rrShadowSkipDraw
b rrShadowOriginalDraw
rrShadowSkipDraw:
lwz r11, 4(r12)
addi r11, r11, 1
stw r11, 4(r12)
blr
0x0245C714 = bla rrShadowDraw

rrConsumerHeader:
.int 0x43544343
.int 1
rrConsumerHits:
.int 0
rrConsumerMisses:
.int 0
0x023CEE48 = rrConsumerReturn:
rrConsumerHook:
; Displaced load: the renderer bypasses getRenderCamera and loads entry+8.
lwz r15, 8(r6)
stwu r1, -0x20(r1)
stw r0, 8(r1)
stw r10, 12(r1)
stw r11, 16(r1)
stw r12, 20(r1)
.int 0x7C000026 ; mfcr r0
stw r0, 24(r1)
cmpwi r21, 0
bne rrConsumerExit
; View table guard: never take one of our own camera copies as the native.
lis r12, rrCamera0@ha
addi r12, r12, rrCamera0@l
cmplw r15, r12
blt tpCamNativeKnown
addi r11, r12, 352
cmplw r15, r11
bge tpCamNativeKnown
lis r11, tpNativeCamera@ha
lwz r15, tpNativeCamera@l(r11)
cmpwi r15, 0
beq rrConsumerExit
tpCamNativeKnown:
lis r11, tpNativeCamera@ha
addi r11, r11, tpNativeCamera@l
stw r15, 0(r11)
lis r12, rrCameraEnabled@ha
addi r12, r12, rrCameraEnabled@l
lwz r11, 0(r12)
cmpwi r11, 1
bne rrConsumerExit
lwz r11, 16(r12)
cmpw r15, r11
bne rrConsumerMiss
lis r12, rrEye@ha
addi r12, r12, rrEye@l
lwz r10, 0(r12)
lwz r11, 4(r12)
mulli r11, r11, 2
add r11, r11, r10
mulli r11, r11, 88
lis r15, rrCamera0@ha
addi r15, r15, rrCamera0@l
add r15, r15, r11
lis r12, rrConsumerHits@ha
addi r12, r12, rrConsumerHits@l
b rrConsumerCount
rrConsumerMiss:
lis r12, rrConsumerMisses@ha
addi r12, r12, rrConsumerMisses@l
rrConsumerCount:
lwz r11, 0(r12)
addi r11, r11, 1
stw r11, 0(r12)
rrConsumerExit:
lwz r0, 24(r1)
.int 0x7C0FF120 ; mtcrf 255, r0
lwz r0, 8(r1)
lwz r10, 12(r1)
lwz r11, 16(r1)
lwz r12, 20(r1)
addi r1, r1, 0x20
b rrConsumerReturn
0x023CEE44 = ba rrConsumerHook

rrPoseHeader:
.int 0x43545048
.int 5
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
rrPoseLatch0:
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
rrPoseUsed:
.int 0
rrDioramaDistance:
.int 0x3F266666
rrDioramaAdvance:
.int 0x3EB33333
rrMinDistance:
.int 0x443B8000
.int 0x00000000

rrProjectionHeader:
.int 0x4354504A
.int 1
rrProjectionHits:
.int 0
rrProjectionSource:
.int 0
rrProjectionVtable:
.int 0x10087388
rrProjectionCopies:
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

0x023CEE50 = rrProjectionReturn:
rrProjectionHook:
lwz r16, 12(r6)
stwu r1, -0x20(r1)
stw r0, 8(r1)
stw r10, 12(r1)
stw r11, 16(r1)
stw r12, 20(r1)
.int 0x7C000026 ; mfcr r0
stw r0, 24(r1)
cmpwi r21, 0
bne rrProjectionExit
; View table guard: never copy a projection from one of our own copies.
lis r12, rrProjectionCopies@ha
addi r12, r12, rrProjectionCopies@l
cmplw r16, r12
blt tpProjNativeKnown
addi r11, r12, 736
cmplw r16, r11
bge tpProjNativeKnown
lis r11, tpNativeProjection@ha
lwz r16, tpNativeProjection@l(r11)
cmpwi r16, 0
beq rrProjectionExit
tpProjNativeKnown:
lis r11, tpNativeProjection@ha
addi r11, r11, tpNativeProjection@l
stw r16, 0(r11)
lis r12, rrEye@ha
addi r12, r12, rrEye@l
lwz r10, 0(r12)
lwz r11, 4(r12)
mulli r11, r11, 2
add r11, r11, r10
mulli r11, r11, 88
lis r12, rrCamera0@ha
addi r12, r12, rrCamera0@l
add r12, r12, r11
cmpw r15, r12
bne rrProjectionExit
; Only the camera already accepted by the consumer may change projection.
lis r12, rrSlot@ha
addi r12, r12, rrSlot@l
lwz r11, 0(r12)
mulli r11, r11, 196
lis r12, rrPoseLatch0@ha
addi r12, r12, rrPoseLatch0@l
add r12, r12, r11
lwz r11, 0(r12)
cmpwi r11, 0
beq rrProjectionExit
lis r11, rrSlot@ha
addi r11, r11, rrSlot@l
lwz r11, 0(r11)
mulli r11, r11, 2
add r11, r11, r10
mulli r11, r11, 4
lis r0, rrCameraPoseSequence@ha
add r11, r11, r0
addi r11, r11, rrCameraPoseSequence@l
lwz r0, 0(r11)
lwz r11, 0(r12)
cmpw r0, r11
bne rrProjectionExit
; Verify concrete perspective object class before copying its complete object.
lwz r11, 144(r16)
lis r10, rrProjectionVtable@ha
addi r10, r10, rrProjectionVtable@l
lwz r0, 0(r10)
cmpw r11, r0
bne rrProjectionExit
lis r10, rrEye@ha
addi r10, r10, rrEye@l
lwz r10, 0(r10)
addi r12, r12, 100
cmpwi r10, 1
beq rrProjectionEyeReady
addi r12, r12, 32
rrProjectionEyeReady:
lis r11, rrSlot@ha
addi r11, r11, rrSlot@l
lwz r11, 0(r11)
mulli r11, r11, 2
add r11, r11, r10
mulli r11, r11, 184
lis r10, rrProjectionCopies@ha
addi r10, r10, rrProjectionCopies@l
add r10, r10, r11
lis r11, rrProjectionSource@ha
addi r11, r11, rrProjectionSource@l
stw r16, 0(r11)
lwz r11, 0(r16)
stw r11, 0(r10)
lwz r11, 4(r16)
stw r11, 4(r10)
lwz r11, 8(r16)
stw r11, 8(r10)
lwz r11, 12(r16)
stw r11, 12(r10)
lwz r11, 16(r16)
stw r11, 16(r10)
lwz r11, 20(r16)
stw r11, 20(r10)
lwz r11, 24(r16)
stw r11, 24(r10)
lwz r11, 28(r16)
stw r11, 28(r10)
lwz r11, 32(r16)
stw r11, 32(r10)
lwz r11, 36(r16)
stw r11, 36(r10)
lwz r11, 40(r16)
stw r11, 40(r10)
lwz r11, 44(r16)
stw r11, 44(r10)
lwz r11, 48(r16)
stw r11, 48(r10)
lwz r11, 52(r16)
stw r11, 52(r10)
lwz r11, 56(r16)
stw r11, 56(r10)
lwz r11, 60(r16)
stw r11, 60(r10)
lwz r11, 64(r16)
stw r11, 64(r10)
lwz r11, 68(r16)
stw r11, 68(r10)
lwz r11, 72(r16)
stw r11, 72(r10)
lwz r11, 76(r16)
stw r11, 76(r10)
lwz r11, 80(r16)
stw r11, 80(r10)
lwz r11, 84(r16)
stw r11, 84(r10)
lwz r11, 88(r16)
stw r11, 88(r10)
lwz r11, 92(r16)
stw r11, 92(r10)
lwz r11, 96(r16)
stw r11, 96(r10)
lwz r11, 100(r16)
stw r11, 100(r10)
lwz r11, 104(r16)
stw r11, 104(r10)
lwz r11, 108(r16)
stw r11, 108(r10)
lwz r11, 112(r16)
stw r11, 112(r10)
lwz r11, 116(r16)
stw r11, 116(r10)
lwz r11, 120(r16)
stw r11, 120(r10)
lwz r11, 124(r16)
stw r11, 124(r10)
lwz r11, 128(r16)
stw r11, 128(r10)
lwz r11, 132(r16)
stw r11, 132(r10)
lwz r11, 136(r16)
stw r11, 136(r10)
lwz r11, 140(r16)
stw r11, 140(r10)
lwz r11, 144(r16)
stw r11, 144(r10)
lwz r11, 148(r16)
stw r11, 148(r10)
lwz r11, 152(r16)
stw r11, 152(r10)
lwz r11, 156(r16)
stw r11, 156(r10)
lwz r11, 160(r16)
stw r11, 160(r10)
lwz r11, 164(r16)
stw r11, 164(r10)
lwz r11, 168(r16)
stw r11, 168(r10)
lwz r11, 172(r16)
stw r11, 172(r10)
lwz r11, 176(r16)
stw r11, 176(r10)
lwz r11, 180(r16)
stw r11, 180(r10)
lwz r11, 0(r12)
stw r11, 168(r10)
lwz r11, 4(r12)
stw r11, 172(r10)
lwz r11, 8(r12)
stw r11, 176(r10)
lwz r11, 12(r12)
stw r11, 180(r10)
lwz r11, 16(r12)
stw r11, 4(r10)
stw r11, 68(r10)
lwz r11, 20(r12)
stw r11, 12(r10)
stw r11, 76(r10)
lwz r11, 24(r12)
stw r11, 24(r10)
stw r11, 88(r10)
lwz r11, 28(r12)
stw r11, 28(r10)
stw r11, 92(r10)
lis r11, rrEye@ha
addi r11, r11, rrEye@l
lwz r11, 0(r11)
cmpwi r11, 1
beq rrScalarLeft
lwz r11, 52(r12)
stw r11, 156(r10)
lwz r11, 56(r12)
stw r11, 160(r10)
lwz r11, 60(r12)
stw r11, 164(r10)
b rrScalarDone
rrScalarLeft:
lwz r11, 72(r12)
stw r11, 156(r10)
lwz r11, 76(r12)
stw r11, 160(r10)
lwz r11, 80(r12)
stw r11, 164(r10)
rrScalarDone:
; Only the copied projection changes. Native source and far plane stay intact.
lis r11, rrSlot@ha
lwz r0, rrSlot@l(r11)
mulli r0, r0, 2
lis r11, rrEye@ha
lwz r12, rrEye@l(r11)
add r0, r0, r12
mulli r0, r0, 4
lis r11, tfNearState@ha
addi r11, r11, tfNearState@l
add r12, r11, r0
lwz r0, 0(r12)
cmpwi r0, 1
bne tfNearDone
lwz r0, 16(r11)
stw r0, 148(r10)
tfNearDone:
lwz r11, 0(r10)
andi. r11, r11, 65535
lis r0, 0x0101
add r11, r11, r0
stw r11, 0(r10)
mr r16, r10
; View table override: every later reader of this view entry sees the eye's
; camera and projection copies.
stw r16, 12(r6)
stw r15, 8(r6)
lis r12, tpViewTable@ha
addi r12, r12, tpViewTable@l
stw r6, 0(r12)
lwz r11, 4(r12)
addi r11, r11, 1
stw r11, 4(r12)
lis r12, rrSlot@ha
addi r12, r12, rrSlot@l
lwz r11, 0(r12)
mulli r11, r11, 196
lis r12, rrPoseLatch0@ha
addi r12, r12, rrPoseLatch0@l
add r12, r12, r11
lwz r0, 0(r12)
lis r12, rrEye@ha
addi r12, r12, rrEye@l
lwz r10, 0(r12)
lwz r11, 4(r12)
mulli r11, r11, 2
add r11, r11, r10
mulli r11, r11, 4
lis r12, rrProjectionPoseSequence@ha
addi r12, r12, rrProjectionPoseSequence@l
add r12, r12, r11
stw r0, 0(r12)
lis r12, rrProjectionHits@ha
addi r12, r12, rrProjectionHits@l
lwz r11, 0(r12)
addi r11, r11, 1
stw r11, 0(r12)
rrProjectionExit:
lwz r0, 24(r1)
.int 0x7C0FF120 ; mtcrf 255, r0
lwz r0, 8(r1)
lwz r10, 12(r1)
lwz r11, 16(r1)
lwz r12, 20(r1)
addi r1, r1, 0x20
b rrProjectionReturn
0x023CEE4C = ba rrProjectionHook

rrPoseMarkerMagic:
.int 0x3E400000
.int 0x3F500000
rrCameraPoseSequence:
.int 0
.int 0
.int 0
.int 0
rrProjectionPoseSequence:
.int 0
.int 0
.int 0
.int 0

0x0255F6EC = rrShadowSecondOriginal0:
; Shared shadow state (mechanism, kept from the former probe hook 0): during
; the second eye's record this native call is skipped; otherwise it runs as
; the game wrote it. The probe's recording is gone.
rrShadowSecondSkip0:
lis r12, rrSecondRecord@ha
lwz r11, rrSecondRecord@l(r12)
cmpwi r11, 1
beqlr
b rrShadowSecondOriginal0
0x0245CE18 = bla rrShadowSecondSkip0

0x0255F6EC = rrShadowSecondOriginal1:
; Shared shadow state (mechanism, kept from the former probe hook 1): during
; the second eye's record this native call is skipped; otherwise it runs as
; the game wrote it. The probe's recording is gone.
rrShadowSecondSkip1:
lis r12, rrSecondRecord@ha
lwz r11, rrSecondRecord@l(r12)
cmpwi r11, 1
beqlr
b rrShadowSecondOriginal1
0x0245CF30 = bla rrShadowSecondSkip1

0x0255FA3C = rrShadowSecondOriginal2:
; Shared shadow state (mechanism, kept from the former probe hook 2): during
; the second eye's record this native call is skipped; otherwise it runs as
; the game wrote it. The probe's recording is gone.
rrShadowSecondSkip2:
lis r12, rrSecondRecord@ha
lwz r11, rrSecondRecord@l(r12)
cmpwi r11, 1
beqlr
b rrShadowSecondOriginal2
0x0245CF70 = bla rrShadowSecondSkip2


rrDeferredCameraReturn:
.int 1


rrMenuCameraUsed:
.int 0
.int 0
.int 0
.int 0
rrMenuMetadataMagic:
.int 0x3E600000

rrFollowZoomConstants:
.int 0x3C0EFB23
.int 0x3E8930A3
.int 0x406ED9EC

; HUT2: binding calls, current slot0 buffer, HUD calls, four eye/slot records.
rrHudTargetData:
.int 0x48555432
.int 0
.int 0
.int 0
rrHudTargetRecords:
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

0x0243969C = rrHudOriginalDraw:
rrHudTrackColor:
; Tail-call original binding with all argument registers unchanged.
cmpwi r4, 0
bne rrHudTrackExit
lis r12, rrHudTargetData@ha
addi r12, r12, rrHudTargetData@l
lwz r11, 4(r12)
addi r11, r11, 1
stw r11, 4(r12)
stw r3, 8(r12)
rrHudTrackExit:
b import.gx2.GX2SetColorBuffer
rrHudTrackDraw:
mflr r0
stwu r1, -0x40(r1)
stw r0, 0x44(r1)
stw r3, 0x30(r1)
li r0, 0
stw r0, 0x28(r1)
; r7 is actor; r3 is original layout argument. Do not alter either.
; Gameplay overlay classes that belong on the world HUD surface: the HUD
; actor (0x1002E6FC) and the GamePad guide balloon actor (0x100A3FAC, the
; class measured in the drawn layout list on 2026-09-21; its pane is set
; once per frame from the game's mono camera and projection, identical in
; both eye passes, so it can only be fused on the world-fixed surface).
; Captures per eye accumulate on the host. Everything else keeps the game's
; own placement and the existing surface path.
lwz r11, 0(r7)
lis r12, 0x1003
addi r12, r12, -6404
cmpw r11, r12
beq rrHudTrackTake
lis r12, 0x100a
addi r12, r12, 0x3fac
cmpw r11, r12
bne rrHudDrawPass
rrHudTrackTake:
lis r12, rrHudTargetData@ha
addi r12, r12, rrHudTargetData@l
lwz r11, 12(r12)
addi r11, r11, 1
stw r11, 12(r12)
stw r11, 0x18(r1)
lis r10, rrSlot@ha
addi r10, r10, rrSlot@l
lwz r10, 0(r10)
andi. r10, r10, 1
add r10, r10, r10
lis r11, rrEye@ha
addi r11, r11, rrEye@l
lwz r11, 0(r11)
andi. r11, r11, 1
add r10, r10, r11
add r10, r10, r10
add r10, r10, r10
add r10, r10, r10
add r10, r10, r10
add r10, r10, r10
addi r10, r10, 16
add r10, r12, r10
; count, actor, layout, current buffer, binding serial, reserved*3.
lwz r11, 0(r10)
addi r11, r11, 1
stw r11, 0(r10)
stw r7, 4(r10)
stw r3, 8(r10)
lwz r11, 8(r12)
stw r11, 12(r10)
lwz r11, 4(r12)
stw r11, 16(r10)
lis r12, rrHudWorldAck@ha
addi r12, r12, rrHudWorldAck@l
lwz r11, 0(r12)
lis r10, 0x4855
addi r10, r10, 0x4131
cmpw r11, r10
bne rrHudDrawPass
lis r12, rrHudTargetData@ha
addi r12, r12, rrHudTargetData@l
lwz r3, 8(r12)
cmpwi r3, 0
beq rrHudDrawPass
lwz r11, 4(r3)
cmpwi r11, 1280
bne rrHudDrawPass
lwz r11, 8(r3)
cmpwi r11, 720
bne rrHudDrawPass
stw r3, 0x2c(r1)
li r0, 1
stw r0, 0x28(r1)
li r4, 0
bl rrHudEmit
rrHudDrawPass:
lwz r3, 0x30(r1)
bl rrHudOriginalDraw
lwz r0, 0x28(r1)
cmpwi r0, 0
beq rrHudWorldExit
lwz r3, 0x2c(r1)
li r4, 1
bl rrHudEmit
rrHudWorldExit:
lwz r0, 0x44(r1)
mtlr r0
addi r1, r1, 0x40
blr
rrHudWorldMagic:
.int 0x48554131
rrHudWorldAck:
.int 0
rrHudValues:
.int 0x3e900000
.int 0x3f300000
.int 0x3e800000
.int 0x3f400000
.int 0x00000000
.int 0x3e800000
.int 0x3f000000
.int 0x3f400000
rrHudEmit:
lis r12, rrHudValues@ha
addi r12, r12, rrHudValues@l
lfs f1, 0(r12)
lfs f2, 4(r12)
cmpwi r4, 0
bne rrHudEmitEnd
lfs f3, 8(r12)
b rrHudEmitIndex
rrHudEmitEnd:
lfs f3, 12(r12)
rrHudEmitIndex:
lis r10, rrSlot@ha
addi r10, r10, rrSlot@l
lwz r10, 0(r10)
add r10, r10, r10
lis r11, rrEye@ha
addi r11, r11, rrEye@l
lwz r11, 0(r11)
add r10, r10, r11
add r10, r10, r10
add r10, r10, r10
add r12, r12, r10
lfs f4, 16(r12)
b import.gx2.GX2ClearColor
0x022CF194 = bla rrHudTrackColor
0x022E5178 = bla rrHudTrackColor
0x022E51B0 = bla rrHudTrackColor

; Per-actor capture retired 2026-09-21: the group bracket below captures every
; 2D layout of the loop on stereo eye passes (rrHudTrackDraw stays for reference).

; ---------------------------------------------------------------------------
; 2D layouts on the world-fixed surface (2026-09-21). Every layout group drawn
; by the loop 02394924 is bracketed with the capture markers, but ONLY on eye
; passes that will become stereo frames: the camera consumer ran for this
; eye/slot AND the projection consumed the latched pose -- the same predicate
; the eye marker stamps, so the host will compose the canvas. Flat (surface)
; frames keep every layout in the image; the surface shows them world-fixed.
; The host accumulates the groups of one eye on one canvas (Mario core).
rrUiActiveBuffer:
.int 0
rrUiGroupBegin:
stwu r1, -0x20(r1)
mflr r0
stw r0, 0x24(r1)
lis r12, rrUiActiveBuffer@ha
li r11, 0
stw r11, rrUiActiveBuffer@l(r12)
lis r12, rrHudWorldAck@ha
lwz r11, rrHudWorldAck@l(r12)
lis r10, 0x4855
addi r10, r10, 0x4131
cmpw r11, r10
bne rrUiGroupBeginExit
lis r12, rrEye@ha
addi r12, r12, rrEye@l
lwz r11, 0(r12)
lwz r10, 4(r12)
mulli r9, r10, 2
add r9, r9, r11
mulli r9, r9, 4
lis r12, rrMenuCameraUsed@ha
addi r12, r12, rrMenuCameraUsed@l
lwzx r11, r12, r9
cmpwi r11, 0
beq rrUiGroupBeginExit
mulli r10, r10, 196
lis r12, rrPoseLatch0@ha
addi r12, r12, rrPoseLatch0@l
add r12, r12, r10
lwz r10, 0(r12)
cmpwi r10, 0
beq rrUiGroupBeginExit
lis r12, rrProjectionPoseSequence@ha
addi r12, r12, rrProjectionPoseSequence@l
lwzx r11, r12, r9
cmpw r11, r10
bne rrUiGroupBeginExit
lis r12, rrHudTargetData@ha
addi r12, r12, rrHudTargetData@l
lwz r3, 8(r12)
cmpwi r3, 0
beq rrUiGroupBeginExit
lwz r11, 4(r3)
cmpwi r11, 1280
bne rrUiGroupBeginExit
lwz r11, 8(r3)
cmpwi r11, 720
bne rrUiGroupBeginExit
lis r12, rrUiActiveBuffer@ha
stw r3, rrUiActiveBuffer@l(r12)
li r4, 0
bl rrHudEmit
rrUiGroupBeginExit:
lwz r0, 0x24(r1)
mtlr r0
addi r1, r1, 0x20
lwz r0, 0xC(r31)
b rrUiGroupLoop
rrUiGroupEnd:
stwu r1, -0x20(r1)
mflr r0
stw r0, 0x24(r1)
lis r12, rrUiActiveBuffer@ha
lwz r3, rrUiActiveBuffer@l(r12)
li r11, 0
stw r11, rrUiActiveBuffer@l(r12)
cmpwi r3, 0
beq rrUiGroupEndExit
li r4, 1
bl rrHudEmit
rrUiGroupEndExit:
lwz r0, 0x24(r1)
mtlr r0
addi r1, r1, 0x20
lwz r29, 0xC(r1)
b rrUiGroupReturn
0x02394998 = ba rrUiGroupBegin
0x0239499C = rrUiGroupLoop:
0x023949DC = ba rrUiGroupEnd
0x023949E0 = rrUiGroupReturn:

; Transition wipes (2026-09-21, from the class timeline of run 01:45): the
; level-start card/iris layout (class 0x10030AC4: the level-name card on the
; flat frame, then the shrinking iris over the world) and the level-end
; closing wipe (0x1002FF54) are not drawn on captured stereo passes -- they
; would sit on the panel as an orange field with a hole. On flat frames
; (the card with the level name) they draw as always; the game's own timing
; is untouched, only the draw call is skipped.
rrUiSkipDraw:
lis r12, rrUiActiveBuffer@ha
lwz r12, rrUiActiveBuffer@l(r12)
cmpwi r12, 0
beq rrUiSkipDrawPass
lwz r11, 0(r7)
lis r12, 0x1003
addi r12, r12, 0x0AC4
cmpw r11, r12
beq rrUiSkipDrawSkip
lis r12, 0x1003
addi r12, r12, -172
cmpw r11, r12
beq rrUiSkipDrawSkip
rrUiSkipDrawPass:
b rrHudOriginalDraw
rrUiSkipDrawSkip:
blr
0x023949C4 = bla ghFilterDraw

; Head xyz, active, look distance, actor, FOV limits, tolerance, activations;
; neutral head centre xyz, anchored flag, anchored actor, minus half, inverse Y world size.
tfEyeAnchor:
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x42C80000
.int 0x00000000
.int 0x3C0EFB23
.int 0x3DFB7679
.int 0x4E6E6B28
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0xBF000000
.int 0x3DCCCCCD

tfRecenter:
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x3F000000
.int 0x40400000
.int 0x38D1B717

; CTXT: epoch, held, candidate, best squared XZ distance, request, candidate epoch;
; position valid, position epoch, copied head xyz, radius squared, activations.
xtData:
.int 0x43545854
.int 3
.int 0
.int 0
.int 0
.int 0x47EF4200 ; 350 squared
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0x47EF4200
.int 0
.int 0 ; +3C last nonzero input buttons (before interception)
.int 0 ; +40 native lift update count
.int 0 ; +44 in-range lift count
.int 0 ; +48 input updates with a fresh candidate
.int 0 ; +4C requests issued

.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x43480000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x3F800000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000

xtInput:
stwu r1, -0xD0(r1)
stw r0, 8(r1)
mflr r0
stw r0, 12(r1)
.int 0x7C000026
stw r0, 16(r1)
stw r3, 20(r1)
stw r4, 24(r1)
stw r5, 28(r1)
stw r6, 32(r1)
stw r7, 36(r1)
stw r8, 40(r1)
stw r9, 44(r1)
stw r10, 48(r1)
stw r11, 52(r1)
stw r12, 56(r1)
.int 0xD8010040
.int 0xD8210048
.int 0xD8410050
.int 0xD8610058
.int 0xD8810060
.int 0xD8A10068
.int 0xD8C10070
.int 0xD8E10078
.int 0xD9010080
.int 0xD9210088
.int 0xD9410090
.int 0xD9610098
.int 0xD98100A0
.int 0xD9A100A8

lis r12, xtData@ha
addi r12, r12, xtData@l
; Physical Y is a VR-owned toggle, independent of the native zoom permission.
; Only take the button while the validated player camera has a fresh snapshot.
lwz r8, 8(r1)
andi. r9, r8, 8
lwz r10, 0x94(r12)
stw r9, 0x94(r12)
lwz r11, 0x20(r12)
cmpwi r11, 1
bne tfInputInactive
lwz r0, 8(r12)
lwz r11, 0x24(r12)
subf r11, r11, r0
cmplwi r11, 2
bgt tfInputInactive
cmpwi r9, 0
beq tfInputMask
cmpwi r10, 0
bne tfInputMask
; Three camera states on the one button: diorama (0) -> middle (2) ->
; first person (1) -> diorama. Every other reader asks for 1 = first person.
lwz r11, 0x90(r12)
li r10, 2
cmpwi r11, 0
beq tfInputStore
li r10, 1
cmpwi r11, 2
beq tfInputStore
li r10, 0
tfInputStore:
stw r10, 0x90(r12)
tfInputMask:
lis r10, 0xFFFF
ori r10, r10, 0xFFF7
and r8, r8, r10
stw r8, 8(r1)
b tfInputDone
tfInputInactive:
li r11, 0
stw r11, 0x90(r12)
tfInputDone:
; Physical R3: request a pose-latched recenter only while first person is on.
lwz r8, 8(r1)
andi. r9, r8, 0x40
lwz r10, 0x9C(r12)
stw r9, 0x9C(r12)
lwz r11, 0x90(r12)
cmpwi r11, 1
bne tfRecenterInputInactive
cmpwi r9, 0
beq tfRecenterInputDone
lis r11, 0xFFFF
ori r11, r11, 0xFFBF
and r8, r8, r11
stw r8, 8(r1)
cmpwi r10, 0
bne tfRecenterInputDone
li r11, 1
stw r11, 0x98(r12)
b tfRecenterInputDone
tfRecenterInputInactive:
li r11, 0
stw r11, 0x98(r12)
tfRecenterInputDone:
li r0, 0
stw r0, 0x18(r12)
stw r0, 0x10(r12)
lwz r5, 8(r12)
lwz r11, 0x54(r12)
addi r3, r12, 0x100
li r4, 16
li r6, 0
li r7, 0
lis r9, 0x7F80
; Resolve identity from this frame's own registry; never dereference actors.
xtResolveLoop:
lwz r0, 0(r3)
cmpwi r0, 0
beq xtResolveNext
lwz r10, 4(r3)
cmpw r10, r5
bne xtResolveNext
cmpw r0, r11
bne xtResolveNearest
mr r6, r3
xtResolveNearest:
lwz r10, 20(r3)
cmplw r10, r9
bge xtResolveNext
mr r9, r10
mr r7, r3
xtResolveNext:
addi r3, r3, 32
addi r4, r4, -1
cmpwi r4, 0
bne xtResolveLoop
lwz r8, 8(r1)
andi. r0, r8, 0x10
beq xtReleaseSelection
cmpwi r6, 0
bne xtHaveSelection
mr r6, r7
xtHaveSelection:
lwz r8, 8(r1)
lis r10, 0xC
and r10, r8, r10
lwz r11, 0x50(r12)
stw r10, 0x50(r12)
cmpwi r6, 0
beq xtNoSelection
cmpwi r11, 0
bne xtSelectDone
lis r11, 4
cmpw r10, r11
beq xtCycleLeft
lis r11, 8
cmpw r10, r11
bne xtSelectDone
li r10, 1
b xtCycleStart
xtCycleLeft:
li r10, -1
xtCycleStart:
lfs f0, 24(r6)
lwz r11, 0(r6)
addi r3, r12, 0x100
li r4, 16
li r7, 0 ; next in requested direction
li r9, 0 ; wrap endpoint
xtCycleLoop:
lwz r0, 0(r3)
cmpwi r0, 0
beq xtCycleNext
lwz r8, 4(r3)
cmpw r8, r5
bne xtCycleNext
lfs f1, 24(r3)
cmpwi r9, 0
beq xtSetWrap
lfs f3, 24(r9)
fcmpu cr0, f1, f3
cmpwi r10, 1
beq xtWrapRight
fcmpu cr0, f1, f3
bgt xtSetWrap
blt xtWrapDone
lwz r8, 0(r9)
cmplw r0, r8
bgt xtSetWrap
b xtWrapDone
xtWrapRight:
fcmpu cr0, f1, f3
blt xtSetWrap
bgt xtWrapDone
lwz r8, 0(r9)
cmplw r0, r8
bge xtWrapDone
xtSetWrap:
mr r9, r3
xtWrapDone:
cmpw r0, r11
beq xtCycleNext
cmpwi r10, 1
beq xtGreater
fcmpu cr0, f1, f0
blt xtDirectionOK
bgt xtCycleNext
cmplw r0, r11
blt xtDirectionOK
b xtCycleNext
xtGreater:
fcmpu cr0, f1, f0
bgt xtDirectionOK
blt xtCycleNext
cmplw r0, r11
ble xtCycleNext
xtDirectionOK:
cmpwi r7, 0
beq xtSetNext
lfs f2, 24(r7)
cmpwi r10, 1
beq xtNextRight
fcmpu cr0, f1, f2
bgt xtSetNext
blt xtCycleNext
lwz r8, 0(r7)
cmplw r0, r8
bgt xtSetNext
b xtCycleNext
xtNextRight:
fcmpu cr0, f1, f2
blt xtSetNext
bgt xtCycleNext
lwz r8, 0(r7)
cmplw r0, r8
bge xtCycleNext
xtSetNext:
mr r7, r3
xtCycleNext:
addi r3, r3, 32
addi r4, r4, -1
cmpwi r4, 0
bne xtCycleLoop
cmpwi r7, 0
bne xtUseNext
mr r7, r9
xtUseNext:
mr r6, r7
xtSelectDone:
lwz r9, 0(r6)
stw r9, 0x54(r12)
stw r9, 0x10(r12)
stw r5, 0x1C(r12)
lwz r8, 0x48(r12)
addi r8, r8, 1
stw r8, 0x48(r12)
lwz r0, 8(r6)
stw r0, 0x60(r12)
lfs f0, 12(r6)
lfs f1, 0x70(r12)
fadds f0, f0, f1
stfs f0, 0x64(r12)
lwz r0, 16(r6)
stw r0, 0x68(r12)
addi r5, r5, 1
stw r5, 0x58(r12)
b xtButton
xtNoSelection:
li r9, 0
stw r9, 0x54(r12)
addi r5, r5, 1
xtButton:
stw r5, 8(r12)
lwz r8, 8(r1)
cmpwi r8, 0
beq xtRecorded
stw r8, 0x3C(r12)
xtRecorded:
andi. r11, r8, 0x10
lwz r10, 12(r12)
stw r11, 12(r12)
cmpwi r9, 0
beq xtInputFinish
xtInputMask:
lis r10, 0xFFF3
ori r10, r10, 0xFFEF ; mask only X and D-pad L/R, only near live lifts
and r8, r8, r10
b xtInputFinish
xtReleaseSelection:
; Release only the previously selected, still fresh target. Never substitute
; the nearest lift here when the chosen one has disappeared or left range.
lwz r10, 12(r12)
cmpwi r10, 0
beq xtSelectionCleared
cmpwi r6, 0
beq xtSelectionCleared
lwz r9, 0(r6)
stw r9, 0x18(r12)
lwz r10, 0x4C(r12)
addi r10, r10, 1
stw r10, 0x4C(r12)
xtSelectionCleared:
li r0, 0
stw r0, 0x54(r12)
stw r0, 12(r12)
stw r0, 0x50(r12)
addi r5, r5, 1
stw r5, 8(r12)
cmpwi r8, 0
beq xtInputFinish
stw r8, 0x3C(r12)
xtInputFinish:
stw r8, 0x10C(r29)
.int 0xC8010040
.int 0xC8210048
.int 0xC8410050
.int 0xC8610058
.int 0xC8810060
.int 0xC8A10068
.int 0xC8C10070
.int 0xC8E10078
.int 0xC9010080
.int 0xC9210088
.int 0xC9410090
.int 0xC9610098
.int 0xC98100A0
.int 0xC9A100A8
lwz r3, 20(r1)
lwz r4, 24(r1)
lwz r5, 28(r1)
lwz r6, 32(r1)
lwz r7, 36(r1)
lwz r8, 40(r1)
lwz r9, 44(r1)
lwz r10, 48(r1)
lwz r11, 52(r1)
lwz r12, 56(r1)
lwz r0, 16(r1)
.int 0x7C0FF120
lwz r0, 12(r1)
mtlr r0
lwz r0, 8(r1)
addi r1, r1, 0xD0
lwz r0, 0x10C(r29)
b xtInputReturn

; Native AssistSlideMapParts update. r31 is alive by ownership of this call.
xtUpdate:
stwu r1, -0xD0(r1)
stw r0, 8(r1)
mflr r0
stw r0, 12(r1)
.int 0x7C000026
stw r0, 16(r1)
stw r3, 20(r1)
stw r4, 24(r1)
stw r5, 28(r1)
stw r6, 32(r1)
stw r7, 36(r1)
stw r8, 40(r1)
stw r9, 44(r1)
stw r10, 48(r1)
stw r11, 52(r1)
stw r12, 56(r1)
.int 0xD8010040 ; stfd f0, 64(r1)
.int 0xD8210048 ; stfd f1, 72(r1)
.int 0xD8410050 ; stfd f2, 80(r1)
.int 0xD8610058 ; stfd f3, 88(r1)
.int 0xD8810060 ; stfd f4, 96(r1)
.int 0xD8A10068 ; stfd f5, 104(r1)
.int 0xD8C10070 ; stfd f6, 112(r1)
.int 0xD8E10078 ; stfd f7, 120(r1)
.int 0xD9010080 ; stfd f8, 128(r1)
.int 0xD9210088 ; stfd f9, 136(r1)
.int 0xD9410090 ; stfd f10, 144(r1)
.int 0xD9610098 ; stfd f11, 152(r1)
.int 0xD98100A0 ; stfd f12, 160(r1)
.int 0xD9A100A8 ; stfd f13, 168(r1)
lis r12, xtData@ha
addi r12, r12, xtData@l
lwz r10, 0x40(r12)
addi r10, r10, 1
stw r10, 0x40(r12)
lwz r0, 0x20(r12)
cmpwi r0, 1
bne xtUpdateDone
lwz r9, 8(r12)
lwz r10, 0x24(r12)
subf r10, r10, r9
cmplwi r10, 2
bgt xtUpdateDone
lwz r0, 0(r31)
lis r10, 0x1003
ori r10, r10, 0x2214
cmpw r0, r10
bne xtUpdateDone
lbz r0, 0x109(r31) ; native interaction disabled
cmpwi r0, 0
bne xtUpdateDone
lwz r11, 0x28(r31) ; same position accessor as 0233AF88 -> 0233AE14
lis r10, 0x1000
cmplw r11, r10
blt xtUpdateDone
lis r10, 0x5000
cmplw r11, r10
bge xtUpdateDone
andi. r0, r11, 3
bne xtUpdateDone
lfs f0, 0(r11)
lfs f1, 0x28(r12)
fsubs f0, f0, f1
fmuls f0, f0, f0
lfs f1, 8(r11)
lfs f2, 0x30(r12)
fsubs f1, f1, f2
fmuls f1, f1, f1
fadds f0, f0, f1
; Integer float ordering rejects NaN/Inf as well as out-of-range distances.
stfs f0, 0xC0(r1)
lwz r10, 0xC0(r1)
lwz r11, 0x34(r12)
cmplw r10, r11
bge xtUpdateDone
lwz r11, 0x44(r12)
addi r11, r11, 1
stw r11, 0x44(r12)
; Register the live actor in bounded guest-owned storage.
addi r3, r12, 0x100
li r4, 16
li r5, 0
xtRegistryLoop:
lwz r0, 0(r3)
cmpw r0, r31
beq xtRegistryFound
cmpwi r0, 0
beq xtRegistryFree
lwz r6, 4(r3)
subf r6, r6, r9
cmplwi r6, 1
ble xtRegistryNext
xtRegistryFree:
mr r5, r3
xtRegistryNext:
addi r3, r3, 32
addi r4, r4, -1
cmpwi r4, 0
bne xtRegistryLoop
cmpwi r5, 0
beq xtCheckRequest
mr r3, r5
xtRegistryFound:
stw r31, 0(r3)
stw r9, 4(r3)
stw r10, 20(r3)
lwz r11, 0x28(r31)
lwz r0, 0(r11)
stw r0, 8(r3)
lwz r0, 4(r11)
stw r0, 12(r3)
lwz r0, 8(r11)
stw r0, 16(r3)
lfs f0, 0(r11)
lfs f1, 0x80(r12)
fmuls f0, f0, f1
lfs f1, 4(r11)
lfs f2, 0x84(r12)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 8(r11)
lfs f2, 0x88(r12)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 24(r3)
lwz r0, 0x54(r12)
cmpw r0, r31
bne xtCheckRequest
lwz r0, 0(r11)
stw r0, 0x60(r12)
lfs f0, 4(r11)
lfs f1, 0x70(r12)
fadds f0, f0, f1
stfs f0, 0x64(r12)
lwz r0, 8(r11)
stw r0, 0x68(r12)
stw r9, 0x58(r12)
xtCheckRequest:
lwz r10, 0x18(r12)
cmpw r10, r31
bne xtUpdateDone
li r0, 0
stw r0, 0x18(r12) ; consume before any native callback (also on rejection)
lbz r0, 0x108(r31)
cmpwi r0, 0
bne xtUpdateDone
lwz r10, 0x38(r12)
addi r10, r10, 1
stw r10, 0x38(r12)
; Match the native accepted-touch path at 02106968..021069B4.
li r0, 2
stw r0, 0x104(r31)
li r0, 1
stb r0, 0x108(r31)
lwz r3, 0x84(r31)
cmpwi r3, 0
beq xtSingle
bl 0x021075C8 ; native group activation
b xtUpdateDone
xtSingle:
mr r3, r31
bl 0x02106700 ; native tap transition, preserves movement/state eligibility
xtUpdateDone:
.int 0xC8010040 ; lfd f0, 64(r1)
.int 0xC8210048 ; lfd f1, 72(r1)
.int 0xC8410050 ; lfd f2, 80(r1)
.int 0xC8610058 ; lfd f3, 88(r1)
.int 0xC8810060 ; lfd f4, 96(r1)
.int 0xC8A10068 ; lfd f5, 104(r1)
.int 0xC8C10070 ; lfd f6, 112(r1)
.int 0xC8E10078 ; lfd f7, 120(r1)
.int 0xC9010080 ; lfd f8, 128(r1)
.int 0xC9210088 ; lfd f9, 136(r1)
.int 0xC9410090 ; lfd f10, 144(r1)
.int 0xC9610098 ; lfd f11, 152(r1)
.int 0xC98100A0 ; lfd f12, 160(r1)
.int 0xC9A100A8 ; lfd f13, 168(r1)
lwz r3, 20(r1)
lwz r4, 24(r1)
lwz r5, 28(r1)
lwz r6, 32(r1)
lwz r7, 36(r1)
lwz r8, 40(r1)
lwz r9, 44(r1)
lwz r10, 48(r1)
lwz r11, 52(r1)
lwz r12, 56(r1)
lwz r0, 16(r1)
.int 0x7C0FF120
lwz r0, 12(r1)
mtlr r0
lwz r0, 8(r1)
addi r1, r1, 0xD0
lwz r12, 0x100(r31) ; displaced instruction
b xtUpdateReturn
0x022C3200 = b xtInput
0x022C3204 = xtInputReturn:
0x021069E8 = b xtUpdate
0x021069EC = xtUpdateReturn:

xtMarker:
.int 0x43544D4B
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

ctAimUpdate:
stwu r1, -0xD0(r1)
stw r0, 8(r1)
mflr r0
stw r0, 12(r1)
.int 0x7C000026
stw r0, 16(r1)
stw r3, 20(r1)
stw r4, 24(r1)
stw r5, 28(r1)
stw r6, 32(r1)
stw r7, 36(r1)
stw r8, 40(r1)
stw r9, 44(r1)
stw r10, 48(r1)
stw r11, 52(r1)
stw r12, 56(r1)
.int 0xD8010040
.int 0xD8210048
.int 0xD8410050
.int 0xD8610058
.int 0xD8810060
.int 0xD8A10068
.int 0xD8C10070
.int 0xD8E10078
.int 0xD9010080
.int 0xD9210088
.int 0xD9410090
.int 0xD9610098
.int 0xD98100A0
.int 0xD9A100A8
.int 0x7C0902A6 ; mfctr r0
stw r0, 0xC0(r1)
lis r12, ctAim@ha
addi r12, r12, ctAim@l
li r0, 0
stw r0, 0x0C(r12)
; This is the live Truck callback after its native rider-state gate.
lwz r0, 0(r31)
lis r11, 0x1006
ori r11, r11, 0x7E4C
cmpw r0, r11
bne ctAimUpdateDone
lwz r3, 0x8C(r31)
lis r0, 0x1000
cmplw r3, r0
blt ctAimUpdateDone
lis r0, 0x5000
cmplw r3, r0
bge ctAimUpdateDone
andi. r0, r3, 3
bne ctAimUpdateDone
lwz r0, 0(r3)
lis r11, 0x1006
ori r11, r11, 0x81A8
cmpw r0, r11
bne ctAimUpdateDone
; Same origin getter chain as the native projectile launch.
bl 0x021170A0
lis r0, 0x1000
cmplw r3, r0
blt ctAimUpdateDone
lis r0, 0x5000
cmplw r3, r0
bge ctAimUpdateDone
andi. r0, r3, 3
bne ctAimUpdateDone
bl 0x022AF85C
lis r0, 0x1000
cmplw r3, r0
blt ctAimUpdateDone
lis r0, 0x5000
cmplw r3, r0
bge ctAimUpdateDone
andi. r0, r3, 3
bne ctAimUpdateDone
lis r12, ctAim@ha
addi r12, r12, ctAim@l
lwz r0, 0(r3)
stw r0, 20(r12)
lwz r0, 4(r3)
stw r0, 24(r12)
lwz r0, 8(r3)
stw r0, 28(r12)
addi r3, r31, 0x1C
li r4, 1
bl 0x0235ABD8
lis r0, 0x1000
cmplw r3, r0
blt ctAimUpdateDone
lis r0, 0x5000
cmplw r3, r0
bge ctAimUpdateDone
andi. r0, r3, 3
bne ctAimUpdateDone
lis r12, ctAim@ha
addi r12, r12, ctAim@l
stw r3, 0x10(r12)
; Native target minus camera origin, including the game's 8-unit Y correction.
lfs f0, 64(r3)
lfs f1, 52(r3)
fsubs f0, f0, f1
stfs f0, 32(r12)
lfs f0, 68(r3)
lfs f1, 56(r3)
fsubs f0, f0, f1
lfs f1, 0x54(r12)
fsubs f0, f0, f1
stfs f0, 36(r12)
lfs f0, 72(r3)
lfs f1, 60(r3)
fsubs f0, f0, f1
stfs f0, 40(r12)
lfs f1, 32(r12)
fcmpu cr0, f1, f1
bne ctAimUpdateDone
fmuls f1, f1, f1
fmr f0, f1
lfs f1, 36(r12)
fcmpu cr0, f1, f1
bne ctAimUpdateDone
fmuls f1, f1, f1
fadds f0, f0, f1
lfs f1, 40(r12)
fcmpu cr0, f1, f1
bne ctAimUpdateDone
fmuls f1, f1, f1
fadds f0, f0, f1
lfs f2, 0x58(r12)
fcmpu cr0, f0, f2
ble ctAimUpdateDone
lfs f2, 0x70(r12)
fcmpu cr0, f0, f2
bgt ctAimUpdateDone
.int 0xFC200034 ; frsqrte f1,f0
fmuls f2, f1, f1
fmuls f2, f2, f0
lfs f3, 0x68(r12)
fsubs f2, f3, f2
fmuls f1, f1, f2
lfs f3, 0x6C(r12)
fmuls f1, f1, f3
fmuls f2, f1, f1
fmuls f2, f2, f0
lfs f3, 0x68(r12)
fsubs f2, f3, f2
fmuls f1, f1, f2
lfs f3, 0x6C(r12)
fmuls f1, f1, f3
lfs f2, 32(r12)
fmuls f2, f2, f1
stfs f2, 32(r12)
lfs f2, 36(r12)
fmuls f2, f2, f1
stfs f2, 36(r12)
lfs f2, 40(r12)
fmuls f2, f2, f1
stfs f2, 40(r12)
; Controller ray: the launch direction is where the right hand points.
lis r11, tpPointer@ha
addi r11, r11, tpPointer@l
lwz r0, 104(r11)
cmpwi r0, 0
beq ctRayNone
lis r10, xtData@ha
addi r10, r10, xtData@l
lwz r10, 8(r10)
lwz r0, 100(r11)
subf r10, r0, r10
cmplwi r10, 2
bgt ctRayNone
lwz r0, 88(r11)
stw r0, 0x20(r12)
lwz r0, 92(r11)
stw r0, 0x24(r12)
lwz r0, 96(r11)
stw r0, 0x28(r12)
lwz r10, 164(r11)
addi r10, r10, 1
stw r10, 164(r11)
b ctRayApplied
ctRayNone:
lfs f0, 32(r12)
lfs f1, 0(r3)
lfs f2, 0x38(r12)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 16(r3)
lfs f2, 0x3C(r12)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 32(r12)
lfs f0, 36(r12)
lfs f1, 4(r3)
lfs f2, 0x38(r12)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 20(r3)
lfs f2, 0x3C(r12)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 36(r12)
lfs f0, 40(r12)
lfs f1, 8(r3)
lfs f2, 0x38(r12)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 24(r3)
lfs f2, 0x3C(r12)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 40(r12)
ctRayApplied:
lfs f1, 32(r12)
fcmpu cr0, f1, f1
bne ctAimUpdateDone
fmuls f1, f1, f1
fmr f0, f1
lfs f1, 36(r12)
fcmpu cr0, f1, f1
bne ctAimUpdateDone
fmuls f1, f1, f1
fadds f0, f0, f1
lfs f1, 40(r12)
fcmpu cr0, f1, f1
bne ctAimUpdateDone
fmuls f1, f1, f1
fadds f0, f0, f1
lfs f2, 0x58(r12)
fcmpu cr0, f0, f2
ble ctAimUpdateDone
lfs f2, 0x70(r12)
fcmpu cr0, f0, f2
bgt ctAimUpdateDone
.int 0xFC200034 ; frsqrte f1,f0
fmuls f2, f1, f1
fmuls f2, f2, f0
lfs f3, 0x68(r12)
fsubs f2, f3, f2
fmuls f1, f1, f2
lfs f3, 0x6C(r12)
fmuls f1, f1, f3
fmuls f2, f1, f1
fmuls f2, f2, f0
lfs f3, 0x68(r12)
fsubs f2, f3, f2
fmuls f1, f1, f2
lfs f3, 0x6C(r12)
fmuls f1, f1, f3
lfs f2, 32(r12)
fmuls f2, f2, f1
stfs f2, 32(r12)
lfs f2, 36(r12)
fmuls f2, f2, f1
stfs f2, 36(r12)
lfs f2, 40(r12)
fmuls f2, f2, f1
stfs f2, 40(r12)
lfs f0, 32(r12)
lfs f1, 0x50(r12)
fmuls f0, f0, f1
lfs f1, 20(r12)
fadds f0, f0, f1
fcmpu cr0, f0, f0
bne ctAimUpdateDone
stfs f0, 44(r12)
lfs f0, 36(r12)
lfs f1, 0x50(r12)
fmuls f0, f0, f1
lfs f1, 24(r12)
fadds f0, f0, f1
fcmpu cr0, f0, f0
bne ctAimUpdateDone
stfs f0, 48(r12)
lfs f0, 40(r12)
lfs f1, 0x50(r12)
fmuls f0, f0, f1
lfs f1, 28(r12)
fadds f0, f0, f1
fcmpu cr0, f0, f0
bne ctAimUpdateDone
stfs f0, 52(r12)
lis r11, xtData@ha
addi r11, r11, xtData@l
lwz r0, 8(r11)
stw r0, 8(r12)
lwz r11, 0x64(r12)
addi r11, r11, 1 ; not via r0: addi reads r0 as the number zero
stw r11, 0x64(r12)
stw r31, 0x0C(r12)
ctAimUpdateDone:
lwz r0, 0xC0(r1)
.int 0x7C0903A6 ; mtctr r0
.int 0xC8010040
.int 0xC8210048
.int 0xC8410050
.int 0xC8610058
.int 0xC8810060
.int 0xC8A10068
.int 0xC8C10070
.int 0xC8E10078
.int 0xC9010080
.int 0xC9210088
.int 0xC9410090
.int 0xC9610098
.int 0xC98100A0
.int 0xC9A100A8
lwz r3, 20(r1)
lwz r4, 24(r1)
lwz r5, 28(r1)
lwz r6, 32(r1)
lwz r7, 36(r1)
lwz r8, 40(r1)
lwz r9, 44(r1)
lwz r10, 48(r1)
lwz r11, 52(r1)
lwz r12, 56(r1)
lwz r0, 16(r1)
.int 0x7C0FF120
lwz r0, 12(r1)
mtlr r0
lwz r0, 8(r1)
addi r1, r1, 0xD0
lis r9, 0x1006 ; displaced instruction
b ctAimUpdateReturn
ctAimShot:
stwu r1, -0xD0(r1)
stw r0, 8(r1)
mflr r0
stw r0, 12(r1)
.int 0x7C000026
stw r0, 16(r1)
stw r3, 20(r1)
stw r4, 24(r1)
stw r5, 28(r1)
stw r6, 32(r1)
stw r7, 36(r1)
stw r8, 40(r1)
stw r9, 44(r1)
stw r10, 48(r1)
stw r11, 52(r1)
stw r12, 56(r1)
.int 0xD8010040
.int 0xD8210048
.int 0xD8410050
.int 0xD8610058
.int 0xD8810060
.int 0xD8A10068
.int 0xD8C10070
.int 0xD8E10078
.int 0xD9010080
.int 0xD9210088
.int 0xD9410090
.int 0xD9610098
.int 0xD98100A0
.int 0xD9A100A8
.int 0x7C0902A6 ; mfctr r0
stw r0, 0xC0(r1)
lis r12, ctAim@ha
addi r12, r12, ctAim@l
lwz r0, 0x0C(r12)
cmpw r0, r31
bne ctAimShotDone
lis r11, xtData@ha
addi r11, r11, xtData@l
lwz r11, 8(r11)
lwz r0, 8(r12)
cmpw r11, r0
bne ctAimShotDone
; Replace only the launch-direction argument on the caller's stack.
lwz r0, 32(r12)
stw r0, 216(r1)
lwz r0, 36(r12)
stw r0, 220(r1)
lwz r0, 40(r12)
stw r0, 224(r1)
lwz r11, 0x60(r12)
addi r11, r11, 1 ; not via r0: addi reads r0 as the number zero
stw r11, 0x60(r12)
ctAimShotDone:
lwz r0, 0xC0(r1)
.int 0x7C0903A6 ; mtctr r0
.int 0xC8010040
.int 0xC8210048
.int 0xC8410050
.int 0xC8610058
.int 0xC8810060
.int 0xC8A10068
.int 0xC8C10070
.int 0xC8E10078
.int 0xC9010080
.int 0xC9210088
.int 0xC9410090
.int 0xC9610098
.int 0xC98100A0
.int 0xC9A100A8
lwz r3, 20(r1)
lwz r4, 24(r1)
lwz r5, 28(r1)
lwz r6, 32(r1)
lwz r7, 36(r1)
lwz r8, 40(r1)
lwz r9, 44(r1)
lwz r10, 48(r1)
lwz r11, 52(r1)
lwz r12, 56(r1)
lwz r0, 16(r1)
.int 0x7C0FF120
lwz r0, 12(r1)
mtlr r0
lwz r0, 8(r1)
addi r1, r1, 0xD0
addi r4, r1, 0x2C ; displaced origin argument
b ctAimShotReturn
ctAimStick:
stfs f13, 0x124(r29) ; original right-stick Y store, before the save
stwu r1, -0xD0(r1)
stw r0, 8(r1)
mflr r0
stw r0, 12(r1)
.int 0x7C000026
stw r0, 16(r1)
stw r3, 20(r1)
stw r4, 24(r1)
stw r5, 28(r1)
stw r6, 32(r1)
stw r7, 36(r1)
stw r8, 40(r1)
stw r9, 44(r1)
stw r10, 48(r1)
stw r11, 52(r1)
stw r12, 56(r1)
.int 0xD8010040
.int 0xD8210048
.int 0xD8410050
.int 0xD8610058
.int 0xD8810060
.int 0xD8A10068
.int 0xD8C10070
.int 0xD8E10078
.int 0xD9010080
.int 0xD9210088
.int 0xD9410090
.int 0xD9610098
.int 0xD98100A0
.int 0xD9A100A8
.int 0x7C0902A6 ; mfctr r0
stw r0, 0xC0(r1)
lis r11, xtData@ha
addi r11, r11, xtData@l
lis r10, tfLook@ha
addi r10, r10, tfLook@l
lwz r0, 0x90(r11)
cmpwi r0, 1
bne tfLookInactive
lwz r0, 0x20(r11)
cmpwi r0, 1
bne tfLookInactive
lwz r8, 8(r11)
lwz r0, 0x24(r11)
subf r8, r0, r8
cmplwi r8, 2
bgt tfLookInactive
li r0, 1
stw r0, 8(r10)
; A held X gives the stick to the live cart aim adapter.
lwz r0, 0x0C(r11)
cmpwi r0, 0
beq tfLookTurn
lis r12, ctAim@ha
addi r12, r12, ctAim@l
lwz r0, 0x0C(r12)
cmpwi r0, 0
beq tfLookTurn
lwz r8, 8(r11)
lwz r0, 8(r12)
subf r8, r0, r8
cmplwi r8, 2
ble tfLookOriginalCart
; The wheel has already consumed its stick when X is held.
tfLookTurn:
lfs f0, 0x120(r29)
fcmpu cr0, f0, f0
bne tfLookConsume
fmr f1, f0
.int 0xFC200A10 ; fabs f1,f1
lfs f2, 16(r10)
fcmpu cr0, f1, f2
ble tfLookConsume
lfs f2, 20(r10)
fcmpu cr0, f1, f2
bgt tfLookConsume
; Same quadratic response as Mario; input runs on the fixed 60Hz game tick.
fmuls f0, f0, f1
lfs f2, 12(r10)
fmuls f0, f0, f2
fmuls f2, f0, f0
; sin t = t - t^3/6, cos t = 1 - t^2/2: at 160 deg/s a step is 2.7 degrees,
; and without the cubic term the turn overshoots by a third of a degree per
; full revolution (check_free_look, 2026-09-27).
lfs f4, 36(r10)
fmuls f3, f2, f4
fmuls f3, f3, f0
fsubs f0, f0, f3
lfs f4, 24(r10)
fmuls f2, f2, f4
lfs f4, 20(r10)
fsubs f2, f4, f2
lfs f4, 0(r10)
lfs f5, 4(r10)
fmuls f6, f4, f2
fmuls f7, f5, f0
fsubs f6, f6, f7
fmuls f7, f5, f2
fmuls f8, f4, f0
fadds f7, f7, f8
; Renormalize every update to avoid drift over repeated full revolutions.
fmuls f0, f6, f6
fmuls f2, f7, f7
fadds f0, f0, f2
.int 0xFC200034 ; frsqrte f1,f0
fmuls f2, f1, f1
fmuls f2, f2, f0
lfs f4, 32(r10)
fsubs f2, f4, f2
fmuls f1, f1, f2
lfs f4, 24(r10)
fmuls f1, f1, f4
fmuls f6, f6, f1
fmuls f7, f7, f1
stfs f6, 0(r10)
stfs f7, 4(r10)
tfLookConsume:
li r0, 0
stw r0, 0x120(r29)
stw r0, 0x124(r29)
b ctAimStickDone
tfLookInactive:
bl thmReset
lfs f0, 20(r10)
stfs f0, 0(r10)
li r0, 0
stw r0, 4(r10)
stw r0, 8(r10)
tfLookOriginalCart:
lis r12, ctAim@ha
addi r12, r12, ctAim@l
lwz r0, 0x0C(r12)
cmpwi r0, 0
beq ctAimStickInactive
lis r11, xtData@ha
addi r11, r11, xtData@l
lwz r11, 8(r11)
lwz r0, 8(r12)
subf r11, r0, r11
cmplwi r11, 2
bgt ctAimStickInactive
lfs f0, 288(r29)
fcmpu cr0, f0, f0
bne ctAimStickAxis0Done
fmr f1, f0
.int 0xFC200A10 ; fabs f1,f1
lfs f2, 0x44(r12)
fcmpu cr0, f1, f2
ble ctAimStickAxis0Done
lfs f2, 0x48(r12)
fcmpu cr0, f1, f2
bgt ctAimStickAxis0Done
lfs f2, 0x40(r12)
fmuls f0, f0, f2
lfs f1, 56(r12)
fadds f0, f0, f1
lfs f2, 0x48(r12)
fcmpu cr0, f0, f2
ble ctAimStickAxis0Lower
fmr f0, f2
ctAimStickAxis0Lower:
fneg f2, f2
fcmpu cr0, f0, f2
bge ctAimStickAxis0Store
fmr f0, f2
ctAimStickAxis0Store:
stfs f0, 56(r12)
ctAimStickAxis0Done:
lfs f0, 292(r29)
fcmpu cr0, f0, f0
bne ctAimStickAxis1Done
fmr f1, f0
.int 0xFC200A10 ; fabs f1,f1
lfs f2, 0x44(r12)
fcmpu cr0, f1, f2
ble ctAimStickAxis1Done
lfs f2, 0x48(r12)
fcmpu cr0, f1, f2
bgt ctAimStickAxis1Done
lfs f2, 0x40(r12)
fmuls f0, f0, f2
lfs f1, 60(r12)
fadds f0, f0, f1
lfs f2, 0x48(r12)
fcmpu cr0, f0, f2
ble ctAimStickAxis1Lower
fmr f0, f2
ctAimStickAxis1Lower:
fneg f2, f2
fcmpu cr0, f0, f2
bge ctAimStickAxis1Store
fmr f0, f2
ctAimStickAxis1Store:
stfs f0, 60(r12)
ctAimStickAxis1Done:
lfs f0, 0x58(r12)
stfs f0, 0x120(r29)
stfs f0, 0x124(r29)
b ctAimStickDone
ctAimStickInactive:
li r0, 0
stw r0, 0x38(r12)
stw r0, 0x3C(r12)
ctAimStickDone:
lis r10, tfLook@ha
addi r10, r10, tfLook@l
lwz r0, 8(r10)
cmpwi r0, 1
bne tfLookMovementDone
lfs f4, 0(r10)
lfs f5, 4(r10)
; Head-relative movement only in the effective first-person camera.
lis r12, rrSlot@ha
lwz r11, rrSlot@l(r12)
cmplwi r11, 1
bgt thmMovementReset
mulli r11, r11, 2
lis r12, rrEye@ha
lwz r0, rrEye@l(r12)
cmplwi r0, 1
bgt thmMovementReset
add r11, r11, r0
mulli r11, r11, 4
lis r12, tfNearState@ha
addi r12, r12, tfNearState@l
add r12, r12, r11
lwz r0, 0(r12)
cmpwi r0, 1
bne thmMovementReset
; A live minecart owns aiming; retain its existing movement behaviour.
lis r12, ctAim@ha
addi r12, r12, ctAim@l
lwz r0, 0x0C(r12)
cmpwi r0, 0
beq thmMovementHead
lwz r11, 8(r12)
lis r12, xtData@ha
addi r12, r12, xtData@l
lwz r0, 8(r12)
subf r11, r11, r0
cmplwi r11, 2
ble thmMovementReset
thmMovementHead:
bl thmCompose
b thmMovementReady
thmMovementReset:
bl thmReset
thmMovementReady:
lfs f1, 0x118(r29)
lfs f2, 0x11C(r29)
fmuls f6, f1, f4
fmuls f7, f2, f5
fadds f6, f6, f7
fmuls f8, f2, f4
fmuls f7, f1, f5
fsubs f8, f8, f7
stfs f6, 0x118(r29)
stfs f8, 0x11C(r29)
tfLookMovementDone:
lwz r0, 0xC0(r1)
.int 0x7C0903A6 ; mtctr r0
.int 0xC8010040
.int 0xC8210048
.int 0xC8410050
.int 0xC8610058
.int 0xC8810060
.int 0xC8A10068
.int 0xC8C10070
.int 0xC8E10078
.int 0xC9010080
.int 0xC9210088
.int 0xC9410090
.int 0xC9610098
.int 0xC98100A0
.int 0xC9A100A8
lwz r3, 20(r1)
lwz r4, 24(r1)
lwz r5, 28(r1)
lwz r6, 32(r1)
lwz r7, 36(r1)
lwz r8, 40(r1)
lwz r9, 44(r1)
lwz r10, 48(r1)
lwz r11, 52(r1)
lwz r12, 56(r1)
lwz r0, 16(r1)
.int 0x7C0FF120
lwz r0, 12(r1)
mtlr r0
lwz r0, 8(r1)
addi r1, r1, 0xD0
b ctAimStickReturn
0x02201358 = b ctAimUpdate
0x0220135C = ctAimUpdateReturn:
0x02201498 = b ctAimShot
0x0220149C = ctAimShotReturn:
0x022C3228 = b ctAimStick
0x022C322C = ctAimStickReturn:
ctAim:
.int 0x4354414D
.int 0x00000001
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x3C449BA6
.int 0x3E19999A
.int 0x3F800000
.int 0x3F800000
.int 0x44FA0000
.int 0x41000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x40400000
.int 0x3F000000
.int 0x5A0E1BCA
.int 0x00000000
.int 0x00000000
.int 0x00000000

tfLook:
.int 0x3F800000
.int 0x00000000
.int 0x00000000
.int 0x3D3EA2F1
.int 0x3E19999A
.int 0x3F800000
.int 0x3F000000
.int 0x00000000
.int 0x40400000
.int 0x3E2AAAAB

; Private experiment. Native guide lifecycle decides ownership of the stick.
; No pointer retained here is dereferenced outside the native guide callback.
swData:
.int 0x43545748 ; CTWH
.int 1
.int 0 ; 08 input epoch
.int 0 ; 0C last active-guide epoch
.int 0 ; 10 guide owns camera stick
.int 0 ; 14 raw right-stick X
.int 0 ; 18 last guide (diagnostic only)
.int 0 ; 1C active-guide callbacks
.int 0 ; 20 modified input batches
.int 0 ; 24 stick-driven updates
.int 0 ; 28 guide-exit calls
.int 0 ; 2C previously injected guide (identity only)
.int 0x3D800000 ; 30 squared radial deadzone (0.25)^2
.int 0x42652EE1 ; 34 radians to degrees, native delta clamp is +/-15
.int 0 ; 38 zero
.int 0 ; 3C last injected delta
.int 0 ; 40 previous stick X
.int 0 ; 44 previous stick Y
.int 0 ; 48 raw right-stick Y
.int 0 ; 4C previous squared radius
.int 0x41700000 ; 50 native maximum delta 15
.int 0x40000000 ; 54 maximum squared radius / factor 2

; VPADRead has returned; r31 still owns the complete status array.
; Save the raw stick BEFORE masking every returned sample, including flags.
swAfterRead:
stw r3, 0xAD4(r31) ; displaced instruction
stwu r1, -0x30(r1)
stw r0, 0x08(r1)
.int 0x7C000026 ; mfcr r0
stw r0, 0x0C(r1)
stw r9, 0x10(r1)
stw r10, 0x14(r1)
stw r11, 0x18(r1)
stw r12, 0x1C(r1)
stw r8, 0x20(r1)
lis r12, swData@ha
addi r12, r12, swData@l
lwz r11, 0x08(r12)
addi r11, r11, 1
stw r11, 0x08(r12)
li r0, 0
stw r0, 0x14(r12)
stw r0, 0x48(r12)
cmpwi r3, 1
blt swReadDone
cmpwi r3, 16
bgt swReadDone
lwz r0, 0x28(r31) ; status[0] +0x14, array begins owner+0x14
stw r0, 0x14(r12)
lwz r0, 0x2C(r31) ; status[0].rightStick.y
stw r0, 0x48(r12)
 ; First person owns camera turning unless X is held for interaction.
lis r8, xtData@ha
addi r8, r8, xtData@l
lwz r0, 0x90(r8)
cmpwi r0, 1
bne tfWheelNormal
lwz r0, 0x14(r31) ; VPADStatus hold; processed X0x10 comes from raw0x1000
andi. r0, r0, 0x1000
bne tfWheelNormal
li r0, 0
stw r0, 0x14(r12)
stw r0, 0x48(r12)
stw r0, 0x10(r12)
b swReadDone
tfWheelNormal:
lwz r0, 0x10(r12)
cmpwi r0, 1
bne swReadDone
lwz r10, 0x0C(r12)
subf r10, r10, r11
cmplwi r10, 1
bgt swReadDone ; stale ownership cannot steal the stick after a scene change
lwz r0, 0x20(r12)
addi r0, r0, 1
stw r0, 0x20(r12)
mr r10, r3
addi r11, r31, 0x14
lis r9, 0xF87F
ori r9, r9, 0xFFFF ; clear only VPAD right-stick direction bits
li r0, 0
swMaskSample:
stw r0, 0x14(r11)
stw r0, 0x18(r11)
lwz r8, 0(r11)
and r8, r8, r9
stw r8, 0(r11)
lwz r8, 4(r11)
and r8, r8, r9
stw r8, 4(r11)
lwz r8, 8(r11)
and r8, r8, r9
stw r8, 8(r11)
addi r11, r11, 0xAC
addi r10, r10, -1
cmpwi r10, 0
bne swMaskSample
swReadDone:
lwz r8, 0x20(r1)
lwz r9, 0x10(r1)
lwz r10, 0x14(r1)
lwz r11, 0x18(r1)
lwz r12, 0x1C(r1)
lwz r0, 0x0C(r1)
.int 0x7C0FF120 ; mtcrf 0xFF, r0
lwz r0, 0x08(r1)
addi r1, r1, 0x30
b swReadReturn

; Reached only AFTER the native inactive-state branch has been passed.
; r30 is a currently executing TouchRotateGuide, never a scanned pointer.
swGuideActive:
lis r12, swData@ha
addi r12, r12, swData@l
lbz r0, 0x4C(r30)
cmpwi r0, 0
beq swNativeTouch
lwz r0, 0x08(r12)
stw r0, 0x0C(r12)
li r0, 1
stw r0, 0x10(r12)
stw r30, 0x18(r12)
lwz r0, 0x1C(r12)
addi r0, r0, 1
stw r0, 0x1C(r12)
lfs f0, 0x14(r12)
lfs f1, 0x48(r12)
fmuls f3, f0, f0
fmadds f3, f1, f1, f3
fcmpu cr0, f3, f3
bne swStickReleased ; NaN is not equal to itself
lfs f2, 0x30(r12)
fcmpu cr0, f3, f2
ble swStickReleased
; Reject non-finite/out-of-range input instead of writing it to the guide.
lfs f2, 0x54(r12)
fcmpu cr0, f3, f2
bgt swStickReleased
lwz r0, 0x2C(r12)
cmplw r0, r30
bne swSeedCircle
lfs f4, 0x40(r12)
lfs f5, 0x44(r12)
; Signed inter-sample rotation. Cross product divided by mean radius^2
; approximates sin(delta), avoids an angle-wrap discontinuity and does not
; turn for a stationary or purely radial stick. Reject jumps >=90 degrees.
fmuls f6, f4, f0
fmadds f6, f5, f1, f6
lfs f7, 0x38(r12)
fcmpu cr0, f6, f7
ble swSeedCircle
fmuls f6, f5, f0
fmuls f7, f4, f1
fsubs f6, f7, f6
lfs f7, 0x4C(r12)
fadds f7, f7, f3
fmuls f6, f6, f2
fdivs f6, f6, f7
lfs f2, 0x34(r12)
fmuls f6, f6, f2
lfs f2, 0x50(r12)
fcmpu cr0, f6, f2
ble swClampLower
fmr f6, f2
swClampLower:
fneg f2, f2
fcmpu cr0, f6, f2
bge swCircleReady
fmr f6, f2
b swCircleReady
swSeedCircle:
lfs f6, 0x38(r12)
swCircleReady:
stfs f0, 0x40(r12)
stfs f1, 0x44(r12)
stfs f3, 0x4C(r12)
stfs f6, 0x58(r30)
stfs f6, 0x3C(r12)
li r0, 1
stb r0, 0x74(r30)
li r0, 0
stw r0, 0x90(r30)
stw r30, 0x2C(r12)
lwz r0, 0x24(r12)
addi r0, r0, 1
stw r0, 0x24(r12)
b swGuideDone
swStickReleased:
lwz r0, 0x2C(r12)
cmplw r0, r30
bne swNativeTouch
; Stop our own previous movement immediately; then let native touch run.
li r0, 0
stw r0, 0x58(r30)
stb r0, 0x74(r30)
stw r0, 0x2C(r12)
stw r0, 0x3C(r12)
swNativeTouch:
li r28, 0 ; displaced instruction
b swGuideReturn

; Native guide deactivation releases ownership immediately, also at neutral.
swGuideExit:
lis r12, swData@ha
addi r12, r12, swData@l
lwz r0, 0x18(r12)
cmplw r0, r3
bne swExitOriginal
li r0, 0
stw r0, 0x10(r12)
stw r0, 0x2C(r12)
stw r0, 0x3C(r12)
lwz r0, 0x28(r12)
addi r0, r0, 1
stw r0, 0x28(r12)
swExitOriginal:
lis r4, 0x1010 ; displaced instruction for native inactive state
b swExitReturn

0x022C2E90 = swReadReturn:
0x020FE290 = swGuideReturn:
0x020FE6E0 = swGuideDone:
0x020FE760 = swExitReturn:
0x022C2E8C = ba swAfterRead
0x020FE28C = ba swGuideActive
0x020FE75C = ba swGuideExit

tfLevel:
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
.int 0x3F000000
.int 0x40400000
.int 0x38D1B717

tfNearState:
.int 0
.int 0
.int 0
.int 0
.int 0x41200000

; First-person player visibility: render-only, original predicate in diorama.
0x0242F1DC = tfHideNativeResume:
tfHideShape:
stwu r1, -0x20(r1)
stw r0, 8(r1)
.int 0x7C000026 ; mfcr r0
stw r0, 12(r1)
stw r7, 16(r1)
stw r8, 20(r1)
stw r12, 24(r1)
lis r7, xtData@ha
addi r7, r7, xtData@l
lwz r0, 0x90(r7)
cmpwi r0, 1
bne tfHidePass
; Diagnostics: every model the renderer asks about, keyed by pointer bits
; 4..11 with up to eight probes. Header: calls, -, distinct, no free slot.
lis r8, tfHideSeen@ha
addi r8, r8, tfHideSeen@l
lwz r12, 0(r8)
addi r12, r12, 1
stw r12, 0(r8)
andi. r12, r3, 0xFF0
add r12, r12, r8
addi r12, r12, 16
li r11, 8
tfHideSeenProbe:
lwz r0, 0(r12)
cmpw r0, r3
beq tfHideSeenHit
cmpwi r0, 0
beq tfHideSeenInsert
addi r12, r12, 16
addi r11, r11, -1
cmpwi r11, 0
bne tfHideSeenProbe
lwz r11, 12(r8)
addi r11, r11, 1
stw r11, 12(r8)
b tfHideSeenDone
tfHideSeenInsert:
stw r3, 0(r12)
lwz r11, 8(r8)
addi r11, r11, 1
stw r11, 8(r8)
tfHideSeenHit:
lwz r11, 4(r12)
addi r11, r11, 1
stw r11, 4(r12)
tfHideSeenDone:
lis r8, tfHideModel@ha
addi r8, r8, tfHideModel@l
; Reject an identity older than two fixed-rate controller ticks, including
; across level changes. Unsigned subtraction also handles epoch wraparound.
lwz r12, 8(r7)
lwz r0, 4(r8)
subf r12, r0, r12
cmplwi r12, 2
bgt tfHidePass
lwz r12, 16(r8)
cmplwi r12, 64
bgt tfHidePass
cmpwi r12, 0
beq tfHidePass
addi r7, r8, 20
tfHideCompare:
lwz r0, 0(r7)
cmpw r3, r0
beq tfHideMatched
addi r7, r7, 4
addi r12, r12, -1
cmpwi r12, 0
bgt tfHideCompare
b tfHidePass
tfHideMatched:
lwz r12, 8(r8)
addi r12, r12, 1
stw r12, 8(r8)
lwz r7, 16(r1)
lwz r8, 20(r1)
lwz r12, 24(r1)
lwz r0, 12(r1)
.int 0x7C0FF120 ; mtcrf 255,r0
lwz r0, 8(r1)
addi r1, r1, 0x20
li r3, 0
blr
tfHidePass:
lwz r7, 16(r1)
lwz r8, 20(r1)
lwz r12, 24(r1)
lwz r0, 12(r1)
.int 0x7C0FF120 ; mtcrf 255,r0
lwz r0, 8(r1)
addi r1, r1, 0x20
lwz r11, 0(r3)
b tfHideNativeResume
0x0242F1D8 = ba tfHideShape
tfHideModel:
.int 0 ; first captured model (the rig), kept for the diagnostics readout
.int 0 ; most recent validated camera input epoch
.int 0 ; suppressed shape-query count (private diagnostics)
.int 0 ; reserved
.int 0 ; captured model count
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
.int 0
.int 0
; The actor queue of the walk: count, reserved, entries.
tfHideQueue:
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
.int 0
.int 0
.int 0
.int 0
; Diagnostics: calls, -, distinct models, overflows; then the slots
; (model, hits, -, -).
tfHideSeen:
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
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0

mtPad:
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

; The pad read itself, then the controllers written into the samples.
tfPadInput:
stwu r1, -0x30(r1)
mflr r0
stw r0, 0x34(r1)
stw r4, 8(r1)
stw r6, 12(r1)
bl import.vpad.VPADRead
lwz r4, 8(r1)
lwz r6, 12(r1)
cmpwi r3, 0
ble tfPadInputDone
; Motion controls: the VR controllers are written into the pad state before
; anything else reads it. Nothing here depends on Cemu's input configuration.
lis r9, mtPad@ha
addi r9, r9, mtPad@l
lwz r11, 0(r9)
cmpwi r11, 0
beq tfMotionDone
; Tablet pointer: the right controller's direction in the native camera.
lis r7, tpPointer@ha
addi r7, r7, tpPointer@l
li r0, 0
stw r0, 8(r7)
stw r0, 12(r7)
stw r0, 32(r7)
stw r0, 48(r7)
lis r12, tfMotionData@ha
addi r12, r12, tfMotionData@l
li r0, -1
stw r0, 20(r12)
li r0, 0
stw r0, 24(r12)
lwz r11, 88(r9)
cmpwi r11, 0
beq tpPointerDone
li r0, 1
stw r0, 32(r7)
stw r0, 48(r7)
lfs f0, 100(r9)
fneg f0, f0
stfs f0, 36(r7)
lfs f0, 116(r9)
fneg f0, f0
stfs f0, 40(r7)
lfs f0, 132(r9)
fneg f0, f0
stfs f0, 44(r7)
; In the cart the trigger fires (cart flag for the mapping); no pen there.
lis r8, ctAim@ha
addi r8, r8, ctAim@l
lwz r0, 0x0C(r8)
cmpwi r0, 0
beq tpPointerNoCart
lis r11, xtData@ha
addi r11, r11, xtData@l
lwz r11, 8(r11)
lwz r0, 8(r8)
subf r11, r0, r11
cmplwi r11, 2
bgt tpPointerNoCart
li r0, 1
stw r0, 24(r12)
b tpPointerDone
tpPointerNoCart:
; FP supplies a world ray to the native touch collision query.
lis r8, tfEyeAnchor@ha
addi r8, r8, tfEyeAnchor@l
lwz r0, 12(r8)
cmpwi r0, 1
bne tpFpPadDiorama
lis r8, tpFpRay@ha
addi r8, r8, tpFpRay@l
lwz r0, 0(r8)
cmpwi r0, 1
bne tpPointerDone
lis r11, xtData@ha
addi r11, r11, xtData@l
lwz r11, 8(r11)
lwz r0, 4(r8)
subf r11, r0, r11
cmplwi r11, 2
bgt tpPointerDone
; Touch coordinates retain native pressed/released bookkeeping; FP picking
; itself uses our world ray, so it is not clipped to the old TV rectangle.
lfs f5, 108(r7)
fmr f6, f5
b tpFpPadCoordinates
tpFpPadDiorama:
; The game's perspective object, as the pack tracks it.
lis r8, rrProjectionSource@ha
addi r8, r8, rrProjectionSource@l
lwz r8, 0(r8)
lis r0, 0x1000
cmplw r8, r0
blt tpPointerDone
lis r0, 0x5000
cmplw r8, r0
bge tpPointerDone
andi. r0, r8, 3
bne tpPointerDone
lwz r0, 144(r8)
lis r11, rrProjectionVtable@ha
addi r11, r11, rrProjectionVtable@l
lwz r11, 0(r11)
cmpw r0, r11
bne tpPointerDone
lwz r11, 168(r8)
lwz r0, 140(r7)
cmplw r11, r0
blt tpPointerDone
lwz r0, 144(r7)
cmplw r11, r0
bgt tpPointerDone
lwz r11, 172(r8)
lwz r0, 148(r7)
cmplw r11, r0
blt tpPointerDone
lwz r0, 152(r7)
cmplw r11, r0
bgt tpPointerDone
lfs f1, 168(r8)
lfs f2, 172(r8)
; Forward means -z clearly positive.
lfs f3, 44(r7)
fneg f3, f3
lfs f4, 132(r7)
fcmpu cr0, f3, f4
ble tpPointerDone
lfs f5, 36(r7)
fdivs f5, f5, f3
lfs f6, 40(r7)
fdivs f6, f6, f3
fmuls f7, f1, f2
fdivs f5, f5, f7
fdivs f6, f6, f1
lfs f8, 108(r7)
fmuls f5, f5, f8
fadds f5, f5, f8
fmuls f6, f6, f8
fsubs f6, f8, f6
stfs f5, 24(r7)
stfs f6, 28(r7)
lfs f9, 120(r7)
lfs f10, 124(r7)
fcmpu cr0, f5, f9
blt tpPointerDone
fcmpu cr0, f5, f10
bgt tpPointerDone
fcmpu cr0, f6, f9
blt tpPointerDone
fcmpu cr0, f6, f10
bgt tpPointerDone
lfs f11, 128(r7)
fcmpu cr0, f5, f11
bge tpPointerClampLo5
fmr f5, f11
tpPointerClampLo5:
lfs f11, 136(r7)
fcmpu cr0, f5, f11
ble tpPointerClampHi5
fmr f5, f11
tpPointerClampHi5:
lfs f11, 128(r7)
fcmpu cr0, f6, f11
bge tpPointerClampLo6
fmr f6, f11
tpPointerClampLo6:
lfs f11, 136(r7)
fcmpu cr0, f6, f11
ble tpPointerClampHi6
fmr f6, f11
tpPointerClampHi6:
tpFpPadCoordinates:
lfs f11, 112(r7)
fmuls f5, f5, f11
stfs f5, 16(r7)
lfs f11, 116(r7)
fmuls f6, f6, f11
stfs f6, 20(r7)
li r0, 1
stw r0, 8(r7)
lwz r11, 160(r7)
addi r11, r11, 1
stw r11, 160(r7)
; The trigger touches; while it is the pen it is not B.
li r0, -17
stw r0, 20(r12)
lwz r11, 140(r9)
andi. r11, r11, 16
beq tpPointerDone
li r0, 1
stw r0, 12(r7)
lwz r11, 172(r7)
addi r11, r11, 1
stw r11, 172(r7)
tpPointerDone:
lis r7, tfMotionData@ha
addi r7, r7, tfMotionData@l
li r5, 0
lis r6, 65535
ori r6, r6, 65535
lwz r11, 16(r9)
cmpwi r11, 0
beq tfMotionLeftDone
lwz r11, 68(r9)
li r12, 1
and r12, r11, r12
cmpwi r12, 0
beq tfMotionLeftDoneBit0
ori r5, r5, 8192
lis r12, 65535
ori r12, r12, 57343
and r6, r6, r12
tfMotionLeftDoneBit0:
li r12, 2
and r12, r11, r12
cmpwi r12, 0
beq tfMotionLeftDoneBit1
ori r5, r5, 4096
lis r12, 65535
ori r12, r12, 61439
and r6, r6, r12
tfMotionLeftDoneBit1:
li r12, 16
and r12, r11, r12
cmpwi r12, 0
beq tfMotionLeftDoneBit2
ori r5, r5, 128
lis r12, 65535
ori r12, r12, 65407
and r6, r6, r12
tfMotionLeftDoneBit2:
li r12, 32
and r12, r11, r12
cmpwi r12, 0
beq tfMotionLeftDoneBit3
ori r5, r5, 32
lis r12, 65535
ori r12, r12, 65503
and r6, r6, r12
tfMotionLeftDoneBit3:
li r12, 8
and r12, r11, r12
cmpwi r12, 0
beq tfMotionLeftDoneBit4
ori r5, r5, 8
lis r12, 65535
ori r12, r12, 65527
and r6, r6, r12
tfMotionLeftDoneBit4:
li r12, 4
and r12, r11, r12
cmpwi r12, 0
beq tfMotionLeftDoneBit5
lis r12, 2
add r5, r5, r12
lis r12, 65533
ori r12, r12, 65535
and r6, r6, r12
tfMotionLeftDoneBit5:
tfMotionLeftDone:
lwz r11, 88(r9)
cmpwi r11, 0
beq tfMotionRightDone
lwz r11, 140(r9)
lwz r12, 20(r7)
and r11, r11, r12
li r12, 1
and r12, r11, r12
cmpwi r12, 0
beq tfMotionRightDoneBit0
ori r5, r5, 32768
lis r12, 65535
ori r12, r12, 32767
and r6, r6, r12
tfMotionRightDoneBit0:
li r12, 2
and r12, r11, r12
cmpwi r12, 0
beq tfMotionRightDoneBit1
ori r5, r5, 16384
lis r12, 65535
ori r12, r12, 49151
and r6, r6, r12
tfMotionRightDoneBit1:
li r12, 16
and r12, r11, r12
cmpwi r12, 0
beq tfMotionRightDoneBit2
lwz r12, 24(r7)
cmpwi r12, 0
bne tfMotionRightDoneBit2Cart
ori r5, r5, 16384
lis r12, 65535
ori r12, r12, 49151
and r6, r6, r12
b tfMotionRightDoneBit2
tfMotionRightDoneBit2Cart:
ori r5, r5, 4096
lis r12, 65535
ori r12, r12, 61439
and r6, r6, r12
tfMotionRightDoneBit2:
li r12, 32
and r12, r11, r12
cmpwi r12, 0
beq tfMotionRightDoneBit3
ori r5, r5, 16
lis r12, 65535
ori r12, r12, 65519
and r6, r6, r12
tfMotionRightDoneBit3:
li r12, 4
and r12, r11, r12
cmpwi r12, 0
beq tfMotionRightDoneBit4
ori r5, r5, 8192
lis r12, 65535
ori r12, r12, 57343
and r6, r6, r12
tfMotionRightDoneBit4:
tfMotionRightDone:
li r8, 0
lwz r11, 16(r9)
cmpwi r11, 0
beq tfMotionLeftStick
lfs f4, 80(r9)
lfs f5, 84(r9)
fmuls f6, f4, f4
fmuls f7, f5, f5
fadds f6, f6, f7
lfs f0, 0(r7)
.int 0xFC060000 ; fcmpu cr0, f6, f0
blt tfMotionLeftStick
li r8, 1
tfMotionLeftStick:
li r10, 0
lwz r11, 88(r9)
cmpwi r11, 0
beq tfMotionRightStick
lfs f8, 152(r9)
lfs f9, 156(r9)
fmuls f6, f8, f8
fmuls f7, f9, f9
fadds f6, f6, f7
lfs f0, 0(r7)
.int 0xFC060000 ; fcmpu cr0, f6, f0
blt tfMotionRightStick
li r10, 1
tfMotionRightStick:
; Geste: linker Controller am Kopf schaltet das Steuerkreuz auf.
li r11, 0
lwz r12, 16(r9)
cmpwi r12, 0
beq tfMotionReach
lfs f10, 4(r9)
lfs f11, 32(r9)
fsubs f10, f10, f11
fmuls f12, f10, f10
lfs f10, 8(r9)
lfs f11, 48(r9)
fsubs f10, f10, f11
fmuls f10, f10, f10
fadds f12, f12, f10
lfs f10, 12(r9)
lfs f11, 64(r9)
fsubs f10, f10, f11
fmuls f10, f10, f10
fadds f12, f12, f10
lfs f0, 4(r7)
.int 0xFC0C0000 ; fcmpu cr0, f12, f0
bge tfMotionReach
li r11, 1
tfMotionReach:
cmpwi r11, 0
beq tfMotionGestureDone
lfs f10, 152(r9)
lfs f11, 156(r9)
lfs f0, 8(r7)
.int 0xFC0A0000 ; fcmpu cr0, f10, f0
ble tfMotionNoRight
ori r5, r5, 1024
lis r12, 65535
ori r12, r12, 64511
and r6, r6, r12
tfMotionNoRight:
lfs f0, 12(r7)
.int 0xFC0A0000 ; fcmpu cr0, f10, f0
bge tfMotionNoLeft
ori r5, r5, 2048
lis r12, 65535
ori r12, r12, 63487
and r6, r6, r12
tfMotionNoLeft:
lfs f0, 8(r7)
.int 0xFC0B0000 ; fcmpu cr0, f11, f0
ble tfMotionNoUp
ori r5, r5, 512
lis r12, 65535
ori r12, r12, 65023
and r6, r6, r12
tfMotionNoUp:
lfs f0, 12(r7)
.int 0xFC0B0000 ; fcmpu cr0, f11, f0
bge tfMotionNoDown
ori r5, r5, 256
lis r12, 65535
ori r12, r12, 65279
and r6, r6, r12
tfMotionNoDown:
li r10, 1
lfs f8, 16(r7)
lfs f9, 16(r7)
tfMotionGestureDone:
mr r0, r3
cmpwi r0, 16
blt tfMotionCount
li r0, 16
tfMotionCount:
mulli r0, r0, 0xAC
add r0, r0, r4
mr r11, r4
tfMotionNext:
cmpw r11, r0
bge tfMotionDone
lwz r12, 0(r11)
and r12, r12, r6
add r12, r12, r5
stw r12, 0(r11)
cmpwi r8, 0
beq tfMotionKeepLeft
stfs f4, 12(r11)
stfs f5, 16(r11)
tfMotionKeepLeft:
cmpwi r10, 0
beq tfMotionKeepRight
stfs f8, 20(r11)
stfs f9, 24(r11)
tfMotionKeepRight:
addi r11, r11, 0xAC
b tfMotionNext
tfMotionDone:
tfPadInputDone:
lwz r0, 0x34(r1)
mtlr r0
addi r1, r1, 0x30
blr
0x022C2E88 = bla tfPadInput

tfMotionData:
.int 0x3CB851EC
.int 0x4845C100
.int 0x3F000000
.int 0xBF000000
.int 0x00000000
.int 0xFFFFFFFF
.int 0

tpTouch0:
.int 0x5404063E ; clrlwi r4, r0, 0x18 (displaced)
lis r12, tpPointer@ha
addi r12, r12, tpPointer@l
lwz r0, 8(r12)
cmpwi r0, 0
beq tpTouch0Done
lwz r4, 156(r12)
addi r4, r4, 1
stw r4, 156(r12)
lwz r4, 12(r12)
lfs f1, 16(r12)
lfs f2, 20(r12)
tpTouch0Done:
blr
0x022C3328 = bla tpTouch0
tpTouch1:
.int 0x387D0178 ; addi r3, r29, 0x178 (displaced)
lis r12, tpPointer@ha
addi r12, r12, tpPointer@l
lwz r0, 8(r12)
cmpwi r0, 0
beq tpTouch1Done
lwz r4, 156(r12)
addi r4, r4, 1
stw r4, 156(r12)
lwz r4, 12(r12)
lfs f1, 16(r12)
lfs f2, 20(r12)
tpTouch1Done:
blr
0x022C3380 = bla tpTouch1
tpTouch2:
.int 0x387D0184 ; addi r3, r29, 0x184 (displaced)
lis r12, tpPointer@ha
addi r12, r12, tpPointer@l
lwz r0, 8(r12)
cmpwi r0, 0
beq tpTouch2Done
lwz r4, 156(r12)
addi r4, r4, 1
stw r4, 156(r12)
lwz r4, 12(r12)
lfs f1, 16(r12)
lfs f2, 20(r12)
tpTouch2Done:
blr
0x022C33DC = bla tpTouch2

tpPointer:
.int 0x43545054
.int 0x00000001
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x3F000000
.int 0x44A00000
.int 0x44340000
.int 0xBCA3D70A
.int 0x3F828F5C
.int 0x00000000
.int 0x38D1B717
.int 0x3F800000
.int 0x3C23D70A
.int 0x40400000
.int 0x3F000000
.int 0x40800000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000

; View table restore: the native objects go back before the game's own
; logic runs. Reached from rrBeforeCalc and rrSecondDraw with LR saved.
tpViewRestore:
lis r12, tpViewTable@ha
addi r12, r12, tpViewTable@l
lwz r11, 0(r12)
cmpwi r11, 0
beq tpViewRestoreDone
lwz r0, 12(r11)
lis r12, rrProjectionCopies@ha
addi r12, r12, rrProjectionCopies@l
cmplw r0, r12
blt tpViewRestoreCamera
addi r12, r12, 736
cmplw r0, r12
bge tpViewRestoreCamera
lis r12, tpNativeProjection@ha
lwz r12, tpNativeProjection@l(r12)
cmpwi r12, 0
beq tpViewRestoreCamera
stw r12, 12(r11)
tpViewRestoreCamera:
lwz r0, 8(r11)
lis r12, rrCamera0@ha
addi r12, r12, rrCamera0@l
cmplw r0, r12
blt tpViewRestoreDone
addi r12, r12, 352
cmplw r0, r12
bge tpViewRestoreDone
lis r12, tpNativeCamera@ha
lwz r12, tpNativeCamera@l(r12)
cmpwi r12, 0
beq tpViewRestoreDone
stw r12, 8(r11)
tpViewRestoreDone:
blr

; entry, writes; the native camera and projection last seen by the hooks.
tpViewTable:
.int 0
.int 0
tpNativeCamera:
.int 0
tpNativeProjection:
.int 0

tfMiddle:
.int 0x3F000000
.int 0

; Depth of field off: take the branch the game takes when its own switch is
; clear, so the pass is never entered and r8 keeps the previous target.
0x023EA5B4 = tfDofSkip:
0x023EA5A8 = b tfDofSkip

; Glare off: take the branch the game takes when the flare filter's own switch
; is clear, so the effect is never entered and r31 keeps the current target.
0x023CF6CC = tfGlareSkip:
0x023CF638 = b tfGlareSkip

; Light shafts off: take the branch the game takes when the god ray reports
; nothing to do, so the effect is never entered and r31 keeps the target.
0x023CF61C = tfGodRaySkip:
0x023CF564 = b tfGodRaySkip

; Horizontal head-based movement, shared gamepad/VR input path.
thmReset:
lis r12, thmState@ha
addi r12, r12, thmState@l
li r0, 0
stw r0, 16(r12)
stw r0, 12(r12)
stw r0, 4(r12)
lis r0, 0x3F80
stw r0, 8(r12)
stw r0, 0(r12)
blr
thmCompose:
lis r12, thmState@ha
addi r12, r12, thmState@l
lis r10, rrSlot@ha
lwz r10, rrSlot@l(r10)
cmplwi r10, 1
bgt thmCached
mulli r10, r10, 196
lis r9, rrPoseLatch0@ha
addi r9, r9, rrPoseLatch0@l
add r10, r10, r9
lwz r11, 0(r10)
cmpwi r11, 0
beq thmCached
lwz r9, 16(r12)
cmpw r11, r9
beq thmCached
; Inverse eye rotation row 2 is the head forward axis in anchor space.
; Translation, pitch magnitude and roll do not steer the horizontal stick.
lfs f6, 44(r10)
lfs f7, 36(r10)
fneg f7, f7
fmuls f9, f6, f6
fmuls f10, f7, f7
fadds f9, f9, f10
lfs f13, 36(r12)
.int 0xFC096800 ; fcmpu cr0,f9,f13
blt thmCached
lfs f13, 40(r12)
.int 0xFC096800 ; fcmpu cr0,f9,f13
bgt thmCached
; Reject NaN by checking each source word, rather than float comparisons.
lwz r0, 44(r10)
rlwinm r0, r0, 0, 1, 31
lis r9, 0x3F82
cmplw r0, r9
bgt thmCached
lwz r0, 36(r10)
rlwinm r0, r0, 0, 1, 31
cmplw r0, r9
bgt thmCached
lfs f10, 20(r12)
fmuls f11, f10, f10
fmuls f11, f11, f9
lfs f13, 24(r12)
fmuls f11, f11, f13
lfs f13, 28(r12)
fsubs f11, f13, f11
fmuls f10, f10, f11
fmuls f11, f10, f10
fmuls f11, f11, f9
lfs f13, 24(r12)
fmuls f11, f11, f13
lfs f13, 28(r12)
fsubs f11, f13, f11
fmuls f10, f10, f11
fmuls f11, f10, f10
fmuls f11, f11, f9
lfs f13, 24(r12)
fmuls f11, f11, f13
lfs f13, 28(r12)
fsubs f11, f13, f11
fmuls f10, f10, f11
fmuls f11, f10, f10
fmuls f11, f11, f9
lfs f13, 24(r12)
fmuls f11, f11, f13
lfs f13, 28(r12)
fsubs f11, f13, f11
fmuls f10, f10, f11
fmuls f11, f10, f10
fmuls f11, f11, f9
lfs f13, 24(r12)
fmuls f11, f11, f13
lfs f13, 28(r12)
fsubs f11, f13, f11
fmuls f10, f10, f11
fmuls f11, f10, f10
fmuls f11, f11, f9
lfs f13, 24(r12)
fmuls f11, f11, f13
lfs f13, 28(r12)
fsubs f11, f13, f11
fmuls f10, f10, f11
fmuls f11, f10, f10
fmuls f11, f11, f9
lfs f13, 24(r12)
fmuls f11, f11, f13
lfs f13, 28(r12)
fsubs f11, f13, f11
fmuls f10, f10, f11
fmuls f11, f10, f10
fmuls f11, f11, f9
lfs f13, 24(r12)
fmuls f11, f11, f13
lfs f13, 28(r12)
fsubs f11, f13, f11
fmuls f10, f10, f11
fmuls f6, f6, f10
fmuls f7, f7, f10
lwz r9, 16(r12)
stw r11, 16(r12)
cmpwi r9, 0
beq thmStoreRaw
; Smooth the unnormalised vector; never feed its normalisation back.
; This also allows an exact 180-degree reversal to cross through zero.
lfs f8, 0(r12)
lfs f9, 4(r12)
lfs f10, 32(r12)
fsubs f6, f6, f8
fsubs f7, f7, f9
fmuls f6, f6, f10
fmuls f7, f7, f10
fadds f6, f6, f8
fadds f7, f7, f9
thmStoreRaw:
stfs f6, 0(r12)
stfs f7, 4(r12)
fmuls f9, f6, f6
fmuls f10, f7, f7
fadds f9, f9, f10
lfs f13, 36(r12)
.int 0xFC096800 ; fcmpu cr0,f9,f13
blt thmCached
lfs f10, 20(r12)
fmuls f11, f10, f10
fmuls f11, f11, f9
lfs f13, 24(r12)
fmuls f11, f11, f13
lfs f13, 28(r12)
fsubs f11, f13, f11
fmuls f10, f10, f11
fmuls f11, f10, f10
fmuls f11, f11, f9
lfs f13, 24(r12)
fmuls f11, f11, f13
lfs f13, 28(r12)
fsubs f11, f13, f11
fmuls f10, f10, f11
fmuls f11, f10, f10
fmuls f11, f11, f9
lfs f13, 24(r12)
fmuls f11, f11, f13
lfs f13, 28(r12)
fsubs f11, f13, f11
fmuls f10, f10, f11
fmuls f11, f10, f10
fmuls f11, f11, f9
lfs f13, 24(r12)
fmuls f11, f11, f13
lfs f13, 28(r12)
fsubs f11, f13, f11
fmuls f10, f10, f11
fmuls f11, f10, f10
fmuls f11, f11, f9
lfs f13, 24(r12)
fmuls f11, f11, f13
lfs f13, 28(r12)
fsubs f11, f13, f11
fmuls f10, f10, f11
fmuls f11, f10, f10
fmuls f11, f11, f9
lfs f13, 24(r12)
fmuls f11, f11, f13
lfs f13, 28(r12)
fsubs f11, f13, f11
fmuls f10, f10, f11
fmuls f11, f10, f10
fmuls f11, f11, f9
lfs f13, 24(r12)
fmuls f11, f11, f13
lfs f13, 28(r12)
fsubs f11, f13, f11
fmuls f10, f10, f11
fmuls f11, f10, f10
fmuls f11, f11, f9
lfs f13, 24(r12)
fmuls f11, f11, f13
lfs f13, 28(r12)
fsubs f11, f13, f11
fmuls f10, f10, f11
fmuls f6, f6, f10
fmuls f7, f7, f10
stfs f6, 8(r12)
stfs f7, 12(r12)
thmCached:
lfs f6, 8(r12)
lfs f7, 12(r12)
; Compose with the existing stick yaw, leaving the view itself untouched.
fmuls f8, f4, f6
fmuls f9, f5, f7
fsubs f8, f8, f9
fmuls f9, f5, f6
fmuls f10, f4, f7
fadds f5, f9, f10
fmr f4, f8
blr
thmState:
.int 0x3F800000
.int 0x00000000
.int 0x3F800000
.int 0x00000000
.int 0x00000000
.int 0x3F800000
.int 0x3F000000
.int 0x3FC00000
.int 0x3F000000
.int 0x3D23D70A
.int 0x40066666

; Scoped native touch calls: never change the simulation/render camera.
tpFpPoint:
lis r11, tpFpRay@ha
addi r11, r11, tpFpRay@l
lwz r0, 0(r11)
cmpwi r0, 1
bne tpFpPointNative
lis r12, mtPad@ha
addi r12, r12, mtPad@l
lwz r0, 0(r12)
cmpwi r0, 0
beq tpFpPointNative
lwz r0, 88(r12)
cmpwi r0, 0
beq tpFpPointNative
lis r12, tpPointer@ha
addi r12, r12, tpPointer@l
lwz r0, 8(r12)
cmpwi r0, 1
bne tpFpPointNative
lis r12, tfEyeAnchor@ha
addi r12, r12, tfEyeAnchor@l
lwz r0, 12(r12)
cmpwi r0, 1
bne tpFpPointNative
lis r12, xtData@ha
addi r12, r12, xtData@l
lwz r0, 0x90(r12)
cmpwi r0, 1
bne tpFpPointNative
lwz r12, 8(r12)
lwz r0, 4(r11)
subf r12, r0, r12
cmplwi r12, 2
bgt tpFpPointNative
lwz r0, 20(r11)
stw r0, 0(r3)
lwz r0, 24(r11)
stw r0, 4(r3)
lwz r0, 28(r11)
stw r0, 8(r3)
blr
tpFpPointNative:
b 0x023953D0
0x0215ACF0 = bla tpFpPoint
tpFpOrigin:
lis r11, tpFpRay@ha
addi r11, r11, tpFpRay@l
lwz r0, 0(r11)
cmpwi r0, 1
bne tpFpOriginNative
lis r12, mtPad@ha
addi r12, r12, mtPad@l
lwz r0, 0(r12)
cmpwi r0, 0
beq tpFpOriginNative
lwz r0, 88(r12)
cmpwi r0, 0
beq tpFpOriginNative
lis r12, tpPointer@ha
addi r12, r12, tpPointer@l
lwz r0, 8(r12)
cmpwi r0, 1
bne tpFpOriginNative
lis r12, tfEyeAnchor@ha
addi r12, r12, tfEyeAnchor@l
lwz r0, 12(r12)
cmpwi r0, 1
bne tpFpOriginNative
lis r12, xtData@ha
addi r12, r12, xtData@l
lwz r0, 0x90(r12)
cmpwi r0, 1
bne tpFpOriginNative
lwz r12, 8(r12)
lwz r0, 4(r11)
subf r12, r0, r12
cmplwi r12, 2
bgt tpFpOriginNative
addi r3, r11, 8
blr
tpFpOriginNative:
b 0x0235AD98
tpFpCollision:
lis r11, tpFpRay@ha
addi r11, r11, tpFpRay@l
lwz r0, 0(r11)
cmpwi r0, 1
bne tpFpCollisionNative
lis r12, mtPad@ha
addi r12, r12, mtPad@l
lwz r0, 0(r12)
cmpwi r0, 0
beq tpFpCollisionNative
lwz r0, 88(r12)
cmpwi r0, 0
beq tpFpCollisionNative
lis r12, tpPointer@ha
addi r12, r12, tpPointer@l
lwz r0, 8(r12)
cmpwi r0, 1
bne tpFpCollisionNative
lis r12, tfEyeAnchor@ha
addi r12, r12, tfEyeAnchor@l
lwz r0, 12(r12)
cmpwi r0, 1
bne tpFpCollisionNative
lis r12, xtData@ha
addi r12, r12, xtData@l
lwz r0, 0x90(r12)
cmpwi r0, 1
bne tpFpCollisionNative
lwz r12, 8(r12)
lwz r0, 4(r11)
subf r12, r0, r12
cmplwi r12, 2
bgt tpFpCollisionNative
addi r4, r11, 32
addi r5, r11, 44
tpFpCollisionNative:
b 0x02365738
tpFpRay:
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
.int 0x43FA0000
.int 0x45FA0000
.int 0x40000000
.int 0x3F000000
.int 0x3FC00000

; GuideMessage's native icon enum: 0 DRC, 1 Gyro, 2 R, 3 Hand,
; 4 trick-art/start, 5+ no icon. Hide 0-3, including the right-stick camera guide.
; Record accepted shows only (020F2AC8), including visible-message reuse.
; Bounded cache entries are actor, layout, icon; unknown entries draw normally.
ghNext:
.int 0
ghEntries:
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

ghRemember:
stwu r1, -0x20(r1)
stw r0, 8(r1)
stw r10, 12(r1)
stw r11, 16(r1)
stw r12, 20(r1)
.int 0x7C000026
stw r0, 24(r1)
lis r12, ghEntries@ha
addi r12, r12, ghEntries@l
li r10, 16
ghRememberLoop:
lwz r11, 0(r12)
cmpw r11, r29
beq ghRememberStore
addi r12, r12, 12
addi r10, r10, -1
cmpwi r10, 0
bne ghRememberLoop
lis r11, ghNext@ha
lwz r10, ghNext@l(r11)
lis r12, ghEntries@ha
addi r12, r12, ghEntries@l
add r12, r12, r10
addi r10, r10, 12
cmpwi r10, 192
blt ghRememberNext
li r10, 0
ghRememberNext:
stw r10, ghNext@l(r11)
ghRememberStore:
stw r29, 0(r12)
lwz r11, 0x30(r29)
stw r11, 4(r12)
stw r30, 8(r12)
lwz r0, 24(r1)
.int 0x7C0FF120
lwz r0, 8(r1)
lwz r10, 12(r1)
lwz r11, 16(r1)
lwz r12, 20(r1)
addi r1, r1, 0x20
stw r6, 0x5C(r29)
b ghRememberReturn
0x020F2AC8 = ba ghRemember
0x020F2ACC = ghRememberReturn:

ghFilterDraw:
; Host acknowledgement also covers flat VR canvas frames. Without a host,
; preserve the original desktop tutorials. All camera modes use this path.
lis r12, rrHudWorldAck@ha
lwz r11, rrHudWorldAck@l(r12)
lis r12, 0x4855
addi r12, r12, 0x4131
cmpw r11, r12
bne ghDrawPass
lwz r11, 0(r7)
lis r12, 0x1003
addi r12, r12, -12900
cmpw r11, r12
bne ghDrawPass
lis r12, ghEntries@ha
addi r12, r12, ghEntries@l
li r10, 16
ghDrawLoop:
lwz r11, 0(r12)
cmpw r11, r7
bne ghDrawNext
lwz r11, 4(r12)
cmpw r11, r3
bne ghDrawPass
lwz r11, 8(r12)
cmpwi r11, 0
beq ghDrawSkip
cmpwi r11, 1
beq ghDrawSkip
cmpwi r11, 2
beq ghDrawSkip
cmpwi r11, 3
beq ghDrawSkip
b ghDrawPass
ghDrawNext:
addi r12, r12, 12
addi r10, r10, -1
cmpwi r10, 0
bne ghDrawLoop
ghDrawPass:
b rrUiSkipDraw
ghDrawSkip:
blr

; Surface markers use native nearest intersections, including hover.
smQuery:
stwu r1, -0xD0(r1)
stw r0, 8(r1)
mflr r0
stw r0, 12(r1)
.int 0x7C000026
stw r0, 16(r1)
stw r3, 20(r1)
stw r4, 24(r1)
stw r5, 28(r1)
stw r6, 32(r1)
stw r7, 36(r1)
stw r8, 40(r1)
stw r9, 44(r1)
stw r10, 48(r1)
stw r11, 52(r1)
stw r12, 56(r1)
.int 0xD8010040
.int 0xD8210048
.int 0xD8410050
.int 0xD8610058
.int 0xD8810060
.int 0xD8A10068
.int 0xD8C10070
.int 0xD8E10078
.int 0xD9010080
.int 0xD9210088
.int 0xD9410090
.int 0xD9610098
.int 0xD98100A0
.int 0xD9A100A8
bl smPrepare
.int 0xC8010040
.int 0xC8210048
.int 0xC8410050
.int 0xC8610058
.int 0xC8810060
.int 0xC8A10068
.int 0xC8C10070
.int 0xC8E10078
.int 0xC9010080
.int 0xC9210088
.int 0xC9410090
.int 0xC9610098
.int 0xC98100A0
.int 0xC9A100A8
lwz r3, 20(r1)
lwz r4, 24(r1)
lwz r5, 28(r1)
lwz r6, 32(r1)
lwz r7, 36(r1)
lwz r8, 40(r1)
lwz r9, 44(r1)
lwz r10, 48(r1)
lwz r11, 52(r1)
lwz r12, 56(r1)
lwz r0, 16(r1)
.int 0x7C0FF120
lwz r0, 12(r1)
mtlr r0
lwz r0, 8(r1)
addi r1, r1, 0xD0
b 0x0215BB50
0x0215BF48 = bla smQuery
smPrepare:
stwu r1, -0x20(r1)
mflr r0
stw r0, 0x24(r1)
.int 0x7C0902A6
stw r0, 8(r1)
lis r12, smHit@ha
addi r12, r12, smHit@l
li r0, 0
stw r0, 0(r12)
stw r0, 4(r12)
stw r0, 100(r12)
stw r0, 116(r12)
lfs f0, 80(r12)
stfs f0, 68(r12)
lis r11, xtData@ha
addi r11, r11, xtData@l
lwz r0, 8(r11)
stw r0, 8(r12)
lwz r0, 0x90(r11)
stw r0, 12(r12)
lis r7, ctAim@ha
addi r7, r7, ctAim@l
lwz r0, 12(r7)
cmpwi r0, 0
beq smPrepareSelection
lwz r8, 8(r11)
lwz r0, 8(r7)
subf r8, r0, r8
cmplwi r8, 2
bgt smPrepareSelection
li r0, 2
stw r0, 0(r12)
li r0, 1
stw r0, 16(r12)
lwz r0, 20(r7)
stw r0, 20(r12)
lwz r0, 32(r7)
stw r0, 84(r12)
lwz r0, 24(r7)
stw r0, 24(r12)
lwz r0, 36(r7)
stw r0, 88(r12)
lwz r0, 28(r7)
stw r0, 28(r12)
lwz r0, 40(r7)
stw r0, 92(r12)
b smPrepareVectors
smPrepareSelection:
lwz r0, 0x54(r11)
cmpwi r0, 0
beq smPreparePen
lis r7, smEye@ha
addi r7, r7, smEye@l
lwz r8, 0(r7)
cmpwi r8, 1
bne smPreparePen
lwz r8, 8(r7)
lwz r0, 0x90(r11)
cmpw r8, r0
bne smPreparePen
lwz r8, 8(r11)
lwz r0, 4(r7)
subf r8, r0, r8
cmplwi r8, 2
bgt smPreparePen
lwz r8, 8(r11)
lwz r0, 0x58(r11)
subf r8, r0, r8
cmplwi r8, 1
bgt smPreparePen
lwz r0, 0x54(r11)
stw r0, 100(r12)
lfs f0, 12(r7)
stfs f0, 20(r12)
lfs f1, 96(r11)
fsubs f1, f1, f0
stfs f1, 104(r12)
fmuls f1, f1, f1
fmr f3, f1
lfs f0, 16(r7)
stfs f0, 24(r12)
lfs f1, 100(r11)
lfs f2, 0x70(r11)
fsubs f1, f1, f2
fsubs f1, f1, f0
stfs f1, 108(r12)
fmuls f1, f1, f1
fadds f3, f3, f1
lfs f0, 20(r7)
stfs f0, 28(r12)
lfs f1, 104(r11)
fsubs f1, f1, f0
stfs f1, 112(r12)
fmuls f1, f1, f1
fadds f3, f3, f1
fcmpu cr0, f3, f3
bne smPrepareDone
lfs f0, 76(r12)
fmuls f0, f0, f0
fcmpu cr0, f3, f0
blt smPrepareDone
lfs f0, 96(r12)
fcmpu cr0, f3, f0
bgt smPrepareDone
addi r3, r12, 84
addi r4, r12, 104
bl 0x0231FFD8
lis r12, smHit@ha
addi r12, r12, smHit@l
li r0, 4
stw r0, 0(r12)
li r0, 2
stw r0, 16(r12)
b smPrepareVectors
smPreparePen:
lis r11, tpFpRay@ha
addi r11, r11, tpFpRay@l
lwz r0, 0(r11)
cmpwi r0, 1
bne smPrepareDiorama
lis r12, mtPad@ha
addi r12, r12, mtPad@l
lwz r0, 0(r12)
cmpwi r0, 0
beq smPrepareDiorama
lwz r0, 88(r12)
cmpwi r0, 0
beq smPrepareDiorama
lis r12, tpPointer@ha
addi r12, r12, tpPointer@l
lwz r0, 8(r12)
cmpwi r0, 1
bne smPrepareDiorama
lis r12, tfEyeAnchor@ha
addi r12, r12, tfEyeAnchor@l
lwz r0, 12(r12)
cmpwi r0, 1
bne smPrepareDiorama
lis r12, xtData@ha
addi r12, r12, xtData@l
lwz r0, 0x90(r12)
cmpwi r0, 1
bne smPrepareDiorama
lwz r12, 8(r12)
lwz r0, 4(r11)
subf r12, r0, r12
cmplwi r12, 2
bgt smPrepareDiorama
lis r12, smHit@ha
addi r12, r12, smHit@l
li r0, 1
stw r0, 0(r12)
li r0, 0
stw r0, 16(r12)
lis r7, tpPointer@ha
addi r7, r7, tpPointer@l
lwz r0, 8(r11)
stw r0, 20(r12)
lwz r0, 88(r7)
stw r0, 84(r12)
lwz r0, 12(r11)
stw r0, 24(r12)
lwz r0, 92(r7)
stw r0, 88(r12)
lwz r0, 16(r11)
stw r0, 28(r12)
lwz r0, 96(r7)
stw r0, 92(r12)
b smPrepareVectors
smPrepareDiorama:
lis r12, smHit@ha
addi r12, r12, smHit@l
lis r7, tpPointer@ha
addi r7, r7, tpPointer@l
lwz r0, 8(r7)
cmpwi r0, 1
bne smPrepareDone
lis r11, tfEyeAnchor@ha
addi r11, r11, tfEyeAnchor@l
lwz r0, 12(r11)
cmpwi r0, 1
beq smPrepareDone
li r0, 3
stw r0, 0(r12)
li r0, 0
stw r0, 16(r12)
b smPrepareDone
smPrepareVectors:
lfs f0, 20(r12)
lfs f1, 84(r12)
lfs f2, 76(r12)
fmuls f2, f1, f2
fadds f2, f0, f2
stfs f2, 44(r12)
lfs f2, 72(r12)
fmuls f1, f1, f2
stfs f1, 56(r12)
lfs f0, 24(r12)
lfs f1, 88(r12)
lfs f2, 76(r12)
fmuls f2, f1, f2
fadds f2, f0, f2
stfs f2, 48(r12)
lfs f2, 72(r12)
fmuls f1, f1, f2
stfs f1, 60(r12)
lfs f0, 28(r12)
lfs f1, 92(r12)
lfs f2, 76(r12)
fmuls f2, f1, f2
fadds f2, f0, f2
stfs f2, 52(r12)
lfs f2, 72(r12)
fmuls f1, f1, f2
stfs f1, 64(r12)
smPrepareDone:
lwz r0, 8(r1)
.int 0x7C0903A6
lwz r0, 0x24(r1)
mtlr r0
addi r1, r1, 0x20
blr
smHover:
stwu r1, -0xD0(r1)
stw r0, 8(r1)
mflr r0
stw r0, 12(r1)
.int 0x7C000026
stw r0, 16(r1)
stw r3, 20(r1)
stw r4, 24(r1)
stw r5, 28(r1)
stw r6, 32(r1)
stw r7, 36(r1)
stw r8, 40(r1)
stw r9, 44(r1)
stw r10, 48(r1)
stw r11, 52(r1)
stw r12, 56(r1)
.int 0xD8010040
.int 0xD8210048
.int 0xD8410050
.int 0xD8610058
.int 0xD8810060
.int 0xD8A10068
.int 0xD8C10070
.int 0xD8E10078
.int 0xD9010080
.int 0xD9210088
.int 0xD9410090
.int 0xD9610098
.int 0xD98100A0
.int 0xD9A100A8
.int 0x7C0902A6
stw r0, 176(r1)
stw r27, 180(r1)
stw r28, 184(r1)
stw r29, 188(r1)
bl smPrepare
lis r12, smHit@ha
addi r12, r12, smHit@l
lwz r0, 0(r12)
cmpwi r0, 1
beq smHoverQuery
cmpwi r0, 2
beq smHoverQuery
cmpwi r0, 4
bne smHoverDone
smHoverQuery:
lwz r29, 8(r30)
cmpwi r29, 0
beq smHoverDone
lwz r0, 0x88(r29)
cmpwi r0, 0
beq smHoverDone
lwz r28, 0x8C(r29)
cmpwi r28, 0
beq smHoverDone
mr r3, r29
bl 0x0215BB50
lis r12, smHit@ha
addi r12, r12, smHit@l
mr r3, r28
addi r4, r12, 20
addi r5, r29, 0x9C
bl 0x0238CFDC
li r27, 0
smHoverSensorLoop:
lwz r0, 0x20(r28)
cmplw r27, r0
bge smHoverDone
mr r3, r28
mr r4, r27
bl 0x0238CE8C
cmpwi r3, 0
beq smHoverNext
bl smSensorCandidate
smHoverNext:
addi r27, r27, 1
b smHoverSensorLoop
smHoverDone:
lis r12, smHit@ha
addi r12, r12, smHit@l
li r0, 0
stw r0, 0(r12)
lwz r27, 180(r1)
lwz r28, 184(r1)
lwz r29, 188(r1)
lwz r0, 176(r1)
.int 0x7C0903A6
.int 0xC8010040
.int 0xC8210048
.int 0xC8410050
.int 0xC8610058
.int 0xC8810060
.int 0xC8A10068
.int 0xC8C10070
.int 0xC8E10078
.int 0xC9010080
.int 0xC9210088
.int 0xC9410090
.int 0xC9610098
.int 0xC98100A0
.int 0xC9A100A8
lwz r3, 20(r1)
lwz r4, 24(r1)
lwz r5, 28(r1)
lwz r6, 32(r1)
lwz r7, 36(r1)
lwz r8, 40(r1)
lwz r9, 44(r1)
lwz r10, 48(r1)
lwz r11, 52(r1)
lwz r12, 56(r1)
lwz r0, 16(r1)
.int 0x7C0FF120
lwz r0, 12(r1)
mtlr r0
lwz r0, 8(r1)
addi r1, r1, 0xD0
lwz r3, 8(r30)
blr
0x0215ADA4 = bla smHover
smNormalize:
lis r12, smHit@ha
addi r12, r12, smHit@l
lwz r0, 0(r12)
cmpwi r0, 1
beq smNormalizeRay
cmpwi r0, 2
beq smNormalizeRay
cmpwi r0, 4
bne smNormalizeNative
smNormalizeRay:
lwz r0, 84(r12)
stw r0, 0(r3)
lwz r0, 88(r12)
stw r0, 4(r3)
lwz r0, 92(r12)
stw r0, 8(r3)
blr
smNormalizeNative:
b 0x0231FFD8
0x0215BBD8 = bla smNormalize
smOrigin:
lis r12, smHit@ha
addi r12, r12, smHit@l
lwz r0, 0(r12)
cmpwi r0, 1
beq smOriginRay
cmpwi r0, 2
beq smOriginRay
cmpwi r0, 4
beq smOriginRay
; Preserve the native getter, and remember its exact origin for diorama.
stwu r1, -0x20(r1)
mflr r0
stw r0, 0x24(r1)
bl 0x0235AD98
lis r12, smHit@ha
addi r12, r12, smHit@l
lwz r0, 0(r3)
stw r0, 20(r12)
lwz r0, 4(r3)
stw r0, 24(r12)
lwz r0, 8(r3)
stw r0, 28(r12)
lwz r0, 0x24(r1)
mtlr r0
addi r1, r1, 0x20
blr
smOriginRay:
addi r3, r12, 20
blr
0x0215BB78 = bla smOrigin
0x0215BFC8 = bla smOrigin
0x0215C09C = bla smOrigin
smCollision:
lis r12, smHit@ha
addi r12, r12, smHit@l
lwz r0, 0(r12)
cmpwi r0, 1
beq smCollisionRay
cmpwi r0, 2
beq smCollisionRay
cmpwi r0, 4
bne smCollisionNative
smCollisionRay:
addi r4, r12, 44
addi r5, r12, 56
smCollisionNative:
b 0x02365738
0x0215BCF4 = bla smCollision
smMeshHit:
stwu r1, -0xD0(r1)
stw r0, 8(r1)
mflr r0
stw r0, 12(r1)
.int 0x7C000026
stw r0, 16(r1)
stw r3, 20(r1)
stw r4, 24(r1)
stw r5, 28(r1)
stw r6, 32(r1)
stw r7, 36(r1)
stw r8, 40(r1)
stw r9, 44(r1)
stw r10, 48(r1)
stw r11, 52(r1)
stw r12, 56(r1)
.int 0xD8010040
.int 0xD8210048
.int 0xD8410050
.int 0xD8610058
.int 0xD8810060
.int 0xD8A10068
.int 0xD8C10070
.int 0xD8E10078
.int 0xD9010080
.int 0xD9210088
.int 0xD9410090
.int 0xD9610098
.int 0xD98100A0
.int 0xD9A100A8
addi r7, r28, 0x64
bl smCandidate
cmpwi r8, 0
beq smMeshDone
lwz r3, 0(r28)
cmpwi r3, 0
beq smMeshClassified
lwz r3, 0x120(r3)
cmpwi r3, 0
beq smMeshClassified
lwz r3, 0x2C(r3)
bl smClassifyOwner
smMeshClassified:
lwz r0, 0(r12)
cmpwi r0, 4
bne smMeshDone
; A closer wall invalidates the selected-platform marker instead of moving it.
li r0, 0
stw r0, 4(r12)
lwz r8, 0(r28)
cmpwi r8, 0
beq smMeshDone
lwz r8, 0x120(r8)
cmpwi r8, 0
beq smMeshDone
lwz r8, 0x2C(r8)
lwz r0, 100(r12)
cmpw r8, r0
bne smMeshDone
li r0, 1
stw r0, 4(r12)
smMeshDone:
.int 0xC8010040
.int 0xC8210048
.int 0xC8410050
.int 0xC8610058
.int 0xC8810060
.int 0xC8A10068
.int 0xC8C10070
.int 0xC8E10078
.int 0xC9010080
.int 0xC9210088
.int 0xC9410090
.int 0xC9610098
.int 0xC98100A0
.int 0xC9A100A8
lwz r3, 20(r1)
lwz r4, 24(r1)
lwz r5, 28(r1)
lwz r6, 32(r1)
lwz r7, 36(r1)
lwz r8, 40(r1)
lwz r9, 44(r1)
lwz r10, 48(r1)
lwz r11, 52(r1)
lwz r12, 56(r1)
lwz r0, 16(r1)
.int 0x7C0FF120
lwz r0, 12(r1)
mtlr r0
lwz r0, 8(r1)
addi r1, r1, 0xD0
mr r26, r28
blr
0x0215BDA4 = bla smMeshHit
smSensorHit:
stwu r1, -0xD0(r1)
stw r0, 8(r1)
mflr r0
stw r0, 12(r1)
.int 0x7C000026
stw r0, 16(r1)
stw r3, 20(r1)
stw r4, 24(r1)
stw r5, 28(r1)
stw r6, 32(r1)
stw r7, 36(r1)
stw r8, 40(r1)
stw r9, 44(r1)
stw r10, 48(r1)
stw r11, 52(r1)
stw r12, 56(r1)
.int 0xD8010040
.int 0xD8210048
.int 0xD8410050
.int 0xD8610058
.int 0xD8810060
.int 0xD8A10068
.int 0xD8C10070
.int 0xD8E10078
.int 0xD9010080
.int 0xD9210088
.int 0xD9410090
.int 0xD9610098
.int 0xD98100A0
.int 0xD9A100A8
mr r3, r21
bl smSensorCandidate
.int 0xC8010040
.int 0xC8210048
.int 0xC8410050
.int 0xC8610058
.int 0xC8810060
.int 0xC8A10068
.int 0xC8C10070
.int 0xC8E10078
.int 0xC9010080
.int 0xC9210088
.int 0xC9410090
.int 0xC9610098
.int 0xC98100A0
.int 0xC9A100A8
lwz r3, 20(r1)
lwz r4, 24(r1)
lwz r5, 28(r1)
lwz r6, 32(r1)
lwz r7, 36(r1)
lwz r8, 40(r1)
lwz r9, 44(r1)
lwz r10, 48(r1)
lwz r11, 52(r1)
lwz r12, 56(r1)
lwz r0, 16(r1)
.int 0x7C0FF120
lwz r0, 12(r1)
mtlr r0
lwz r0, 8(r1)
addi r1, r1, 0xD0
lwz r11, 0x88(r29)
blr
0x0215C0E0 = bla smSensorHit
smSensorCandidate:
lis r12, smHit@ha
addi r12, r12, smHit@l
lwz r0, 0(r12)
cmpwi r0, 4
bne smSensorAny
lwz r8, 0x2C(r3)
lwz r0, 100(r12)
cmpw r8, r0
bne smSensorDone
smSensorAny:
stwu r1, -0x10(r1)
mflr r0
stw r0, 0x14(r1)
addi r7, r3, 0x20
bl smCandidate
cmpwi r8, 0
beq smSensorClassified
lwz r3, 0x2C(r3)
bl smClassifyOwner
smSensorClassified:
lwz r0, 0x14(r1)
mtlr r0
addi r1, r1, 0x10
smSensorDone:
blr
smSensorNear:
stwu r1, -0xD0(r1)
stw r0, 8(r1)
mflr r0
stw r0, 12(r1)
.int 0x7C000026
stw r0, 16(r1)
stw r3, 20(r1)
stw r4, 24(r1)
stw r5, 28(r1)
stw r6, 32(r1)
stw r7, 36(r1)
stw r8, 40(r1)
stw r9, 44(r1)
stw r10, 48(r1)
stw r11, 52(r1)
stw r12, 56(r1)
.int 0xD8010040
.int 0xD8210048
.int 0xD8410050
.int 0xD8610058
.int 0xD8810060
.int 0xD8A10068
.int 0xD8C10070
.int 0xD8E10078
.int 0xD9010080
.int 0xD9210088
.int 0xD9410090
.int 0xD9610098
.int 0xD98100A0
.int 0xD9A100A8
lis r12, smHit@ha
addi r12, r12, smHit@l
lwz r0, 0(r12)
cmpwi r0, 1
beq smSensorNearRay
cmpwi r0, 2
beq smSensorNearRay
cmpwi r0, 4
bne smSensorNearNative
smSensorNearRay:
lfs f0, 76(r12)
fcmpu cr0, f1, f0
b smSensorNearStore
smSensorNearNative:
fcmpu cr0, f1, f31
smSensorNearStore:
.int 0x7C000026
stw r0, 16(r1) ; return the comparison CR, preserve every other register
.int 0xC8010040
.int 0xC8210048
.int 0xC8410050
.int 0xC8610058
.int 0xC8810060
.int 0xC8A10068
.int 0xC8C10070
.int 0xC8E10078
.int 0xC9010080
.int 0xC9210088
.int 0xC9410090
.int 0xC9610098
.int 0xC98100A0
.int 0xC9A100A8
lwz r3, 20(r1)
lwz r4, 24(r1)
lwz r5, 28(r1)
lwz r6, 32(r1)
lwz r7, 36(r1)
lwz r8, 40(r1)
lwz r9, 44(r1)
lwz r10, 48(r1)
lwz r11, 52(r1)
lwz r12, 56(r1)
lwz r0, 16(r1)
.int 0x7C0FF120
lwz r0, 12(r1)
mtlr r0
lwz r0, 8(r1)
addi r1, r1, 0xD0
blr
0x0215C0C8 = bla smSensorNear
smQueryEnd:
stwu r1, -0xD0(r1)
stw r0, 8(r1)
mflr r0
stw r0, 12(r1)
.int 0x7C000026
stw r0, 16(r1)
stw r3, 20(r1)
stw r4, 24(r1)
stw r5, 28(r1)
stw r6, 32(r1)
stw r7, 36(r1)
stw r8, 40(r1)
stw r9, 44(r1)
stw r10, 48(r1)
stw r11, 52(r1)
stw r12, 56(r1)
.int 0xD8010040
.int 0xD8210048
.int 0xD8410050
.int 0xD8610058
.int 0xD8810060
.int 0xD8A10068
.int 0xD8C10070
.int 0xD8E10078
.int 0xD9010080
.int 0xD9210088
.int 0xD9410090
.int 0xD9610098
.int 0xD98100A0
.int 0xD9A100A8
lis r12, smHit@ha
addi r12, r12, smHit@l
li r0, 0
stw r0, 0(r12)
.int 0xC8010040
.int 0xC8210048
.int 0xC8410050
.int 0xC8610058
.int 0xC8810060
.int 0xC8A10068
.int 0xC8C10070
.int 0xC8E10078
.int 0xC9010080
.int 0xC9210088
.int 0xC9410090
.int 0xC9610098
.int 0xC98100A0
.int 0xC9A100A8
lwz r3, 20(r1)
lwz r4, 24(r1)
lwz r5, 28(r1)
lwz r6, 32(r1)
lwz r7, 36(r1)
lwz r8, 40(r1)
lwz r9, 44(r1)
lwz r10, 48(r1)
lwz r11, 52(r1)
lwz r12, 56(r1)
lwz r0, 16(r1)
.int 0x7C0FF120
lwz r0, 12(r1)
mtlr r0
lwz r0, 8(r1)
addi r1, r1, 0xD0
mr r3, r30
blr
0x0215C87C = bla smQueryEnd
smCandidate:
lis r12, smHit@ha
addi r12, r12, smHit@l
li r8, 0
lwz r0, 0(r12)
cmpwi r0, 0
beq smCandidateDone
lfs f1, 0(r7)
lfs f2, 20(r12)
fsubs f1, f1, f2
fmuls f1, f1, f1
fmr f0, f1
lfs f1, 4(r7)
lfs f2, 24(r12)
fsubs f1, f1, f2
fmuls f1, f1, f1
fadds f0, f0, f1
lfs f1, 8(r7)
lfs f2, 28(r12)
fsubs f1, f1, f2
fmuls f1, f1, f1
fadds f0, f0, f1
fcmpu cr0, f0, f0
bne smCandidateDone
lfs f1, 76(r12)
fmuls f1, f1, f1
fcmpu cr0, f0, f1
blt smCandidateDone
lfs f1, 68(r12)
fcmpu cr0, f0, f1
bge smCandidateDone
lfs f1, 96(r12)
fcmpu cr0, f0, f1
bgt smCandidateDone
stfs f0, 68(r12)
lwz r0, 0(r7)
stw r0, 32(r12)
lwz r0, 4(r7)
stw r0, 36(r12)
lwz r0, 8(r7)
stw r0, 40(r12)
li r0, 0
stw r0, 116(r12)
li r0, 1
stw r0, 4(r12)
li r8, 1
smCandidateDone:
blr
smClassifyOwner:
; Touch sensors are not HitSensors. Inspect the owner's HitSensorKeeper
; (native getter 0233C81C), then the documented native body categories.
; Unknown targets, terrain, lifts and pure attack/projectile sensors use hand.
cmpwi r3, 0
beq smClassifyDone
lwz r3, 0x4C(r3)
cmpwi r3, 0
beq smClassifyDone
lwz r4, 4(r3)
cmplwi r4, 64
bgt smClassifyDone
cmpwi r4, 0
beq smClassifyDone
lwz r3, 8(r3)
cmpwi r3, 0
beq smClassifyDone
smClassifyLoop:
lwz r5, 0(r3)
cmpwi r5, 0
beq smClassifyNext
lwz r5, 4(r5)
cmpwi r5, 5
beq smClassifyEnemy
cmpwi r5, 6
beq smClassifyEnemy
cmpwi r5, 9
beq smClassifyEnemy
cmpwi r5, 10
beq smClassifyEnemy
smClassifyNext:
addi r3, r3, 4
addi r4, r4, -1
cmpwi r4, 0
bne smClassifyLoop
smClassifyDone:
blr
smClassifyEnemy:
li r0, 1
stw r0, 116(r12)
blr
smHit:
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x45FA0000
.int 0x40000000
.int 0x7149F2CA
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x4C744341
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
smEye:
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
