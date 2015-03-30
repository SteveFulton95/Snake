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

headStartL = $0a00
headStartH = $0a01
snakeIndexPtrL = $20
snakeIndexPtrH = $21
screenPtrL = $22
screenPtrH = $23
snakeBodyLength = $24 ; length of the snake

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
		;jsr initBorder
		jsr initInput
		jsr initPlayer
		jsr initFood
		jmp gameLoop
brk
		
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
		; Beyond zero page there is an array of pointers to screen memory.
		; These pointers represent the snakes position on screen.
		; In order to access each pointer each byte of the pointer
		; must be copied back to zero page then used to access the screen.
		; If the array is made in zero page then it will begin to overflow
		; to page two which causes bad things to happen.

		; init the first snake body pointer (starting in page 10)
		lda #$c8		;low byte of middle of screen
		sta headStartL
		sta screenPtrL
		lda #$71		;high byte of middle of screen
		sta headStartH
		sta screenPtrH
		
		lda #8 ; the snakes body starts at 4 long
		sta snakeBodyLength
		
		;draw the head to the screen
		ldy #0
		lda #$21
		sta (screenPtrL),y	;draws the player in start loc
		
		lda #$64			;starts the player moving right
		sta direction
		rts
		
initFood		;this doesn't really work
		ldy #0
		lda #$20
		;sta (foodL),y
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
		lda #$2a
		sta (foodL),y
		rts
		
gameLoop
		jsr getInput
		;jsr updatePlayer
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

updatePlayer
		; change all of the snake pointers
		jsr moveBody
		;update the head of the snake based on input
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
		sec
		lda headStartL
		sbc #40
		sta headStartL
		lda headStartH
		sbc #0
		sta headStartH
		rts
moveDown
		clc
		lda headStartL
		adc #40
		sta headStartL
		lda headStartH
		adc #0
		sta headStartH
		rts
moveLeft
		sec
		lda headStartL
		sbc #1
		sta headStartL
		lda headStartH
		sbc #0
		sta headStartH
		rts

moveRight
		clc
		lda headStartL
		adc #1
		sta headStartL
		lda headStartH
		adc #0
		sta headStartH
		rts
		
moveBody
		jsr erase ;erase the old tail position
		jsr shift
		rts
		
shift
		;push all of the snake but the tail onto the stack
		ldx #00
pushStack
		lda headStartL,x
		pha
		inx
		cpx snakeBodyLength
		bne pushStack
		
		ldx snakeBodyLength
		inx
bodyLoop
		pla
		sta headStartL,x
		dex
		cpx #01
		bne bodyLoop
		rts

erase
		ldy #0
		
		;make sure the snakeIndexPrt is pointing to the tail of the snake
		clc
		lda #$00
		adc snakeBodyLength	; add the body length
		sta snakeIndexPtrL
		lda #$0a
		adc #$00
		sta snakeIndexPtrH
		
		; init the screen pointer to the last snake pointer
		lda (snakeIndexPtrL),y
		sta screenPtrL
		iny
		lda (snakeIndexPtrL),y
		sta screenPtrH
		
		dey
		lda #$20
		sta (screenPtrL),y	;erases the player pos
		rts
		
checkCollision
		jsr borderCheck
		jsr selfCheck
		jsr foodCheck
		rts
		
selfCheck
		ldy #00
		lda headStartL
		sta screenPtrL
		lda headStartH
		sta screenPtrH
		lda (screenPtrL),y
		cmp #$21
		beq gameOver
		rts
borderCheck
		ldy #00
		lda headStartL
		sta screenPtrL
		lda headStartH
		sta screenPtrH
		lda (screenPtrL),y
		cmp #$00
		beq gameOver
		rts
		
foodCheck
		ldy #00
		lda headStartL
		sta screenPtrL
		lda headStartH
		sta screenPtrH
		lda (screenPtrL),y
		cmp #$2a
		beq eatFood
		rts
		
eatFood
		jsr initFood
		clc
		lda #6
		adc snakeBodyLength
		sta snakeBodyLength
		rts

drawPlayer
		ldy #00
		lda headStartL
		sta screenPtrL
		lda headStartH
		sta screenPtrH
		lda #$21
		sta (screenPtrL),y
		rts
		
gameOver
		jmp start
		
clearScreen 
		lda #$29
		sta $03		;storing the low byte of the screen
		lda #$70
		sta $04		;storing the high byte of the screen
		ldy #0
		ldx #23
		
clear
		lda #$20	;loading space into accumulator
		sta ($03),y	;storing space into the appropriate screen address
		iny
		cpy #$26	;test if row was cleared
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
