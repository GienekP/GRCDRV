;-----------------------------------------------------------------------		
;
; G: RAM-CART Driver reloc code (XEX USR CAR)
; (c) GienekP
;
;-----------------------------------------------------------------------
.LOCAL	
;-----------------------------------------------------------------------
DEST    = $00			; use address LNFLG & NGFLAG as a temp
PTR		= $1D
;-----------------------------------------------------------------------		
CASINI  = $02
BOOT?   = $09
DOSVEC  = $0A
DOSINI  = $0C
MEMLO   = $02E7
CASBUF  = $0400

;-----------------------------------------------------------------------		
; THIS PART IS FULL RELOC CODE
;-----------------------------------------------------------------------		
 
		ORG $4000
		RUN START
		
		pla				; for BASIC
START	lda DEST+1		; store LNFLG & NGFLAG
		pha
		lda DEST
		pha
		lda PTR+1		; store $1D
		pha
		lda PTR
		pha	

		; DETECT PC-ADDR
		lda #$68
		sta CASBUF
		sta CASBUF+3
		lda #$85
		sta CASBUF+1
		sta CASBUF+4		
		lda #DEST
		sta CASBUF+2
		sta CASBUF+10
		lda #DEST+1
		sta CASBUF+5
		sta CASBUF+7		
		lda #$A5
		sta CASBUF+6
		sta CASBUF+9	
		lda #$48
		sta CASBUF+8
		sta CASBUF+11	
		lda #$60
		sta CASBUF+12
		jsr CASBUF		; PC address to stack
MARK	clc				; <-this address-1 is detected
		lda DEST
		adc #<(GNEWDEV+1-MARK)
		sta PTR
		lda DEST+1
		adc #>(GNEWDEV+1-MARK)
		sta PTR+1		; in (PTR) is GNEWDEV absolute address
		
		; SET SOURCE AND DESTINATION ADDRESS	
		lda MEMLO		; copy MEMLO
		sta DEST
		lda MEMLO+1
		sta DEST+1
		
		clc				; incrase MEMLO
		lda DEST
		adc #<(GENDPRO+1-GNEWDEV)
		sta MEMLO
		lda DEST+1
		adc #>(GENDPRO+1-GNEWDEV)
		sta MEMLO+1
		
		; PTR   - start source copy data
		; DEST  - start destination copy data
		; MEMLO - end destination copy data
		lda DEST+1
		pha
		lda DEST
		pha
		lda PTR+1
		pha
		lda PTR
		pha	
		
		ldx #0
CPYLOOP	lda (PTR,X)
		sta (DEST,X)
	
		clc
		lda PTR
		adc #1
		sta PTR
		bcc L0
		inc PTR+1
		
L0		clc
		lda DEST
		adc #1
		sta DEST
		bcc L1
		inc DEST+1	
		
L1		lda MEMLO
		cmp DEST
		bne CPYLOOP
		lda MEMLO+1
		cmp DEST+1
		bne CPYLOOP
		
		pla
		sta PTR
		pla
		sta PTR+1
		pla
		sta DEST
		pla
		sta DEST+1
		
		lda DEST
		sta PTR
		lda DEST+1
		sta PTR+1
		
		; Recalculate VECTOR TABLE
		clc				; find GNEWDEV address
		lda DEST
		adc #<(GDRIVER-GNEWDEV)
		sta DEST
		lda DEST+1
		adc #>(GDRIVER-GNEWDEV)
		sta DEST+1	
		
		ldy #$00		; OPEN-1
		clc
		lda DEST
		adc #<(OPEN-GDRIVER-1)
		sta (DEST),Y
		lda DEST+1
		adc #>(OPEN-GDRIVER-1)
		iny
		sta (DEST),Y
		
		ldy #$02		; CLOSE-1
		clc
		lda DEST
		adc #<(CLOSE-GDRIVER-1)
		sta (DEST),Y
		lda DEST+1
		adc #>(CLOSE-GDRIVER-1)
		iny
		sta (DEST),Y
		
		ldy #$04		; GET-1
		clc
		lda DEST
		adc #<(GET-GDRIVER-1)
		sta (DEST),Y
		lda DEST+1
		adc #>(GET-GDRIVER-1)
		iny
		sta (DEST),Y

		ldy #$06		; PUT-1
		clc
		lda DEST
		adc #<(PUT-GDRIVER-1)
		sta (DEST),Y
		lda DEST+1
		adc #>(PUT-GDRIVER-1)
		iny
		sta (DEST),Y		

		ldy #$08		; STATUS-1
		clc
		lda DEST
		adc #<(STATUS-GDRIVER-1)
		sta (DEST),Y
		lda DEST+1
		adc #>(STATUS-GDRIVER-1)
		iny
		sta (DEST),Y

		ldy #$0A		; SPEC-1
		clc
		lda DEST
		adc #<(SPEC-GDRIVER-1)
		sta (DEST),Y
		lda DEST+1
		adc #>(SPEC-GDRIVER-1)
		iny
		sta (DEST),Y
		
		ldy #$0D		; GRCINIT
		clc
		lda DEST
		adc #<(GRCINIT-GDRIVER)
		sta (DEST),Y
		lda DEST+1
		adc #>(GRCINIT-GDRIVER)
		iny
		sta (DEST),Y
		
		lda PTR			; restore MEMLO (jump again)
		sta DEST
		sta MEMLO
		lda PTR+1
		sta DEST+1
		sta MEMLO+1
		
		; Write absolute G-table address
		ldy #(R1-GNEWDEV+1)
		clc
		lda DEST
		adc #<(GDRIVER-GNEWDEV)
		sta (DEST),Y
		lda DEST+1
		adc #>(GDRIVER-GNEWDEV)
		iny
		iny
		sta (DEST),y
	
		; Test RESET INIT
		lda BOOT?
		cmp #$00
		beq VCAS
		lda DEST+1
		cmp #$07
		bne END
		lda DEST
		cmp #$00
		bne END
		
VCAS	lda #$02		; absence DOS
		sta BOOT?

		lda DEST
		sta CASINI
		sta DOSINI
		;sta DOSVEC
		lda DEST+1
		sta CASINI+1
		sta DOSINI+1
		;sta DOSVEC+1
		
END		pla				; restore $1D
		sta PTR
		pla
		sta PTR+1
		pla				; restore LNFLG & NGFLAG
		sta DEST
		pla
		sta DEST+1
		jmp (MEMLO)
;-----------------------------------------------------------------------		
.ENDL
;-----------------------------------------------------------------------		
		ICL "grcdrv.asm"
;-----------------------------------------------------------------------		
