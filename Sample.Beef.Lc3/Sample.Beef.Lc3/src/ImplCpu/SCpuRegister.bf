using System;

namespace Sample.Beef.Lc3.ImplCpu;

struct SCpuRegister
{
    enum E_FLAGS
    {
        FL_POS = 1 << 0, /* P */
        FL_ZRO = 1 << 1, /* Z */
        FL_NEG = 1 << 2, /* N */
    }

    uint16[10] _reg;

    public ref uint16 R_R0 mut => ref _reg[0];
    public ref uint16 R_R1 mut => ref _reg[1];
    public ref uint16 R_R2 mut => ref _reg[2];
    public ref uint16 R_R3 mut => ref _reg[3];
    public ref uint16 R_R4 mut => ref _reg[4];
    public ref uint16 R_R5 mut => ref _reg[5];
    public ref uint16 R_R6 mut => ref _reg[6];
    public ref uint16 R_R7 mut => ref _reg[7];
    public ref uint16 R_PC mut => ref _reg[8]; /* program counter */
    public ref uint16 R_COND mut => ref _reg[9];
    public ref uint16 this[int index] mut => ref _reg[index];

    public void update_flags(uint16 r) mut
    {
        if (_reg[r] == 0)
        {
            R_COND = (.)E_FLAGS.FL_ZRO;
        }
        else if (_reg[r] >> 15 != 0) /* a 1 in the left-most bit indicates negative */
        {
            R_COND = (.)E_FLAGS.FL_NEG;
        }
        else
        {
            R_COND = (.)E_FLAGS.FL_POS;
        }
    }

    public void Init() mut
    {
        /* since exactly one condition flag should be set at any given time, set the Z flag */
        R_COND = (.)E_FLAGS.FL_ZRO;

        /* set the PC to starting position */
        /* 0x3000 is the default */
        const uint16 PC_START = 0x3000;
        R_PC = PC_START;
    }

    public override void ToString(String outString) mut
    {
        outString.Append("======== Register ===========\n");
        outString.AppendF("R0: 0x{:X4}\n", R_R0);
        outString.AppendF("R1: 0x{:X4}\n", R_R1);
        outString.AppendF("R2: 0x{:X4}\n", R_R2);
        outString.AppendF("R3: 0x{:X4}\n", R_R3);
        outString.AppendF("R4: 0x{:X4}\n", R_R4);
        outString.AppendF("R5: 0x{:X4}\n", R_R5);
        outString.AppendF("R6: 0x{:X4}\n", R_R6);
        outString.AppendF("R7: 0x{:X4}\n", R_R7);
        outString.Append("FL: ");
        outString.Append((R_COND == (.)E_FLAGS.FL_POS) ? "P" : ".");
        outString.Append((R_COND == (.)E_FLAGS.FL_ZRO) ? "Z" : ".");
        outString.Append((R_COND == (.)E_FLAGS.FL_NEG) ? "N" : ".");
        outString.Append("\n");
        outString.AppendF("PC: 0x{:X4}\n", R_PC);
    }
}
