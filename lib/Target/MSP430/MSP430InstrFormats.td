//===-- MSP430InstrFormats.td - MSP430 Instruction Formats -*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source 
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
//  Describe MSP430 instructions format here
//

class SourceMode<bits<2> val> {
  bits<2> Value = val;
}

def SrcReg      : SourceMode<0>;
def SrcMem      : SourceMode<1>;
def SrcIndReg   : SourceMode<2>;
def SrcPostInc  : SourceMode<3>;
def SrcImm      : SourceMode<3>;

class DestMode<bit val> {
  bit Value = val;
}

def DstReg      : DestMode<0>;
def DstMem      : DestMode<1>;

// Generic MSP430 Format
class MSP430Inst<dag outs, dag ins, int size, string asmstr> : Instruction {
  field bits<16> Inst;

  let Namespace = "MSP430";

  dag OutOperandList = outs;
  dag InOperandList  = ins;

  let AsmString   = asmstr;
}

// FIXME: Create different classes for different addressing modes.

// MSP430 Double Operand (Format I) Instructions
class IForm<bits<4> opcode, DestMode dest, bit bw, SourceMode src, int size,
            dag outs, dag ins, string asmstr, list<dag> pattern>
  : MSP430Inst<outs, ins, size, asmstr> {
  let Pattern = pattern;
  let Size = size;

  DestMode ad = dest;
  SourceMode as = src;
  
  let Inst{12-15} = opcode;
  let Inst{7}     = ad.Value;
  let Inst{6}     = bw;
  let Inst{4-5}   = as.Value;
}

// 8 bit IForm instructions
class IForm8<bits<4> opcode, DestMode dest, SourceMode src, int size,
             dag outs, dag ins, string asmstr, list<dag> pattern>
  : IForm<opcode, dest, 1, src, size, outs, ins, asmstr, pattern>;

class I8rr<bits<4> opcode,
           dag outs, dag ins, string asmstr, list<dag> pattern>
  : IForm8<opcode, DstReg, SrcReg, 2, outs, ins, asmstr, pattern>;

class I8ri<bits<4> opcode,
           dag outs, dag ins, string asmstr, list<dag> pattern>
  : IForm8<opcode, DstReg, SrcImm, 4, outs, ins, asmstr, pattern>;

class I8rm<bits<4> opcode,
           dag outs, dag ins, string asmstr, list<dag> pattern>
  : IForm8<opcode, DstReg, SrcMem, 4, outs, ins, asmstr, pattern>;

class I8mr<bits<4> opcode,
           dag outs, dag ins, string asmstr, list<dag> pattern>
  : IForm8<opcode, DstMem, SrcReg, 4, outs, ins, asmstr, pattern>;

class I8mi<bits<4> opcode,
           dag outs, dag ins, string asmstr, list<dag> pattern>
  : IForm8<opcode, DstMem, SrcImm, 6, outs, ins, asmstr, pattern>;

class I8mm<bits<4> opcode,
           dag outs, dag ins, string asmstr, list<dag> pattern>
  : IForm8<opcode, DstMem, SrcMem, 6, outs, ins, asmstr, pattern>;

// 16 bit IForm instructions
class IForm16<bits<4> opcode, DestMode dest, SourceMode src, int size,
              dag outs, dag ins, string asmstr, list<dag> pattern>
  : IForm<opcode, dest, 0, src, size, outs, ins, asmstr, pattern>;

class I16rr<bits<4> opcode,
            dag outs, dag ins, string asmstr, list<dag> pattern>
  : IForm16<opcode, DstReg, SrcReg, 2, outs, ins, asmstr, pattern>;

class I16ri<bits<4> opcode,
            dag outs, dag ins, string asmstr, list<dag> pattern>
  : IForm16<opcode, DstReg, SrcImm, 4, outs, ins, asmstr, pattern>;

class I16rm<bits<4> opcode,
            dag outs, dag ins, string asmstr, list<dag> pattern>
  : IForm16<opcode, DstReg, SrcMem, 4, outs, ins, asmstr, pattern>;

class I16mr<bits<4> opcode,
            dag outs, dag ins, string asmstr, list<dag> pattern>
  : IForm16<opcode, DstMem, SrcReg, 4, outs, ins, asmstr, pattern>;

class I16mi<bits<4> opcode,
            dag outs, dag ins, string asmstr, list<dag> pattern>
  : IForm16<opcode, DstMem, SrcImm, 6, outs, ins, asmstr, pattern>;

class I16mm<bits<4> opcode,
            dag outs, dag ins, string asmstr, list<dag> pattern>
  : IForm16<opcode, DstMem, SrcMem, 6, outs, ins, asmstr, pattern>;

// MSP430 Single Operand (Format II) Instructions
class IIForm<bits<9> opcode, bit bw, SourceMode src, int size,
             dag outs, dag ins, string asmstr, list<dag> pattern>
  : MSP430Inst<outs, ins, size, asmstr> {
  let Pattern = pattern;
  
  SourceMode as = src;

  let Inst{7-15} = opcode;
  let Inst{6}    = bw;
  let Inst{4-5}  = as.Value;
}

// 8 bit IIForm instructions
class IIForm8<bits<9> opcode, SourceMode src, int size,
              dag outs, dag ins, string asmstr, list<dag> pattern>
  : IIForm<opcode, 1, src, size, outs, ins, asmstr, pattern>;

class II8r<bits<9> opcode,
           dag outs, dag ins, string asmstr, list<dag> pattern>
  : IIForm8<opcode, SrcReg, 2, outs, ins, asmstr, pattern>;

class II8m<bits<9> opcode,
           dag outs, dag ins, string asmstr, list<dag> pattern>
  : IIForm8<opcode, SrcMem, 4, outs, ins, asmstr, pattern>;

class II8i<bits<9> opcode,
           dag outs, dag ins, string asmstr, list<dag> pattern>
  : IIForm8<opcode, SrcImm, 4, outs, ins, asmstr, pattern>;

// 16 bit IIForm instructions
class IIForm16<bits<9> opcode, SourceMode src, int size,
               dag outs, dag ins, string asmstr, list<dag> pattern>
  : IIForm<opcode, 0, src, size, outs, ins, asmstr, pattern>;

class II16r<bits<9> opcode,
            dag outs, dag ins, string asmstr, list<dag> pattern>
  : IIForm16<opcode, SrcReg, 2, outs, ins, asmstr, pattern>;

class II16m<bits<9> opcode,
            dag outs, dag ins, string asmstr, list<dag> pattern>
  : IIForm16<opcode, SrcMem, 4, outs, ins, asmstr, pattern>;

class II16i<bits<9> opcode,
            dag outs, dag ins, string asmstr, list<dag> pattern>
  : IIForm16<opcode, SrcImm, 4, outs, ins, asmstr, pattern>;

// MSP430 Conditional Jumps Instructions
class CJForm<bits<3> opcode, bits<3> cond,
             dag outs, dag ins, string asmstr, list<dag> pattern>
  : MSP430Inst<outs, ins, 2, asmstr> {
  let Pattern = pattern;
  
  let Inst{13-15} = opcode;
  let Inst{10-12} = cond;
}

// Pseudo instructions
class Pseudo<dag outs, dag ins, string asmstr, list<dag> pattern>
  : MSP430Inst<outs, ins, 0, asmstr> {
  let Pattern = pattern;
  let Inst{15-0} = 0;
}
