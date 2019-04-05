MOV AX, CS
MOV DS, AX
MOV ES, AX

MOV [tempDw], 512
MOV [tempCw], 2750
	CALL InitFloppy

      .z:
	MOV AX, [tempCw]
	MOV BX, [tempDw]
	MOV CX, 1
	MOV DX, 0
	PUSHAD
	CALL ReadFloppy
	POPAD
	ADD [tempCw], 1
	ADD [tempDw], 512
	CMP [tempCw], 2755
	je .exitload
	jmp .z
      .exitload:

	jmp 512

	RETF

InitFloppy: ; AX = Floppy
	PUSHAD
	MOV AH, 0
	MOV DL, AL
	INT 13h
	MOV [TempByte], AH
	POPAD
	MOV AH, 0
	MOV AL, [TempByte]
	RETN ; AX = Fehlercode

ReadFloppy: ; AX = Sektor / BX = Buffer / CX = Anzahl / DX = Floppy / ES = Offset
	PUSHAD
	PUSH BX
	PUSH CX
	PUSH DX
	PUSH ES
	MOV DX, 0
	MOV BX, 18
	DIV BX
	MOV [Sektor], DL
	MOV [Track], AL
	MOV AH, 0
	MOV AL, [Track]
	MOV BL, 2
	DIV BL
	MOV [Track], AL
	MOV [Head], AH
	ADD [Sektor], 1
	POP ES
	POP DX
	POP CX
	POP BX
	MOV AH, 2
	MOV AL, CL
	MOV DH, [Head]
	MOV CH, [Track]
	MOV CL, [Sektor]
	INT 13h
	MOV [TempByte], AH
	POPAD
	MOV AH, 0
	MOV AL, [TempByte]
	RETN ; AX = Fehlercode

Variables:
TempWord	dw 0
TempByte	db 0
Sektor		db 0
Track		db 0
Head		db 0
tempCw		dw 0
tempDw		dw 0

TIMES 512-($-$$) DB 0

