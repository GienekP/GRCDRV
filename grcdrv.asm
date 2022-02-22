;-----------------------------------------------------------------------		
;
; G: RAM-CART Driver
; (c) GienekP
;
;-----------------------------------------------------------------------
ICAX1Z  = $2A
ICAX2Z  = $2B
COLBAKS = $02C8
MEMLO   = $02E7
COLBAK  = $D01A
RANDOM  = $D20A
NEWDEV  = $EEBC

;-----------------------------------------------------------------------		
; MAIN PROCEDURE - call NEWDEV
;-----------------------------------------------------------------------		
GNEWDEV		lda #$0F
		sta COLBAKS	
		clc				; incrase MEMLO
		lda MEMLO
		adc #<(GENDPRO+1-GNEWDEV)
		sta MEMLO
		lda MEMLO+1
		adc #>(GENDPRO+1-GNEWDEV)
		sta MEMLO+1		
		ldx #'G'
R1		ldy #<GDRIVER
		lda #>GDRIVER
		jmp NEWDEV
;-----------------------------------------------------------------------		
; VECTOR TABLE
;-----------------------------------------------------------------------		
GDRIVER		.WORD OPEN-1
		.WORD CLOSE-1
		.WORD GET-1
		.WORD PUT-1
		.WORD STATUS-1
		.WORD SPEC-1
		jmp GRCINIT
		dta 0
;-----------------------------------------------------------------------		
; GRCINIT
;-----------------------------------------------------------------------		
GRCINIT		lda #$08
		sta COLBAKS
		rts
;-----------------------------------------------------------------------		
; OPEN routine
;-----------------------------------------------------------------------		
OPEN		lda ICAX1Z
		cmp #$0C
		beq IOOP
		cmp #$08
		beq OPOP
		cmp #$04
		beq IPOP
		ldy #$92
		rts
		
		;open for INPUT/OUTPUT
IOOP		ldx ICAX2Z
PATCH	
OK		ldy #$01
		rts
		
		;open for OUTPUT only
OPOP		ldx #$FF
		clc
		bcc PATCH
		
		;open for INPUT only
IPOP		ldx #$00
		clc
		bcc PATCH
;-----------------------------------------------------------------------		
; CLOSE routine
;-----------------------------------------------------------------------		
CLOSE		ldx #$00
		ldy #$01
		rts		
;-----------------------------------------------------------------------		
GET		lda RANDOM
		ldy #$01
		rts
;-----------------------------------------------------------------------		
; PUT routine
;-----------------------------------------------------------------------		
PUT		sta COLBAK
		ldy #$01
		rts
;-----------------------------------------------------------------------		
; STATUS routine
;-----------------------------------------------------------------------		
STATUS  	rts
;-----------------------------------------------------------------------		
; Nothing special, just a marking of the end
;-----------------------------------------------------------------------		
SPEC
GENDPRO		rts
;-----------------------------------------------------------------------
