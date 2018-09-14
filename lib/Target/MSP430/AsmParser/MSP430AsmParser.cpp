//===- MSP430AsmParser.cpp - Parse MSP430 assembly to MCInst instructions -===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "MSP430.h"
#include "MSP430RegisterInfo.h"
#include "MCTargetDesc/MSP430MCTargetDesc.h"

#include "llvm/ADT/APInt.h"
#include "llvm/ADT/StringSwitch.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCInstBuilder.h"
#include "llvm/MC/MCParser/MCAsmLexer.h"
#include "llvm/MC/MCParser/MCParsedAsmOperand.h"
#include "llvm/MC/MCParser/MCTargetAsmParser.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/MC/MCSymbol.h"
#include "llvm/MC/MCValue.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/MathExtras.h"
#include "llvm/Support/TargetRegistry.h"

#define DEBUG_TYPE "MSP430-asm-parser"

namespace llvm {

/// Parses MSP430 assembly from a stream.
class MSP430AsmParser : public MCTargetAsmParser {
  const MCSubtargetInfo &STI;
  MCAsmParser &Parser;
  const MCRegisterInfo *MRI;

  bool MatchAndEmitInstruction(SMLoc IDLoc, unsigned &Opcode,
                               OperandVector &Operands, MCStreamer &Out,
                               uint64_t &ErrorInfo,
                               bool MatchingInlineAsm) override;

  bool ParseRegister(unsigned &RegNo, SMLoc &StartLoc, SMLoc &EndLoc) override;

  bool ParseInstruction(ParseInstructionInfo &Info, StringRef Name,
                        SMLoc NameLoc, OperandVector &Operands) override;

  bool ParseDirective(AsmToken DirectiveID) override;

  unsigned validateTargetOperandClass(MCParsedAsmOperand &Op,
                                      unsigned Kind) override;

  /// @name Auto-generated Matcher Functions
  /// {

#define GET_ASSEMBLER_HEADER
#include "MSP430GenAsmMatcher.inc"

  /// }

public:
  MSP430AsmParser(const MCSubtargetInfo &STI, MCAsmParser &Parser,
                  const MCInstrInfo &MII, const MCTargetOptions &Options)
      : MCTargetAsmParser(Options, STI, MII), STI(STI), Parser(Parser) {
    MCAsmParserExtension::Initialize(Parser);
    MRI = getContext().getRegisterInfo();

    //setAvailableFeatures(ComputeAvailableFeatures(STI.getFeatureBits()));
  }

  MCAsmParser &getParser() const { return Parser; }
  MCAsmLexer &getLexer() const { return Parser.getLexer(); }
};

/// An parsed MSP430 assembly operand.
class MSP430Operand : public MCParsedAsmOperand {
public:
  void addRegOperands(MCInst &Inst, unsigned N) const {
    assert(0 && "NYI");
  }

  void addImmOperands(MCInst &Inst, unsigned N) const {
    assert(0 && "NYI");
  }

  StringRef getToken() const {
    assert(0 && "NYI");
  }
};

bool MSP430AsmParser::MatchAndEmitInstruction(SMLoc Loc, unsigned &Opcode,
                                              OperandVector &Operands,
                                              MCStreamer &Out,
                                              uint64_t &ErrorInfo,
                                              bool MatchingInlineAsm) {
  assert(0 && "NYI");
  return false;
}

bool MSP430AsmParser::ParseRegister(unsigned &RegNo, SMLoc &StartLoc,
                                    SMLoc &EndLoc) {
  assert(0 && "NYI");
  return false;
}

bool MSP430AsmParser::ParseInstruction(ParseInstructionInfo &Info,
                                       StringRef Mnemonic, SMLoc NameLoc,
                                       OperandVector &Operands) {
  assert(0 && "NYI");
  return false;
}

bool MSP430AsmParser::ParseDirective(llvm::AsmToken DirectiveID) {
  assert(0 && "NYI");
  return false;
}

#define GET_REGISTER_MATCHER
#define GET_MATCHER_IMPLEMENTATION
#include "MSP430GenAsmMatcher.inc"

// Uses enums defined in MSP430GenAsmMatcher.inc
unsigned MSP430AsmParser::validateTargetOperandClass(MCParsedAsmOperand &AsmOp,
                                                     unsigned ExpectedKind) {
  assert(0 && "NYI");
  return Match_InvalidOperand;
}

extern "C" void LLVMInitializeMSP430AsmParser() {
  RegisterMCAsmParser<MSP430AsmParser> X(getTheMSP430Target());
}

} // end of namespace llvm
