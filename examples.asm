MOV AX, CS
MOV DS, AX
MOV ES, AX

MOV CX, 13
MOV DX, welcome
CALL SetFlag
MOV SI, Welcome
CALL WriteString
MOV SI, NewLine
CALL WriteString

RETF

WriteString: ; SI = String
	LODSB			; Zeichen nach AL kopieren
	CMP AL, 0		; Ist AL = 0 ?
	JE WriteStringEnd	; dann Abbruch
	MOV AH, 0Eh		; Funktion
	MOV BH, 0		; Bildschirmseite
	INT 10h 		; Schreiben
	JMP WriteString 	; Naechster Durchlauf
      WriteStringEnd:
	RETN ; No               ; Funktionsruecksprung

SetFlag: ; CX = Leange / DX = Flag
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
	RETN ; No

Welcome db 'Hello World !',13,10,0
welcome db 0Bh,0Bh,0Bh,0Bh,0Bh,07h,0Fh,0Fh,0Fh,0Fh,0Fh,07h,0Ch
NewLine db 13,10,0

TIMES 512-($-$$) DB 0