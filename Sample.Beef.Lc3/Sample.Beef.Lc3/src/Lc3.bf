using System;
using System.Collections;
using System.IO;
using Sample.Beef.Lc3.ImplCpu;

namespace Sample.Beef.Lc3;

class Lc3
{
    internal Cpu Cpu = new Cpu() ~ delete _;

    public bool LoadRom(StringView romPath)
    {
        List<uint8> data = new List<uint8>();
        MemoryStream ms = scope MemoryStream(data);
        if (File.ReadAll(romPath, data) case .Err(let err))
        {
            return false;
        }

        Cpu.Bus.LoadRom(ms);

        return true;
    }

    public void Run()
    {
        Cpu.Init();
        Cpu.Run();
        Cpu.Deinit();
    }
}
