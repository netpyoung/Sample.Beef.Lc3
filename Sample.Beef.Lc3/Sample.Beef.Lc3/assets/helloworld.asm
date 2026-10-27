; LC3Edit.exe > Translate > Assemble

.ORIG x3000
	LEA R0, HELLOWORLD
	PUTS
	HALT
	
HELLOWORLD .STRINGZ "Hello World\n"

	.END