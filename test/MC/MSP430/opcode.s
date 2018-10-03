; RUN: llvm-mc -triple msp430 -show-encoding < %s | FileCheck %s
foo:
  ;; IForm8 instructions
  mov.b  r7, r8 ; CHECK: mov.b  r7, r8 ; encoding: [0x48,0x47]
  add.b  r7, r8 ; CHECK: add.b  r7, r8 ; encoding: [0x48,0x57]
  addc.b r7, r8 ; CHECK: addc.b r7, r8 ; encoding: [0x48,0x67]
  subc.b r7, r8 ; CHECK: subc.b r7, r8 ; encoding: [0x48,0x77]
  sub.b  r7, r8 ; CHECK: sub.b  r7, r8 ; encoding: [0x48,0x87]
  cmp.b  r7, r8 ; CHECK: cmp.b  r7, r8 ; encoding: [0x48,0x97]
  dadd.b r7, r8 ; CHECK: dadd.b r7, r8 ; encoding: [0x48,0xa7]
  bit.b  r7, r8 ; CHECK: bit.b  r7, r8 ; encoding: [0x48,0xb7]
  bic.b  r7, r8 ; CHECK: bic.b  r7, r8 ; encoding: [0x48,0xc7]
  bis.b  r7, r8 ; CHECK: bis.b  r7, r8 ; encoding: [0x48,0xd7]
  xor.b  r7, r8 ; CHECK: xor.b  r7, r8 ; encoding: [0x48,0xe7]
  and.b  r7, r8 ; CHECK: and.b  r7, r8 ; encoding: [0x48,0xf7]

  ;; IForm16 instructions
  mov    r7, r8 ; CHECK: mov    r7, r8 ; encoding: [0x08,0x47]
  add    r7, r8 ; CHECK: add    r7, r8 ; encoding: [0x08,0x57]
  addc   r7, r8 ; CHECK: addc   r7, r8 ; encoding: [0x08,0x67]
  subc   r7, r8 ; CHECK: subc   r7, r8 ; encoding: [0x08,0x77]
  sub    r7, r8 ; CHECK: sub    r7, r8 ; encoding: [0x08,0x87]
  cmp    r7, r8 ; CHECK: cmp    r7, r8 ; encoding: [0x08,0x97]
  dadd   r7, r8 ; CHECK: dadd   r7, r8 ; encoding: [0x08,0xa7]
  bit    r7, r8 ; CHECK: bit    r7, r8 ; encoding: [0x08,0xb7]
  bic    r7, r8 ; CHECK: bic    r7, r8 ; encoding: [0x08,0xc7]
  bis    r7, r8 ; CHECK: bis    r7, r8 ; encoding: [0x08,0xd7]
  xor    r7, r8 ; CHECK: xor    r7, r8 ; encoding: [0x08,0xe7]
  and    r7, r8 ; CHECK: and    r7, r8 ; encoding: [0x08,0xf7]

  ;; IIForm8 instructions
  rrc.b  r7     ; CHECK: rrc.b  r7     ; encoding: [0x47,0x10]
  rra.b  r7     ; CHECK: rra.b  r7     ; encoding: [0x47,0x11]
  push.b r7     ; CHECK: push.b r7     ; encoding: [0x47,0x12]

  ;; IIForm16 instructions
  rrc    r7     ; CHECK: rrc    r7     ; encoding: [0x07,0x10]
  swpb   r7     ; CHECK: swpb   r7     ; encoding: [0x87,0x10]
  rra    r7     ; CHECK: rra    r7     ; encoding: [0x07,0x11]
  sxt    r7     ; CHECK: sxt    r7     ; encoding: [0x87,0x11]
  push   r7     ; CHECK: push   r7     ; encoding: [0x07,0x12]
  call   r7     ; CHECK: call   r7     ; encoding: [0x87,0x12]
  reti          ; CHECK: reti          ; encoding: [0x00,0x13]

  ;; CJForm instructions
  jnz    foo    ; CHECK: jne    foo    ; encoding: [A,0b001000AA]
                ; CHECK:               ;   fixup A - offset: 0, value: foo, kind: fixup_10_pcrel
  jne    foo    ; CHECK: jne    foo    ; encoding: [A,0b001000AA]
                ; CHECK:               ;   fixup A - offset: 0, value: foo, kind: fixup_10_pcrel
  jeq    foo    ; CHECK: jeq    foo    ; encoding: [A,0b001001AA]
                ; CHECK:               ;   fixup A - offset: 0, value: foo, kind: fixup_10_pcrel
  jz     foo    ; CHECK: jeq    foo    ; encoding: [A,0b001001AA]
                ; CHECK:               ;   fixup A - offset: 0, value: foo, kind: fixup_10_pcrel
  jnc    foo    ; CHECK: jlo    foo    ; encoding: [A,0b001010AA]
                ; CHECK:               ;   fixup A - offset: 0, value: foo, kind: fixup_10_pcrel
  jlo    foo    ; CHECK: jlo    foo    ; encoding: [A,0b001010AA]
                ; CHECK:               ;   fixup A - offset: 0, value: foo, kind: fixup_10_pcrel
  jc     foo    ; CHECK: jhs    foo    ; encoding: [A,0b001011AA]
                ; CHECK:               ;   fixup A - offset: 0, value: foo, kind: fixup_10_pcrel
  jhs    foo    ; CHECK: jhs    foo    ; encoding: [A,0b001011AA]
                ; CHECK:               ;   fixup A - offset: 0, value: foo, kind: fixup_10_pcrel
  jn     foo    ; CHECK: jn     foo    ; encoding: [A,0b001100AA]
                ; CHECK:               ;   fixup A - offset: 0, value: foo, kind: fixup_10_pcrel
  jge    foo    ; CHECK: jge    foo    ; encoding: [A,0b001101AA]
                ; CHECK:               ;   fixup A - offset: 0, value: foo, kind: fixup_10_pcrel
  jl     foo    ; CHECK: jl     foo    ; encoding: [A,0b001110AA]
                ; CHECK:               ;   fixup A - offset: 0, value: foo, kind: fixup_10_pcrel
  jmp    foo    ; CHECK: jmp    foo    ; encoding: [A,0b001111AA]
                ; CHECK:               ;   fixup A - offset: 0, value: foo, kind: fixup_10_pcrel


  ;; Emulated arithmetic instructions
  adc    r7     ; CHECK: addc   #0, r7 ; encoding: [0x07,0x63]
  dadc   r7     ; CHECK: dadd   #0, r7 ; encoding: [0x07,0xa3]
  dec    r7     ; CHECK: sub    #1, r7 ; encoding: [0x17,0x83]
  decd   r7     ; CHECK: sub    #2, r7 ; encoding: [0x27,0x83]
  inc    r7     ; CHECK: add    #1, r7 ; encoding: [0x17,0x53]
  incd   r7     ; CHECK: add    #2, r7 ; encoding: [0x27,0x53]
  sbc    r7     ; CHECK: subc   #0, r7 ; encoding: [0x07,0x73]

  ;; Emulated logical instructions
  inv    r7     ; CHECK: xor   #-1, r7 ; encoding: [0x37,0xe3]
;  rla    r7     ; HECK: add    r7, r7 ; encoding: [0x07,0x57]
  rlc    r7     ; CHECK: addc   r7, r7 ; encoding: [0x07,0x67]

  ;; Emulated program flow control instructions
;  br     r7     ; mov  r7, pc
  dint          ; CHECK: bic    #8, r2 ; encoding: [0x32,0xc2]
  eint          ; CHECK: bis    #8, r2 ; encoding: [0x32,0xd2]
;  nop           ; mov  #0, r3
;  ret           ; mov  @sp+, pc

  ;; Emulated data instruction
  clr    r7     ; CHECK: mov    #0, r7 ; encoding: [0x07,0x43]
  clrc          ; CHECK: bic    #1, r2 ; encoding: [0x12,0xc3]
  clrn          ; CHECK: bic    #4, r2 ; encoding: [0x22,0xc2]
  clrz          ; CHECK: bic    #2, r2 ; encoding: [0x22,0xc3]
;  pop    r7     ; mov  @sp+, r7
  setc          ; CHECK: bis    #1, r2 ; encoding: [0x12,0xd3]
  setn          ; CHECK: bis    #4, r2 ; encoding: [0x22,0xd2]
  setz          ; CHECK: bis    #2, r2 ; encoding: [0x22,0xd3]
  tst    r7     ; CHECK: cmp    #0, r7 ; encoding: [0x07,0x93]

