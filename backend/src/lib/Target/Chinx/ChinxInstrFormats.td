class Format<bits<4> val> {
    bits<4> Value = val;
}

def Pseudo : Format<0>;
def FrmR : Format<1>;
def FrmI : Format<2>;
def FrmJ : Format<3>;
def FrmOther : Format<4>;

class ChinxInst<dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin, Format f> :
    Instruction {
        field bits<32> Inst;
        Format Form = f;
        let Namespace = "Chinx";
        let Size = 4;
        bits<6> Opcode = 0;
        let Inst{31-26} = Opcode;
        let OutOperandList = outs;
        let InOperandList = ins;
        let AsmString = asmstr;
        let Pattern = pattern;
        let Itinerary = itin;
        bits<4> FormBits = Form.Value;
        let TSFlags{3-0} = FormBits;
        let DecoderNamespace = "Chinx";
        field bits<32> SoftFail = 0;
    }

class FR<bits<6> op, dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin> :
    ChinxInst<outs, ins, asmstr, pattern, itin, FrmR>
    {
        bits<5> ra;
        bits<5> rb;
        bits<5> rc;
        bits<11> reserved;
        let Opcode = op;
        let Inst{25-21} = ra;
        let Inst{20-16} = rb;
        let Inst{15-11} = rc;
        let Inst{10-0} = reserved;
    }

class FI<bits<6> op, dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin> :
    ChinxInst<outs, ins, asmstr, pattern, itin, FrmI>
    {
        bits<5> ra;
        bits<5> rb;
        bits<16> imm16;
        let Opcode = op;
        let Inst{25-21} = ra;
        let Inst{20-16} = rb;
        let Inst{15-0} = imm16;
    }

class FJ<bits<6> op, dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin> :
    ChinxInst<outs, ins, asmstr, pattern, itin, FrmJ>
    {
        bits<26> addr;
        let Opcode = op;
        let Inst{25-0} = addr;
    }