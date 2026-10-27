using System;

namespace Sample.Beef.Lc3.ImplPlatform;

static
{
    public static readonly IPlatform S_PLATFORM = new Platform_Windows() ~ delete _;
}

interface IPlatform
{
    void disable_input_buffering();
    void restore_input_buffering();
    bool check_key();
}

#if BF_PLATFORM_WINDOWS
class Platform_Windows : IPlatform
{
    Windows.Handle hStdin = .InvalidHandle;
    uint32 fdwMode;
    uint32 fdwOldMode;

    public void disable_input_buffering()
    {
        hStdin = Windows.GetStdHandle(Windows.STD_INPUT_HANDLE);
        Console.[Friend]GetConsoleMode(hStdin, out fdwOldMode); /* save old mode */
        fdwMode = fdwOldMode
            ^ Console.[Friend]ENABLE_ECHO_INPUT /* no input echo */
            ^ Console.[Friend]ENABLE_LINE_INPUT; /* return when one or more characters are available */
        Console.[Friend]SetConsoleMode(hStdin, fdwMode); /* set new mode */
        FlushConsoleInputBuffer(hStdin); /* clear buffer */
    }

    public void restore_input_buffering()
    {
        Console.[Friend]SetConsoleMode(hStdin, fdwOldMode);
    }

    public bool check_key()
    {
        let waitObject = Windows.WaitForSingleObject(hStdin, 1000);
        switch (waitObject) {
        case Windows.WAIT_OBJECT_0: return Console.KeyAvailable;
        case Windows.WAIT_ABANDONED: return false;
        case Windows.WAIT_TIMEOUT: return false;
        case Windows.WAIT_FAILED: return false;
        default:
            Runtime.FatalError();
        }
    }

    [CLink, CallingConvention(.Stdcall)]
    static extern Windows.IntBool FlushConsoleInputBuffer(Windows.Handle hConsoleInput);
}
#endif // BF_PLATFORM_WINDOWS