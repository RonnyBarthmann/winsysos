org 7C00h
use16

init:
	MOV AX, CS
	MOV DS, AX
	MOV ES, AX

welcome:
	jmp Version

start:
	MOV SI, NewLine
	CALL WriteString
	MOV DI, Command
	CALL ReadString
	MOV SI, NewLine
	CALL WriteString
	MOV CX, 6
	MOV SI, ResetCd
	MOV DI, Command
	REP CMPSB
	jz Reset
	MOV CX, 5
	MOV SI, ExitCmd
	MOV DI, Command
	REP CMPSB
	jz Exit
	MOV CX, 4
	MOV SI, VerComd
	MOV DI, Command
	REP CMPSB
	jz Version
	MOV CX, 1
	MOV SI, NoneCmd
	MOV DI, Command
	REP CMPSB
	jz start
	MOV CX, 20
	MOV DX, ErrFlag
	CALL SetFlag
	MOV SI, ErrStrg
	CALL WriteString
	jmp start

Reset:
	MOV CX, 30
	MOV DX, ResetFg
	CALL SetFlag
	MOV SI, ResetSt
	CALL WriteString
	INT 19h

Exit:
	MOV CX, 28
	MOV DX, ExitFlg
	CALL SetFlag
	MOV SI, ExitStr
	CALL WriteString
	CLI
	hlt
	STI

Hang:
	jmp Hang

Version:
	MOV CX, 20
	MOV DX, VerFlag
	CALL SetFlag
	MOV SI, VerStrg
	CALL WriteString
	jmp start

WriteString:
	LODSB
	CMP AL, 0
	JE WriteStringEnd
	MOV AH, 0Eh
	MOV BH, 0
	INT 10h
	JMP WriteString
      WriteStringEnd:
	RETN

SetFlag:
	PUSH DX
	PUSH CX
	MOV AH, 03h
	MOV BH, 0
	INT 10h
	MOV AX, 0B800h
	MOV ES, AX
	POP CX
	MOV AL, DL
	MOV AH, 0
	MOV BL, DH
	MOV BH, 0
	MOV DI, BX
	IMUL DI, 160
	ADD DI, AX
	POP DX
	MOV SI, DX
      SetFlagNext:
	INC DI
	MOVSB
	DEC CX
	CMP CX, 0
	JE SetFlagEnd
	jmp SetFlagNext
      SetFlagEnd:
	MOV AX, CS
	MOV DS, AX
	MOV ES, AX
	RETN

ReadString:
	MOV AH, 0
	INT 16h
	CMP AL, 13
	JE ReadStringEnd
	CMP AL, 8
	JE ClearChar
	STOSB
	MOV AH, 0Eh
	MOV BH, 0
	INT 10h
	JMP ReadString
      ClearChar:
	SUB DI, 1
	MOV AH, 0Eh
	MOV BH, 0
	INT 10h
	MOV AL, 32
	MOV AH, 0Eh
	MOV BH, 0
	INT 10h
	MOV AL, 8
	MOV AH, 0Eh
	MOV BH, 0
	INT 10h
	JMP ReadString
      ReadStringEnd:
	MOV AL, 0
	STOSB
	RETN

DataArea:
      BufferArea:
	Command db '        '
      CommandArea:
	ResetCd db 'reset',0
	ExitCmd db 'exit',0
	VerComd db 'ver',0
	NoneCmd db 0
      StringArea:
	ExitStr db 'Bitte den PC ausschalten ...',13,10,0
	ExitFlg db 0Fh,0Fh,0Fh,0Fh,0Fh,07h,07h,07h,07h,07h,0Fh,0Fh,07h,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,07h,07h,07h,07h
	ResetSt db 'System wird zurueckgesetzt ...',13,10,0
	ResetFg db 0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,07h,07h,07h,07h,07h,07h,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,07h,07h,07h,07h
	ErrStrg db 'Ungueltiger Befehl !',13,10,0
	ErrFlag db 0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,07h,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,07h,0Fh
	VerStrg db 'ASmallOS v0.0.1 Beta',13,10,0
	VerFlag db 0Bh,0Bh,0Bh,0Bh,0Bh,0Bh,0Bh,0Bh,07h,0Fh,0Fh,07h,07h,07h,07h,07h,0Ch,0Ch,0Ch,0Ch
	NewLine db 13,10,0

TIMES 512-($-$$)-2 DB 0
DW 0xAA55