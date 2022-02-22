;
; XEXloader for RAM-CART
; (c) GienekP
;

//DBG = $AE

SBL = $A0
SBH = SBL+1
SAL = $A2
SAH = SAL+1
EBL = $A4
EBH = EBL+1
EAL = $A6
EAH = EAL+1

CNTL = $A8
CNTH = CNTL+1
ENTL = $AA
ENTH = ENTL+1
D50  = $AC

COLBAKS = $02C8
INITAD  = $02E2
RUNAD   = $02E0
COLBAK  = $D01A

		ORG $0600
		RUN START
		
START		lda #$00
		
		sta SBL
		sta SBH
		sta EBL
		sta EBH	

LOADER		lda <RETURN
		sta INITAD
		lda >RETURN
		sta INITAD+1
		
		lda <NORUN
		sta RUNAD
		lda >NORUN
		sta RUNAD+1
		
		jsr NEWBANK
		
		ldx #$00	; X zawsze 0
		ldy #$01	; Y zawsze 1 RAM-CART OFF
			
		lda (SAL,X)	; Test [ $FF $FF ]
		cmp #$FF
		beq l0
NOXEX		lda $14
		sta COLBAKS
		jmp NOXEX
		rts	
l0		jsr NEXT
		lda (SAL,X)
		cmp #$FF
		bne NOXEX
		jsr NEXT
		
NEWBL		jsr TESTEND	; Czy są nowe bloki
		lda (SAL,X)	; Adres startu
		sta CNTL
		jsr NEXT
		lda (SAL,X)
		sta CNTH
		jsr NEXT
			
		lda (SAL,X)	; Adres konca
		sta ENTL
		jsr NEXT		
		lda (SAL,X)
		sta ENTH
		jsr NEXT
				
COPY		lda D50		; Wlaczamy RAM-CART
		sta $D501
		lda (SAL,X) 	; Kopiowanie danej
		sty $D501	; Wylaczamy RAM-CART
		sta (CNTL,X)
		sta COLBAK	
		
		lda CNTL	; Czy koniec bloku
		cmp ENTL
		bne NOTEND
		lda CNTH
		cmp ENTH
		beq GOINIT
		
NOTEND		inc CNTL	; Zwiększamy adres docelowy
		bne l1
		inc CNTH
l1		jsr NEXT
		jmp COPY
		
TRIK		jmp (INITAD)	; Koniec bloku - szybciej skoczyc na RTS niz badac
GOINIT  	jsr TRIK

		ldx #$00	; X zawsze 0
		ldy #$01	; Y zawsze 1 RAM-CART OFF
		
		lda <RETURN	; Przygotuje dla przyszlosci
		sta INITAD
		lda >RETURN
		sta INITAD+1			

		jsr NEXT
		lda (SAL,X) 	; Czy może FF
		cmp #$FF	; Wersja z nowym [ $FF $FF ]
		bne l3
		jsr NEXT
		lda (SAL,X) ; Musi byc FF
		cmp #$FF
		beq l2
		jmp NOXEX
l2		jsr NEXT
l3		jmp NEWBL	
		
NEXT		jsr TESTEND
		inc SAL		; Nastepny adres RAM-CARTa
		bne	RETURN
		inc SAH
		lda SAH
		cmp #$C0	; Koniec RAM-CARTa $C000 - 1
		bne RETURN
		lda #$00	; Poczatek RAM-CARTa $8000
		sta SAH
		inc SBL
		lda SBL
		cmp #$40
		bne NEWBANK
		stx SBL
		inc SBH
		
NEWBANK 	lda SBL		; Przełączenie nowego banku
		and #$3F
		asl
		asl
		ora #$02	; Tak mowi ZENON :)
		sta $D500
		sta D50		; Kopia
		lda SBH
		sta $D501
		
RETURN		rts		; Powrot z lokalnych okolicznych funkcji
		
TESTEND		lda SAL		; Czy koniec danych
		cmp EAL
		bne RETURN
		lda SAH
		cmp EAH
		bne RETURN
		lda SBL
		cmp EBL
		bne RETURN
		lda SBH
		cmp EBH
		bne RETURN	
		jmp (RUNAD)
		
NORUN		jmp NORUN

end 		dta $00
