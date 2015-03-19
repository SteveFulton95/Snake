; Name:				Steve Fulton
; Course:			cpsc 370
; Instructor:			Dr. Conlon
; Date started:			February 7, 2015
; Last modification:		March 18, 2015
; Purpose of programe:		snake game.

	.CR	6502		; Assemble 6502 language
	.LI	on,toff		; Listing on, no timing included.
	.TF 	snake.prg,BIN	; Object file and format

iobase	= $8800
iostat	= iobase+1
iocmd	= iobase+2
ioctrl	= iobase+3

playerLocL	= $15
playerLocH	= $16
direction	= $17

; w - #$77
; a - #$61
; s - #$73
; d - #$64
up		= $10
down	= $11
left	= $12
right	= $13

	
		.OR $0300
start	
		jsr clearScreen
		jsr initInput
		jsr initPlayer
		jmp gameLoop
		
clearScreen 
		lda #$00
		sta $03		;storing the low byte of the screen
		lda #$70
		sta $04		;storing the high byte of the screen
		ldy #0
		ldx #25
		
clear
		lda #$20	;loading space into accumulator
		sta ($03),y	;storing space into the appropriate screen address
		iny
		cpy #$28	;test if row was cleared
		bne clear
		
		;changing rows
		clc
		ldy #0	;reseting the y register
		lda $03	;loading the value in memory 03
		adc #40	;adding 40 to that value
		sta $03	;storing it back into memory 03
		lda $04
		adc #00
		sta $04
		dex		;decrementing x for the row counter
		cpx #$00 ;if the x register is 0 then we have cleared the screen
		bne clear	;branches if we aren't done clearing the screen
		
initInput
		cli
		lda #%00001011
		sta iocmd
		lda #%00011010
		sta ioctrl
		lda #$00
		sta iostat
		
		lda #$77
		sta up
		lda #$73
		sta down
		lda #$61
		sta left
		lda #$64
		sta right
		rts
		
initPlayer
		lda #$c8		;low byte of middle of screen
		sta playerLocL
		lda #$71		;high byte of middle of screen
		sta playerLocH
		ldy #0
		lda #$21
		sta (playerLocL),y	;draws the player in start loc
		lda #$64			;starts the player moving right
		sta direction
		rts
		
gameLoop
		jsr getInput
		jsr drawPlayer
		jsr delay
		jmp gameLoop
getInput
		lda iostat		;read the ACIA status
		and #%00001000	;checking if its empty
		beq drawPlayer
		
updatePlayer
		lda iobase
		cmp up
		beq directionUp
		cmp down
		beq directionDown
		cmp left
		beq directionLeft
		cmp right
		beq directionRight
		rts
		
directionUp
		lda iobase
		sta direction
		rts
directionDown
		lda iobase
		sta direction
		rts
directionLeft
		lda iobase
		sta direction
		rts
directionRight
		lda iobase
		sta direction
		rts
		
drawPlayer
		lda direction
		cmp up
		beq moveUp
		cmp down
		beq moveDown
		cmp left
		beq moveLeft
		cmp right
		beq moveRight
		rts
		
moveUp
		jsr erase
		sec
		lda playerLocL
		sbc #40
		sta playerLocL
		lda playerLocH
		sbc #0
		sta playerLocH
		
		lda #$21
		sta (playerLocL),y
		rts
moveDown
		jsr erase
		clc
		lda playerLocL
		adc #40
		sta playerLocL
		lda playerLocH
		adc #0
		sta playerLocH
		
		lda #$21
		sta (playerLocL),y
		rts
moveLeft
		jsr erase
		sec
		lda playerLocL
		sbc #1
		sta playerLocL
		lda playerLocH
		sbc #0
		sta playerLocH
		
		lda #$21
		sta (playerLocL),y
		rts

moveRight
		jsr erase
		clc
		lda playerLocL
		adc #1
		sta playerLocL
		lda playerLocH
		adc #0
		sta playerLocH
		
		lda #$21
		sta (playerLocL),y	;draws the current loc
		rts

erase
		ldy #0
		lda #$20
		sta (playerLocL),y	;erases the previous loc
		
		
delay
		txa
		pha
		tya
		pha
		ldy $ff
bigDelay
		ldx $ff
		tya
		pha
		lda #00
delayLoop
		dex
		ldy #$01
loop3	
		;sbc #10
		dey
		cpy #$00
		bne loop3
		
		cpx $00
		bne delayLoop
		pla
		tay
		dey
		cpy $00
		bne bigDelay
		
		pla
		tay
		pla
		tax
		rts
		
gameOver
		jmp start

		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		