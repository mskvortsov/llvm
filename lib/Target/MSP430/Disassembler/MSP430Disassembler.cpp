//===-- MSP430Disassembler.cpp - Disassembler for MSP430 ------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the MSP430Disassembler class.
//
//===----------------------------------------------------------------------===//

#include "MCTargetDesc/MSP430MCTargetDesc.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCDisassembler/MCDisassembler.h"
#include "llvm/MC/MCFixedLenDisassembler.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/Support/Endian.h"
#include "llvm/Support/TargetRegistry.h"

using namespace llvm;

#define DEBUG_TYPE "msp430-disassembler"

typedef MCDisassembler::DecodeStatus DecodeStatus;

namespace {
class MSP430Disassembler : public MCDisassembler {

public:
  MSP430Disassembler(const MCSubtargetInfo &STI, MCContext &Ctx)
      : MCDisassembler(STI, Ctx) {}

  DecodeStatus getInstruction(MCInst &Instr, uint64_t &Size,
                              ArrayRef<uint8_t> Bytes, uint64_t Address,
                              raw_ostream &VStream,
                              raw_ostream &CStream) const override;
};
} // end anonymous namespace

static MCDisassembler *createMSP430Disassembler(const Target &T,
                                                const MCSubtargetInfo &STI,
                                                MCContext &Ctx) {
  return new MSP430Disassembler(STI, Ctx);
}

extern "C" void LLVMInitializeMSP430Disassembler() {
  TargetRegistry::RegisterMCDisassembler(getTheMSP430Target(),
                                         createMSP430Disassembler);
}

DecodeStatus MSP430Disassembler::getInstruction(MCInst &Instr, uint64_t &Size,
                                                ArrayRef<uint8_t> Bytes,
                                                uint64_t Address,
                                                raw_ostream &VStream,
                                                raw_ostream &CStream) const {
  return DecodeStatus::Fail;
}
