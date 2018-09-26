//===-- MSP430FixupKinds.h - MSP430 Specific Fixup Entries ------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_MSP430_MCTARGETDESC_MSP430FIXUPKINDS_H
#define LLVM_LIB_TARGET_MSP430_MCTARGETDESC_MSP430FIXUPKINDS_H

#include "llvm/MC/MCFixup.h"

#undef MSP430

namespace llvm {
namespace MSP430 {
enum Fixups {
  fixup_32 = FirstTargetFixupKind,
  fixup_10_pcrel,
  fixup_16,
  fixup_16_pcrel,
  fixup_16_byte,
  fixup_16_pcrel_byte,
  fixup_2x_pcrel,
  fixup_rl_pcrel,
  fixup_8,
  fixup_sym_diff,

  // Marker
  LastTargetFixupKind,
  NumTargetFixupKinds = LastTargetFixupKind - FirstTargetFixupKind
};
} // end namespace MSP430
} // end namespace llvm

#endif
