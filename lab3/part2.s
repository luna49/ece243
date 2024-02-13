/* Program to Count the number of 1's in a 32-bit word,
located at InputWord */

.global _start
_start:
	/* Put your code here */
	movia r8, InputWord		# load address of InputWord into r8
	ldw r4, 0(r8)			# load value of InputWord into r4
    movia r2, 0				# counts the number of 1s
	
	call ONES

	movia r8, Answer		# load address of Answer into r8
    stw r2, 0(r8)			# store into memory Answer
	br endiloop
	
endiloop: 
	br endiloop
	
ONES:
    beq r4, r0, return		# finish if no more bits left
	andi r11, r4, 1			# get least sig bit using AND to check if 1
    add r2, r11, r2			# add 0 or 1 to counter
	srai r4, r4, 1			# shift right 1 to get next bit
	br ONES
	
return:
	ret

InputWord: .word 0x4a01fead

Answer: .word 0
	
	