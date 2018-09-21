; RUN: llvm-mc -triple msp430 -show-encoding < %s | FileCheck %s

foo:
  mov.w r8, r15             ; MOV16rr  SrcReg
  mov.w disp+2(r8), r15     ; MOV16rm  SrcMem      R_MSP430_16_BYTE
  mov.w disp+2, r15         ; MOV16rm  SrcMem      R_MSP430_16_PCREL_BYTE
  mov.w &disp+2, r15        ; MOV16rm  SrcMem      R_MSP430_16
  mov.w @r8, r15            ; MOV16rn  SrcIndReg
  mov.w @r8+, r15           ; MOV16rp  SrcPostInc
  mov.w #disp+2, r15        ; MOV16ri  SrcImm      R_MSP430_16_BYTE

disp:
  .word 0xcafe
  .word 0xbabe

; CHECK: mov.w	r8, r15         ; encoding: [0x0f,0x48]
