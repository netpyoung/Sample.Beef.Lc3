using System;
using System.Collections;
using System.IO;

using internal Sample.Beef.Lc3;

namespace Sample.Beef.Lc3.Tests;

class Test_Lc3
{
    [Test]
    public static void Test_Hello()
    {
        Lc3 lc3 = scope Lc3();

        List<uint16> list16 = scope List<uint16>();
        list16.Add(0x3000); // .ORIG x3000
        list16.Add(0xF025); // HALT

        lc3.Cpu.Bus.LoadRom(list16);
        lc3.Cpu.Init();
        defer lc3.Cpu.Deinit();

        lc3.Cpu.Step();
        Test.Assert(lc3.Cpu.Register.R_PC == 0x3001);
    }
}



//struct RedirectToFile : IDisposable
//{
//    public this(StringView path)
//    {
//        FileStream fs = new FileStream();
//        if (fs.Create(path, .Write) case .Err)
//        {
//            return;
//        }
//
//        StreamWriter writer = new StreamWriter(fs, Encoding.UTF8, bufferSize: 4096, ownsStream: true);
//        writer.AutoFlush = false;
//
//        Console.mOut = writer;
//        Console.[Friend]OutputEncoding = Encoding.UTF8;
//    }
//
//    public void Dispose()
//    {
//        Console.mOut.Flush();
//    }
//}