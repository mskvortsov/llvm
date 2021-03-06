; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=x86_64-unknown-unknown -mattr=avx512f %s -o - | FileCheck %s

; This asserted because we didn't account for a zext of a non-SETCC node:
; https://bugs.llvm.org/show_bug.cgi?id=32316

define i8 @PR32316(i8 %t1, i32 %t5, i8 %t8)  {
; CHECK-LABEL: PR32316:
; CHECK:       # %bb.0:
; CHECK-NEXT:    xorl %eax, %eax
; CHECK-NEXT:    testb %dil, %dil
; CHECK-NEXT:    sete %al
; CHECK-NEXT:    cmpl %esi, %eax
; CHECK-NEXT:    seta %al
; CHECK-NEXT:    cmpb $1, %dl
; CHECK-NEXT:    sbbb $-1, %al
; CHECK-NEXT:    retq
  %t2 = icmp eq i8 %t1, 0
  %t3 = zext i1 %t2 to i32
  %t6 = icmp ugt i32 %t3, %t5
  %t7 = zext i1 %t6 to i8
  %t9 = icmp ne i8 %t8, 0
  %t10 = zext i1 %t9 to i8
  %t11 = add i8 %t7, %t10
  ret i8 %t11
}

