; Name:				Steve Fulton
; Course:			cpsc 370
; Instructor:			Dr. Conlon
; Date started:			February 7, 2015
; Last modification:		March 9, 2015
; Purpose of programe:		Snake game.

	.CR	6502		; Assemble 6502 language
	.LI	on,toff		; Listing on, no timing included.
	.TF 	snake.prg,BIN	; Object file and format

	.OR $0300
start:	cld
		jsr clearScreen
		jsr initSnake
		jsr initTarget
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

initSnake
		rts

initTarget	
		rts
		
gameLoop
		jsr getInput
		jsr updateSnake
		jsr drawSnake
		jsr drawTarget
		jsr checkCollision
		jmp gameLoop

getInput
		rts

drawTarget
		rts
		
drawSnake
		rts

updateSnake
		rts
		
		
checkCollision
		jmp gameOver
		
gameOver	