# Sample.Beef.Lc3

Sample [[LC3](Little Computer 3)](https://en.wikipedia.org/wiki/Little_Computer_3) Emulator Implemented in the Beef.

- [beeflang](https://www.beeflang.org/)

## Ref


-  [Write your Own Virtual Machine By: Justin Meiners and Ryan Pendleton](https://www.jmeiners.com/lc3-vm/)
   - <https://www.jmeiners.com/>
   - <https://www.jmeiners.com/lc3-vm/supplies/lc3-isa.pdf>
   - roms
     - <https://github.com/rpendleton/lc3-2048>
     - <https://github.com/justinmeiners/lc3-rogue>
   - <https://highered.mheducation.com/sites/0072467509/student_view0/lc-3_simulator.html>
     - LC3Edit.exe > Translate > Assemble
- <https://acg.cis.upenn.edu/milom/cse240-Fall05/handouts/lc3guide.html>
- <https://pc-fan.net/lc3-vm-c-series-summary/>
  - <https://zenn.dev/pcfan/books/01609be22b38cf>
  - <https://github.com/k1117n-cmyk/lc3-vm-c/>
- <https://github.com/kobby-pentangeli/lc3box>
  - cargo run -p lc3box -- asm examples/hello_world.asm -o hello_world.obj
- Introduction To Computing Systems: From Bits & Gates To C/C++ & Beyond
  - CHAPTER5 The LC-3
- <https://github.com/leachim6/hello-world/blob/main/a/Assembler%20lc3.asm>

``` asm
.ORIG x3000
	LEA R0, HELLOWORLD
	PUTS
	HALT
	
HELLOWORLD .STRINGZ "Hello World\n"

	.END
```
