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

  bool requiresDiffExpressionRelocations() const override;

  void applyFixup(const MCAssembler &Asm, const MCFixup &Fixup,
                  const MCValue &Target, MutableArrayRef<char> Data,
                  uint64_t Value, bool IsResolved,
                  const MCSubtargetInfo *STI) const override;

  std::unique_ptr<MCObjectTargetWriter>
  createObjectTargetWriter() const override;

  bool shouldForceRelocation(const MCAssembler &Asm, const MCFixup &Fixup,
                             const MCValue &Target) override;

  bool fixupNeedsRelaxation(const MCFixup &Fixup, uint64_t Value,
                            const MCRelaxableFragment *DF,
                            const MCAsmLayout &Layout) const override;

  bool fixupNeedsRelaxationAdvanced(const MCFixup &Fixup, bool Resolved,
                                    uint64_t Value,
                                    const MCRelaxableFragment *DF,
                                    const MCAsmLayout &Layout,
                                    const bool WasForced) const override;

  unsigned getNumFixupKinds() const override;

  const MCFixupKindInfo &getFixupKindInfo(MCFixupKind Kind) const override;

  bool mayNeedRelaxation(const MCInst &Inst,
                         const MCSubtargetInfo &STI) const override;

  void relaxInstruction(const MCInst &Inst, const MCSubtargetInfo &STI,
                        MCInst &Res) const override;


  bool writeNopData(raw_ostream &OS, uint64_t Count) const override;
};

bool MSP430AsmBackend::requiresDiffExpressionRelocations() const {
  assert(0 && "NYI");
}

void MSP430AsmBackend::applyFixup(const MCAssembler &Asm, const MCFixup &Fixup,
                                  const MCValue &Target,
                                  MutableArrayRef<char> Data,
                                  uint64_t Value, bool IsResolved,
                                  const MCSubtargetInfo *STI) const {
  assert(0 && "NYI");
}

std::unique_ptr<MCObjectTargetWriter>
MSP430AsmBackend::createObjectTargetWriter() const {
  return createMSP430ELFObjectWriter(OSABI);
}

bool MSP430AsmBackend::shouldForceRelocation(const MCAssembler &Asm,
                                             const MCFixup &Fixup,
                                             const MCValue &Target) {
  assert(0 && "NYI");
}

bool MSP430AsmBackend::fixupNeedsRelaxation(const MCFixup &Fixup,
                                            uint64_t Value,
                                            const MCRelaxableFragment *DF,
                                            const MCAsmLayout &Layout) const {
  assert(0 && "NYI");
}

bool MSP430AsmBackend::fixupNeedsRelaxationAdvanced(const MCFixup &Fixup,
                                                    bool Resolved,
                                                    uint64_t Value,
                                                    const MCRelaxableFragment *DF,
                                                    const MCAsmLayout &Layout,
                                                    const bool WasForced) const {
  assert(0 && "NYI");
}

unsigned MSP430AsmBackend::getNumFixupKinds() const {
  assert(0 && "NYI");
}

const MCFixupKindInfo &MSP430AsmBackend::getFixupKindInfo(MCFixupKind Kind) const {
  assert(0 && "NYI");
}

bool MSP430AsmBackend::mayNeedRelaxation(const MCInst &Inst,
                         const MCSubtargetInfo &STI) const {
  assert(0 && "NYI");
}

void MSP430AsmBackend::relaxInstruction(const MCInst &Inst,
                                        const MCSubtargetInfo &STI,
                                        MCInst &Res) const {
  assert(0 && "NYI");
}

bool MSP430AsmBackend::writeNopData(raw_ostream &OS, uint64_t Count) const {
  assert(0 && "NYI");
}

} // end anonymous namespace

MCAsmBackend *llvm::createMSP430MCAsmBackend(const Target &T,
                                             const MCSubtargetInfo &STI,
                                             const MCRegisterInfo &MRI,
                                             const MCTargetOptions &Options) {
  const Triple &TT = STI.getTargetTriple();
  uint8_t OSABI = MCELFObjectTargetWriter::getOSABI(TT.getOS());
  return new MSP430AsmBackend(STI, OSABI);
}
