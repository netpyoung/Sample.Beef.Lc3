using System;
using System.Collections;
using System.IO;
using Sample.Beef.Lc3.ImplPlatform;

namespace Sample.Beef.Lc3.ImplCpu;

struct SCpuBuss
{
    enum E_MR // Memory Mapped Registers
    {
        MR_KBSR = 0xFE00, /* keyboard status */
        MR_KBDR = 0xFE02 /* keyboard data */
    }

    const int MEMORY_MAX = (1 << 16);
    uint16[MEMORY_MAX] memory = .(); /* 65536 locations */

    public uint16 Read(uint16 address) mut
    {
        if (address == (.)E_MR.MR_KBSR)
        {
            if (S_PLATFORM.check_key())
            {
                memory[(.)E_MR.MR_KBSR] = (1 << 15);
                memory[(.)E_MR.MR_KBDR] = (uint16)(char8)Console.Read().Get();
            }
            else
            {
                memory[(.)E_MR.MR_KBSR] = 0;
            }
        }

        return memory[address];
    }

    public void Write(uint16 address, uint16 val) mut
    {
        memory[address] = val;
    }

    public Span<uint16> GetMemorySpan() mut
    {
        return .(&memory, memory.Count);
    }

    // public void LoadRom(List<uint8> list)
    public void LoadRom(MemoryStream ms_BigEndian) mut
    {
        /* the origin tells us where in memory to place the image */
        uint16 origin = ms_BigEndian.Read<uint16>().Get();
        origin = swapBigEndianToLittleEndian16(origin);

        /* we know the maximum file size so we only need one fread */
        uint16 max_read = (.)(MEMORY_MAX - origin);

        Span<uint16> p = GetMemorySpan();
        p.Adjust(origin);

        loop:for (int i = 0; i < max_read; ++i)
        {
            switch (ms_BigEndian.Read<uint16>())
            {
            case .Err:
                break loop;
            case .Ok(let val):
                p[0] = val;
                /* swap to little endian */
                p[0] = swapBigEndianToLittleEndian16(p[0]);
                p.Adjust(1);
            }
        }
    }

    public void LoadRom(Span<uint16> littleEndianVals) mut
    {
        uint16 origin = littleEndianVals[0];
        origin = origin;

        Span<uint16> p = GetMemorySpan();
        p.Adjust(origin);

        loop:for (int i = 1; i < littleEndianVals.Length; ++i)
        {
            p[0] = littleEndianVals[i];
            p.Adjust(1);
        }
    }

    [Inline]
    uint16 swapBigEndianToLittleEndian16(uint16 big)
    {
        uint16 little = (big << 8) | (big >> 8);
        return little;
    }
}