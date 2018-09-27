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
}

// Operand for printing out a condition code.
def cc : Operand<i8> {
  let PrintMethod = "printCCOperand";
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

let hasSideEffects = 0 in
def NOP : Pseudo<(outs), (ins), "nop", []>;

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
  def JMP : CJForm<0b111, (outs), (ins jmptarget:$dst),
                   "jmp\t$dst",
                   [(br bb:$dst)]>;
  let isIndirectBranch = 1 in {
    // Long branches
    def Bi  : I16ri<0b0100, (outs), (ins i16imm:$dst),
                    "br\t$dst",
                    [(brind tblockaddress:$dst)]>;
    def Br  : I16rr<0b0100, (outs), (ins GR16:$dst),
                    "br\t$dst",
                    [(brind GR16:$dst)]>;
    def Bm  : I16rm<0b0100, (outs), (ins memsrc:$dst),
                    "br\t$dst",
                    [(brind (load addr:$dst))]>;
  }
}

// Conditional branches
let Uses = [SR] in
  def JCC : CJForm<0,
                   (outs), (ins jmptarget:$dst, cc:$cc),
                   "j$cc\t$dst",
                   [(MSP430brcc bb:$dst, imm:$cc)]>;
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
                       (outs GR16:$dst), (ins), "pop.w\t$dst", []> {
  let src = 1;
}

let mayStore = 1 in
def PUSH16r  : II16r<0b100,
                     (outs), (ins GR16:$src), "push.w\t$src", []>;
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
                    "mov.w\t{$src, $dst}",
                    []>;
}

// FIXME: Provide proper encoding!
let isReMaterializable = 1, isAsCheapAsAMove = 1 in {
def MOV8ri  : I8ri<0b0100,
                   (outs GR8:$dst), (ins i8imm:$src),
                   "mov.b\t{$src, $dst}",
                   [(set GR8:$dst, imm:$src)]>;
def MOV16ri : I16ri<0b0100,
                    (outs GR16:$dst), (ins i16imm:$src),
                    "mov.w\t{$src, $dst}",
                    [(set GR16:$dst, imm:$src)]>;
}

let canFoldAsLoad = 1, isReMaterializable = 1 in {
def MOV8rm  : I8rm<0b0100,
                   (outs GR8:$dst), (ins memsrc:$src),
                   "mov.b\t{$src, $dst}",
                   [(set GR8:$dst, (load addr:$src))]>;
def MOV16rm : I16rm<0b0100,
                    (outs GR16:$dst), (ins memsrc:$src),
                    "mov.w\t{$src, $dst}",
                    [(set GR16:$dst, (load addr:$src))]>;
}

def MOVZX16rr8 : I8rr<0b0100,
                      (outs GR16:$dst), (ins GR8:$src),
                      "mov.b\t{$src, $dst}",
                      [(set GR16:$dst, (zext GR8:$src))]>;
def MOVZX16rm8 : I8rm<0b0100,
                      (outs GR16:$dst), (ins memsrc:$src),
                      "mov.b\t{$src, $dst}",
                      [(set GR16:$dst, (zextloadi16i8 addr:$src))]>;

let mayLoad = 1, hasExtraDefRegAllocReq = 1, Constraints = "$src = $wb" in {
def MOV8rp  : IForm8<0b0100, DstReg, SrcPostInc, 2,
                     (outs GR8:$dst, GR16:$wb), (ins GR16:$src),
                     "mov.b\t{@$src+, $dst}", []>;
def MOV16rp : IForm16<0b0100, DstReg, SrcPostInc, 2,
                      (outs GR16:$dst, GR16:$wb), (ins GR16:$src),
                      "mov.w\t{@$src+, $dst}", []>;
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

def MOV8mi  : I8mi<0b0100,
                   (outs), (ins memdst:$dst, i8imm:$src),
                   "mov.b\t{$src, $dst}",
                   [(store (i8 imm:$src), addr:$dst)]>;
def MOV16mi : I16mi<0b0100,
                    (outs), (ins memdst:$dst, i16imm:$src),
                    "mov.w\t{$src, $dst}",
                    [(store (i16 imm:$src), addr:$dst)]>;

def MOV8mr  : I8mr<0b0100,
                   (outs), (ins memdst:$dst, GR8:$src),
                   "mov.b\t{$src, $dst}",
                   [(store GR8:$src, addr:$dst)]>;
def MOV16mr : I16mr<0b0100,
                    (outs), (ins memdst:$dst, GR16:$src),
                    "mov.w\t{$src, $dst}",
                    [(store GR16:$src, addr:$dst)]>;

def MOV8mm  : I8mm<0b0100,
                   (outs), (ins memdst:$dst, memsrc:$src),
                   "mov.b\t{$src, $dst}",
                   [(store (i8 (load addr:$src)), addr:$dst)]>;
def MOV16mm : I16mm<0b0100,
                    (outs), (ins memdst:$dst, memsrc:$src),
                    "mov.w\t{$src, $dst}",
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
                   !strconcat(asmstring, ".w $src, $dst"),
                   [(set GR16:$dst, (node GR16:$src2, GR16:$src)),
                    (implicit SR)]>;
  }
  def 8rm : I8rm<opcode, (outs GR8:$dst), (ins GR8:$src2, memsrc:$src),
                 !strconcat(asmstring, ".b $src, $dst"),
                 [(set GR8:$dst, (node GR8:$src2, (load addr:$src))),
                  (implicit SR)]>;
  def 16rm : I16rm<opcode, (outs GR16:$dst), (ins GR16:$src2, memsrc:$src),
                   !strconcat(asmstring, ".w $src, $dst"),
                   [(set GR16:$dst, (node GR16:$src2, (load addr:$src))),
                    (implicit SR)]>;
  let mayLoad = 1,
      hasExtraDefRegAllocReq = 1,
      Constraints = "$base = $wb, $src = $dst" in {
  def 8rp : IForm8<opcode, DstReg, SrcPostInc, 2,
                     (outs GR8:$dst, GR8:$wb), (ins GR8:$src, GR8:$base),
                     !strconcat(asmstring, ".b @$base+, $dst"), []>;
  def 16rp : IForm16<opcode, DstReg, SrcPostInc, 2,
                     (outs GR16:$dst, GR16:$wb), (ins GR16:$src, GR16:$base),
                     !strconcat(asmstring, ".w @$base+, $dst"), []>;
  }
  def 8ri : I8ri<opcode, (outs GR8:$dst), (ins GR8:$src2, i8imm:$src),
                 !strconcat(asmstring, ".b $src, $dst"),
                 [(set GR8:$dst, (node GR8:$src2, imm:$src)),
                  (implicit SR)]>;
  def 16ri : I16ri<opcode, (outs GR16:$dst), (ins GR16:$src2, i16imm:$src),
                 !strconcat(asmstring, ".w $src, $dst"),
                 [(set GR16:$dst, (node GR16:$src2, imm:$src)),
                  (implicit SR)]>;
  }
  def 8mr : I8mr<opcode, (outs), (ins memdst:$dst, GR8:$src),
                 !strconcat(asmstring, ".b $src, $dst"),
                 [(store (node (load addr:$dst), GR8:$src), addr:$dst),
                  (implicit SR)]>;
  def 16mr : I16mr<opcode, (outs), (ins memdst:$dst, GR16:$src),
                   !strconcat(asmstring, ".w $src, $dst"),
                   [(store (node (load addr:$dst), GR16:$src), addr:$dst),
                    (implicit SR)]>;
  def 8mi : I8mi<opcode, (outs), (ins memdst:$dst, i8imm:$src),
                 !strconcat(asmstring, ".b $src, $dst"),
                 [(store (node (load addr:$dst), (i8 imm:$src)), addr:$dst),
                  (implicit SR)]>;
  def 16mi : I16mi<opcode, (outs), (ins memdst:$dst, i16imm:$src),
                   !strconcat(asmstring, ".w $src, $dst"),
                   [(store (node (load addr:$dst), (i16 imm:$src)), addr:$dst),
                    (implicit SR)]>;
  def 8mm : I8mm<opcode, (outs), (ins memdst:$dst, memsrc:$src),
                 !strconcat(asmstring, ".b $src, $dst"),
                 [(store (node (load addr:$dst), 
                               (i8 (load addr:$src))), addr:$dst),
                  (implicit SR)]>;
  def 16mm : I16mm<opcode, (outs), (ins memdst:$dst, memsrc:$src),
                   !strconcat(asmstring, ".w $src, $dst"),
                   [(store (node (load addr:$dst), 
                                 (i16 (load addr:$src))), addr:$dst),
                    (implicit SR)]>;
  }
}

defm ADD : Arith<0b0101, "add",  add,  1, []>;
defm ADC : Arith<0b0110, "addc", adde, 1, [SR]>;
defm AND : Arith<0b1111, "and",  and,  1, []>;
defm OR  : Arith<0b1101, "bis",  or,   1, []>;
defm BIC : Arith<0b1100, "bic",  bic,  0, []>;
defm XOR : Arith<0b1110, "xor",  xor,  1, []>;
defm SUB : Arith<0b1000, "sub",  sub,  0, []>;
defm SBC : Arith<0b0111, "subc", sube, 0, [SR]>;

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
                    "rra.w\t$dst",
                    [(set GR16:$dst, (MSP430rra GR16:$src)),
                     (implicit SR)]>;

def SHL8r1  : I8rr<0,
                   (outs GR8:$dst), (ins GR8:$src),
                   "rla.b\t$dst",
                   [(set GR8:$dst, (MSP430rla GR8:$src)),
                    (implicit SR)]>;
def SHL16r1 : I16rr<0,
                    (outs GR16:$dst), (ins GR16:$src),
                    "rla.w\t$dst",
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
                      "rrc.w\t$dst",
                      [(set GR16:$dst, (MSP430rrc GR16:$src)),
                       (implicit SR)]>;
}

// FIXME: Memory sext's ?
def SEXT16r : II16r<0b011,
                    (outs GR16:$dst), (ins GR16:$src),
                    "sxt\t$dst",
                    [(set GR16:$dst, (sext_inreg GR16:$src, i8)),
                     (implicit SR)]>;

} // Defs = [SR]

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
                    "cmp.w $src, $dst",
                    [(MSP430cmp GR16:$dst, GR16:$src), (implicit SR)]>;

def CMP8ri  : I8ri<0b1001,
                   (outs), (ins GR8:$dst, i8imm:$src),
                   "cmp.b $src, $dst",
                   [(MSP430cmp GR8:$dst, imm:$src), (implicit SR)]>;
def CMP16ri : I16ri<0b1001,
                    (outs), (ins GR16:$dst, i16imm:$src),
                    "cmp.w $src, $dst",
                    [(MSP430cmp GR16:$dst, imm:$src), (implicit SR)]>;

def CMP8mi  : I8mi<0b1001,
                   (outs), (ins memsrc:$dst, i8imm:$src),
                   "cmp.b $src, $dst",
                   [(MSP430cmp (load addr:$dst),
                               (i8 imm:$src)), (implicit SR)]>;
def CMP16mi : I16mi<0b1001,
                    (outs), (ins memsrc:$dst, i16imm:$src),
                    "cmp.w $src, $dst",
                     [(MSP430cmp (load addr:$dst),
                                 (i16 imm:$src)), (implicit SR)]>;

def CMP8rm  : I8rm<0b1001,
                   (outs), (ins GR8:$dst, memsrc:$src),
                   "cmp.b $src, $dst",
                   [(MSP430cmp GR8:$dst, (load addr:$src)), 
                    (implicit SR)]>;
def CMP16rm : I16rm<0b1001,
                    (outs), (ins GR16:$dst, memsrc:$src),
                    "cmp.w $src, $dst",
                    [(MSP430cmp GR16:$dst, (load addr:$src)),
                     (implicit SR)]>;

def CMP8mr  : I8mr<0b1001,
                   (outs), (ins memsrc:$dst, GR8:$src),
                   "cmp.b $src, $dst",
                   [(MSP430cmp (load addr:$dst), GR8:$src),
                    (implicit SR)]>;
def CMP16mr : I16mr<0b1001,
                    (outs), (ins memsrc:$dst, GR16:$src),
                    "cmp.w $src, $dst",
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
                    "bit.w $src, $dst",
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
                    "bit.w $src, $dst",
                    [(MSP430cmp (and_su GR16:$dst, imm:$src), 0),
                     (implicit SR)]>;

def BIT8rm  : I8rm<0b1011,
                   (outs), (ins GR8:$dst, memdst:$src),
                   "bit.b $src, $dst",
                   [(MSP430cmp (and_su GR8:$dst,  (load addr:$src)), 0),
                    (implicit SR)]>;
def BIT16rm : I16rm<0b1011,
                    (outs), (ins GR16:$dst, memdst:$src),
                    "bit.w $src, $dst",
                    [(MSP430cmp (and_su GR16:$dst,  (load addr:$src)), 0),
                     (implicit SR)]>;

def BIT8mr  : I8mr<0b1011,
                  (outs), (ins memsrc:$dst, GR8:$src),
                  "bit.b $src, $dst",
                  [(MSP430cmp (and_su (load addr:$dst), GR8:$src), 0),
                   (implicit SR)]>;
def BIT16mr : I16mr<0b1011,
                    (outs), (ins memsrc:$dst, GR16:$src),
                    "bit.w $src, $dst",
                    [(MSP430cmp (and_su (load addr:$dst), GR16:$src), 0),
                     (implicit SR)]>;

def BIT8mi  : I8mi<0b1011,
                   (outs), (ins memsrc:$dst, i8imm:$src),
                   "bit.b $src, $dst",
                   [(MSP430cmp (and_su (load addr:$dst), (i8 imm:$src)), 0),
                    (implicit SR)]>;
def BIT16mi : I16mi<0b1011,
                    (outs), (ins memsrc:$dst, i16imm:$src),
                    "bit.w $src, $dst",
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
                    "bit.w $src, $dst",
                    [(MSP430cmp (and_su (i16 (load addr:$dst)),
                                        (load addr:$src)),
                                 0),
                     (implicit SR)]>;
} // Defs = [SR]

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
