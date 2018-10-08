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

  DecodeStatus getInstruction(MCInst &MI, uint64_t &Size,
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

static const unsigned GR8DecoderTable[] = {
  MSP430::PCB,  MSP430::SPB,  MSP430::SRB,  MSP430::CGB,
  MSP430::FPB,  MSP430::R5B,  MSP430::R6B,  MSP430::R7B,
  MSP430::R8B,  MSP430::R8B,  MSP430::R10B, MSP430::R11B,
  MSP430::R12B, MSP430::R13B, MSP430::R14B, MSP430::R15B
};

static DecodeStatus DecodeGR8RegisterClass(MCInst &MI, uint64_t RegNo,
                                           uint64_t Address,
                                           const void *Decoder) {
  if (RegNo > 15)
    return MCDisassembler::Fail;

  unsigned Reg = GR8DecoderTable[RegNo];
  MI.addOperand(MCOperand::createReg(Reg));
  return MCDisassembler::Success;
}

static const unsigned GR16DecoderTable[] = {
  MSP430::PC,  MSP430::SP,  MSP430::SR,  MSP430::CG,
  MSP430::FP,  MSP430::R5,  MSP430::R6,  MSP430::R7,
  MSP430::R8,  MSP430::R8,  MSP430::R10, MSP430::R11,
  MSP430::R12, MSP430::R13, MSP430::R14, MSP430::R15
};

static DecodeStatus DecodeGR16RegisterClass(MCInst &MI, uint64_t RegNo,
                                            uint64_t Address,
                                            const void *Decoder) {
  if (RegNo > 15)
    return MCDisassembler::Fail;

  unsigned Reg = GR16DecoderTable[RegNo];
  MI.addOperand(MCOperand::createReg(Reg));
  return MCDisassembler::Success;
}

#include "MSP430GenDisassemblerTables.inc"

DecodeStatus MSP430Disassembler::getInstruction(MCInst &MI, uint64_t &Size,
                                                ArrayRef<uint8_t> Bytes,
                                                uint64_t Address,
                                                raw_ostream &VStream,
                                                raw_ostream &CStream) const {
  uint64_t Insn;
  DecodeStatus Result;
  if (Bytes.size() < 2) {
    Size = 0;
    return MCDisassembler::Fail;
  }
  Insn = support::endian::read16le(Bytes.data());
  Result = decodeInstruction(DecoderTable16, MI, Insn, Address, this, STI);
  if (Result != MCDisassembler::Fail) {
    Size = 2;
    return Result;
  }

  // TODO 4, 6 byte instructions

  Size = 2;
  return DecodeStatus::Fail;
}
