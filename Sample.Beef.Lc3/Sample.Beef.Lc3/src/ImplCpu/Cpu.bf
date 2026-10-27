using System;

using Sample.Beef.Lc3.ImplPlatform;

namespace Sample.Beef.Lc3.ImplCpu;

class Cpu
{
    enum E_OPCODE
    {
        OP_BR = 0x00, /* branch */
        OP_ADD = 0x01, /* add  */
        OP_LD = 0x02, /* load */
        OP_ST = 0x03, /* store */
        OP_JSR = 0x04, /* jump register */
        OP_AND = 0x05, /* bitwise and */
        OP_LDR = 0x06, /* load register */
        OP_STR = 0x07, /* store register */
        OP_RTI = 0x08, /* unused */
        OP_NOT = 0x09, /* bitwise not */
        OP_LDI = 0x0A, /* load indirect */
        OP_STI = 0x0B, /* store indirect */
        OP_JMP = 0x0C, /* jump */
        OP_RES = 0x0D, /* reserved (unused) */
        OP_LEA = 0x0E, /* load effective address */
        OP_TRAP  = 0x0F /* execute trap */
    }

    enum E_TRAP
    {
        TRAP_GETC = 0x20, /* get character from keyboard, not echoed onto the terminal */
        TRAP_OUT = 0x21, /* output a character */
        TRAP_PUTS = 0x22, /* output a word string */
        TRAP_IN = 0x23, /* get character from keyboard, echoed onto the terminal */
        TRAP_PUTSP = 0x24, /* output a byte string */
        TRAP_HALT = 0x25 /* halt the program */
    }

    internal SCpuRegister Register = .();

    public SCpuBuss Bus = .();

    public void Init()
    {
        Console.OnCancel.Add(new => OnCancel);
        S_PLATFORM.disable_input_buffering();

        Register.Init();
    }

    public void Deinit()
    {
        S_PLATFORM.restore_input_buffering();
    }

    void OnCancel(Console.CancelKind cancelKind, ref bool terminate)
    {
        S_PLATFORM.restore_input_buffering();
        Console.WriteLine();
        Environment.Exit(-2);
    }

    uint16 FetchU16()
    {
        uint16 data = Bus.Read(Register.R_PC);
        Register.R_PC++;
        return data;
    }

    public void Run()
    {
        while (true)
        {
            if (!Step())
            {
                break;
            }
        }
    }

    internal bool Step()
    {
        uint16 instr = FetchU16();
        uint16 op = instr >> 12;

        switch ((E_OPCODE)op)
        {
        case .OP_ADD:
            /* destination register (DR) */
            uint16 r0 = (instr >> 9) & 0x7;
            /* first operand (SR1) */
            uint16 r1 = (instr >> 6) & 0x7;
            /* whether we are in immediate mode */
            uint16 imm_flag = (instr >> 5) & 0x1;

            if (imm_flag != 0)
            {
                uint16 imm5 = sign_extend(instr & 0x1F, 5);
                Register[r0] = Register[r1] + imm5;
            }
            else
            {
                uint16 r2 = instr & 0x7;
                Register[r0] = Register[r1] + Register[r2];
            }

            Register.update_flags(r0);
        case .OP_AND:
            uint16 r0 = (instr >> 9) & 0x7;
            uint16 r1 = (instr >> 6) & 0x7;
            uint16 imm_flag = (instr >> 5) & 0x1;

            if (imm_flag != 0)
            {
                uint16 imm5 = sign_extend(instr & 0x1F, 5);
                Register[r0] = Register[r1] & imm5;
            }
            else
            {
                uint16 r2 = instr & 0x7;
                Register[r0] = Register[r1] & Register[r2];
            }
            Register.update_flags(r0);
        case .OP_NOT:
            uint16 r0 = (instr >> 9) & 0x7;
            uint16 r1 = (instr >> 6) & 0x7;

            Register[r0] = ~Register[r1];
            Register.update_flags(r0);
        case .OP_BR:
            uint16 pc_offset = sign_extend(instr & 0x1FF, 9);
            uint16 cond_flag = (instr >> 9) & 0x7;
            if (cond_flag & Register.R_COND != 0)
            {
                Register.R_PC += pc_offset;
            }
        case .OP_JMP:
            /* Also handles RET */
            uint16 r1 = (instr >> 6) & 0x7;
            Register.R_PC = Register[r1];
        case .OP_JSR:
            uint16 long_flag = (instr >> 11) & 1;
            Register.R_R7 = Register.R_PC;
            if (long_flag != 0)
            {
                uint16 long_pc_offset = sign_extend(instr & 0x7FF, 11);
                Register.R_PC += long_pc_offset; /* JSR */
            }
            else
            {
                uint16 r1 = (instr >> 6) & 0x7;
                Register.R_PC = Register[r1]; /* JSRR */
            }
        case .OP_LD:
            uint16 r0 = (instr >> 9) & 0x7;
            uint16 pc_offset = sign_extend(instr & 0x1FF, 9);
            Register[r0] = Bus.Read(Register.R_PC + pc_offset);
            Register.update_flags(r0);
        case .OP_LDI:
            /* destination register (DR) */
            uint16 r0 = (instr >> 9) & 0x7;
            /* PCoffset 9*/
            uint16 pc_offset = sign_extend(instr & 0x1FF, 9);
            /* add pc_offset to the current PC, look at that memory location to get the final address */
            Register[r0] = Bus.Read(Bus.Read(Register.R_PC + pc_offset));
            Register.update_flags(r0);
        case .OP_LDR:
            uint16 r0 = (instr >> 9) & 0x7;
            uint16 r1 = (instr >> 6) & 0x7;
            uint16 offset = sign_extend(instr & 0x3F, 6);
            Register[r0] = Bus.Read(Register[r1] + offset);
            Register.update_flags(r0);
        case .OP_LEA:

            uint16 r0 = (instr >> 9) & 0x7;
            uint16 pc_offset = sign_extend(instr & 0x1FF, 9);
            Register[r0] = Register.R_PC + pc_offset;
            Register.update_flags(r0);
        case .OP_ST:
            uint16 r0 = (instr >> 9) & 0x7;
            uint16 pc_offset = sign_extend(instr & 0x1FF, 9);
            Bus.Write(Register.R_PC + pc_offset, Register[r0]);
        case .OP_STI:
            uint16 r0 = (instr >> 9) & 0x7;
            uint16 pc_offset = sign_extend(instr & 0x1FF, 9);
            Bus.Write(Bus.Read(Register.R_PC + pc_offset), Register[r0]);
        case .OP_STR:
            {
                uint16 r0 = (instr >> 9) & 0x7;
                uint16 r1 = (instr >> 6) & 0x7;
                uint16 offset = sign_extend(instr & 0x3F, 6);
                Bus.Write(Register[r1] + offset, Register[r0]);
            }
        case .OP_TRAP:
            Register.R_R7 = Register.R_PC;

            switch ((E_TRAP)(instr & 0xFF))
            {
            case .TRAP_GETC:
                /* read a single ASCII char */
                Register.R_R0 = (uint16)Console.Read().Get();
                Register.update_flags(0);
            case .TRAP_OUT:
                Console.Write((char8)Register.R_R0);
                Console.Out.Flush();
            case .TRAP_PUTS:
                /* one char per word */

                Span<uint16> s = Bus.GetMemorySpan();
                s.Adjust(Register.R_R0);
                for (let c in s)
                {
                    if (c == 0)
                    {
                        break;
                    }
                    Console.Write((char8)c);
                }
                Console.Out.Flush();
            case .TRAP_IN:
                Console.Write("Enter a character: ");
                char8 c = Console.Read().Get();
                Console.Write(c);
                Console.Out.Flush();
                Register.R_R0 = (uint16)c;
                Register.update_flags(0);
            case .TRAP_PUTSP:
                Span<uint16> s = Bus.GetMemorySpan();
                s.Adjust(Register.R_R0);

                for (let c in s)
                {
                    if (c == 0)
                    {
                        break;
                    }

                    char8 char1 = (.)(c & 0xFF);
                    Console.Write(char1);
                    char8 char2 = (.)(c >> 8);
                    if (char2 != 0)
                    {
                        Console.Write(char2);
                    }
                }
                Console.Out.Flush();
            case .TRAP_HALT:
                Console.Write("HALT");
                Console.Out.Flush();
                return false;
            }
        case .OP_RES: fallthrough;
        case .OP_RTI: fallthrough;
        default:
            Runtime.FatalError();
        }

        return true;
    }

    static uint16 sign_extend(uint16 x, int bit_count)
    {
        if ((x >> (bit_count - 1)) & 1 != 0)
        {
            return x | (0xFFFF << bit_count);
        }

        return x;
    }
}
