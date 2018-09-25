//===-- MSP430ELFObjectWriter.cpp - MSP430 ELF Writer ---------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "MCTargetDesc/MSP430FixupKinds.h"
#include "MCTargetDesc/MSP430MCTargetDesc.h"
#include "llvm/MC/MCELFObjectWriter.h"
#include "llvm/MC/MCFixup.h"
#include "llvm/MC/MCObjectWriter.h"
#include "llvm/Support/ErrorHandling.h"

using namespace llvm;

namespace {
class MSP430ELFObjectWriter : public MCELFObjectTargetWriter {
public:
  MSP430ELFObjectWriter(uint8_t OSABI);

  ~MSP430ELFObjectWriter() override;

  // Return true if the given relocation must be with a symbol rather than
  // section plus offset.
  bool needsRelocateWithSymbol(const MCSymbol &Sym,
                               unsigned Type) const override {
    return true;
  }

protected:
  unsigned getRelocType(MCContext &Ctx, const MCValue &Target,
                        const MCFixup &Fixup, bool IsPCRel) const override;
};
}

MSP430ELFObjectWriter::MSP430ELFObjectWriter(uint8_t OSABI)
    : MCELFObjectTargetWriter(false, OSABI, ELF::EM_MSP430,
                              /*HasRelocationAddend*/ true) {}

MSP430ELFObjectWriter::~MSP430ELFObjectWriter() {}

unsigned MSP430ELFObjectWriter::getRelocType(MCContext &Ctx,
                                            const MCValue &Target,
                                            const MCFixup &Fixup,
                                            bool IsPCRel) const {
  assert(0 && "NYI");
}

std::unique_ptr<MCObjectTargetWriter>
llvm::createMSP430ELFObjectWriter(uint8_t OSABI) {
  return llvm::make_unique<MSP430ELFObjectWriter>(OSABI);
}
