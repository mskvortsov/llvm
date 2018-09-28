; RUN: llvm-mc -triple msp430 -show-encoding < %s | FileCheck %s

foo:
  mov.w r8, r15
  mov.w disp+2(r8), r15
  mov.w disp+2, r15
  mov.w &disp+2, r15
  mov.w @r8, r15
  mov.w @r8+, r15
  mov.w #disp+2, r15

; CHECK:	mov.w	r8, r15                 ; encoding: [0x0f,0x48]
; CHECK:	mov.w	disp+2(r8), r15         ; encoding: [0x1f,0x48,A,A]
; CHECK:                                        ;   fixup A - offset: 2, value: disp+2, kind: fixup_16_byte
; CHECK:	mov.w	disp+2, r15             ; encoding: [0x1f,0x40,A,A]
; CHECK:                                        ;   fixup A - offset: 2, value: disp+2, kind: fixup_16_pcrel_byte
; CHECK:	mov.w	&disp+2, r15            ; encoding: [0x1f,0x42,A,A]
; CHECK:                                        ;   fixup A - offset: 2, value: disp+2, kind: fixup_16
; CHECK:	mov.w	0(r8), r15              ; encoding: [0x1f,0x48,0x00,0x00]
; CHECK:	mov.w	@r8+, r15               ; encoding: [0x3f,0x48]
; CHECK:	mov.w	#disp+2, r15            ; encoding: [0x3f,0x40,A,A]
; CHECK:                                        ;   fixup A - offset: 2, value: disp+2, kind: fixup_16_byte

  mov.w #42, r15
  mov.w #42, 12(r15)
  mov.w disp, disp+2

; CHECK:	mov.w	#42, r15                ; encoding: [0x3f,0x40,0x2a,0x00]
; CHECK:	mov.w	#42, 12(r15)            ; encoding: [0xbf,0x40,0x2a,0x00,0x0c,0x00]
; CHECK:	mov.w	disp, disp+2            ; encoding: [0x90,0x40,A,A,B,B]
; CHECK:                                        ;   fixup A - offset: 2, value: disp, kind: fixup_16_pcrel_byte
; CHECK:                                        ;   fixup B - offset: 4, value: disp+2, kind: fixup_16_pcrel_byte

disp:
  .word 0xcafe
  .word 0xbabe
