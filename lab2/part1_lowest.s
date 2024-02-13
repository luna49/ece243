.global _start
_start: movia r8, result # the address of the result
	ldw r9,4(r8)	# the number of numbers is in r9
	
	movia r10, numbers  # the address of the numbers is in r10
	
	
/* keep the smallest number so far in r11 */

	ldw	r11,(r10)
	
/* loop to search for lowest number */

loop: subi r9, r9, 1
       ble r9, r0, finished
	   
	   addi r10,r10,4   # add 4 to pointer to the numbers to point to next one
	   
	   ldw  r12, (r10)  # load the next number into r12
	   
		blt  r12, r11, smallest  # if the current number is smaller, update r11
        br  loop

smallest:
        mov r11, r12   # update r11 to store the smaller number
        br  loop
	   


finished: stw r11,(r8)    # store the answer into result
iloop: br iloop

result: .word 0
n:      .word 15   # Change the number of elements to 15
numbers: .word 7, 2, 9, 4, 8, 6, 1, 3, 5, 10, 12, 15, 11, 14, 13   # Choose 15 unique numbers
	