; Name:				Steve Fulton
; Course:			cpsc 370
; Instructor:			Dr. Conlon
; Date started:			February 7, 2015
; Last modification:		March 19, 2015
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

foodL	= $18
foodH	= $19

borderL	= $30
borderH	= $31

; w - #$77
; a - #$61
; s - #$73
; d - #$64
up		= $10
down	= $11
left	= $12
right	= $13

tempL	= $20
tempH	= $21

	
		.OR $0300
start	
		cli
		jsr clearScreen
		jsr initBorder
		jsr initInput
		jsr initPlayer
		jsr initFood
		jmp gameLoop
		
initBorder
		lda #$d8
		sta borderL
		lda #$6f
		sta borderH
		ldy #0
		jsr borderLoop
		lda #$e8
		sta borderL
		lda #$73
		sta borderH
		ldy #0
		jsr borderLoop
		rts
borderLoop
		lda #$30
		sta (borderL),y
		iny
		cpy #$28
		bne borderLoop
		rts
		
		
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
		
initFood		;this doesnt really work
		ldy #0
		lda #$20
		sta (foodL),y
		lda iocmd
		adc playerLocH
		lsr
		sbc playerLocL
		and #%00000011
		clc
		adc #$70
		sta foodH
		
		lda playerLocL
		sbc tempL
		rol
		and #%01111111
		sta foodL
		lda #$22
		sta (foodL),y
		rts
		
gameLoop
		jsr getInput
		jsr checkCollision
		jsr drawPlayer
		jsr delay
		jmp gameLoop
		
getInput
		lda iostat		;read the ACIA status
		and #%00001000	;checking if its empty
		beq updatePlayer
		
updateDirection
		lda iobase
		sta direction
		jsr updatePlayer
		rts

updatePlayer
		lda direction
		cmp up
		beq moveUp
		cmp down
		beq moveDown
		cmp left
		beq moveLeft
		cmp right
		beq moveRight
		jmp checkCollision
		
moveUp
		jsr erase
		sec
		lda playerLocL
		sbc #40
		sta playerLocL
		lda playerLocH
		sbc #0
		sta playerLocH
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
		rts
		
erase
		ldy #0
		lda #$20
		sta (playerLocL),y	;erases the player pos
		rts
		
checkCollision
		jsr borderCheck
		jsr foodCheck
		rts
		
borderCheck
		lda (playerLocL),y
		cmp #$30
		beq gameOver
		rts
		
foodCheck
		lda (playerLocL),y
		cmp #$22
		beq eatFood
		rts
		
eatFood
		jsr initFood
		rts

drawPlayer
		lda #$21
		sta (playerLocL),y
		rts
		
gameOver
		jmp start
		
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
		rts
		
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

		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		