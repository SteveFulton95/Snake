; Name:						Steve Fulton and Dan Martin
; Course:					cpsc 370
; Instructor:				Dr. Conlon
; Date started:				February 7, 2015
; Last modification:		April 08, 2015
; Purpose of programe:		snake game.

	.CR	6502				; Assemble 6502 language
	.LI	on,toff				; Listing on, no timing included.
	.TF 	snake.prg,BIN	; Object file and format

iobase	= $8800
iostat	= iobase+1
iocmd	= iobase+2
ioctrl	= iobase+3

direction	= $17			; current direction
prevDir		= $27			; previous direction
tempDir		= $28			; "goal" direction before verified correctness

foodL	= $18				; low byte of the food position on screen
foodH	= $19				; high byte of the food position on screen

headStartL = $0a00			; starting position of the snake array
headStartH = $0a01			
screenPtrL = $22			; pointer used to access the screen
screenPtrH = $23		
snakeBodyLength = $24 		; length of the snake in bytes

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
		jsr initInput
		jsr initPlayer
		jsr initFood
		jmp gameLoop
brk	
	
initInput
		; sets what keys are up, down, left, and right	
		cli
		lda #%00001011	;Taken from Dr. Conlon
		sta iocmd
		lda #%00011010
		sta ioctrl
		lda #$00
		sta iostat
		
		lda #$77	; hex value for 'w'
		sta up		; store in up
		lda #$73	; hex value for 's'
		sta down
		lda #$61	; hex value for 'a'
		sta left
		lda #$64	; hex value for 'd'
		sta right
		rts
		
initPlayer
		; Beyond zero page there is an array of pointers to screen memory.
		; These pointers represent the snakes position on screen.
		; In order to access each pointer each byte of the pointer
		; must be copied back to zero page then used to access the screen.
		; If the array is made in zero page then it will begin to overflow
		; on to page two which causes bad things to happen.

		; init the first snake body pointer (starting in page 10)
		lda #$c8			;low byte of middle of screen
		sta headStartL
		sta screenPtrL
		lda #$71			;high byte of middle of screen
		sta headStartH
		sta screenPtrH
		
		lda #8				; the snakes body starts as 8 bytes of pointers
		sta snakeBodyLength
							;draw the head to the screen
		ldy #0
		lda #$21
		sta (screenPtrL),y	;draws the player in starting location
		
		lda #$64			;starts the player moving right
		sta direction
		rts
		
initFood
		; This subroutine pseudo-randomly places food on the screen
		; if it detects a conflict in the chosen location it will replace
		; the food to a new pseudo-random position.
		ldy #0
		ldx #0
replaceFood
		; This basically just puts a bunch of variables together
		; and tries to get something seemingly random out of it.
		; I tried to use as many variables as possible to make the food
		; placement follow basically no discernible pattern
		lda iocmd
		adc foodL
		rol
		sbc screenPtrL
		and #%00000011		; Make sure the high byte is 73 or less
		clc					; I do this by anding the combination of
		adc #$70			; variables with 3 then adding 70.
		sta foodH
		
		txa
		sbc screenPtrL
		eor snakeBodyLength
		adc #$01
		adc foodH
		rol
		and #$e8
		sta foodL
		inx					
		lda (foodL),y		; If the food placement is not blank try again
		cmp #$20
		bne replaceFood
		
		lda #$2a			; Store the food on screen
		sta (foodL),y
		rts
		
gameLoop
		jsr getInput		; gets and checks input from user
		jsr updatePlayer	; updates the player position (does not draw)
		jsr checkCollision	; checks the new position for collisions
		jsr drawPlayer		; if no collisions - draw player
		jsr delay			; delays the game so its playable
		jmp gameLoop		; do it all again

; checks the users input for a specific direction
checkDirection	;compares the "goal" direction with wasd
		lda tempDir			;loads in the input from user
		cmp up				;compares to 'w'
		beq checkDown		;branches to opposite direction 'd'
		cmp down
		beq checkUp
		cmp left
		beq checkRight
		cmp right
		beq checkLeft
		rts
		
;if "goal" direction is opposite of current direction do nothing		
checkUp
		lda prevDir				; loads the previous direction
		cmp up					; compares to 'w'
		bne updateDirection		; if they arent equal we will updateDirection
		rts
checkDown
		lda prevDir
		cmp down
		bne updateDirection
		rts
checkLeft
		lda prevDir
		cmp left
		bne updateDirection
		rts
checkRight
		lda prevDir
		cmp right
		bne updateDirection
		rts

doneInput
		rts	; all done with getting and checking the input

; gets and checks for valid input		
getInput
		lda iostat			; read the ACIA status
		and #%00001000		; checking if its empty
		beq doneInput		; branches if there was no input
		lda iobase			; loads the input into accumulator
		sta tempDir			; stores it in a temp direction
		lda direction		; loads current direction
		sta prevDir			; stores it into previous direction
		jsr checkDirection	; jumps to checkDirection
		rts

; updates the snakes direction		
updateDirection				;updates previous and current direction
		lda direction		;loads current direction
		sta prevDir			;stores it into previous
		lda iobase			;loads input direction
		sta direction		;stores it into direction
		rts
	
; updates the players position (does not draw the player)	
updatePlayer
							; change all of the snake pointers
		jsr moveBody
							;update the head of the snake based on input
		lda direction		; loads direction into accumulator
		cmp up				; compare to 'w'
		beq moveUp			; branches if they are equal to move up
		cmp down
		beq moveDown
		cmp left
		beq moveLeft
		cmp right
		beq moveRight
		rts

; moves the snake up		
moveUp
		sec					; set the carry
		lda headStartL		; load headStartL into accumulator
		sbc #40				; subtract with carry decimal 40
		sta headStartL		; store it back into headStartL
		lda headStartH		; load headStartH into accumulator
		sbc #0				; subtract with carry decimal 0
		sta headStartH		; store it back into headStartH
		rts
moveDown
		clc					; clear the carry
		lda headStartL		; load headStartL into accumulator
		adc #40				; add with carry decimal 40
		sta headStartL		; store it back into headStartL
		lda headStartH
		adc #0
		sta headStartH
		rts
moveLeft
		sec
		lda headStartL
		sbc #1				; decimal 1 because we aren't moving a row
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
		; This subroutine shifts the entire array of pointers that
		; represent the snake so that it can move smoothly without
		; having to redraw the entire snake
		
		jsr erase 				; erase the old tail position
		jsr shift 				; shift the array of snake pointers
		rts						; to prepare for a new head to be made
		
shift							; push all of the snake except
		ldx #00					; the last tail pointer onto the stack
pushStack
		lda headStartL,x
		pha
		inx
		cpx snakeBodyLength
		bne pushStack
		
		ldx snakeBodyLength
		inx
								; pop off the pointers in reverse order
bodyLoop						; and store them shifted down by 2 back
		pla						; the array
		sta headStartL,x
		dex
		cpx #01
		bne bodyLoop
		rts

erase
		ldy #0
		; init the screen pointer to the last snake pointer
		ldy snakeBodyLength
		lda headStartL,y
		sta screenPtrL
		iny
		lda headStartL,y
		sta screenPtrH
		
		ldy #$00
		lda #$20
		sta (screenPtrL),y		;erases the tail
		rts
		
checkCollision
		jsr borderCheck			; checks for snake collisions with the border
		jsr selfCheck			; checks collision with the snake itself
		jsr foodCheck			; checks for food collision
		rts

; checks for the snake colliding into itself		
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
	
; checks for the snake colliding into the border	
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
	
; checks for the snake colliding into food	
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
	
; eats the food if there was food collision	
eatFood
		jsr initFood		; place a new random food
		clc
		lda #6
		adc snakeBodyLength
		sta snakeBodyLength
		rts

; draws the player based on the updated position of the player
drawPlayer
		ldy #00
		lda headStartL
		sta screenPtrL
		lda headStartH
		sta screenPtrH
		lda #$21
		sta (screenPtrL),y
		rts
	
; game is over. jump back to the start of the game	
gameOver
		jmp start
	
; clears the screen and makes the border	
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
		ldy #0		;reseting the y register
		lda $03		;loading the value in memory 03
		adc #40		;adding 40 to that value
		sta $03		;storing it back into memory 03
		lda $04
		adc #00
		sta $04
		dex			;decrementing x for the row counter
		cpx #$00 	;if the x register is 0 then we have cleared the screen
		bne clear	;branches if we aren't done clearing the screen
		rts
	
; delays the speed of the game so its playable and smooth	
; this basically just right shifts register a for some number of times
delay
		ldx #$e0
		lda #$ff
delayLoop1
		ldy #$ff
delayLoop2
		lsr 
		dey
		bne delayLoop2
		dex
		bne delayLoop1
		rts
