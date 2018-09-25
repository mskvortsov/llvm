//===-- MSP430ELFStreamer.h - MSP430 ELF Target Streamer -------*- C++ -*--===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_MSP430_MCTARGETDESC_MSP430ELFSTREAMER_H
#define LLVM_LIB_TARGET_MSP430_MCTARGETDESC_MSP430ELFSTREAMER_H

#include "llvm/MC/MCStreamer.h"
#include "llvm/MC/MCELFStreamer.h"

namespace llvm {

class MSP430TargetELFStreamer : public MCTargetStreamer {
public:
  MCELFStreamer &getStreamer();
  MSP430TargetELFStreamer(MCStreamer &S, const MCSubtargetInfo &STI);
};
}
#endif
