
VERSION_STRING_1 equ '[Version: 0.0.2 Beta]'
VERSION_STRING_2 equ 'v0.0.2 Beta'

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

Reset:
	MOV SI, NewLine
	CALL WriteString
	MOV CX, 30
	MOV DX, ResetFg
	CALL SetFlag
	MOV SI, ResetSt
	CALL WriteString
	MOV SI, NewLine
	CALL WriteString
	INT 19h

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
	CALL WriteColorWarning
	MOV SI, NewLine
	CALL WriteString
	MOV SI, Change2
	CALL WriteString
	MOV SI, NewLine
	CALL WriteString
	jmp start

Exit:
	MOV SI, NewLine
	CALL WriteString
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
	RETN ; No

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

ReadString: ; DI = Buffer
	MOV AH, 0		; Funktion
	INT 16h 		; Zeichen einlesen
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
		db '  Befehl  | Erklaerung',13,10
		db '  --------+---------------------------------',13,10
		db '  exit    | Faehrt WinSysOS herunter',13,10
		db '  ver     | Zeigt die Versionsnummer an',13,10
		db '  help    | Zeigt diese Hilfe an',13,10
		db '  info    | Zeigt Informationen zu WinSysOS an',13,10
		db '  changes | Zeigt den Verlauf der Aenderungen an',13,10
		db '  cls     | Loescht den Bildschirminhalt',13,10
		db '',13,10
		db ' Bitte achten sie darauf das ALLE Zeichen kleingeschrieben werden muessen',13,10,0
	InfoStr db ' Hallo ich bin der ersteller von WindowSystemOS und auch der gruender',13,10
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
		db '  [+] Commander Prefix "CMD>"',13,10,0
	ChoiceS db 'Bitte Auswealen : ',0
	BreakSt db 'Abgebrochen...',13,10,0
	WaitStr db ' Weiter mit ENTER oder SPACE ...',13,10,0
	WaitFlg db 07h,0Bh,0Bh,0Bh,0Bh,0Bh,0Bh,07h,07h,07h,07h,07h,0Fh,0Fh,0Fh,0Fh,0Fh,07h,07h,07h,07h,07h,07h,0Fh,0Fh,0Fh,0Fh,0Fh,07h,07h,07h,07h
	NewLine db 13,10,0

Variables:
LineX		dw ?
LineY		dw ?
ClearScreenLine dw 0

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