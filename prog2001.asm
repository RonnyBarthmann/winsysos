MOV AX, CS
MOV DS, AX
MOV ES, AX

MOV SI, LoadString
CALL WriteString

MOV [tempDw], 512
MOV [tempCw], 2755

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
	CMP [tempCw], 2880
	je .exitload
	jmp .z
      .exitload:

	MOV AX, CS
	MOV DS, AX
	MOV ES, AX
	MOV AH, 00h
	MOV AL, 13h
	INT 10h

	MOV [tempEw], 0
	MOV [tempFw], 199
	MOV SI, Picture
    .y:
      .x:
	MOV AH, 0Ch
	LODSB	 ; Farbe
	MOV BH, 0      ; Seite
	MOV CX, [tempEw]     ; X-Pos
	MOV DX, [tempFw]     ; Y-Pos
	INT 10h
	CMP [tempEw], 319
	jb .nextx
	CMP [tempFw], 0
	ja .nexty
	jmp .end
      .nextx:
	ADD [tempEw], 1
	jmp .x
      .nexty:
	MOV [tempEw], 0
	SUB [tempFw], 1
	jmp .y
      .end:

	CALL WaitForKey

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

WaitForKey: ; No
	MOV AH, 0		; Funktion
	INT 16h 		; Zeichen einlesen
	CMP AL, 13		; Ist AL = 13 ?
	JE WaitForKeyEnd	   ; dann Abbruch
	CMP AL, 32		; Ist AL = 32 ?
	JE WaitForKeyEnd	   ; dann Abbruch
	JMP WaitForKey		   ; Naechster Durchlauf
      WaitForKeyEnd:
	RETN ; No               ; Funktionsruecksprung

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

LoadString	db 'Lade Bildsektoren ... Bitte warten ...',13,10,0

Variables:
TempWord	dw 0
TempByte	db 0
Sektor		db 0
Track		db 0
Head		db 0
tempCw		dw 0
tempDw		dw 0
tempEw		dw 0
tempFw		dw 0

TIMES 512-($-$$) DB 0

Picture:
