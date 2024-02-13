/* Program to Count the number of 1's in a 32-bit word,
located at InputWord */

.global _start
_start:
	/* Put your code here */
	movia r8, InputWord		# load address of InputWord into r8
	ldw r9, 0(r8)			# load value of InputWord into r9
    movia r10, 0			# set counter to start at 0

loop:
    beq r9, r0, done	# finish if no more bits left

    andi r11, r9, 1			# get least sig bit using AND to check if 1
    beq r11, r0, shift_next	# if the bit = 0, go to shift right

    addi r10, r10, 1		# increment counter by 1

shift_next:
    srai r9, r9, 1			# shift right 1 to get next bit
    br loop
	
done:
	movia r8, Answer		# load address of Answer into r8
    stw r10, 0(r8)			# store into memory Answer
	br endiloop
	
endiloop: 
	br endiloop

InputWord: .word 0x4a01fead

Answer: .word 0
	
	
