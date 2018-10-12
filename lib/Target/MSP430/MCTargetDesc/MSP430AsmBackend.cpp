//===-- MSP430AsmBackend.cpp - MSP430 Assembler Backend -------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "MCTargetDesc/MSP430FixupKinds.h"
#include "MCTargetDesc/MSP430MCTargetDesc.h"
#include "llvm/ADT/APInt.h"
#include "llvm/MC/MCAsmBackend.h"
#include "llvm/MC/MCAssembler.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCDirectives.h"
#include "llvm/MC/MCELFObjectWriter.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCFixupKindInfo.h"
#include "llvm/MC/MCObjectWriter.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/MC/MCSymbol.h"
#include "llvm/MC/MCTargetOptions.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

namespace {
class MSP430AsmBackend : public MCAsmBackend {
  const MCSubtargetInfo &STI;
  uint8_t OSABI;

public:
  MSP430AsmBackend(const MCSubtargetInfo &STI, uint8_t OSABI)
      : MCAsmBackend(support::little), STI(STI), OSABI(OSABI) {}
  ~MSP430AsmBackend() override {}

  uint64_t adjustFixupValue(const MCFixup &Fixup, uint64_t Value,
                            MCContext &Ctx) const;

  void applyFixup(const MCAssembler &Asm, const MCFixup &Fixup,
                  const MCValue &Target, MutableArrayRef<char> Data,
                  uint64_t Value, bool IsResolved,
                  const MCSubtargetInfo *STI) const override;

  std::unique_ptr<MCObjectTargetWriter>
  createObjectTargetWriter() const override {
    return createMSP430ELFObjectWriter(OSABI);
  }

  bool fixupNeedsRelaxation(const MCFixup &Fixup, uint64_t Value,
                            const MCRelaxableFragment *DF,
                            const MCAsmLayout &Layout) const override {
    return false;
  }

  bool fixupNeedsRelaxationAdvanced(const MCFixup &Fixup, bool Resolved,
                                    uint64_t Value,
                                    const MCRelaxableFragment *DF,
                                    const MCAsmLayout &Layout,
                                    const bool WasForced) const override {
    return false;
  }

  unsigned getNumFixupKinds() const override {
    return MSP430::NumTargetFixupKinds;
  }

  const MCFixupKindInfo &getFixupKindInfo(MCFixupKind Kind) const override;

  bool mayNeedRelaxation(const MCInst &Inst,
                         const MCSubtargetInfo &STI) const override {
    return false;
  }

  void relaxInstruction(const MCInst &Inst, const MCSubtargetInfo &STI,
                        MCInst &Res) const override {}

  bool writeNopData(raw_ostream &OS, uint64_t Count) const override;
};

uint64_t MSP430AsmBackend::adjustFixupValue(const MCFixup &Fixup,
                                            uint64_t Value,
                                            MCContext &Ctx) const {
  unsigned Kind = Fixup.getKind();
  switch (Kind) {
  case MSP430::fixup_10_pcrel: {
    if (Value & 0x1)
      Ctx.reportError(Fixup.getLoc(), "fixup value must be 2-byte aligned");

    // Offset is signed
    int16_t Offset = Value;
    // Jumps are in words
    Offset >>= 1;
    // PC points to the next instruction so decrement by one
    --Offset;

    if (Offset < -512 || Offset > 511)
      Ctx.reportError(Fixup.getLoc(), "fixup value out of range");

    // Mask 10 bits
    Offset &= 0x3ff;

    return Offset;
  }
  default:
    return Value;
  }
}

void MSP430AsmBackend::applyFixup(const MCAssembler &Asm, const MCFixup &Fixup,
                                  const MCValue &Target,
                                  MutableArrayRef<char> Data,
                                  uint64_t Value, bool IsResolved,
                                  const MCSubtargetInfo *STI) const {
  Value = adjustFixupValue(Fixup, Value, Asm.getContext());
  MCFixupKindInfo Info = getFixupKindInfo(Fixup.getKind());
  if (!Value)
    return; // Doesn't change encoding.

  // Shift the value into position.
  Value <<= Info.TargetOffset;

  unsigned Offset = Fixup.getOffset();
  unsigned NumBytes = alignTo(Info.TargetSize + Info.TargetOffset, 8) / 8;

  assert(Offset + NumBytes <= Data.size() && "Invalid fixup offset!");

  // For each byte of the fragment that the fixup touches, mask in the
  // bits from the fixup value.
  for (unsigned i = 0; i != NumBytes; ++i) {
    Data[Offset + i] |= uint8_t((Value >> (i * 8)) & 0xff);
  }
}

const MCFixupKindInfo &MSP430AsmBackend::getFixupKindInfo(MCFixupKind Kind) const {
  const static MCFixupKindInfo Infos[MSP430::NumTargetFixupKinds] = {
    {"fixup_32", 0, 32, 0},
    {"fixup_10_pcrel", 0, 10, MCFixupKindInfo::FKF_IsPCRel},
    {"fixup_16", 0, 16, 0},
    {"fixup_16_pcrel", 0, 16, MCFixupKindInfo::FKF_IsPCRel},
    {"fixup_16_byte", 0, 16, 0},
    {"fixup_16_pcrel_byte", 0, 16, MCFixupKindInfo::FKF_IsPCRel},
    {"fixup_2x_pcrel", 0, 0, MCFixupKindInfo::FKF_IsPCRel},
    {"fixup_rl_pcrel", 0, 0, MCFixupKindInfo::FKF_IsPCRel},
    {"fixup_8", 0, 8, 0},
    {"fixup_sym_diff", 0, 0, 0},
  };

  if (Kind < FirstTargetFixupKind)
    return MCAsmBackend::getFixupKindInfo(Kind);

  return Infos[Kind - FirstTargetFixupKind];
}

bool MSP430AsmBackend::writeNopData(raw_ostream &OS, uint64_t Count) const {
  if ((Count % 2) != 0)
    return false;

  // The canonical nop on MSP430 is mov #0, r3
  uint64_t NopCount = Count / 2;
  while (NopCount--)
    OS.write("\x03\x43", 2);

  return true;
}

} // end anonymous namespace

MCAsmBackend *llvm::createMSP430MCAsmBackend(const Target &T,
                                             const MCSubtargetInfo &STI,
                                             const MCRegisterInfo &MRI,
                                             const MCTargetOptions &Options) {
  return new MSP430AsmBackend(STI, ELF::ELFOSABI_STANDALONE);
}
