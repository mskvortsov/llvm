; RUN: llvm-mc -triple msp430 -show-encoding < %s | FileCheck %s

foo:

  mov r0, r1

; CHECK: mov r0, r1
