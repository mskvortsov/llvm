//===-- MSP430MCCodeEmitter.cpp - Convert MSP430 code to machine code -----===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the MSP430MCCodeEmitter class.
//
//===----------------------------------------------------------------------===//

#include "MCTargetDesc/MSP430MCTargetDesc.h"

#include "llvm/ADT/APFloat.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/MC/MCCodeEmitter.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCFixup.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/Support/Endian.h"
#include "llvm/Support/EndianStream.h"
#include "llvm/Support/raw_ostream.h"

#define DEBUG_TYPE "mccodeemitter"

namespace llvm {

class MSP430MCCodeEmitter : public MCCodeEmitter {
  MSP430MCCodeEmitter(const MSP430MCCodeEmitter &) = delete;
  void operator=(const MSP430MCCodeEmitter &) = delete;
  MCContext &Ctx;
  MCInstrInfo const &MCII;

public:
  MSP430MCCodeEmitter(MCContext &ctx, MCInstrInfo const &MCII)
      : Ctx(ctx), MCII(MCII) {}

  ~MSP430MCCodeEmitter() override {}

  void encodeInstruction(const MCInst &MI, raw_ostream &OS,
                         SmallVectorImpl<MCFixup> &Fixups,
                         const MCSubtargetInfo &STI) const override;

  /// TableGen'erated function for getting the binary encoding for an
  /// instruction.
  uint64_t getBinaryCodeForInstr(const MCInst &MI,
                                 SmallVectorImpl<MCFixup> &Fixups,
                                 const MCSubtargetInfo &STI) const;

  /// Returns the binary encoding of operand.
  ///
  /// If the machine operand requires relocation, the relocation is recorded
  /// and zero is returned.
  unsigned getMachineOpValue(const MCInst &MI, const MCOperand &MO,
                             SmallVectorImpl<MCFixup> &Fixups,
                             const MCSubtargetInfo &STI) const;

  unsigned getMemOperandValue(const MCInst &MI, unsigned Op,
                              SmallVectorImpl<MCFixup> &Fixups,
                              const MCSubtargetInfo &STI) const;
};

void MSP430MCCodeEmitter::encodeInstruction(const MCInst &MI, raw_ostream &OS,
                                            SmallVectorImpl<MCFixup> &Fixups,
                                            const MCSubtargetInfo &STI) const {
  const MCInstrDesc &Desc = MCII.get(MI.getOpcode());
  // Get byte count of instruction.
  unsigned Size = Desc.getSize();

  uint64_t BinaryOpCode = getBinaryCodeForInstr(MI, Fixups, STI);
  const uint16_t *Words = reinterpret_cast<uint16_t const *>(&BinaryOpCode);
  size_t WordCount = Size / 2;

  for (size_t i = 0; i < WordCount; ++i) {
    uint16_t Word = Words[i];
    support::endian::write(OS, Word, support::little);
  }
}

unsigned MSP430MCCodeEmitter::getMachineOpValue(const MCInst &MI,
                                                const MCOperand &MO,
                                                SmallVectorImpl<MCFixup> &Fixups,
                                                const MCSubtargetInfo &STI) const {
  if (MO.isReg()) {
    unsigned Reg = Ctx.getRegisterInfo()->getEncodingValue(MO.getReg());
    return Reg;
  }

  assert(0 && "NYI");
}

unsigned MSP430MCCodeEmitter::getMemOperandValue(const MCInst &MI,
                                                 unsigned Op,
                                                 SmallVectorImpl<MCFixup> &Fixups,
                                                 const MCSubtargetInfo &STI) const {
  const MCOperand &MO = MI.getOperand(Op);
  assert(MO.isReg() && "Register operand expected");
  return Ctx.getRegisterInfo()->getEncodingValue(MO.getReg());
}

MCCodeEmitter *createMSP430MCCodeEmitter(const MCInstrInfo &MCII,
                                         const MCRegisterInfo &MRI,
                                         MCContext &Ctx) {
  return new MSP430MCCodeEmitter(Ctx, MCII);
}

#include "MSP430GenMCCodeEmitter.inc"

} // end of namespace llvm
