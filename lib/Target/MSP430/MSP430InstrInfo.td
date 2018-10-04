//===-- MSP430InstrInfo.td - MSP430 Instruction defs -------*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source 
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file describes the MSP430 instructions in TableGen format.
//
//===----------------------------------------------------------------------===//

include "MSP430InstrFormats.td"

//===----------------------------------------------------------------------===//
// Type Constraints.
//===----------------------------------------------------------------------===//
class SDTCisI8<int OpNum> : SDTCisVT<OpNum, i8>;
class SDTCisI16<int OpNum> : SDTCisVT<OpNum, i16>;

//===----------------------------------------------------------------------===//
// Type Profiles.
//===----------------------------------------------------------------------===//
def SDT_MSP430Call         : SDTypeProfile<0, -1, [SDTCisVT<0, iPTR>]>;
def SDT_MSP430CallSeqStart : SDCallSeqStart<[SDTCisVT<0, i16>,
                                             SDTCisVT<1, i16>]>;
def SDT_MSP430CallSeqEnd   : SDCallSeqEnd<[SDTCisVT<0, i16>, SDTCisVT<1, i16>]>;
def SDT_MSP430Wrapper      : SDTypeProfile<1, 1, [SDTCisSameAs<0, 1>,
                                                  SDTCisPtrTy<0>]>;
def SDT_MSP430Cmp          : SDTypeProfile<0, 2, [SDTCisSameAs<0, 1>]>;
def SDT_MSP430BrCC         : SDTypeProfile<0, 2, [SDTCisVT<0, OtherVT>,
                                                  SDTCisVT<1, i8>]>;
def SDT_MSP430SelectCC     : SDTypeProfile<1, 3, [SDTCisSameAs<0, 1>,
                                                  SDTCisSameAs<1, 2>, 
                                                  SDTCisVT<3, i8>]>;
def SDT_MSP430Shift        : SDTypeProfile<1, 2, [SDTCisSameAs<0, 1>,
                                                  SDTCisI8<2>]>;
def SDT_MSP430DAdd         : SDTypeProfile<1, 2, [SDTCisSameAs<0, 1>,
                                                  SDTCisSameAs<0, 2>,
                                                  SDTCisInt<0>]>;

//===----------------------------------------------------------------------===//
// MSP430 Specific Node Definitions.
//===----------------------------------------------------------------------===//
def MSP430retflag  : SDNode<"MSP430ISD::RET_FLAG", SDTNone,
                       [SDNPHasChain, SDNPOptInGlue, SDNPVariadic]>;
def MSP430retiflag : SDNode<"MSP430ISD::RETI_FLAG", SDTNone,
                       [SDNPHasChain, SDNPOptInGlue, SDNPVariadic]>;

def MSP430rra     : SDNode<"MSP430ISD::RRA", SDTIntUnaryOp, []>;
def MSP430rla     : SDNode<"MSP430ISD::RLA", SDTIntUnaryOp, []>;
def MSP430rrc     : SDNode<"MSP430ISD::RRC", SDTIntUnaryOp, []>;

def MSP430call    : SDNode<"MSP430ISD::CALL", SDT_MSP430Call,
                     [SDNPHasChain, SDNPOutGlue, SDNPOptInGlue, SDNPVariadic]>;
def MSP430callseq_start :
                 SDNode<"ISD::CALLSEQ_START", SDT_MSP430CallSeqStart,
                        [SDNPHasChain, SDNPOutGlue]>;
def MSP430callseq_end :
                 SDNode<"ISD::CALLSEQ_END",   SDT_MSP430CallSeqEnd,
                        [SDNPHasChain, SDNPOptInGlue, SDNPOutGlue]>;
def MSP430Wrapper : SDNode<"MSP430ISD::Wrapper", SDT_MSP430Wrapper>;
def MSP430cmp     : SDNode<"MSP430ISD::CMP", SDT_MSP430Cmp, [SDNPOutGlue]>;
def MSP430brcc    : SDNode<"MSP430ISD::BR_CC", SDT_MSP430BrCC,
                            [SDNPHasChain, SDNPInGlue]>;
def MSP430selectcc: SDNode<"MSP430ISD::SELECT_CC", SDT_MSP430SelectCC,
                            [SDNPInGlue]>;
def MSP430shl     : SDNode<"MSP430ISD::SHL", SDT_MSP430Shift, []>;
def MSP430sra     : SDNode<"MSP430ISD::SRA", SDT_MSP430Shift, []>;
def MSP430srl     : SDNode<"MSP430ISD::SRL", SDT_MSP430Shift, []>;
def MSP430dadd    : SDNode<"MSP430ISD::DADD", SDT_MSP430DAdd, []>;

//===----------------------------------------------------------------------===//
// MSP430 Operand Definitions.
//===----------------------------------------------------------------------===//

def MemAsmOperand : AsmOperandClass {
  let Name = "Mem";
}

// Address operands
def memsrc : Operand<i16> {
  let PrintMethod = "printSrcMemOperand";
  let MIOperandInfo = (ops GR16, i16imm);
  let ParserMatchClass = MemAsmOperand;
  let EncoderMethod = "getMemOperandValue";
}

def memdst : Operand<i16> {
  let PrintMethod = "printSrcMemOperand";
  let MIOperandInfo = (ops GR16, i16imm);
  let ParserMatchClass = MemAsmOperand;
  let EncoderMethod = "getMemOperandValue";
}

// Short jump targets have OtherVT type and are printed as pcrel imm values.
def jmptarget : Operand<OtherVT> {
  let PrintMethod = "printPCRelImmOperand";
  let EncoderMethod = "getPCRelImmValue";
}

// Operand for printing out a condition code.
def cc : Operand<i8> {
  let PrintMethod = "printCCOperand";
  let EncoderMethod = "getCCValue";
}

def CGImmAsmOperand : AsmOperandClass {
  let Name = "CGImm";
  let RenderMethod = "addImmOperands";
}

def cg8imm : Operand<i8>,
             ImmLeaf<i8, [{return Imm == 0 || Imm == 1 || Imm == 2 ||
                                  Imm == 4 || Imm == 8 || Imm == -1;}]> {
  let ParserMatchClass = CGImmAsmOperand;
  let EncoderMethod = "getCGImmOpValue";
}

def cg16imm : Operand<i16>,
              ImmLeaf<i16, [{return Imm == 0 || Imm == 1 || Imm == 2 ||
                                    Imm == 4 || Imm == 8 || Imm == -1;}]> {
  let ParserMatchClass = CGImmAsmOperand;
  let EncoderMethod = "getCGImmOpValue";
}

//===----------------------------------------------------------------------===//
// MSP430 Complex Pattern Definitions.
//===----------------------------------------------------------------------===//

def addr : ComplexPattern<iPTR, 2, "SelectAddr", [], []>;

//===----------------------------------------------------------------------===//
// Pattern Fragments
def zextloadi16i8 : PatFrag<(ops node:$ptr), (i16 (zextloadi8 node:$ptr))>;
def  extloadi16i8 : PatFrag<(ops node:$ptr), (i16 ( extloadi8 node:$ptr))>;
def bic : PatFrag<(ops node:$lhs, node:$rhs), (and node:$lhs, (not node:$rhs))>;
def and_su : PatFrag<(ops node:$lhs, node:$rhs), (and node:$lhs, node:$rhs), [{
  return N->hasOneUse();
}]>;
//===----------------------------------------------------------------------===//
// Instruction list..

// ADJCALLSTACKDOWN/UP implicitly use/def SP because they may be expanded into
// a stack adjustment and the codegen must know that they may modify the stack
// pointer before prolog-epilog rewriting occurs.
// Pessimistically assume ADJCALLSTACKDOWN / ADJCALLSTACKUP will become
// sub / add which can clobber SR.
let isCodeGenOnly = 1, Defs = [SP, SR], Uses = [SP] in {
def ADJCALLSTACKDOWN : Pseudo<(outs), (ins i16imm:$amt1, i16imm:$amt2),
                              "#ADJCALLSTACKDOWN $amt1 $amt2",
                              [(MSP430callseq_start timm:$amt1, timm:$amt2)]>;
def ADJCALLSTACKUP   : Pseudo<(outs), (ins i16imm:$amt1, i16imm:$amt2),
                              "#ADJCALLSTACKUP $amt1 $amt2",
                              [(MSP430callseq_end timm:$amt1, timm:$amt2)]>;
}

let isCodeGenOnly = 1, Defs = [SR], Uses = [SP] in {
def ADDframe : Pseudo<(outs GR16:$dst), (ins i16imm:$base, i16imm:$offset),
                      "# ADDframe PSEUDO", []>;
}

let isCodeGenOnly = 1, usesCustomInserter = 1 in {
  let Uses = [SR] in {
  def Select8  : Pseudo<(outs GR8:$dst), (ins GR8:$src, GR8:$src2, i8imm:$cc),
                        "# Select8 PSEUDO",
                        [(set GR8:$dst,
                          (MSP430selectcc GR8:$src, GR8:$src2, imm:$cc))]>;
  def Select16 : Pseudo<(outs GR16:$dst), (ins GR16:$src, GR16:$src2, i8imm:$cc),
                        "# Select16 PSEUDO",
                        [(set GR16:$dst,
                          (MSP430selectcc GR16:$src, GR16:$src2, imm:$cc))]>;
  }
  let Defs = [SR] in {
  def Shl8     : Pseudo<(outs GR8:$dst), (ins GR8:$src, GR8:$cnt),
                        "# Shl8 PSEUDO",
                        [(set GR8:$dst, (MSP430shl GR8:$src, GR8:$cnt))]>;
  def Shl16    : Pseudo<(outs GR16:$dst), (ins GR16:$src, GR8:$cnt),
                        "# Shl16 PSEUDO",
                        [(set GR16:$dst, (MSP430shl GR16:$src, GR8:$cnt))]>;
  def Sra8     : Pseudo<(outs GR8:$dst), (ins GR8:$src, GR8:$cnt),
                        "# Sra8 PSEUDO",
                        [(set GR8:$dst, (MSP430sra GR8:$src, GR8:$cnt))]>;
  def Sra16    : Pseudo<(outs GR16:$dst), (ins GR16:$src, GR8:$cnt),
                        "# Sra16 PSEUDO",
                        [(set GR16:$dst, (MSP430sra GR16:$src, GR8:$cnt))]>;
  def Srl8     : Pseudo<(outs GR8:$dst), (ins GR8:$src, GR8:$cnt),
                        "# Srl8 PSEUDO",
                        [(set GR8:$dst, (MSP430srl GR8:$src, GR8:$cnt))]>;
  def Srl16    : Pseudo<(outs GR16:$dst), (ins GR16:$src, GR8:$cnt),
                        "# Srl16 PSEUDO",
                        [(set GR16:$dst, (MSP430srl GR16:$src, GR8:$cnt))]>;

  }
}

//===----------------------------------------------------------------------===//
//  Control Flow Instructions...
//

// FIXME: Provide proper encoding!
let isReturn = 1, isTerminator = 1, isBarrier = 1 in {
  def RET  : IForm16<0b0100, DstReg, SrcPostInc, 2,
                     (outs), (ins), "ret",  [(MSP430retflag)]> {
    let src = 1;
    let dst = 0;
  }
  def RETI : IIForm16<0b110, SrcReg, 2,
                      (outs), (ins), "reti", [(MSP430retiflag)]> {
    let src = 0;
  }
}

let isBranch = 1, isTerminator = 1 in {

// FIXME: expand opcode & cond field for branches!

// Direct branch
let isBarrier = 1 in {
  // Short branch
  def JMP : CJForm<(outs), (ins jmptarget:$dst),
                   "jmp\t$dst",
                   [(br bb:$dst)]> {
    let cond = 0b111;
  }
  let isIndirectBranch = 1, dst = 0 in {
    // Long branches
    def Bi  : I16ri<0b0100, (outs), (ins i16imm:$src),
                    "br\t$src",
                    [(brind tblockaddress:$src)]>;
    def Br  : I16rr<0b0100, (outs), (ins GR16:$src),
                    "br\t$src",
                    [(brind GR16:$src)]>;
    def Bm  : I16rm<0b0100, (outs), (ins memsrc:$src),
                    "br\t$src",
                    [(brind (load addr:$src))]>;
  }
}

// Conditional branches
let Uses = [SR] in
  def JCC : CJForm<(outs), (ins jmptarget:$dst, cc:$cond),
                   "j$cond\t$dst",
                   [(MSP430brcc bb:$dst, imm:$cond)]>;
} // isBranch, isTerminator

//===----------------------------------------------------------------------===//
//  Call Instructions...
//
// All calls clobber the non-callee saved registers. SPW is marked as
// a use to prevent stack-pointer assignments that appear immediately
// before calls from potentially appearing dead. Uses for argument
// registers are added manually.
let isCall = 1,
    Defs = [R11, R12, R13, R14, R15, SR],
    Uses = [SP] in {
  def CALLi     : II16i<0b101,
                        (outs), (ins i16imm:$dst),
                        "call\t$dst", [(MSP430call imm:$dst)]>;
  def CALLr     : II16r<0b101,
                        (outs), (ins GR16:$dst),
                        "call\t$dst", [(MSP430call GR16:$dst)]>;
  def CALLm     : II16m<0b101,
                        (outs), (ins memsrc:$dst),
                        "call\t$dst", [(MSP430call (load addr:$dst))]>;
}

//===----------------------------------------------------------------------===//
//  Miscellaneous Instructions...
//
let Defs = [SP], Uses = [SP], hasSideEffects=0 in {
let mayLoad = 1 in
def POP16r   : IForm16<0b0100, DstReg, SrcPostInc, 2,
                       (outs GR16:$dst), (ins), "pop\t$dst", []> {
  let src = 1;
}

let mayStore = 1 in
def PUSH8r :  II8r<0b100, (outs), (ins GR8:$src), "push.b\t$src", []>;
def PUSH16r : II16r<0b100, (outs), (ins GR16:$src), "push\t$src", []>;
def PUSH16c : II16c<0b100, (outs), (ins cg16imm:$imm), "push\t$imm", []>;
def PUSH16i : II16i<0b100, (outs), (ins i16imm:$src), "push\t$src", []>;
}

//===----------------------------------------------------------------------===//
// Move Instructions

// FIXME: Provide proper encoding!
let hasSideEffects = 0 in {
def MOV8rr  : I8rr<0b0100,
                   (outs GR8:$dst), (ins GR8:$src),
                   "mov.b\t{$src, $dst}",
                   []>;
def MOV16rr : I16rr<0b0100,
                    (outs GR16:$dst), (ins GR16:$src),
                    "mov\t{$src, $dst}",
                    []>;
}

// FIXME: Provide proper encoding!
let isReMaterializable = 1, isAsCheapAsAMove = 1 in {
def MOV8rc : I16rc<0b0100,
                   (outs GR8:$dst), (ins cg8imm:$imm),
                   "mov.b $imm, $dst",
                   [(set GR8:$dst, cg8imm:$imm)]>;
def MOV16rc : I16rc<0b0100,
                    (outs GR16:$dst), (ins cg16imm:$imm),
                    "mov $imm, $dst",
                    [(set GR16:$dst, cg16imm:$imm)]>;
def MOV8ri  : I8ri<0b0100,
                   (outs GR8:$dst), (ins i8imm:$src),
                   "mov.b\t{$src, $dst}",
                   [(set GR8:$dst, imm:$src)]>;
def MOV16ri : I16ri<0b0100,
                    (outs GR16:$dst), (ins i16imm:$src),
                    "mov\t{$src, $dst}",
                    [(set GR16:$dst, imm:$src)]>;
}

let canFoldAsLoad = 1, isReMaterializable = 1 in {
def MOV8rm  : I8rm<0b0100,
                   (outs GR8:$dst), (ins memsrc:$src),
                   "mov.b\t{$src, $dst}",
                   [(set GR8:$dst, (load addr:$src))]>;
def MOV16rm : I16rm<0b0100,
                    (outs GR16:$dst), (ins memsrc:$src),
                    "mov\t{$src, $dst}",
                    [(set GR16:$dst, (load addr:$src))]>;
}

let isCodeGenOnly = 1 in {
def MOVZX16rr8 : I8rr<0b0100,
                      (outs GR16:$dst), (ins GR8:$src),
                      "mov.b\t{$src, $dst}",
                      [(set GR16:$dst, (zext GR8:$src))]>;
def MOVZX16rm8 : I8rm<0b0100,
                      (outs GR16:$dst), (ins memsrc:$src),
                      "mov.b\t{$src, $dst}",
                      [(set GR16:$dst, (zextloadi16i8 addr:$src))]>;
}

let mayLoad = 1, hasExtraDefRegAllocReq = 1, Constraints = "$src = $wb" in {
def MOV8rp  : I8rp<0b0100,
                   (outs GR8:$dst, GR16:$wb), (ins GR16:$src),
                   "mov.b\t{@$src+, $dst}", []>;
def MOV16rp : I16rp<0b0100,
                    (outs GR16:$dst, GR16:$wb), (ins GR16:$src),
                    "mov\t{@$src+, $dst}", []>;
}

// Any instruction that defines a 8-bit result leaves the high half of the
// register. Truncate can be lowered to EXTRACT_SUBREG, and CopyFromReg may
// be copying from a truncate, but any other 8-bit operation will zero-extend
// up to 16 bits.
def def8 : PatLeaf<(i8 GR8:$src), [{
  return N->getOpcode() != ISD::TRUNCATE &&
         N->getOpcode() != TargetOpcode::EXTRACT_SUBREG &&
         N->getOpcode() != ISD::CopyFromReg;
}]>;

// In the case of a 8-bit def that is known to implicitly zero-extend,
// we can use a SUBREG_TO_REG.
def : Pat<(i16 (zext def8:$src)),
          (SUBREG_TO_REG (i16 0), GR8:$src, subreg_8bit)>;

def MOV8mc  : I8mc<0b0100,
                   (outs), (ins memdst:$dst, cg8imm:$imm),
                   "mov.b\t{$imm, $dst}",
                   [(store (i8 cg8imm:$imm), addr:$dst)]>;
def MOV16mc : I16mc<0b0100,
                    (outs), (ins memdst:$dst, cg16imm:$imm),
                    "mov\t{$imm, $dst}",
                    [(store (i16 cg16imm:$imm), addr:$dst)]>;

def MOV8mi  : I8mi<0b0100,
                   (outs), (ins memdst:$dst, i8imm:$src),
                   "mov.b\t{$src, $dst}",
                   [(store (i8 imm:$src), addr:$dst)]>;
def MOV16mi : I16mi<0b0100,
                    (outs), (ins memdst:$dst, i16imm:$src),
                    "mov\t{$src, $dst}",
                    [(store (i16 imm:$src), addr:$dst)]>;

def MOV8mr  : I8mr<0b0100,
                   (outs), (ins memdst:$dst, GR8:$src),
                   "mov.b\t{$src, $dst}",
                   [(store GR8:$src, addr:$dst)]>;
def MOV16mr : I16mr<0b0100,
                    (outs), (ins memdst:$dst, GR16:$src),
                    "mov\t{$src, $dst}",
                    [(store GR16:$src, addr:$dst)]>;

def MOV8mm  : I8mm<0b0100,
                   (outs), (ins memdst:$dst, memsrc:$src),
                   "mov.b\t{$src, $dst}",
                   [(store (i8 (load addr:$src)), addr:$dst)]>;
def MOV16mm : I16mm<0b0100,
                    (outs), (ins memdst:$dst, memsrc:$src),
                    "mov\t{$src, $dst}",
                    [(store (i16 (load addr:$src)), addr:$dst)]>;

//===----------------------------------------------------------------------===//
// Arithmetic Instructions

multiclass Arith<bits<4> opcode, string asmstring, SDNode node,
                 bit commutes, list<Register> uses> {
  let Defs = [SR], Uses = uses in {
  let Constraints = "$src2 = $dst" in {
  let isCommutable = commutes in {
  def 8rr : I8rr<opcode, (outs GR8:$dst), (ins GR8:$src2, GR8:$src),
                 !strconcat(asmstring, ".b $src, $dst"),
                 [(set GR8:$dst, (node GR8:$src2, GR8:$src)),
                  (implicit SR)]>;
  def 16rr : I16rr<opcode, (outs GR16:$dst), (ins GR16:$src2, GR16:$src),
                   !strconcat(asmstring, " $src, $dst"),
                   [(set GR16:$dst, (node GR16:$src2, GR16:$src)),
                    (implicit SR)]>;
  }
  def 8rm : I8rm<opcode, (outs GR8:$dst), (ins GR8:$src2, memsrc:$src),
                 !strconcat(asmstring, ".b $src, $dst"),
                 [(set GR8:$dst, (node GR8:$src2, (load addr:$src))),
                  (implicit SR)]>;
  def 16rm : I16rm<opcode, (outs GR16:$dst), (ins GR16:$src2, memsrc:$src),
                   !strconcat(asmstring, " $src, $dst"),
                   [(set GR16:$dst, (node GR16:$src2, (load addr:$src))),
                    (implicit SR)]>;
  let mayLoad = 1,
      hasExtraDefRegAllocReq = 1,
      Constraints = "$base = $wb, $src = $dst" in {
  def 8rp : I8rp<opcode, (outs GR8:$dst, GR8:$wb), (ins GR8:$src, GR8:$base),
                 !strconcat(asmstring, ".b @$base+, $dst"), []>;
  def 16rp : I16rp<opcode, (outs GR16:$dst, GR16:$wb), (ins GR16:$src, GR16:$base),
                   !strconcat(asmstring, " @$base+, $dst"), []>;
  }
  def 8rc : I8rc<opcode, (outs GR8:$dst), (ins GR8:$src2, cg8imm:$imm),
                 !strconcat(asmstring, ".b $imm, $dst"),
                 [(set GR8:$dst, (node GR8:$src2, cg8imm:$imm)),
                  (implicit SR)]>;
  def 16rc : I16rc<opcode, (outs GR16:$dst), (ins GR16:$src2, cg16imm:$imm),
                 !strconcat(asmstring, " $imm, $dst"),
                 [(set GR16:$dst, (node GR16:$src2, cg16imm:$imm)),
                  (implicit SR)]>;
  def 8ri : I8ri<opcode, (outs GR8:$dst), (ins GR8:$src2, i8imm:$src),
                 !strconcat(asmstring, ".b $src, $dst"),
                 [(set GR8:$dst, (node GR8:$src2, imm:$src)),
                  (implicit SR)]>;
  def 16ri : I16ri<opcode, (outs GR16:$dst), (ins GR16:$src2, i16imm:$src),
                 !strconcat(asmstring, " $src, $dst"),
                 [(set GR16:$dst, (node GR16:$src2, imm:$src)),
                  (implicit SR)]>;
  }
  def 8mr : I8mr<opcode, (outs), (ins memdst:$dst, GR8:$src),
                 !strconcat(asmstring, ".b $src, $dst"),
                 [(store (node (load addr:$dst), GR8:$src), addr:$dst),
                  (implicit SR)]>;
  def 16mr : I16mr<opcode, (outs), (ins memdst:$dst, GR16:$src),
                   !strconcat(asmstring, " $src, $dst"),
                   [(store (node (load addr:$dst), GR16:$src), addr:$dst),
                    (implicit SR)]>;
  def 8mc : I8mc<opcode, (outs), (ins memdst:$dst, cg8imm:$imm),
                 !strconcat(asmstring, ".b $imm, $dst"),
                 [(store (node (load addr:$dst), (i8 cg8imm:$imm)), addr:$dst),
                  (implicit SR)]>;
  def 16mc : I16mc<opcode, (outs), (ins memdst:$dst, cg16imm:$imm),
                   !strconcat(asmstring, " $imm, $dst"),
                   [(store (node (load addr:$dst), (i16 cg16imm:$imm)), addr:$dst),
                    (implicit SR)]>;
  def 8mi : I8mi<opcode, (outs), (ins memdst:$dst, i8imm:$src),
                 !strconcat(asmstring, ".b $src, $dst"),
                 [(store (node (load addr:$dst), (i8 imm:$src)), addr:$dst),
                  (implicit SR)]>;
  def 16mi : I16mi<opcode, (outs), (ins memdst:$dst, i16imm:$src),
                   !strconcat(asmstring, " $src, $dst"),
                   [(store (node (load addr:$dst), (i16 imm:$src)), addr:$dst),
                    (implicit SR)]>;
  def 8mm : I8mm<opcode, (outs), (ins memdst:$dst, memsrc:$src),
                 !strconcat(asmstring, ".b $src, $dst"),
                 [(store (node (load addr:$dst), 
                               (i8 (load addr:$src))), addr:$dst),
                  (implicit SR)]>;
  def 16mm : I16mm<opcode, (outs), (ins memdst:$dst, memsrc:$src),
                   !strconcat(asmstring, " $src, $dst"),
                   [(store (node (load addr:$dst), 
                                 (i16 (load addr:$src))), addr:$dst),
                    (implicit SR)]>;
  }
}

defm ADD  : Arith<0b0101, "add",  add,  1, []>;
defm ADDC : Arith<0b0110, "addc", adde, 1, [SR]>;
defm AND  : Arith<0b1111, "and",  and,  1, []>;
defm BIS  : Arith<0b1101, "bis",  or,   1, []>;
defm BIC  : Arith<0b1100, "bic",  bic,  0, []>;
defm XOR  : Arith<0b1110, "xor",  xor,  1, []>;
defm SUB  : Arith<0b1000, "sub",  sub,  0, []>;
defm SUBC : Arith<0b0111, "subc", sube, 0, [SR]>;
defm DADD : Arith<0b1010, "dadd", MSP430dadd, 1, [SR]>;

def ADC8r   : InstAlias<"adc.b $dst",  (ADDC8rc   GR8:$dst,     0)>;
def ADC16r  : InstAlias<"adc $dst",    (ADDC16rc  GR16:$dst,    0)>;
def ADC8m   : InstAlias<"adc.b $dst",  (ADDC8mc   memdst:$dst,  0)>;
def ADC16m  : InstAlias<"adc $dst",    (ADDC16mc  memdst:$dst,  0)>;

def DADC8r  : InstAlias<"dadc.b $dst", (DADD8rc   GR8:$dst,     0)>;
def DADC16r : InstAlias<"dadc $dst",   (DADD16rc  GR16:$dst,    0)>;
def DADC8m  : InstAlias<"dadc.b $dst", (DADD8mc   memdst:$dst,  0)>;
def DADC16m : InstAlias<"dadc $dst",   (DADD16mc  memdst:$dst,  0)>;

def DEC8r   : InstAlias<"dec.b $dst",  (SUB8rc    GR8:$dst,     1)>;
def DEC16r  : InstAlias<"dec $dst",    (SUB16rc   GR16:$dst,    1)>;
def DEC8m   : InstAlias<"dec.b $dst",  (SUB8mc    memdst:$dst,  1)>;
def DEC16m  : InstAlias<"dec $dst",    (SUB16mc   memdst:$dst,  1)>;

def DECD8r  : InstAlias<"decd.b $dst", (SUB8rc    GR8:$dst,     2)>;
def DECD16r : InstAlias<"decd $dst",   (SUB16rc   GR16:$dst,    2)>;
def DECD8m  : InstAlias<"decd.b $dst", (SUB8mc    memdst:$dst,  2)>;
def DECD16m : InstAlias<"decd $dst",   (SUB16mc   memdst:$dst,  2)>;

def INC8r   : InstAlias<"inc.b $dst",  (ADD8rc    GR8:$dst,     1)>;
def INC16r  : InstAlias<"inc $dst",    (ADD16rc   GR16:$dst,    1)>;
def INC8m   : InstAlias<"inc.b $dst",  (ADD8mc    memdst:$dst,  1)>;
def INC16m  : InstAlias<"inc $dst",    (ADD16mc   memdst:$dst,  1)>;

def INCD8r  : InstAlias<"incd.b $dst", (ADD8rc    GR8:$dst,     2)>;
def INCD16r : InstAlias<"incd $dst",   (ADD16rc   GR16:$dst,    2)>;
def INCD8m  : InstAlias<"incd.b $dst", (ADD8mc    memdst:$dst,  2)>;
def INCD16m : InstAlias<"incd $dst",   (ADD16mc   memdst:$dst,  2)>;

def SBC8r   : InstAlias<"sbc.b $dst",  (SUBC8rc   GR8:$dst,     0)>;
def SBC16r  : InstAlias<"sbc $dst",    (SUBC16rc  GR16:$dst,    0)>;
def SBC8m   : InstAlias<"sbc.b $dst",  (SUBC8mc   memdst:$dst,  0)>;
def SBC16m  : InstAlias<"sbc $dst",    (SUBC16mc  memdst:$dst,  0)>;

def INV8r   : InstAlias<"inv.b $dst",  (XOR8rc    GR8:$dst,    -1)>;
def INV16r  : InstAlias<"inv $dst",    (XOR16rc   GR16:$dst,   -1)>;
def INV8m   : InstAlias<"inv.b $dst",  (XOR8mc    memdst:$dst, -1)>;
def INV16m  : InstAlias<"inv $dst",    (XOR16mc   memdst:$dst, -1)>;

// TODO rla?

def RLC8r   : InstAlias<"rlc.b $dst",  (ADDC8rr   GR8:$dst,     GR8:$dst)>;
def RLC16r  : InstAlias<"rlc $dst",    (ADDC16rr  GR16:$dst,    GR16:$dst)>;
def RLC8m   : InstAlias<"rlc.b $dst",  (ADDC8mm   memdst:$dst,  memdst:$dst)>;
def RLC16m  : InstAlias<"rlc $dst",    (ADDC16mm  memdst:$dst,  memdst:$dst)>;

// TODO br?

def DINT : InstAlias<"dint", (BIC16rc SR, 8)>;
def EINT : InstAlias<"eint", (BIS16rc SR, 8)>;

def NOP  : InstAlias<"nop",  (MOV16rc CG, 0)>;

// TODO ret?

def CLR8r   : InstAlias<"clr.b $dst",  (MOV8rc    GR8:$dst,     0)>;
def CLR16r  : InstAlias<"clr $dst",    (MOV16rc   GR16:$dst,    0)>;
def CLR8m   : InstAlias<"clr.b $dst",  (MOV8mc    memdst:$dst,  0)>;
def CLR16m  : InstAlias<"clr $dst",    (MOV16mc   memdst:$dst,  0)>;

def CLRC : InstAlias<"clrc", (BIC16rc SR, 1)>;
def CLRN : InstAlias<"clrn", (BIC16rc SR, 4)>;
def CLRZ : InstAlias<"clrz", (BIC16rc SR, 2)>;
def SETC : InstAlias<"setc", (BIS16rc SR, 1)>;
def SETN : InstAlias<"setn", (BIS16rc SR, 4)>;
def SETZ : InstAlias<"setz", (BIS16rc SR, 2)>;

// TODO pop?

let Constraints = "$src = $dst" in {

let Defs = [SR] in {

// FIXME: memory variant!
def SAR8r1  : II8r<0b010,
                   (outs GR8:$dst), (ins GR8:$src),
                   "rra.b\t$dst",
                   [(set GR8:$dst, (MSP430rra GR8:$src)),
                    (implicit SR)]>;
def SAR16r1 : II16r<0b010,
                    (outs GR16:$dst), (ins GR16:$src),
                    "rra\t$dst",
                    [(set GR16:$dst, (MSP430rra GR16:$src)),
                     (implicit SR)]>;

def SHL8r1  : I8rr<0b0101,
                   (outs GR8:$dst), (ins GR8:$src),
                   "rla.b\t$dst",
                   [(set GR8:$dst, (MSP430rla GR8:$src)),
                    (implicit SR)]>;
def SHL16r1 : I16rr<0b0101,
                    (outs GR16:$dst), (ins GR16:$src),
                    "rla\t$dst",
                    [(set GR16:$dst, (MSP430rla GR16:$src)),
                     (implicit SR)]>;

let isCodeGenOnly = 1 in {
def SAR8r1c  : Pseudo<(outs GR8:$dst), (ins GR8:$src),
                      "clrc\n\t"
                      "rrc.b\t$dst",
                      [(set GR8:$dst, (MSP430rrc GR8:$src)),
                       (implicit SR)]>;
def SAR16r1c : Pseudo<(outs GR16:$dst), (ins GR16:$src),
                      "clrc\n\t"
                      "rrc\t$dst",
                      [(set GR16:$dst, (MSP430rrc GR16:$src)),
                       (implicit SR)]>;
}

def RRC8r :   II8r<0b000,
                   (outs GR8:$dst), (ins GR8:$src),
                   "rrc.b $dst",
                   [(set GR8:$dst, (MSP430rrc GR8:$src)),
                    (implicit SR)]>;
def RRC16r : II16r<0b000,
                   (outs GR16:$dst), (ins GR16:$src),
                   "rrc $dst",
                   [(set GR16:$dst, (MSP430rrc GR16:$src)),
                    (implicit SR)]>;

// FIXME: Memory sext's ?
def SEXT16r : II16r<0b011,
                    (outs GR16:$dst), (ins GR16:$src),
                    "sxt\t$dst",
                    [(set GR16:$dst, (sext_inreg GR16:$src, i8)),
                     (implicit SR)]>;

} // Defs = [SR]

let isCodeGenOnly = 1 in
def ZEXT16r : I8rr<0b0100,
                   (outs GR16:$dst), (ins GR16:$src),
                   "mov.b\t{$src, $dst}",
                   [(set GR16:$dst, (zext (trunc GR16:$src)))]>;

// FIXME: Memory bitswaps?
def SWPB16r : II16r<0b001,
                    (outs GR16:$dst), (ins GR16:$src),
                    "swpb\t$dst",
                    [(set GR16:$dst, (bswap GR16:$src))]>;

} // Constraints = "$src = $dst"

// Integer comparisons
let Defs = [SR] in {
def CMP8rr  : I8rr<0b1001,
                   (outs), (ins GR8:$dst, GR8:$src),
                   "cmp.b $src, $dst",
                   [(MSP430cmp GR8:$dst, GR8:$src), (implicit SR)]>;
def CMP16rr : I16rr<0b1001,
                    (outs), (ins GR16:$dst, GR16:$src),
                    "cmp $src, $dst",
                    [(MSP430cmp GR16:$dst, GR16:$src), (implicit SR)]>;

def CMP8rc  : I8rc<0b1001,
                   (outs), (ins GR8:$dst, cg8imm:$imm),
                   "cmp.b $imm, $dst",
                   [(MSP430cmp GR8:$dst, cg8imm:$imm), (implicit SR)]>;
def CMP16rc : I16rc<0b1001,
                    (outs), (ins GR16:$dst, cg16imm:$imm),
                    "cmp $imm, $dst",
                    [(MSP430cmp GR16:$dst, cg16imm:$imm), (implicit SR)]>;

def CMP8ri  : I8ri<0b1001,
                   (outs), (ins GR8:$dst, i8imm:$src),
                   "cmp.b $src, $dst",
                   [(MSP430cmp GR8:$dst, imm:$src), (implicit SR)]>;
def CMP16ri : I16ri<0b1001,
                    (outs), (ins GR16:$dst, i16imm:$src),
                    "cmp $src, $dst",
                    [(MSP430cmp GR16:$dst, imm:$src), (implicit SR)]>;

def CMP8mc  : I8mc<0b1001,
                   (outs), (ins memsrc:$dst, cg8imm:$imm),
                   "cmp.b $imm, $dst",
                   [(MSP430cmp (load addr:$dst), (i8 cg8imm:$imm)),
                    (implicit SR)]>;
def CMP16mc : I16mc<0b1001,
                    (outs), (ins memsrc:$dst, cg16imm:$imm),
                    "cmp $imm, $dst",
                    [(MSP430cmp (load addr:$dst), (i16 cg16imm:$imm)),
                     (implicit SR)]>;

def CMP8mi  : I8mi<0b1001,
                   (outs), (ins memsrc:$dst, i8imm:$src),
                   "cmp.b $src, $dst",
                   [(MSP430cmp (load addr:$dst),
                               (i8 imm:$src)), (implicit SR)]>;
def CMP16mi : I16mi<0b1001,
                    (outs), (ins memsrc:$dst, i16imm:$src),
                    "cmp $src, $dst",
                     [(MSP430cmp (load addr:$dst),
                                 (i16 imm:$src)), (implicit SR)]>;

def CMP8rm  : I8rm<0b1001,
                   (outs), (ins GR8:$dst, memsrc:$src),
                   "cmp.b $src, $dst",
                   [(MSP430cmp GR8:$dst, (load addr:$src)), 
                    (implicit SR)]>;
def CMP16rm : I16rm<0b1001,
                    (outs), (ins GR16:$dst, memsrc:$src),
                    "cmp $src, $dst",
                    [(MSP430cmp GR16:$dst, (load addr:$src)),
                     (implicit SR)]>;

def CMP8mr  : I8mr<0b1001,
                   (outs), (ins memsrc:$dst, GR8:$src),
                   "cmp.b $src, $dst",
                   [(MSP430cmp (load addr:$dst), GR8:$src),
                    (implicit SR)]>;
def CMP16mr : I16mr<0b1001,
                    (outs), (ins memsrc:$dst, GR16:$src),
                    "cmp $src, $dst",
                    [(MSP430cmp (load addr:$dst), GR16:$src), 
                     (implicit SR)]>;

// BIT TESTS, just sets condition codes
// Note that the C condition is set differently than when using CMP.
let isCommutable = 1 in {
def BIT8rr  : I8rr<0b1011,
                   (outs), (ins GR8:$dst, GR8:$src),
                   "bit.b $src, $dst",
                   [(MSP430cmp (and_su GR8:$dst, GR8:$src), 0),
                    (implicit SR)]>;
def BIT16rr : I16rr<0b1011,
                    (outs), (ins GR16:$dst, GR16:$src),
                    "bit $src, $dst",
                    [(MSP430cmp (and_su GR16:$dst, GR16:$src), 0),
                     (implicit SR)]>;
}
def BIT8ri  : I8ri<0b1011,
                   (outs), (ins GR8:$dst, i8imm:$src),
                   "bit.b $src, $dst",
                   [(MSP430cmp (and_su GR8:$dst, imm:$src), 0),
                    (implicit SR)]>;
def BIT16ri : I16ri<0b1011,
                    (outs), (ins GR16:$dst, i16imm:$src),
                    "bit $src, $dst",
                    [(MSP430cmp (and_su GR16:$dst, imm:$src), 0),
                     (implicit SR)]>;

def BIT8rm  : I8rm<0b1011,
                   (outs), (ins GR8:$dst, memdst:$src),
                   "bit.b $src, $dst",
                   [(MSP430cmp (and_su GR8:$dst,  (load addr:$src)), 0),
                    (implicit SR)]>;
def BIT16rm : I16rm<0b1011,
                    (outs), (ins GR16:$dst, memdst:$src),
                    "bit $src, $dst",
                    [(MSP430cmp (and_su GR16:$dst,  (load addr:$src)), 0),
                     (implicit SR)]>;

def BIT8mr  : I8mr<0b1011,
                  (outs), (ins memsrc:$dst, GR8:$src),
                  "bit.b $src, $dst",
                  [(MSP430cmp (and_su (load addr:$dst), GR8:$src), 0),
                   (implicit SR)]>;
def BIT16mr : I16mr<0b1011,
                    (outs), (ins memsrc:$dst, GR16:$src),
                    "bit $src, $dst",
                    [(MSP430cmp (and_su (load addr:$dst), GR16:$src), 0),
                     (implicit SR)]>;

def BIT8mi  : I8mi<0b1011,
                   (outs), (ins memsrc:$dst, i8imm:$src),
                   "bit.b $src, $dst",
                   [(MSP430cmp (and_su (load addr:$dst), (i8 imm:$src)), 0),
                    (implicit SR)]>;
def BIT16mi : I16mi<0b1011,
                    (outs), (ins memsrc:$dst, i16imm:$src),
                    "bit $src, $dst",
                    [(MSP430cmp (and_su (load addr:$dst), (i16 imm:$src)), 0),
                     (implicit SR)]>;

def BIT8mm  : I8mm<0b1011,
                   (outs), (ins memsrc:$dst, memsrc:$src),
                   "bit.b $src, $dst",
                   [(MSP430cmp (and_su (i8 (load addr:$dst)),
                                       (load addr:$src)),
                                 0),
                      (implicit SR)]>;
def BIT16mm : I16mm<0b1011,
                    (outs), (ins memsrc:$dst, memsrc:$src),
                    "bit $src, $dst",
                    [(MSP430cmp (and_su (i16 (load addr:$dst)),
                                        (load addr:$src)),
                                 0),
                     (implicit SR)]>;
} // Defs = [SR]

def TST8r   : InstAlias<"tst.b $dst",  (CMP8rc    GR8:$dst,     0)>;
def TST16r  : InstAlias<"tst $dst",    (CMP16rc   GR16:$dst,    0)>;
def TST8m   : InstAlias<"tst.b $dst",  (CMP8mc    memdst:$dst,  0)>;
def TST16m  : InstAlias<"tst $dst",    (CMP16mc   memdst:$dst,  0)>;

//===----------------------------------------------------------------------===//
// Non-Instruction Patterns

// extload
def : Pat<(extloadi16i8 addr:$src), (MOVZX16rm8 addr:$src)>;

// anyext
def : Pat<(i16 (anyext GR8:$src)),
          (SUBREG_TO_REG (i16 0), GR8:$src, subreg_8bit)>;

// truncs
def : Pat<(i8 (trunc GR16:$src)),
          (EXTRACT_SUBREG GR16:$src, subreg_8bit)>;

// GlobalAddress, ExternalSymbol
def : Pat<(i16 (MSP430Wrapper tglobaladdr:$dst)), (MOV16ri tglobaladdr:$dst)>;
def : Pat<(i16 (MSP430Wrapper texternalsym:$dst)), (MOV16ri texternalsym:$dst)>;
def : Pat<(i16 (MSP430Wrapper tblockaddress:$dst)), (MOV16ri tblockaddress:$dst)>;

def : Pat<(add GR16:$src, (MSP430Wrapper tglobaladdr :$src2)),
          (ADD16ri GR16:$src, tglobaladdr:$src2)>;
def : Pat<(add GR16:$src, (MSP430Wrapper texternalsym:$src2)),
          (ADD16ri GR16:$src, texternalsym:$src2)>;
def : Pat<(add GR16:$src, (MSP430Wrapper tblockaddress:$src2)),
          (ADD16ri GR16:$src, tblockaddress:$src2)>;

def : Pat<(store (i16 (MSP430Wrapper tglobaladdr:$src)), addr:$dst),
          (MOV16mi addr:$dst, tglobaladdr:$src)>;
def : Pat<(store (i16 (MSP430Wrapper texternalsym:$src)), addr:$dst),
          (MOV16mi addr:$dst, texternalsym:$src)>;
def : Pat<(store (i16 (MSP430Wrapper tblockaddress:$src)), addr:$dst),
          (MOV16mi addr:$dst, tblockaddress:$src)>;

// calls
def : Pat<(MSP430call (i16 tglobaladdr:$dst)),
          (CALLi tglobaladdr:$dst)>;
def : Pat<(MSP430call (i16 texternalsym:$dst)),
          (CALLi texternalsym:$dst)>;

// add and sub always produce carry
def : Pat<(addc GR16:$src, GR16:$src2),
          (ADD16rr GR16:$src, GR16:$src2)>;
def : Pat<(addc GR16:$src, (load addr:$src2)),
          (ADD16rm GR16:$src, addr:$src2)>;
def : Pat<(addc GR16:$src, imm:$src2),
          (ADD16ri GR16:$src, imm:$src2)>;
def : Pat<(store (addc (load addr:$dst), GR16:$src), addr:$dst),
          (ADD16mr addr:$dst, GR16:$src)>;
def : Pat<(store (addc (load addr:$dst), (i16 (load addr:$src))), addr:$dst),
          (ADD16mm addr:$dst, addr:$src)>;

def : Pat<(addc GR8:$src, GR8:$src2),
          (ADD8rr GR8:$src, GR8:$src2)>;
def : Pat<(addc GR8:$src, (load addr:$src2)),
          (ADD8rm GR8:$src, addr:$src2)>;
def : Pat<(addc GR8:$src, imm:$src2),
          (ADD8ri GR8:$src, imm:$src2)>;
def : Pat<(store (addc (load addr:$dst), GR8:$src), addr:$dst),
          (ADD8mr addr:$dst, GR8:$src)>;
def : Pat<(store (addc (load addr:$dst), (i8 (load addr:$src))), addr:$dst),
          (ADD8mm addr:$dst, addr:$src)>;

def : Pat<(subc GR16:$src, GR16:$src2),
          (SUB16rr GR16:$src, GR16:$src2)>;
def : Pat<(subc GR16:$src, (load addr:$src2)),
          (SUB16rm GR16:$src, addr:$src2)>;
def : Pat<(subc GR16:$src, imm:$src2),
          (SUB16ri GR16:$src, imm:$src2)>;
def : Pat<(store (subc (load addr:$dst), GR16:$src), addr:$dst),
          (SUB16mr addr:$dst, GR16:$src)>;
def : Pat<(store (subc (load addr:$dst), (i16 (load addr:$src))), addr:$dst),
          (SUB16mm addr:$dst, addr:$src)>;

def : Pat<(subc GR8:$src, GR8:$src2),
          (SUB8rr GR8:$src, GR8:$src2)>;
def : Pat<(subc GR8:$src, (load addr:$src2)),
          (SUB8rm GR8:$src, addr:$src2)>;
def : Pat<(subc GR8:$src, imm:$src2),
          (SUB8ri GR8:$src, imm:$src2)>;
def : Pat<(store (subc (load addr:$dst), GR8:$src), addr:$dst),
          (SUB8mr addr:$dst, GR8:$src)>;
def : Pat<(store (subc (load addr:$dst), (i8 (load addr:$src))), addr:$dst),
          (SUB8mm addr:$dst, addr:$src)>;

// peephole patterns
def : Pat<(and GR16:$src, 255), (ZEXT16r GR16:$src)>;
def : Pat<(MSP430cmp (trunc (and_su GR16:$src, GR16:$src2)), 0),
          (BIT8rr (EXTRACT_SUBREG GR16:$src, subreg_8bit),
                  (EXTRACT_SUBREG GR16:$src2, subreg_8bit))>;
