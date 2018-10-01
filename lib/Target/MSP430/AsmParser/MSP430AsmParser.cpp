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

#define DEBUG_TYPE "msp430-asm-parser"

namespace llvm {

/// Parses MSP430 assembly from a stream.
class MSP430AsmParser : public MCTargetAsmParser {
private:
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

  bool parseJccInstruction(ParseInstructionInfo &Info, StringRef Name,
                           SMLoc NameLoc, OperandVector &Operands);

private:
  bool ParseOperand(OperandVector &Operands);

  bool ParseLiteralValues(unsigned Size, SMLoc L);

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

/// A parsed MSP430 assembly operand.
class MSP430Operand : public MCParsedAsmOperand {
private:
  typedef MCParsedAsmOperand Base;

  enum KindTy {
    k_Immediate,
    k_Register,
    k_Token,
    k_Memory
  } Kind;

public:
  struct RegisterImmediate {
    unsigned Reg;
    const MCExpr *Imm;
  };
  union {
    StringRef Tok;
    RegisterImmediate RegImm;
  };

  SMLoc Start, End;

public:
  MSP430Operand(StringRef Tok, SMLoc const &S)
      : Base(), Kind(k_Token), Tok(Tok), Start(S), End(S) {}
  MSP430Operand(unsigned Reg, SMLoc const &S, SMLoc const &E)
      : Base(), Kind(k_Register), RegImm({Reg, nullptr}), Start(S), End(E) {}
  MSP430Operand(MCExpr const *Imm, SMLoc const &S, SMLoc const &E)
      : Base(), Kind(k_Immediate), RegImm({0, Imm}), Start(S), End(E) {}
  MSP430Operand(unsigned Reg, MCExpr const *Imm, SMLoc const &S, SMLoc const &E)
      : Base(), Kind(k_Memory), RegImm({Reg, Imm}), Start(S), End(E) {}

public:
  void addRegOperands(MCInst &Inst, unsigned N) const {
    assert(Kind == k_Register && "Unexpected operand kind");
    assert(N == 1 && "Invalid number of operands!");

    Inst.addOperand(MCOperand::createReg(getReg()));
  }

  void addExpr(MCInst &Inst, const MCExpr *Expr) const {
    // Add as immediate when possible
    if (!Expr)
      Inst.addOperand(MCOperand::createImm(0));
    else if (const MCConstantExpr *CE = dyn_cast<MCConstantExpr>(Expr))
      Inst.addOperand(MCOperand::createImm(CE->getValue()));
    else
      Inst.addOperand(MCOperand::createExpr(Expr));
  }

  void addImmOperands(MCInst &Inst, unsigned N) const {
    assert(Kind == k_Immediate && "Unexpected operand kind");
    assert(N == 1 && "Invalid number of operands!");

    const MCExpr *Expr = getImm();
    addExpr(Inst, Expr);
  }

  /// Adds the contained reg+imm operand to an instruction.
  void addMemOperands(MCInst &Inst, unsigned N) const {
    assert(Kind == k_Memory && "Unexpected operand kind");
    assert(N == 2 && "Invalid number of operands");

    Inst.addOperand(MCOperand::createReg(getReg()));
    addExpr(Inst, getImm());
  }

  bool isReg() const { return Kind == k_Register; }
  bool isImm() const { return Kind == k_Immediate; }
  bool isToken() const { return Kind == k_Token; }
  bool isMem() const { return Kind == k_Memory; }

  StringRef getToken() const {
    assert(Kind == k_Token && "Invalid access!");
    return Tok;
  }

  unsigned getReg() const {
    assert((Kind == k_Register || Kind == k_Memory) && "Invalid access!");
    return RegImm.Reg;
  }

  const MCExpr *getImm() const {
    assert((Kind == k_Immediate || Kind == k_Memory) && "Invalid access!");
    return RegImm.Imm;
  }

  static std::unique_ptr<MSP430Operand> CreateToken(StringRef Str, SMLoc S) {
    return make_unique<MSP430Operand>(Str, S);
  }

  static std::unique_ptr<MSP430Operand> CreateReg(unsigned RegNum, SMLoc S,
                                                  SMLoc E) {
    return make_unique<MSP430Operand>(RegNum, S, E);
  }

  static std::unique_ptr<MSP430Operand> CreateImm(const MCExpr *Val, SMLoc S,
                                                  SMLoc E) {
    return make_unique<MSP430Operand>(Val, S, E);
  }

  static std::unique_ptr<MSP430Operand> CreateMem(unsigned RegNum,
                                                     const MCExpr *Val,
                                                     SMLoc S, SMLoc E) {
    return make_unique<MSP430Operand>(RegNum, Val, S, E);
  }

  void makeToken(StringRef Token) {
    Kind = k_Token;
    Tok = Token;
  }

  void makeReg(unsigned RegNo) {
    Kind = k_Register;
    RegImm = {RegNo, nullptr};
  }

  void makeImm(MCExpr const *Ex) {
    Kind = k_Immediate;
    RegImm = {0, Ex};
  }

  void makeMem(unsigned RegNo, MCExpr const *Imm) {
    Kind = k_Memory;
    RegImm = {RegNo, Imm};
  }

  SMLoc getStartLoc() const { return Start; }
  SMLoc getEndLoc() const { return End; }

  virtual void print(raw_ostream &O) const {
    switch (Kind) {
    case k_Token:
      O << "Token " << getToken();
      break;
    case k_Register:
      O << "Register " << getReg();
      break;
    case k_Immediate:
      O << "Immediate " << *getImm();
      break;
    case k_Memory:
      O << "Memory ";
      if (getImm())
        O << *getImm();
      O << "(" << getReg() << ")";
      break;
    }
  }
};

bool MSP430AsmParser::MatchAndEmitInstruction(SMLoc Loc, unsigned &Opcode,
                                              OperandVector &Operands,
                                              MCStreamer &Out,
                                              uint64_t &ErrorInfo,
                                              bool MatchingInlineAsm) {
  MCInst Inst;
  unsigned MatchResult =
      MatchInstructionImpl(Operands, Inst, ErrorInfo, MatchingInlineAsm);

  switch (MatchResult) {
  case Match_Success:
    Inst.setLoc(Loc);
    Out.EmitInstruction(Inst, STI);
    return false;
  case Match_MnemonicFail:
    return Error(Loc, "invalid instruction");
  default:
    return true;
  }
}

// Auto-generated by TableGen
static unsigned MatchRegisterName(StringRef Name);
static unsigned MatchRegisterAltName(StringRef Name);

bool MSP430AsmParser::ParseRegister(unsigned &RegNo, SMLoc &StartLoc,
                                    SMLoc &EndLoc) {
  if (getLexer().getKind() == AsmToken::Identifier) {
    StringRef Name = getLexer().getTok().getIdentifier();
    RegNo = MatchRegisterName(Name);
    if (RegNo == MSP430::NoRegister) {
      RegNo = MatchRegisterAltName(Name);
      if (RegNo == MSP430::NoRegister)
        return true;
    }

    AsmToken const &T = getParser().getTok();
    StartLoc = T.getLoc();
    EndLoc = T.getEndLoc();
    getLexer().Lex(); // eat register token

    return false;
  }

  return Error(StartLoc, "invalid register name");
}

bool MSP430AsmParser::parseJccInstruction(ParseInstructionInfo &Info,
                                          StringRef Name, SMLoc NameLoc,
                                          OperandVector &Operands) {
  if (!Name.startswith_lower("j"))
    return true;

  StringRef CC = Name.drop_front().lower();
  unsigned CondCode;
  if (CC == "ne" || CC == "nz")
    CondCode = MSP430CC::COND_NE;
  else if (CC == "eq" || CC == "z")
    CondCode = MSP430CC::COND_E;
  else if (CC == "lo" || CC == "nc")
    CondCode = MSP430CC::COND_LO;
  else if (CC == "hs" || CC == "c")
    CondCode = MSP430CC::COND_HS;
  else if (CC == "n")
    CondCode = MSP430CC::COND_N;
  else if (CC == "ge")
    CondCode = MSP430CC::COND_GE;
  else if (CC == "l")
    CondCode = MSP430CC::COND_L;
  else if (CC == "mp")
    CondCode = MSP430CC::COND_INVALID;
  else
    return Error(NameLoc, "unknown instruction");

  if (CondCode == MSP430CC::COND_INVALID)
    Operands.push_back(MSP430Operand::CreateToken("jmp", NameLoc));
  else {
    Operands.push_back(MSP430Operand::CreateToken("j", NameLoc));
    const MCExpr *CCode = MCConstantExpr::create(CondCode, getContext());
    Operands.push_back(MSP430Operand::CreateImm(CCode, SMLoc(), SMLoc()));
  }

  const MCExpr *Val;
  if (getParser().parseExpression(Val))
    return Error(getLexer().getLoc(), "expected expression operand");

  Operands.push_back(MSP430Operand::CreateImm(Val, SMLoc(), SMLoc()));

  if (getLexer().isNot(AsmToken::EndOfStatement)) {
    SMLoc Loc = getLexer().getLoc();
    getParser().eatToEndOfStatement();
    return Error(Loc, "unexpected token");
  }

  getParser().Lex(); // Consume the EndOfStatement.
  return false;
}

bool MSP430AsmParser::ParseInstruction(ParseInstructionInfo &Info,
                                       StringRef Name, SMLoc NameLoc,
                                       OperandVector &Operands) {
  // Drop .w suffix
  if (Name.endswith_lower(".w"))
    Name = Name.drop_back(2);

  if (!parseJccInstruction(Info, Name, NameLoc, Operands))
    return false;

  // First operand is instruction mnemonic
  Operands.push_back(MSP430Operand::CreateToken(Name, NameLoc));

  // If there are no more operands, then finish
  if (getLexer().is(AsmToken::EndOfStatement))
    return false;

  // Parse first operand
  if (ParseOperand(Operands))
    return true;

  // Parse second operand if any
  if (getLexer().is(AsmToken::Comma)) {
    getLexer().Lex(); // eat Comma
    if (ParseOperand(Operands))
      return true;
  }

  if (getLexer().isNot(AsmToken::EndOfStatement)) {
    SMLoc Loc = getLexer().getLoc();
    getParser().eatToEndOfStatement();
    return Error(Loc, "unexpected token");
  }

  getParser().Lex(); // Consume the EndOfStatement.
  return false;
}

bool MSP430AsmParser::ParseDirective(AsmToken DirectiveID) {
  StringRef IDVal = DirectiveID.getIdentifier();
  if (IDVal.lower() == ".long") {
    ParseLiteralValues(4, DirectiveID.getLoc());
  } else if (IDVal.lower() == ".word" || IDVal.lower() == ".short") {
    ParseLiteralValues(2, DirectiveID.getLoc());
  } else if (IDVal.lower() == ".byte") {
    ParseLiteralValues(1, DirectiveID.getLoc());
  }
  return true;
}

bool MSP430AsmParser::ParseOperand(OperandVector &Operands) {
  switch (getLexer().getKind()) {
    default: return true;
    case AsmToken::Identifier: {
      // try rN
      unsigned RegNo;
      SMLoc StartLoc, EndLoc;
      if (!ParseRegister(RegNo, StartLoc, EndLoc)) {
        Operands.push_back(MSP430Operand::CreateReg(RegNo, StartLoc, EndLoc));
        return false;
      }
      LLVM_FALLTHROUGH;
    }
    case AsmToken::Integer:
    case AsmToken::Plus:
    case AsmToken::Minus: {
      SMLoc StartLoc = getParser().getTok().getLoc();
      const MCExpr *Val;
      // try constexpr[(rN)]
      if (!getParser().parseExpression(Val)) {
        unsigned RegNo = MSP430::PC;
        SMLoc EndLoc = getParser().getTok().getLoc();
        // try (rN)
        if (getLexer().getKind() == AsmToken::LParen) {
          getLexer().Lex(); // eat LParen
          SMLoc RegStartLoc;
          if (ParseRegister(RegNo, RegStartLoc, EndLoc))
            return true;
          if (getLexer().getKind() != AsmToken::RParen)
            return true;
          EndLoc = getParser().getTok().getEndLoc();
          getLexer().Lex(); // eat RParen
        }
        Operands.push_back(MSP430Operand::CreateMem(RegNo, Val, StartLoc,
          EndLoc));
        return false;
      }
      return true;
    }
    case AsmToken::Amp: {
      // try &constexpr
      SMLoc StartLoc = getParser().getTok().getLoc();
      getLexer().Lex(); // eat Amp
      const MCExpr *Val;
      if (!getParser().parseExpression(Val)) {
        SMLoc EndLoc = getParser().getTok().getLoc();
        Operands.push_back(MSP430Operand::CreateMem(MSP430::SR, Val, StartLoc,
          EndLoc));
        return false;
      }
      return true;
    }
    case AsmToken::At: {
      // try @rN[+]
      SMLoc StartLoc = getParser().getTok().getLoc();
      getLexer().Lex(); // eat At
      unsigned RegNo;
      SMLoc RegStartLoc, EndLoc;
      if (ParseRegister(RegNo, RegStartLoc, EndLoc))
        return true;
      if (getLexer().getKind() == AsmToken::Plus) {
        SMLoc PlusLoc = getParser().getTok().getLoc();
        Operands.push_back(MSP430Operand::CreateToken("@", StartLoc));
        Operands.push_back(MSP430Operand::CreateReg(RegNo, RegStartLoc, EndLoc));
        Operands.push_back(MSP430Operand::CreateToken("+", PlusLoc));
        getLexer().Lex(); // eat Plus
        return false;
      }
      const MCExpr *Zero = MCConstantExpr::create(0, getContext());
      Operands.push_back(MSP430Operand::CreateMem(RegNo, Zero, RegStartLoc, EndLoc));
      return false;
    }
    case AsmToken::Hash:
      // try #constexpr
      SMLoc StartLoc = getParser().getTok().getLoc();
      getLexer().Lex(); // eat Hash
      const MCExpr *Val;
      if (!getParser().parseExpression(Val)) {
        SMLoc EndLoc = getParser().getTok().getLoc();
        Operands.push_back(MSP430Operand::CreateImm(Val, StartLoc, EndLoc));
        return false;
      }
      return true;
  }
}

bool MSP430AsmParser::ParseLiteralValues(unsigned Size, SMLoc L) {
  auto parseOne = [&]() -> bool {
    const MCExpr *Value;
    if (getParser().parseExpression(Value))
      return true;
    getParser().getStreamer().EmitValue(Value, Size, L);
    return false;
  };
  return (parseMany(parseOne));
}

extern "C" void LLVMInitializeMSP430AsmParser() {
  RegisterMCAsmParser<MSP430AsmParser> X(getTheMSP430Target());
}

#define GET_REGISTER_MATCHER
#define GET_MATCHER_IMPLEMENTATION
#include "MSP430GenAsmMatcher.inc"

unsigned convertGR16ToGR8(unsigned Reg) {
  switch (Reg) {
  default:
    llvm_unreachable("Unknown GR16 register");
  case MSP430::PC:  return MSP430::PCB;
  case MSP430::SP:  return MSP430::SPB;
  case MSP430::SR:  return MSP430::SRB;
  case MSP430::CG:  return MSP430::CGB;
  case MSP430::FP:  return MSP430::FPB;
  case MSP430::R5:  return MSP430::R5B;
  case MSP430::R6:  return MSP430::R6B;
  case MSP430::R7:  return MSP430::R7B;
  case MSP430::R8:  return MSP430::R8B;
  case MSP430::R9:  return MSP430::R9B;
  case MSP430::R10: return MSP430::R10B;
  case MSP430::R11: return MSP430::R11B;
  case MSP430::R12: return MSP430::R12B;
  case MSP430::R13: return MSP430::R13B;
  case MSP430::R14: return MSP430::R14B;
  case MSP430::R15: return MSP430::R15B;
  }
}

unsigned MSP430AsmParser::validateTargetOperandClass(MCParsedAsmOperand &AsmOp,
                                                     unsigned Kind) {
  MSP430Operand &Op = static_cast<MSP430Operand &>(AsmOp);

  if (!Op.isReg())
    return Match_InvalidOperand;

  unsigned Reg = Op.getReg();
  bool isGR16 =
      MSP430MCRegisterClasses[MSP430::GR16RegClassID].contains(Reg);

  if (isGR16 && (Kind == MCK_GR8)) {
    Op.RegImm.Reg = convertGR16ToGR8(Reg);
    return Match_Success;
  }

  return Match_InvalidOperand;
}

} // end of namespace llvm
