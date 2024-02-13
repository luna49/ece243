/* Program to Count the number of 1's in a 32-bit word,
located at InputWord */

.global _start
_start:
	/* Put your code here */
	movia r8, TEST_NUM			# load address of TEST_NUM into r8
	movia r9, LargestOnes 		# load address of LargestOnes into r10
    movia r10, LargestZeroes 	# load address of LargestZeroes into r12
	
	ldw r14, (r9)		# load 0 into r11
	ldw r12, (r10)		# load 0 into r12

    movia r2, 0					# counts the number of 1s

loop:
	ldw r4, (r8)				# load value of TEST_NUM into r4
	beq r4, r0, endiloop		# end if the word is 0 
	
	movi r2, 0					# reset r2
	call ONES
	ble r2, r14, continue		# if less 1s than stored, go to next
	mov r14, r2
	stw r14, (r9)
	
continue:
	ldw r4, (r8)				# reload for second iteration
	
	movia r13, 0xFFFFFFFF		# load all 1s
	xor r4, r13, r4				# get new number with 1s as 0s
	movi r2, 0					# reset r2
	call ONES
	
	addi r8, r8, 4			# move to next word
	ble r2, r12, loop		# next num if less 0s than stored
	mov r12, r2
	stw r12, (r10)
	
	br loop
	
endiloop: 
	br endiloop
	
ONES:
    beq r4, r0, return		# finish if no more bits left
	andi r11, r4, 1			# get least sig bit using AND to check if 1
    add r2, r11, r2			# add 0 or 1 to counter
	srli r4, r4, 1			# shift right 1 to get next bit
	br ONES
	
return:
	ret

.data
TEST_NUM:  .word 0x4a01fead, 0xF677D671,0xDC9758D5,0xEBBD45D2,0x8059519D
            .word 0x76D8F0D2, 0xB98C9BB5, 0xD7EC3A9E, 0xD9BADC01, 0x89B377CD
            .word 0  # end of list 

LargestOnes: .word 0
LargestZeroes: .word 0
	