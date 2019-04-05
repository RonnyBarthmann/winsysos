
VERSION_STRING_1 equ '[Version: 0.0.3 Beta]'
VERSION_STRING_2 equ 'v0.0.3 Beta'

InitSegment:
	MOV AX, CS		; Kopiere das CodeSegment nach AX
	MOV DS, AX		; Setze das DatenSegment auf das CodeSegment
	MOV ES, AX		; Setze das ExtraSegment auf das CodeSegment

SetupInt21h:
	SHL EAX, 16
	MOV AX, Interrupt21h
	MOV BX, 0
	MOV FS, BX
	CLI
	MOV [FS:21h*4], EAX
	STI

LoadSettings:
	MOV AX, 999
	MOV BX, SettingsArea
	MOV CX, 1
	MOV DX, 0
	CALL ReadFloppy

InitSession:
	CMP [Name], 0
	Je Registry
	CMP [Pass], 0
	je Welcome
	MOV SI, NextLine
	CALL WriteString
	MOV SI, PasswordString
	CALL WriteString
	MOV DI, Buffer
	CALL ReadPassword
	MOV CX, word [PassLen]
	MOV SI, Pass
	MOV DI, Buffer
	REP CMPSB
	jz Welcome
	jmp InitSession


Welcome:
	CALL ClearScreen
	MOV AX, 0
	MOV BX, 0
	MOV CX, MSG_Welcome
	MOV DX, FLG_Welcome
	CALL WriteRawString
	MOV AX, 0
	MOV BX, 7
	CALL SetCursor
	CALL GetCursor
	MOV SI, NextLine
	CALL WriteString
	CALL WriteColorWarning
	MOV SI, NextLine
	CALL WriteString
	MOV SI, UserString
	CALL WriteString
	MOV SI, Name
	CALL WriteString
	MOV SI, NextLine
	CALL WriteString
	MOV SI, NextLine
	CALL WriteString


start:
	MOV SI, PrefixS
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
	MOV CX, 4
	MOV SI, ClsComd
	MOV DI, Command
	REP CMPSB
	jz Clear
	MOV CX, 5
	MOV SI, HelpCmd
	MOV DI, Command
	REP CMPSB
	jz Help
	MOV CX, 5
	MOV SI, InfoCmd
	MOV DI, Command
	REP CMPSB
	jz Info
	MOV CX, 8
	MOV SI, ChangeC
	MOV DI, Command
	REP CMPSB
	jz Changes
	MOV CX, 5
	MOV SI, ReadCmd
	MOV DI, Command
	REP CMPSB
	jz Read1
	MOV CX, 6
	MOV SI, WriteCd
	MOV DI, Command
	REP CMPSB
	jz Write1
	MOV CX, 8
	MOV SI, RReadCd
	MOV DI, Command
	REP CMPSB
	jz RawRead1
	MOV CX, 9
	MOV SI, RWriteC
	MOV DI, Command
	REP CMPSB
	jz RawWrite1
	MOV CX, 5
	MOV SI, readCmd
	MOV DI, Command
	REP CMPSB
	jz Read2
	MOV CX, 6
	MOV SI, writeCd
	MOV DI, Command
	REP CMPSB
	jz Write2
	MOV CX, 8
	MOV SI, rReadCd
	MOV DI, Command
	REP CMPSB
	jz RawRead2
	MOV CX, 9
	MOV SI, rWriteC
	MOV DI, Command
	REP CMPSB
	jz RawWrite2
	MOV CX, 9
	MOV SI, RegComd
	MOV DI, Command
	REP CMPSB
	jz Registry
	MOV CX, 1
	MOV SI, NoneCmd
	MOV DI, Command
	REP CMPSB
	jz start
	MOV CX, 20
	MOV DX, UnknFlg
	CALL SetFlag
	MOV SI, Unknown
	CALL WriteString
	jmp start

Registry:
      .false:
	CMP [Pass], 0
	je .true
	MOV SI, NextLine
	CALL WriteString
	MOV SI, PasswordString
	CALL WriteString
	MOV DI, Buffer
	CALL ReadPassword
	MOV CX, word [PassLen]
	MOV SI, Pass
	MOV DI, Buffer
	REP CMPSB
	MOV SI, NewLine
	CALL WriteString
	je .true
	jmp .false
      .true:
	MOV SI, NameString
	CALL WriteString
	MOV DI, Name
	CALL ReadString
	MOV SI, NewLine
	CALL WriteString
	MOV SI, PasswordString
	CALL WriteString
	MOV DI, Pass
	CALL ReadPassword
	MOV AX, DI
	SUB AX, Pass
	MOV [PassLen], AX
	jmp Welcome

Version:
	MOV SI, NewLine
	CALL WriteString
	CALL WriteColorWarning
	MOV SI, NewLine
	CALL WriteString
	MOV CX, 26
	MOV DX, VerFlag
	Call SetFlag
	MOV SI, VerStrg
	CALL WriteString
	MOV SI, NewLine
	CALL WriteString
	jmp start

Clear:
	CALL ClearScreen
	MOV AX, 0
	MOV BX, 0
	CALL SetCursor
	CALL GetCursor
	jmp start

Help:
	MOV SI, NewLine
	CALL WriteString
	MOV SI, VerStrg
	CALL WriteString
	MOV SI, NewLine
	CALL WriteString
	CALL WriteColorWarning
	MOV SI, NewLine
	CALL WriteString
	MOV SI, HelpStr
	CALL WriteString
	MOV SI, NewLine
	CALL WriteString
	jmp start

Info:
	MOV SI, NewLine
	CALL WriteString
	MOV SI, VerStrg
	CALL WriteString
	MOV SI, NewLine
	CALL WriteString
	CALL WriteColorWarning
	MOV SI, NewLine
	CALL WriteString
	MOV SI, InfoStr
	CALL WriteString
	MOV SI, NewLine
	CALL WriteString
	jmp start

Changes:
	MOV SI, NewLine
	CALL WriteString
	MOV SI, VerStrg
	CALL WriteString
	MOV SI, NewLine
	CALL WriteString
	CALL WriteColorWarning
	MOV SI, NewLine
	CALL WriteString
	MOV SI, Change1
	CALL WriteString
	CALL KeyWait
	CALL ClearScreen
	MOV AX, 0
	MOV BX, 0
	CALL SetCursor
	MOV SI, NewLine
	CALL WriteString
	MOV SI, Change2
	CALL WriteString
	CALL KeyWait
	CALL ClearScreen
	MOV AX, 0
	MOV BX, 0
	CALL SetCursor
	MOV SI, NewLine
	CALL WriteString
	MOV SI, Change3
	CALL WriteString
	MOV SI, NewLine
	CALL WriteString
	jmp start

Read2:
	MOV BX, Command+5
	CALL Dec2Word
	JMP Read
Read1:
	MOV SI, NewLine
	CALL WriteString
	CALL InitFloppy
	MOV CX, 73
	MOV DX, ReadFlg
	CALL SetFlag
	MOV SI, ReadStr
	CALL WriteString
	MOV SI, ChoiceS
	CALL WriteString
	MOV DI, Buffer
	CALL ReadString
	MOV BX, Buffer
	CALL Dec2Word
Read:
	MOV BX, Buffer
	MOV CX, 1
	MOV DX, 0
	CALL ReadFloppy
	MOV SI, NewLine
	CALL WriteString
	MOV SI, NewLine
	CALL WriteString
	MOV SI, Buffer
	CALL WriteString
	MOV SI, NewLine
	CALL WriteString
	MOV SI, NewLine
	CALL WriteString
	jmp start

Write2:
	MOV BX, Command+6
	CALL Dec2Word
	JMP Write
Write1:
	MOV SI, NewLine
	CALL WriteString
	CALL InitFloppy
	MOV CX, 79
	MOV DX, WriteFg
	CALL SetFlag
	MOV SI, WriteSt
	CALL WriteString
	MOV SI, ChoiceS
	CALL WriteString
	MOV DI, Buffer
	CALL ReadString
	MOV BX, Buffer
	CALL Dec2Word
Write:
	PUSH AX
	MOV SI, NewLine
	CALL WriteString
	MOV SI, NewLine
	CALL WriteString
	MOV DI, Buffer
	CALL ReadString2
	POP AX
	MOV BX, Buffer
	MOV CX, 1
	MOV DX, 0
	CALL WriteFloppy
	MOV SI, NewLine
	CALL WriteString
	MOV SI, NewLine
	CALL WriteString
	jmp start

RawRead2:
	MOV BX, Command+8
	CALL Dec2Word
	JMP	       RawRead
RawRead1:
	MOV SI, NewLine
	CALL WriteString
	CALL InitFloppy
	MOV CX, 73
	MOV DX, ReadFlg
	CALL SetFlag
	MOV SI, ReadStr
	CALL WriteString
	MOV SI, ChoiceS
	CALL WriteString
	MOV DI, Buffer
	CALL ReadString
	MOV BX, Buffer
	CALL Dec2Word
RawRead:
	MOV BX, Buffer
	MOV CX, 1
	MOV DX, 0
	CALL ReadFloppy
	CALL ClearScreen
	MOV SI, NewLine
	CALL WriteString
	MOV SI, RawStr1
	CALL WriteString
	MOV [tempE], 0
	MOV [tempF], 0
      Loop1:
    .y:
      .x:
	MOV AH, 0
	MOV AL, [tempE]
	MOV BH, 0
	MOV BL, [tempF]
	IMUL AX, 16
	ADD AX, BX
	MOV SI, Buffer
	ADD SI, AX
	LODSB
	MOV AH, 0
	MOV BX, TempWord
	CALL Byte2String
	MOV AH, 0
	MOV AL, [tempF]
	MOV BH, 0
	MOV BL, [tempE]
	IMUL AX, 4
	ADD AX, 9
	ADD BX, 2
	CALL SetCursor
	MOV SI, TempWord
	CALL WriteString
	PUSHAD
	MOV AH, 0Ah
	MOV BH, 0
	MOV CX, 1
	MOV AL, 104
	INT 10h
	POPAD
	CMP [tempE], 15
	jb .nextx
	CMP [tempF], 15
	jb .nexty
	jmp .end
      .nextx:
	ADD [tempE], 1
	jmp .x
      .nexty:
	MOV [tempE], 0
	ADD [tempF], 1
	jmp .y
      .end:
	MOV SI, NewLine
	CALL WriteString
	MOV SI, NewLine
	CALL WriteString
	CALL WaitKey
	CALL ClearScreen
	MOV SI, NewLine
	CALL WriteString
	MOV SI, RawStr2
	CALL WriteString
	MOV [tempE], 0
	MOV [tempF], 0
      Loop2:
    .y:
      .x:
	MOV AH, 0
	MOV AL, [tempE]
	MOV BH, 0
	MOV BL, [tempF]
	IMUL AX, 16
	ADD AX, BX
	MOV SI, Buffer
	ADD SI, 256
	ADD SI, AX
	LODSB
	MOV AH, 0
	MOV BX, TempWord
	CALL Byte2String
	MOV AH, 0
	MOV AL, [tempF]
	MOV BH, 0
	MOV BL, [tempE]
	IMUL AX, 4
	ADD AX, 9
	ADD BX, 2
	CALL SetCursor
	MOV SI, TempWord
	CALL WriteString
	PUSHAD
	MOV AH, 0Ah
	MOV BH, 0
	MOV CX, 1
	MOV AL, 104
	INT 10h
	POPAD
	CMP [tempE], 15
	jb .nextx
	CMP [tempF], 15
	jb .nexty
	jmp .end
      .nextx:
	ADD [tempE], 1
	jmp .x
      .nexty:
	MOV [tempE], 0
	ADD [tempF], 1
	jmp .y
      .end:
	MOV SI, NewLine
	CALL WriteString
	MOV SI, NewLine
	CALL WriteString
	jmp start

RawWrite2:
	MOV BX, Command+9
	CALL Dec2Word
	JMP	       RawWrite
RawWrite1:
	MOV SI, NewLine
	CALL WriteString
	CALL InitFloppy
	MOV CX, 79
	MOV DX, WriteFg
	CALL SetFlag
	MOV SI, WriteSt
	CALL WriteString
	MOV SI, ChoiceS
	CALL WriteString
	MOV DI, Buffer
	CALL ReadString
	MOV BX, Buffer
	CALL Dec2Word
RawWrite:
	MOV SI, NewLine
	CALL WriteString
	jmp start

Reset:
	MOV SI, NewLine
	CALL WriteString
	MOV AX, 999
	MOV BX, SettingsArea
	MOV CX, 1
	MOV DX, 0
	CALL WriteFloppy
	MOV CX, 30
	MOV DX, ResetFg
	CALL SetFlag
	MOV SI, ResetSt
	CALL WriteString
	MOV SI, NewLine
	CALL WriteString
	INT 19h
	jmp ExitRepeat

Exit:
	MOV SI, NewLine
	CALL WriteString
	MOV AX, 999
	MOV BX, SettingsArea
	MOV CX, 1
	MOV DX, 0
	CALL WriteFloppy
	MOV CX, 28
	MOV DX, ExitFlg
	CALL SetFlag
	MOV SI, ExitStr
	CALL WriteString
	MOV SI, NewLine
	CALL WriteString
	CLI
	hlt
	STI
      ExitRepeat:
	MOV AX, 0
	MOV BX, 0
	CALL SetCursor
	MOV AX, 0B800h
	MOV DS, AX
	MOV ES, AX
	MOV DI, 0
	MOV SI, 0
	CALL ReadString
	jmp ExitRepeat

WaitKey:
	CALL KeyWait
	RETN

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

SetFlag2: ; AX = X / BX = Y / CX = Leange / DX = Flag
	PUSH AX
	MOV AX, 0B800h
	MOV ES, AX
	POP AX
	MOV DI, BX
	IMUL DI, 160
	ADD DI, AX
	MOV SI, DX
      SetFlag2Next:
	INC DI
	MOVSB
	DEC CX
	CMP CX, 0
	JE SetFlag2End
	jmp SetFlag2Next
      SetFlag2End:
	MOV AX, CS
	MOV DS, AX
	MOV ES, AX
	RETN ; No

WriteRawChr: ; AX = X / BX = Y / CX = String
	PUSHAD
	PUSH AX
	MOV AX, 0B800h
	MOV ES, AX
	POP AX
	MOV DI, BX
	IMUL DI, 160
	ADD DI, AX
      WriteNextRawChr:
	MOV SI, CX
	MOVSB
	INC CX
	MOV SI, DX
	INC SI
	INC DI
	INC DX
	MOV SI, CX
	CMP byte [DS:SI], 0
	JE WriteRawChrEnd
	jmp WriteNextRawChr
      WriteRawChrEnd:
	MOV AX, CS
	MOV DS, AX
	MOV ES, AX
	POPAD
	RETN ; No

WriteRawChr2: ; AX = X / BX = Y / CX = String / DX = Leange
	PUSHAD
	PUSH AX
	MOV AX, 0B800h
	MOV ES, AX
	POP AX
	MOV DI, BX
	IMUL DI, 160
	ADD DI, AX
      WriteNextRawChr2:
	MOV SI, CX
	MOVSB
	INC CX
	INC SI
	INC DI
	DEC DX
	MOV SI, CX
	CMP DX, 0
	JE WriteRawChr2End
	jmp WriteNextRawChr2
      WriteRawChr2End:
	MOV AX, CS
	MOV DS, AX
	MOV ES, AX
	POPAD
	RETN ; No

WriteRawFlag: ; AX = X / BX = Y / DX = Flag
	PUSHAD
	PUSH AX
	MOV AX, 0B800h
	MOV ES, AX
	POP AX
	MOV DI, BX
	IMUL DI, 160
	ADD DI, AX
      WriteNextRawFlag:
	MOV SI, CX
	INC SI
	INC DI
	INC CX
	MOV SI, DX
	MOVSB
	INC DX
	MOV SI, DX
	CMP byte [DS:SI], 0
	JE WriteRawFlagEnd
	jmp WriteNextRawFlag
      WriteRawFlagEnd:
	MOV AX, CS
	MOV DS, AX
	MOV ES, AX
	POPAD
	RETN ; No

WriteRawFlag2: ; AX = X / BX = Y / CX = Leange / DX = Flag
	PUSHAD
	PUSH AX
	MOV AX, 0B800h
	MOV ES, AX
	POP AX
	MOV DI, BX
	IMUL DI, 160
	ADD DI, AX
      WriteNextRawFlag2:
	INC SI
	INC DI
	DEC CX
	MOV SI, DX
	MOVSB
	INC DX
	MOV SI, DX
	CMP CX, 0
	JE WriteRawFlag2End
	jmp WriteNextRawFlag2
      WriteRawFlag2End:
	MOV AX, CS
	MOV DS, AX
	MOV ES, AX
	POPAD
	RETN ; No

WriteRawString: ; AX = X / BX = Y / CX = String / DX = Flag
	PUSHAD
	CALL WriteRawChr
	POPAD
	CALL WriteRawFlag
	RETN ; No

SetScreenColor: ; AX = Flag
	MOV DX, AX
	MOV AX, 0
	MOV BX, 0
      ColorNextLine:
	CALL WriteRawFlag
	INC BX
	CMP BX, 25
	JE SetScreenColorEnd
	jmp ColorNextLine
      SetScreenColorEnd:
	RETN ; No

ClearScreen: ; No
	MOV AX, 0
	MOV BX, 0
	MOV CX, ClearFont
	MOV DX, Color_07h
      ClearNextLine:
	CALL WriteRawString
	INC BX
	CMP BX, 25
	JE ClearScreenEnd
	jmp ClearNextLine
      ClearScreenEnd:
	MOV AX, 0
	MOV BX, 0
	CALL SetCursor
	RETN ; No

WriteString2: ; SI = String / CX = Leange
	LODSB			; Zeichen nach AL kopieren
	DEC CX
	CMP CX, 0		; Ist AL = 0 ?
	JE WriteString2End	 ; dann Abbruch
	MOV AH, 0Eh		; Funktion
	MOV BH, 0		; Bildschirmseite
	PUSH CX
	INT 10h 		; Schreiben
	POP CX
	JMP WriteString2	 ; Nächster Durchlauf
      WriteString2End:
	RETN ; No               ; Funktionsrücksprung

WriteString: ; SI = String
	LODSB			; Zeichen nach AL kopieren
	CMP AL, 0		; Ist AL = 0 ?
	JE WriteStringEnd	; dann Abbruch
	MOV AH, 0Eh		; Funktion
	MOV BH, 0		; Bildschirmseite
	INT 10h 		; Schreiben
	JMP WriteString 	; Nächster Durchlauf
      WriteStringEnd:
	RETN ; No               ; Funktionsrücksprung

ReadString2: ; DI = Buffer
	MOV AH, 0		; Funktion
	INT 16h 		; Zeichen einlesen
	CMP AL, 27		; Ist AL = 27 ?
	JE ReadString2End	 ; dann Abbruch
	CMP AL, 13		; Ist AL = 13 ?
	JE ReadNextLine        ; dann Neue Zeile
	CMP AL, 8		; Ist AL = 8 ?
	JE ClearChar2		 ; dann Zeichen löschen
	STOSB			; AL speichern kopieren
	MOV AH, 0Eh		; Funktion
	MOV BH, 0		; Bildschirmseite
	INT 10h 		; Schreiben
	JMP ReadString2 	 ; Nächster Durchlauf
      ReadNextLine:
	STOSB			; AL speichern kopieren
	MOV AH, 0Eh		; Funktion
	MOV BH, 0		; Bildschirmseite
	INT 10h 		; Schreiben
	MOV AL, 10
	STOSB			; AL speichern kopieren
	MOV AH, 0Eh		; Funktion
	MOV BH, 0		; Bildschirmseite
	INT 10h 		; Schreiben
	JMP ReadString2 	 ; Nächster Durchlauf
      ClearChar2:
	SUB DI, 1		; Zeichen Löschen
	MOV AH, 0Eh		; Funktion
	MOV BH, 0		; Bildschirmseite
	INT 10h 		; Schreiben
	MOV AL, 32		; Löschen
	MOV AH, 0Eh		; Funktion
	MOV BH, 0		; Bildschirmseite
	INT 10h 		; Schreiben
	MOV AL, 8		; Zurück
	MOV AH, 0Eh		; Funktion
	MOV BH, 0		; Bildschirmseite
	INT 10h 		; Schreiben
	JMP ReadString2 	 ; Nächster Durchlauf
      ReadString2End:
	MOV AL, 0		; Stringende
	STOSB			; AL speichern kopieren
	RETN ; No               ; Funktionsrücksprung

ReadString: ; DI = Buffer
	MOV AH, 0		; Funktion
	INT 16h 		; Zeichen einlesen
	CMP AL, 27		; Ist AL = 27 ?
	JE ReadStringEnd	; dann Abbruch
	CMP AL, 13		; Ist AL = 13 ?
	JE ReadStringEnd	; dann Abbruch
	CMP AL, 8		; Ist AL = 8 ?
	JE ClearChar		; dann Zeichen löschen
	STOSB			; AL speichern kopieren
	MOV AH, 0Eh		; Funktion
	MOV BH, 0		; Bildschirmseite
	INT 10h 		; Schreiben
	JMP ReadString		; Nächster Durchlauf
      ClearChar:
	SUB DI, 1		; Zeichen Löschen
	MOV AH, 0Eh		; Funktion
	MOV BH, 0		; Bildschirmseite
	INT 10h 		; Schreiben
	MOV AL, 32		; Löschen
	MOV AH, 0Eh		; Funktion
	MOV BH, 0		; Bildschirmseite
	INT 10h 		; Schreiben
	MOV AL, 8		; Zurück
	MOV AH, 0Eh		; Funktion
	MOV BH, 0		; Bildschirmseite
	INT 10h 		; Schreiben
	JMP ReadString		; Nächster Durchlauf
      ReadStringEnd:
	MOV AL, 0		; Stringende
	STOSB			; AL speichern kopieren
	RETN ; No               ; Funktionsrücksprung

ReadPassword: ; DI = Buffer
	MOV AH, 0		; Funktion
	INT 16h 		; Zeichen einlesen
	CMP AL, 27		; Ist AL = 27 ?
	JE ReadPasswordEnd	  ; dann Abbruch
	CMP AL, 13		; Ist AL = 13 ?
	JE ReadPasswordEnd	  ; dann Abbruch
	CMP AL, 8		; Ist AL = 8 ?
	JE ClearPass		; dann Zeichen löschen
	STOSB			; AL speichern kopieren
	MOV AL, 42
	MOV AH, 0Eh		; Funktion
	MOV BH, 0		; Bildschirmseite
	INT 10h 		; Schreiben
	JMP ReadPassword	  ; Nächster Durchlauf
      ClearPass:
	SUB DI, 1		; Zeichen Löschen
	MOV AH, 0Eh		; Funktion
	MOV BH, 0		; Bildschirmseite
	INT 10h 		; Schreiben
	MOV AL, 32		; Löschen
	MOV AH, 0Eh		; Funktion
	MOV BH, 0		; Bildschirmseite
	INT 10h 		; Schreiben
	MOV AL, 8		; Zurück
	MOV AH, 0Eh		; Funktion
	MOV BH, 0		; Bildschirmseite
	INT 10h 		; Schreiben
	JMP ReadPassword	  ; Nächster Durchlauf
      ReadPasswordEnd:
	MOV AL, 0		; Stringende
	STOSB			; AL speichern kopieren
	RETN ; No               ; Funktionsrücksprung

KeyWait: ; No
	MOV CX, 32
	MOV DX, WaitFlg
	CALL SetFlag
	MOV SI, WaitStr
	CALL WriteString
	MOV AH, 0		; Funktion
	INT 16h 		; Zeichen einlesen
	CMP AL, 13		; Ist AL = 13 ?
	JE KeyWaitEnd		; dann Abbruch
	CMP AL, 32		; Ist AL = 32 ?
	JE KeyWaitEnd		; dann Abbruch
	JMP KeyWait		; Nächster Durchlauf
      KeyWaitEnd:
	RETN ; No               ; Funktionsrücksprung

WriteChr: ; AL = Ascii
	MOV AH, 0Eh		; Funktion
	MOV BH, 0		; Bildschirmseite
	INT 10h 		; Schreiben
	RETN ; No               ; Funktionsrücksprung

WriteLineX: ; CX = Leange
	CALL GetCursor		; Cursor ermitteln
WriteLineX2: ; AX = X / BX = Y / CX = Leange
	MOV [LineX], AX 	; X Position
	MOV [LineY], BX 	; Y Position
      WriteLineXNew:
	MOV AX, [LineX] 	; X Position
	MOV BX, [LineY] 	; Y Position
	CALL SetCursor		; Cursor setzen
	MOV AH, 0Eh		; Funktion
	MOV BH, 0		; Bildschirmseite
	MOV AL, '-'		; Waggerechte Linie
	INT 10h 		; Schreiben
	SUB CX, 1		; CX um 1 senken
	ADD [LineX], 1		; X + 1
	JCXZ WriteLineXEnd	; Wenn CX = 0
	JMP WriteLineXNew	; wenn nicht
      WriteLineXEnd:
	RETN ; No               ; Funktionsrücksprung

WriteLineY: ; CX = Leange
	CALL GetCursor		; Cursor ermitteln
WriteLineY2: ; AX = X / BX = Y / CX = Leange
	MOV [LineX], AX 	; X Position
	MOV [LineY], BX 	; Y Position
      WriteLineYNew:
	MOV AX, [LineX] 	; X Position
	MOV BX, [LineY] 	; Y Position
	CALL SetCursor		; Cursor setzen
	MOV AH, 0Eh		; Funktion
	MOV BH, 0		; Bildschirmseite
	MOV AL, '|'		; Senkrechte Linie
	INT 10h 		; Schreiben
	SUB CX, 1		; CX um 1 senken
	ADD [LineY], 1		; X + 1
	JCXZ WriteLineYEnd	; Wenn CX = 0
	JMP WriteLineYNew	; wenn nicht
      WriteLineYEnd:
	RETN ; No               ; Funktionsrücksprung

SetCursor: ; AX = X / BX = Y
	PUSHAW			; Alle Register sichern
	MOV DL, AL		; X Position
	MOV DH, BL		; Y Position
	MOV AH, 02h		; Funktion
	MOV BH, 0		; Bildschirmseite
	INT 10h 		; Setzen
	POPAW			; Alle Register wiederherstellen
	RETN ; No               ; Funktionsrücksprung

GetCursor: ; No
	PUSH DX 		; DX Register sichern
	PUSH CX 		; CX Register sichern
	MOV AH, 03h		; Funktion
	MOV BH, 0		; Bildschirmseite
	INT 10h 		; Ermitteln
	MOV AL, DL		; X Position
	MOV AH, 0		; AH Abschneiden
	MOV BL, DH		; Y Position
	MOV BH, 0		; BH Abschneiden
	POP CX			; CX Register wiederherstellen
	POP DX			; DX Register wiederherstellen
	RETN ; AX = X / BX = Y  ; Funktionsrücksprung

WriteColorWarning: ; No
	CALL GetCursor
	MOV AX, 0
	CALL SetCursor
	MOV CX, 51
	MOV DX, Warnin1
	PUSHAD
	CALL SetFlag2
	POPAD
	INC BX
	MOV CX, 60
	MOV DX, Warnin2
	PUSHAD
	CALL SetFlag2
	POPAD
	INC BX
	MOV CX, 71
	MOV DX, Warnin3
	PUSHAD
	CALL SetFlag2
	POPAD
	MOV SI, Warning
	CALL WriteString
	RETN ; No

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

GetFloppyStatus: ; AX = Floppy
	PUSHAD
	MOV AH, 1
	MOV DL, AL
	INT 13h
	MOV [TempByte], AH
	POPAD
	MOV AH, 0
	MOV AL, [TempByte]
	RETN ; AX = Fehlercode

ReadFloppy: ; AX = Sektor / BX = Buffer / CX = Anzahl / DX = Floppy / ES = Offset
	PUSHAD
	ADD AX, 1
	PUSH BX
	PUSH CX
	PUSH DX
	PUSH ES
	MOV DX, 0
	MOV BX, 18
	DIV BX
	MOV [Sektor], DL
	MOV [Track], AL
	AND AX, 1
	MOV [Head], AL
	MOV AH, 0
	MOV AL, [Track]
	MOV BL, 2
	DIV BL
	MOV [Track], AL
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

WriteFloppy: ; AX = Sektor / BX = Buffer / CX = Anzahl / DX = Floppy / ES = Offset
	PUSHAD
	ADD AX, 1
	PUSH BX
	PUSH CX
	PUSH DX
	PUSH ES
	MOV DX, 0
	MOV BX, 18
	DIV BX
	MOV [Sektor], DL
	MOV [Track], AL
	AND AX, 1
	MOV [Head], AL
	MOV AH, 0
	MOV AL, [Track]
	MOV BL, 2
	DIV BL
	MOV [Track], AL
	POP ES
	POP DX
	POP CX
	POP BX
	MOV AH, 3
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

Value2String: ; Unterroutine
	CMP AL, 9
	ja .true
	jmp .false
      .true:
	ADD AL, 7
      .false:
	RETN ; Unterroutine

Quad2String: ; DX:CX:BX:AX = Nummer
	MOV [temp0], DH
	SHR [temp0], 4
	MOV [temp1], DH
	AND [temp1], 15
	MOV [temp2], DL
	SHR [temp2], 4
	MOV [temp3], DL
	AND [temp3], 15
	MOV [temp4], CH
	SHR [temp4], 4
	MOV [temp5], CH
	AND [temp5], 15
	MOV [temp6], CL
	SHR [temp6], 4
	MOV [temp7], CL
	AND [temp7], 15
	MOV [temp8], BH
	SHR [temp8], 4
	MOV [temp9], BH
	AND [temp9], 15
	MOV [tempA], BL
	SHR [tempA], 4
	MOV [tempB], BL
	AND [tempB], 15
	MOV [tempC], AH
	SHR [tempC], 4
	MOV [tempD], AH
	AND [tempD], 15
	MOV [tempE], AL
	SHR [tempE], 4
	MOV [tempF], AL
	AND [tempF], 15
	MOV [Buffer+0], byte 48
	MOV [Buffer+1], byte 48
	MOV [Buffer+2], byte 48
	MOV [Buffer+3], byte 48
	MOV [Buffer+4], byte 48
	MOV [Buffer+5], byte 48
	MOV [Buffer+6], byte 48
	MOV [Buffer+7], byte 48
	MOV [Buffer+8], byte 48
	MOV [Buffer+9], byte 48
	MOV [Buffer+10], byte 48
	MOV [Buffer+11], byte 48
	MOV [Buffer+12], byte 48
	MOV [Buffer+13], byte 48
	MOV [Buffer+14], byte 48
	MOV [Buffer+15], byte 48
	MOV [Buffer+16], byte 0
	MOV AL,[temp0]
	CALL Value2String
	ADD [Buffer+0],AL
	MOV AL,[temp1]
	CALL Value2String
	ADD [Buffer+1],AL
	MOV AL,[temp2]
	CALL Value2String
	ADD [Buffer+2],AL
	MOV AL,[temp3]
	CALL Value2String
	ADD [Buffer+3],AL
	MOV AL,[temp4]
	CALL Value2String
	ADD [Buffer+4],AL
	MOV AL,[temp5]
	CALL Value2String
	ADD [Buffer+5],AL
	MOV AL,[temp6]
	CALL Value2String
	ADD [Buffer+6],AL
	MOV AL,[temp7]
	CALL Value2String
	ADD [Buffer+7],AL
	MOV AL,[temp8]
	CALL Value2String
	ADD [Buffer+8],AL
	MOV AL,[temp9]
	CALL Value2String
	ADD [Buffer+9],AL
	MOV AL,[tempA]
	CALL Value2String
	ADD [Buffer+10],AL
	MOV AL,[tempB]
	CALL Value2String
	ADD [Buffer+11],AL
	MOV AL,[tempC]
	CALL Value2String
	ADD [Buffer+12],AL
	MOV AL,[tempD]
	CALL Value2String
	ADD [Buffer+13],AL
	MOV AL,[tempE]
	CALL Value2String
	ADD [Buffer+14],AL
	MOV AL,[tempF]
	CALL Value2String
	ADD [Buffer+15],AL
	RETN ; Buffer = String

Long2String: ; DX:AX = Nummer / BX = Buffer
	MOV [temp0], DH
	SHR [temp0], 4
	MOV [temp1], DH
	AND [temp1], 15
	MOV [temp2], DL
	SHR [temp2], 4
	MOV [temp3], DL
	AND [temp3], 15
	MOV [temp4], AH
	SHR [temp4], 4
	MOV [temp5], AH
	AND [temp5], 15
	MOV [temp6], AL
	SHR [temp6], 4
	MOV [temp7], AL
	AND [temp7], 15
	MOV [BX+0], byte 48
	MOV [BX+1], byte 48
	MOV [BX+2], byte 48
	MOV [BX+3], byte 48
	MOV [BX+4], byte 48
	MOV [BX+5], byte 48
	MOV [BX+6], byte 48
	MOV [BX+7], byte 48
	MOV [BX+8], byte 0
	MOV AL,[temp0]
	CALL Value2String
	ADD [BX+0],AL
	MOV AL,[temp1]
	CALL Value2String
	ADD [BX+1],AL
	MOV AL,[temp2]
	CALL Value2String
	ADD [BX+2],AL
	MOV AL,[temp3]
	CALL Value2String
	ADD [BX+3],AL
	MOV AL,[temp4]
	CALL Value2String
	ADD [BX+4],AL
	MOV AL,[temp5]
	CALL Value2String
	ADD [BX+5],AL
	MOV AL,[temp6]
	CALL Value2String
	ADD [BX+6],AL
	MOV AL,[temp7]
	CALL Value2String
	ADD [BX+7],AL
	RETN ; No

Word2String: ; AX = Nummer / BX = Buffer
	MOV [temp0], AH
	SHR [temp0], 4
	MOV [temp1], AH
	AND [temp1], 15
	MOV [temp2], AL
	SHR [temp2], 4
	MOV [temp3], AL
	AND [temp3], 15
	MOV [BX+0], byte 48
	MOV [BX+1], byte 48
	MOV [BX+2], byte 48
	MOV [BX+3], byte 48
	MOV [BX+4], byte 0
	MOV AL,[temp0]
	CALL Value2String
	ADD [BX+0],AL
	MOV AL,[temp1]
	CALL Value2String
	ADD [BX+1],AL
	MOV AL,[temp2]
	CALL Value2String
	ADD [BX+2],AL
	MOV AL,[temp3]
	CALL Value2String
	ADD [BX+3],AL
	RETN ; No

Byte2String: ; AL = Nummer / BX = Buffer
	MOV [temp0], AL
	SHR [temp0], 4
	MOV [temp1], AL
	AND [temp1], 15
	MOV [BX+0], byte 48
	MOV [BX+1], byte 48
	MOV [BX+2], byte 0
	MOV AL,[temp0]
	CALL Value2String
	ADD [BX+0],AL
	MOV AL,[temp1]
	CALL Value2String
	ADD [BX+1],AL
	RETN ; No

String2Value_8: ; Unterroutine
	CMP AL, 102
	ja .error
	CMP AL, 96
	ja .low
	CMP AL, 70
	ja .error
	CMP AL, 64
	ja .upper
	CMP AL, 57
	ja .error
	CMP AL, 47
	ja .value
	CMP AL, 0
	je .error
      .low:
	SUB AL, 87
	jmp .end
      .upper:
	SUB AL, 55
	jmp .end
      .value:
	SUB AL, 48
	jmp .end
      .end:
	RETN
      .error:
	MOV SI, NewLine
	CALL WriteString
	MOV CX, 63
	MOV DX, Val8Flg
	CALL SetFlag
	MOV SI, Val8Str
	CALL WriteString
	MOV DX, 0
	MOV CX, 0
	MOV BX, 0
	MOV AX, 0
	STC
	POP [TempWord]
	RETN ; Unterroutine

String2Value_4: ; Unterroutine
	CMP AL, 102
	ja .error
	CMP AL, 96
	ja .low
	CMP AL, 70
	ja .error
	CMP AL, 64
	ja .upper
	CMP AL, 57
	ja .error
	CMP AL, 47
	ja .value
	CMP AL, 0
	je .error
      .low:
	SUB AL, 87
	jmp .end
      .upper:
	SUB AL, 55
	jmp .end
      .value:
	SUB AL, 48
	jmp .end
      .end:
	RETN
      .error:
	MOV SI, NewLine
	CALL WriteString
	MOV CX, 62
	MOV DX, Val4Flg
	CALL SetFlag
	MOV SI, Val4Str
	CALL WriteString
	MOV DX, 0
	MOV AX, 0
	STC
	POP [TempWord]
	RETN ; Unterroutine

String2Value_2: ; Unterroutine
	CMP AL, 102
	ja .error
	CMP AL, 96
	ja .low
	CMP AL, 70
	ja .error
	CMP AL, 64
	ja .upper
	CMP AL, 57
	ja .error
	CMP AL, 47
	ja .value
	CMP AL, 0
	je .error
      .low:
	SUB AL, 87
	jmp .end
      .upper:
	SUB AL, 55
	jmp .end
      .value:
	SUB AL, 48
	jmp .end
      .end:
	RETN
      .error:
	MOV SI, NewLine
	CALL WriteString
	MOV CX, 62
	MOV DX, Val2Flg
	CALL SetFlag
	MOV SI, Val2Str
	CALL WriteString
	MOV AX, 0
	STC
	POP [TempWord]
	RETN ; Unterroutine

String2Value_1: ; Unterroutine
	CMP AL, 102
	ja .error
	CMP AL, 96
	ja .low
	CMP AL, 70
	ja .error
	CMP AL, 64
	ja .upper
	CMP AL, 57
	ja .error
	CMP AL, 47
	ja .value
	CMP AL, 0
	je .error
      .low:
	SUB AL, 87
	jmp .end
      .upper:
	SUB AL, 55
	jmp .end
      .value:
	SUB AL, 48
	jmp .end
      .end:
	RETN
      .error:
	MOV SI, NewLine
	CALL WriteString
	MOV CX, 63
	MOV DX, Val1Flg
	CALL SetFlag
	MOV SI, Val1Str
	CALL WriteString
	MOV AL, 0
	STC
	POP [TempWord]
	RETN ; Unterroutine

String2Quad: ; Buffer = String
	MOV AL, [Buffer+0]
	CALL String2Value_8
	MOV [temp0], AL
	MOV AL, [Buffer+1]
	CALL String2Value_8
	MOV [temp1], AL
	MOV AL, [Buffer+2]
	CALL String2Value_8
	MOV [temp2], AL
	MOV AL, [Buffer+3]
	CALL String2Value_8
	MOV [temp3], AL
	MOV AL, [Buffer+4]
	CALL String2Value_8
	MOV [temp4], AL
	MOV AL, [Buffer+5]
	CALL String2Value_8
	MOV [temp5], AL
	MOV AL, [Buffer+6]
	CALL String2Value_8
	MOV [temp6], AL
	MOV AL, [Buffer+7]
	CALL String2Value_8
	MOV [temp7], AL
	MOV AL, [Buffer+8]
	CALL String2Value_8
	MOV [temp8], AL
	MOV AL, [Buffer+9]
	CALL String2Value_8
	MOV [temp9], AL
	MOV AL, [Buffer+10]
	CALL String2Value_8
	MOV [tempA], AL
	MOV AL, [Buffer+11]
	CALL String2Value_8
	MOV [tempB], AL
	MOV AL, [Buffer+12]
	CALL String2Value_8
	MOV [tempC], AL
	MOV AL, [Buffer+13]
	CALL String2Value_8
	MOV [tempD], AL
	MOV AL, [Buffer+14]
	CALL String2Value_8
	MOV [tempE], AL
	MOV AL, [Buffer+15]
	CALL String2Value_8
	MOV [tempF], AL
	MOV DX, 0
	MOV CX, 0
	MOV BX, 0
	MOV AX, 0
	SHL [temp0], 4
	ADD DH, [temp0]
	AND [temp1], 15
	ADD DH, [temp1]
	SHL [temp2], 4
	ADD DL, [temp2]
	AND [temp3], 15
	ADD DL, [temp3]
	SHL [temp4], 4
	ADD CH, [temp4]
	AND [temp5], 15
	ADD CH, [temp5]
	SHL [temp6], 4
	ADD CL, [temp6]
	AND [temp7], 15
	ADD CL, [temp7]
	SHL [temp8], 4
	ADD BH, [temp8]
	AND [temp9], 15
	ADD BH, [temp9]
	SHL [tempA], 4
	ADD BL, [tempA]
	AND [tempB], 15
	ADD BL, [tempB]
	SHL [tempC], 4
	ADD AH, [tempC]
	AND [tempD], 15
	ADD AH, [tempD]
	SHL [tempE], 4
	ADD AL, [tempE]
	AND [tempF], 15
	ADD AL, [tempF]
	RETN ; DX:CX:BX:AX = Nummer

String2Long: ; BX = String
	MOV AL, [BX+0]
	CALL String2Value_4
	MOV [temp0], AL
	MOV AL, [BX+1]
	CALL String2Value_4
	MOV [temp1], AL
	MOV AL, [BX+2]
	CALL String2Value_4
	MOV [temp2], AL
	MOV AL, [BX+3]
	CALL String2Value_4
	MOV [temp3], AL
	MOV AL, [BX+4]
	CALL String2Value_4
	MOV [temp4], AL
	MOV AL, [BX+5]
	CALL String2Value_4
	MOV [temp5], AL
	MOV AL, [BX+6]
	CALL String2Value_4
	MOV [temp6], AL
	MOV AL, [BX+7]
	CALL String2Value_4
	MOV [temp7], AL
	MOV DX, 0
	MOV AX, 0
	SHL [temp0], 4
	ADD DH, [temp0]
	AND [temp1], 15
	ADD DH, [temp1]
	SHL [temp2], 4
	ADD DL, [temp2]
	AND [temp3], 15
	ADD DL, [temp3]
	SHL [temp4], 4
	ADD AH, [temp4]
	AND [temp5], 15
	ADD AH, [temp5]
	SHL [temp6], 4
	ADD AL, [temp6]
	AND [temp7], 15
	ADD AL, [temp7]
	RETN ; DX:AX = Nummer

String2Word: ; BX = String
	MOV AL, [BX+0]
	CALL String2Value_2
	MOV [temp0], AL
	MOV AL, [BX+1]
	CALL String2Value_2
	MOV [temp1], AL
	MOV AL, [BX+2]
	CALL String2Value_2
	MOV [temp2], AL
	MOV AL, [BX+3]
	CALL String2Value_2
	MOV [temp3], AL
	MOV AX, 0
	SHL [temp0], 4
	ADD AH, [temp0]
	AND [temp1], 15
	ADD AH, [temp1]
	SHL [temp2], 4
	ADD AL, [temp2]
	AND [temp3], 15
	ADD AL, [temp3]
	RETN ; AX = Nummer

String2Byte: ; BX = String
	MOV AL, [BX+0]
	CALL String2Value_1
	MOV [temp0], AL
	MOV AL, [BX+1]
	CALL String2Value_1
	MOV [temp1], AL
	MOV AX, 0
	SHL [temp0], 4
	ADD AL, [temp0]
	AND [temp1], 15
	ADD AL, [temp1]
	RETN ; AL = Nummer

Quad2String2: ; EDX:EAX = Nummer
	MOV ECX, EDX
	MOV EBX, EAX
	SHR EDX, 16
	AND ECX, 65535
	SHR EBX, 16
	AND EAX, 65535
	CALL Quad2String
	RETN ; Buffer = String

Long2String2: ; EAX = Nummer / BX = Buffer
	MOV EDX, EAX
	SHR EDX, 16
	AND EAX, 65535
	CALL Long2String
	RETN ; No

Word2String2: ; AX = Nummer / BX = Buffer
	CALL Word2String
	RETN ; No

Byte2String2: ; AL = Nummer / BX = Buffer
	CALL Byte2String
	RETN ; No

String2Quad2: ; Buffer = String
	CALL String2Quad
	SHL EDX, 16
	AND ECX, 65535
	SHL EBX, 16
	AND EAX, 65535
	ADD EDX, ECX
	ADD EAX, EBX
	RETN ; EDX:EAX = Nummer

String2Long2: ; BX = String
	CALL String2Long
	SHL EDX, 16
	AND EAX, 65535
	ADD EAX, EDX
	RETN ; EAX = Nummer

String2Word2: ; BX = String
	CALL String2Word
	RETN ; AX = Nummer

String2Byte2: ; BX = String
	CALL String2Byte
	RETN ; AL = Nummer

Dec2Value: ; Unterroutine
	CMP CL, 0
	je .end
	CMP CL, 57
	ja .error
	CMP CL, 48
	jb .error
	SUB CL, 48
	MOV CH, 0
	MOV [TempWord], 10
	MUL [TempWord]
	ADD AX, CX
	RETN
      .error:
	MOV SI, NewLine
	CALL WriteString
	MOV CX, 54
	MOV DX, Dec2Flg
	CALL SetFlag
	MOV SI, Dec2Str
	CALL WriteString
	MOV AX, 0
	STC
      .end:
	POP [TempWord]
	RETN ; Unterroutine

Dec2Word: ; AX = Value / BX = Buffer
	MOV AX, 0
	MOV CL, [BX+0]
	CALL Dec2Value
	MOV CL, [BX+1]
	CALL Dec2Value
	MOV CL, [BX+2]
	CALL Dec2Value
	MOV CL, [BX+3]
	CALL Dec2Value
	MOV CL, [BX+4]
	CALL Dec2Value
      RETN ; No

Interrupt21h:
	IRET

Strings:
	MSG_Welcome	DB '                                                                                '
			DB '--------------------------------------------------------------------------------'
			DB '                                                                                '
			DB ' WinSysOS - Window System Operation System ',VERSION_STRING_1,'                '
			DB '  (c) WindowSystemCompany 2010 - 2019                                           '
			DB '                                                                                '
			DB '--------------------------------------------------------------------------------',0
	FLG_Welcome	DB 80 dup 0Bh
			DB 80 dup 0Bh
			DB 80 dup 0Bh
			DB 80 dup 0Bh
			DB 80 dup 0Bh
			DB 80 dup 0Bh
			DB 80 dup 0Bh,0
	FullLine	DB '--------------------------------------------------------------------------------',0
	NextLine	DB 13,10,0
	Keyboard_DE	DB 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27
			DB 28,29,30,31,32,33,142,21,36,37,'/',132,')=(`,',225,'.-0123456789',153,148
			DB ';',39,':_"ABCDEFGHIJKLMNOPQRSTUVWXZY',129,'#+&?^abcdefghijklmnopqrstuvw'
			DB 'xzy',154,'^','*ø€‚ƒ„…†‡ˆ‰Š‹ŒŽ‘’“”•–—˜™š›œžŸ ¡','¢£¤¥>§¨©ª«¬­®¯øø²³'
			DB 39,'µ¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿ'
	PasswordString	DB 'Bitte Password eingeben :',0
	NameString	DB 'Bitte Username eingeben :',0
	UserString	DB 'Willkommen ',0
	ClearFont	DB 80 dup 20h , 0
	BiosColor	DB 80 dup 97h , 0
	BiosHigh	DB 80 dup 9Fh , 0
	Color_00h	DB 80 dup 00h , 0
	Color_01h	DB 80 dup 01h , 0
	Color_02h	DB 80 dup 02h , 0
	Color_03h	DB 80 dup 03h , 0
	Color_04h	DB 80 dup 04h , 0
	Color_05h	DB 80 dup 05h , 0
	Color_06h	DB 80 dup 06h , 0
	Color_07h	DB 80 dup 07h , 0
	Color_08h	DB 80 dup 08h , 0
	Color_09h	DB 80 dup 09h , 0
	Color_0Ah	DB 80 dup 0Ah , 0
	Color_0Bh	DB 80 dup 0Bh , 0
	Color_0Ch	DB 80 dup 0Ch , 0
	Color_0Dh	DB 80 dup 0Dh , 0
	Color_0Eh	DB 80 dup 0Eh , 0
	Color_0Fh	DB 80 dup 0Fh , 0
	Command 	DB 80 dup 00h
	Buffer		DB 1024 dup 00h



DataArea:
      CommandArea:
	ResetCd db 'reset',0
	ExitCmd db 'exit',0
	VerComd db 'ver',0
	ClsComd db 'cls',0
	HelpCmd db 'help',0
	InfoCmd db 'info',0
	ChangeC db 'changes',0
	ReadCmd db 'read',0
	WriteCd db 'write',0
	RReadCd db 'rawread',0
	RWriteC db 'rawwrite',0
	readCmd db 'read',32
	writeCd db 'write',32
	rReadCd db 'rawread',32
	rWriteC db 'rawwrite',32
	RegComd db 'registry',0
	NoneCmd db 0
	PrefixS db 'CMD> ',0
      StringArea:
	Unknown db 'Ungueltiger Befehl !',13,10,0
	UnknFlg db 0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,07h,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,07h,0Fh
	ResetSt db 'System wird zurueckgesetzt ...',13,10,0
	ResetFg db 0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,07h,07h,07h,07h,07h,07h,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,07h,07h,07h,07h
	ExitStr db 'Bitte den PC ausschalten ...',13,10,0
	ExitFlg db 0Fh,0Fh,0Fh,0Fh,0Fh,07h,07h,07h,07h,07h,0Fh,0Fh,07h,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,07h,07h,07h,07h
	VerStrg db 'WindowSystemOS ',VERSION_STRING_2,13,10,0
	VerFlag db 0Bh,0Bh,0Bh,0Bh,0Bh,0Bh,0Bh,0Bh,0Bh,0Bh,0Bh,0Bh,0Bh,0Bh,07h,0Fh,0Fh,07h,07h,07h,07h,07h,0Ch,0Ch,0Ch,0Ch
	Warning db 'ACHTUNG: WinSysOS ist noch in der Entwicklungsphase',13,10
		db '         es wird keinerlei Garantie gegeben ausserdem haftet',13,10
		db '         die WinSysCompany weder fuer Daten noch fuer Hardware-Schaeden',13,10,0
	Warnin1 db 0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,07h,0Bh,0Bh,0Bh,0Bh,0Bh,0Bh,0Bh,0Bh,07h,07h,07h,07h
		db 07h,07h,07h,07h,07h,07h,07h,07h,07h,07h,07h,07h,07h,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch
		db 0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch
	Warnin2 db 07h,07h,07h,07h,07h,07h,07h,07h,07h,07h,07h,07h,07h,07h,07h,07h,07h,0Ch,0Ch,0Ch,0Ch
		db 0Ch,0Ch,0Ch,0Ch,0Ch,07h,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,07h,07h,07h,07h,07h,07h,07h
		db 07h,07h,07h,07h,07h,07h,07h,07h,07h,07h,07h,07h,07h,07h,07h,07h,07h,07h
	Warnin3 db 07h,07h,07h,07h,07h,07h,07h,07h,07h,07h,07h,07h,07h,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh
		db 0Fh,0Fh,0Fh,0Fh,0Fh,07h,07h,07h,07h,07h,07h,07h,07h,07h,07h,07h,07h,0Ch,0Ch,0Ch,0Ch
		db 0Ch,07h,07h,07h,07h,07h,07h,07h,07h,07h,07h,07h,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch
		db 0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch
	HelpStr db ' Befehle in WindowSystemOS :',13,10
		db '',13,10
		db '  Befehl   | Erklaerung',13,10
		db '  ---------+---------------------------------',13,10
		db '  exit     | Faehrt WinSysOS herunter',13,10
		db '  ver      | Zeigt die Versionsnummer an',13,10
		db '  help     | Zeigt diese Hilfe an',13,10
		db '  info     | Zeigt Informationen zu WinSysOS an',13,10
		db '  changes  | Zeigt den Verlauf der Aenderungen an',13,10
		db '  cls      | Loescht den Bildschirminhalt',13,10
		db '  read     | Sektor auslesen und ausgeben',13,10
		db '  write    | Text auf einen Sektor schreiben',13,10
		db '  rawread  | Sektor auslesen und ausgeben ( rohformat )',13,10
	     ;  db '  rawwrite | Text auf einen Sektor schreiben ( rohformat )',13,10
		db '  registry | Aendernt die Benutzerdaten',13,10
		db '',13,10
		db ' Bitte achten sie darauf das ALLE Zeichen kleingeschrieben werden muessen',13,10,0
	InfoStr db ' Hallo ich bin der Ersteller von WindowSystemOS und auch der gruender',13,10
		db ' von WindowSystemCompany, wenn ihr euch also fragt wer so ein mist',13,10
		db ' programmiert, dann bin ich der schuldige :-)',13,10
		db '',13,10
		db ' Angefangen hat alles ganz harmlos, ehrlich ;-)',13,10
		db ' Ich wollte ein Betriebssystem entwickeln das einzig und alleine in',13,10
		db ' den Bootsektor einer Diskette passt, natuerlich nur mit ein paar',13,10
		db ' Funktionen, aber als ich dann merkte das das doch nicht geht, weil',13,10
		db ' 512 Byte einfach zu wenig sind habe ich mich entschlossen ( nach ein',13,10
		db ' paar Ohrfeigen :-) ) die Grenzen zu loessen und nicht nur einen Sektor zu',13,10
		db ' nutzen sondern eine Datei !',13,10
		db ' Ergebnis : Mein OS wird immer nur aus einer Kernel bestehen bis auch das',13,10
		db ' ABSULUT nicht mehr geht ...',13,10,0
	Change1 db ' Aenderungen von WindowSystemOS :',13,10
		db '',13,10
		db ' * = Geandert / Repariert',13,10
		db ' ! = Hinweis / Info',13,10
		db ' + = Hinzugefuegt',13,10
		db ' - = Entfehrnt',13,10
		db '',13,10
		db '  WinSysOS v0.0.1 Beta [05.05.2011] 4365 Byte',13,10
		db '  ---------------------------------------------',13,10
		db '  [!] Erste Version',13,10
		db '  [+] "RESET" zum zurueksetzen',13,10
		db '  [+] "EXIT" zum runterfahren',13,10
		db '  [+] "VER" zum herausfinden der OS-Version',13,10
		db '  [+] "HELP" als kleine Hilfe',13,10
		db '  [+] "INFO" ein paar Worte vom Programmierer',13,10
		db '  [+] "CLS" um den Bildschirm zu loeschen',13,10
		db '  [+] Color unterstuetzung',13,10
		db '  [+] Back unterstuetzung bei Befehleingabe',13,10
		db '',13,10,0
	Change2 db ' Aenderungen von WindowSystemOS :',13,10
		db '',13,10
		db ' * = Geandert / Repariert',13,10
		db ' ! = Hinweis / Info',13,10
		db ' + = Hinzugefuegt',13,10
		db ' - = Entfehrnt',13,10
		db '',13,10
		db '  WinSysOS v0.0.2 Beta [01.07.2011] 7976 Byte',13,10
		db '  ---------------------------------------------',13,10
		db '  [*] "INFO" zeigt jetzt wirklich Text',13,10
		db '  [*] Komplett neues Style / Farbgebung',13,10
		db '  [+] "CHANGES" zum verfolgen der Anderungen',13,10
		db '  [+] Pause funktion',13,10
		db '  [+] Commander Prefix "CMD>"',13,10
		db '',13,10,0
	Change3 db ' Aenderungen von WindowSystemOS :',13,10
		db '',13,10
		db ' * = Geandert / Repariert',13,10
		db ' ! = Hinweis / Info',13,10
		db ' + = Hinzugefuegt',13,10
		db ' - = Entfehrnt',13,10
		db '',13,10
		db '  WinSysOS v0.0.3 Beta [04.07.2011] 14267 Byte',13,10
		db '  ---------------------------------------------',13,10
		db '  [+] Diskettenzugriffs-Funktionen',13,10
		db '  [+] String2Value zur Zahleingabe ( HEX und DEC )',13,10
		db '  [+] Value2String zur Zahlausgabe ( nur HEX )',13,10
		db '  [+] "Read" zum Lesen von Sektoren',13,10
		db '  [+] "Write" zum Schreiben von Sektoren',13,10
		db '  [+] "RawRead" zum Lesen von Sektoren ( rohformat )',13,10
	     ;  db '  [+] "RawWrite" zum Schreiben von Sektoren ( rohformat )',13,10
		db '  [+] Benutzerverwaltung mit Passwortschutz',13,10
		db '  [+] "Registry" zum aendern der Benutzerdaten',13,10
		db '  [+] Einstellungen werden gespeichert',13,10,0
	ChoiceS db 'Bitte Auswealen : ',0
	BreakSt db 'Abgebrochen...',13,10,0
	WaitStr db ' Weiter mit ENTER oder SPACE ...',13,10,0
	WaitFlg db 07h,0Bh,0Bh,0Bh,0Bh,0Bh,0Bh,07h,07h,07h,07h,07h,0Fh,0Fh,0Fh,0Fh,0Fh,07h,07h,07h,07h,07h,07h,0Fh,0Fh,0Fh,0Fh,0Fh,07h,07h,07h,07h
	Val8Str db 'Ungueltiges Zeichen, nur 0-9 und A-F erlaubt ( 16 Zeichen ) !!!',13,10,0
	Val8Flg db 0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,07h,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,07h,07h,0Fh,0Fh,0Fh,07h,0Fh,0Fh,0Fh,07h,0Fh,0Fh,0Fh
		db 07h,0Fh,0Fh,0Fh,07h,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,07h,0Ch,07h,0Ch,0Ch,07h,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,07h,0Ch,07h,0Fh,0Fh,0Fh
	Val4Str db 'Ungueltiges Zeichen, nur 0-9 und A-F erlaubt ( 8 Zeichen ) !!!',13,10,0
	Val4Flg db 0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,07h,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,07h,07h,0Fh,0Fh,0Fh,07h,0Fh,0Fh,0Fh,07h,0Fh,0Fh
		db 0Fh,07h,0Fh,0Fh,0Fh,07h,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,07h,0Ch,07h,0Ch,07h,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,07h,0Ch,07h,0Fh,0Fh,0Fh
	Val2Str db 'Ungueltiges Zeichen, nur 0-9 und A-F erlaubt ( 4 Zeichen ) !!!',13,10,0
	Val2Flg db 0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,07h,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,07h,07h,0Fh,0Fh,0Fh,07h,0Fh,0Fh,0Fh,07h,0Fh,0Fh
		db 0Fh,07h,0Fh,0Fh,0Fh,07h,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,07h,0Ch,07h,0Ch,07h,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,07h,0Ch,07h,0Fh,0Fh,0Fh
	Val1Str db 'Ungueltiges Zeichen, nur 0-9 und A-F erlaubt ( 2 Zeichen ) !!!',13,10,0
	Val1Flg db 0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,07h,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,07h,07h,0Fh,0Fh,0Fh,07h,0Fh,0Fh,0Fh,07h,0Fh,0Fh
		db 0Fh,07h,0Fh,0Fh,0Fh,07h,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,07h,0Ch,07h,0Ch,07h,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,07h,0Ch,07h,0Fh,0Fh,0Fh
	Dec2Str db 'Ungueltiges Zeichen, nur 0-9 erlaubt ( max 65535 ) !!!',13,10,0
	Dec2Flg db 0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,07h,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,07h,07h,0Fh,0Fh,0Fh,07h,0Fh,0Fh
		db 0Fh,07h,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,07h,0Ch,07h,0Ch,0Ch,0Ch,07h,0Ch,0Ch,0Ch,0Ch,0Ch,07h,0Ch,07h,0Fh,0Fh,0Fh
	ReadStr db 'Bitte ein Sektor zum lesen auswaehlen ( 0-999 = System ) ( max. 2879 ) : ',13,10,0
	ReadFlg db 07h,07h,07h,07h,07h,07h,07h,07h,07h,07h,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,07h,07h,07h,07h,07h,0Fh,0Fh,0Fh,0Fh,0Fh,07h,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh
		db 07h,0Ch,07h,0Ch,0Ch,0Ch,0Ch,0Ch,07h,0Ch,07h,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,07h,0Ch,07h,0Fh,07h,0Fh,0Fh,0Fh,0Fh,07h,0Fh,0Fh,0Fh,0Fh,07h,0Fh,07h,0Fh,07h
	WriteSt db 'Bitte ein Sektor zum beschreiben auswaehlen ( 0-999 = System ) ( max. 2879 ) : ',13,10,0
	WriteFg db 07h,07h,07h,07h,07h,07h,07h,07h,07h,07h,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,07h,07h,07h,07h,07h,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,07h,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh
		db 0Fh,0Fh,0Fh,07h,0Ch,07h,0Ch,0Ch,0Ch,0Ch,0Ch,07h,0Ch,07h,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,07h,0Ch,07h,0Fh,07h,0Fh,0Fh,0Fh,0Fh,07h,0Fh,0Fh,0Fh,0Fh,07h,0Fh,07h,0Fh,07h
	NewLine db 13,10,0
	RawStr1 db '         00h 01h 02h 03h 04h 05h 06h 07h 08h 09h 0Ah 0Bh 0Ch 0Dh 0Eh 0Fh',13,10
		db '   00h ',13,10,'   10h ',13,10,'   20h ',13,10,'   30h ',13,10,'   40h ',13,10,'   50h ',13,10,'   60h ',13,10,'   70h ',13,10
		db '   80h ',13,10,'   90h ',13,10,'   A0h ',13,10,'   B0h ',13,10,'   C0h ',13,10,'   D0h ',13,10,'   E0h ',13,10,'   F0h ',13,10,0
	RawStr2 db '         00h 01h 02h 03h 04h 05h 06h 07h 08h 09h 0Ah 0Bh 0Ch 0Dh 0Eh 0Fh',13,10
		db '  100h ',13,10,'  110h ',13,10,'  120h ',13,10,'  130h ',13,10,'  140h ',13,10,'  150h ',13,10,'  160h ',13,10,'  170h ',13,10
		db '  180h ',13,10,'  190h ',13,10,'  1A0h ',13,10,'  1B0h ',13,10,'  1C0h ',13,10,'  1D0h ',13,10,'  1E0h ',13,10,'  1F0h ',13,10,0



SettingsArea:
	Name	db 40 dup 00h
	Pass	db 40 dup 00h
	PassLen dw 0
TIMES SettingsArea+512-($-$$) DB 0



Variables:
LineX		dw ?
LineY		dw ?
ClearScreenLine dw 0
Sektor		db 0
Track		db 0
Head		db 0
TempQuad	dq 0
TempLong	dd 0
TempWord	dw 0
TempByte	db 0
temp0		db 0
temp1		db 0
temp2		db 0
temp3		db 0
temp4		db 0
temp5		db 0
temp6		db 0
temp7		db 0
temp8		db 0
temp9		db 0
tempA		db 0
tempB		db 0
tempC		db 0
tempD		db 0
tempE		db 0
tempF		db 0
temp0w		dw 0
temp1w		dw 0
temp2w		dw 0
temp3w		dw 0
temp4w		dw 0
temp5w		dw 0
temp6w		dw 0
temp7w		dw 0
temp8w		dw 0
temp9w		dw 0
tempAw		dw 0
tempBw		dw 0
tempCw		dw 0
tempDw		dw 0
tempEw		dw 0
tempFw		dw 0
temp0d		dd 0
temp1d		dd 0
temp2d		dd 0
temp3d		dd 0
temp4d		dd 0
temp5d		dd 0
temp6d		dd 0
temp7d		dd 0
temp8d		dd 0
temp9d		dd 0
tempAd		dd 0
tempBd		dd 0
tempCd		dd 0
tempDd		dd 0
tempEd		dd 0
tempFd		dd 0
temp0q		dq 0
temp1q		dq 0
temp2q		dq 0
temp3q		dq 0
temp4q		dq 0
temp5q		dq 0
temp6q		dq 0
temp7q		dq 0
temp8q		dq 0
temp9q		dq 0
tempAq		dq 0
tempBq		dq 0
tempCq		dq 0
tempDq		dq 0
tempEq		dq 0
tempFq		dq 0

InfoArea:

;   Color ( Hintergrund*16+Fordergrund )
;       0 = Schwarz        8 = Dunkelgrau
;       1 = Dunkelblau     9 = Blau
;       2 = Dunkelgrün     A = Grün
;       3 = Blaugrün       B = Zyan
;       4 = Dunkelrot      C = Rot
;       5 = Lila           D = Magenta
;       6 = Ocker          E = Gelb
;       7 = Hellgrau       F = Weiß

;   Floppy-Fehlercodes
;       00h     kein Fehler
;       01h     Illegale Funktionsnummer
;       02h     Keine Adress-Markierung
;       03h     Diskette ist schreibgeschützt
;       04h     Sektor nicht gefunden
;       05h     Reset erfolglos
;       07h     Fehlerhafte Initialisierung
;       08h     Überlauf DMA
;       09h     Segmentgrenzen-Überlauf des DMA
;       10h     Lesefehler
;       11h     Daten trotz falscher Prüfsumme gelesen
;       20h     Fehler des Controllers
;       40h     Spur nicht gefunden
;       80h     Laufwerk reagiert nicht
;       BBh     BIOS-Fehler
;       FFh     Nicht aufschlüsselbarer Fehler