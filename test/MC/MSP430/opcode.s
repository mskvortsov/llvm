; RUN: llvm-mc -triple msp430 -show-encoding < %s | FileCheck %s
foo:
  ;; IForm8 instructions
;  mov.b  r7, r8 ; HECK: mov.w  r7, r8 ; encoding: [0x48,0x47]
;  add.b  r7, r8 ; HECK: add.w  r7, r8 ; encoding: [0x48,0x57]
;  addc.b r7, r8 ; HECK: addc.w r7, r8 ; encoding: [0x48,0x67]
;  subc.b r7, r8 ; HECK: subc.w r7, r8 ; encoding: [0x48,0x77]
;  sub.b  r7, r8 ; HECK: sub.w  r7, r8 ; encoding: [0x48,0x87]
;  cmp.b  r7, r8 ; HECK: cmp.w  r7, r8 ; encoding: [0x48,0x97]
;  dadd.b r7, r8 ; HECK: cmp.w  r7, r8 ; encoding: [0x48,0x97]
;  bit.b  r7, r8 ; HECK: bit.w  r7, r8 ; encoding: [0x48,0xb7]
;  bic.b  r7, r8 ; HECK: bic.w  r7, r8 ; encoding: [0x48,0xc7]
;  bis.b  r7, r8 ; HECK: bis.w  r7, r8 ; encoding: [0x48,0xd7]
;  xor.b  r7, r8 ; HECK: xor.w  r7, r8 ; encoding: [0x48,0xe7]
;  and.b  r7, r8 ; HECK: and.w  r7, r8 ; encoding: [0x48,0xf7]

  ;; IForm16 instructions
;  mov    r7, r8 ; HECK: mov.w  r7, r8 ; encoding: [0x08,0x47]
;  add    r7, r8 ; HECK: add.w  r7, r8 ; encoding: [0x08,0x57]
;  addc   r7, r8 ; HECK: addc.w r7, r8 ; encoding: [0x08,0x67]
;  subc   r7, r8 ; HECK: subc.w r7, r8 ; encoding: [0x08,0x77]
;  sub    r7, r8 ; HECK: sub.w  r7, r8 ; encoding: [0x08,0x87]
;  cmp    r7, r8 ; HECK: cmp.w  r7, r8 ; encoding: [0x08,0x97]
;  dadd   r7, r8 ; HECK: cmp.w  r7, r8 ; encoding: [0x08,0x97]
;  bit    r7, r8 ; HECK: bit.w  r7, r8 ; encoding: [0x08,0xb7]
;  bic    r7, r8 ; HECK: bic.w  r7, r8 ; encoding: [0x08,0xc7]
;  bis    r7, r8 ; HECK: bis.w  r7, r8 ; encoding: [0x08,0xd7]
;  xor    r7, r8 ; HECK: xor.w  r7, r8 ; encoding: [0x08,0xe7]
;  and    r7, r8 ; HECK: and.w  r7, r8 ; encoding: [0x08,0xf7]

  ;; IIForm8 instructions
;  rrc.b  r7     ; HECK: rrc.b  r7     ; encoding: [0x47,0x10]
;  rra.b  r7     ; HECK: rra.b  r7     ; encoding: [0x47,0x11]
;  push.b r7     ; HECK: push.b r7     ; encoding: [0x47,0x12]

  ;; IIForm16 instructions
;  rrc    r7     ; HECK: rrc.w  r7     ; encoding: [0x07,0x10]
;  swpb   r7     ; HECK: swpb   r7     ; encoding: [0x87,0x10]
;  rra    r7     ; HECK: rra.w  r7     ; encoding: [0x07,0x11]
;  sxt    r7     ; HECK: sxt    r7     ; encoding: [0x87,0x11]
;  push   r7     ; HECK: push.w r7     ; encoding: [0x07,0x12]
;  call   r7     ; HECK: call   r7     ; encoding: [0x87,0x12]
;  reti          ; HECK: reti   r7     ; encoding: [0x00,0x13]

  ;; CJForm instructions
;  jnz    foo    ; HECK: jnz foo       ; encoding: [0x00,0x20]
;  jne    foo    ; HECK: jnz foo       ; encoding: [0x00,0x20]
;  jeq    foo    ; HECK: jeq foo       ; encoding: [0x00,0x24]
;  jz     foo    ; HECK: jz  foo       ; encoding: [0x00,0x24]
;  jnc    foo    ; HECK: jnc foo       ; encoding: [0x00,0x28]
;  jlo    foo    ; HECK: jlo foo       ; encoding: [0x00,0x28]
;  jc     foo    ; HECK: jc  foo       ; encoding: [0x00,0x2c]
;  jhs    foo    ; HECK: jhs foo       ; encoding: [0x00,0x2c]
;  jn     foo    ; HECK: jn  foo       ; encoding: [0x00,0x30]
;  jge    foo    ; HECK: jge foo       ; encoding: [0x00,0x34]
;  jl     foo    ; HECK: jl  foo       ; encoding: [0x00,0x38]
;  jmp    foo    ; HECK: jmp foo       ; encoding: [0x00,0x3c]


  ;; Emulated arithmetic instructions
;  adc    r7     ; addc #0, r7
;  dadc   r7     ; dadd #0, r7
;  dec    r7     ; sub  #1, r7
;  decd   r7     ; sub  #2, r7
;  inc    r7     ; add  #1, r7
;  incd   r7     ; add  #2, r7
;  sbc    r7     ; subc #0, r7

  ;; Emulated logical instructions
;  inv    r7     ; xor  #0xffff, r7
;  rla    r7     ; add  r7, r7
;  rlc    r7     ; addc r7, r7

  ;; Emulated program flow control instructions
;  br     r7     ; mov  r7, pc
;  dint          ; bic  #8, sr
;  eint          ; bis  #8, sr
;  nop           ; mov  #0, r3
;  ret           ; mov  @sp+, pc

  ;; Emulated data instruction
;  clr    r7     ; mov  #0, r7
;  clrc          ; bic  #1, sr
;  clrn          ; bic  #4, sr
;  clrz          ; bic  #2, sr
;  pop    r7     ; mov  @sp+, r7
;  setc          ; bis  #1, sr
;  setn          ; bis  #4, sr
;  setz          ; bis  #2, sr
;  tst    r7     ; cmp  #0, r7

