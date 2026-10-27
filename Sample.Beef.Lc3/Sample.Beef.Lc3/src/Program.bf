using System;
using Sample.Beef.Lc3.ImplCpu;

namespace Sample.Beef.Lc3;

class Program
{
    public static void Main(String[] args)
    {
        String[] args2 = scope String[1];
        args2[0] = "assets/helloworld.obj";

        String[] romPaths = args2;

        int argc = romPaths.Count;
        if (argc < 1)
        {
            /* show usage string */
            Console.WriteLine("lc3 [image-file1] ...");
            Environment.Exit(2);
        }

        Lc3 lc3 = scope Lc3();
        for (let romPath in romPaths)
        {
            if (!lc3.LoadRom(romPath))
            {
                Console.WriteLine("failed to load image: {}", romPath);
                Environment.Exit(1);
            }
        }
        lc3.Run();
    }
}