.text  # The numbers that turn into executable instructions
.global _start
_start:

/* r13 should contain the grade of the person with the student number, -1 if not found */
/* r10 has the student number being searched */

	movia r10, 718293		# r10 is where you put the student number being searched for

/* Your code goes here  */
	movia r9, result
    movi r13, -1            # Initialize r13 to -1 for default
	movia r12, Snumbers    # Load the address of Snumbers into r12
	movia r8, Grades		# Load the address of Grades into r13

search_loop:
    ldw r11, (r12)        # Load the current student number from the list
    beq r11, r0, iloop  # If the current student number is 0, not found done

    beq r10, r11, search_done     # Compare the student number in r10 with the current student number
    
	addi r12, r12, 4        # Move to the next student number in Snumbers list
	addi r8, r8, 4		# Increment counter
    br search_loop          # Repeat the loop

search_done:
    ldw r13, (r8)           # Load the grade into r13
	
iloop: br iloop

.data  	# the numbers that are the data 

/* result should hold the grade of the student number put into r10, or
-1 if the student number isn't found */ 

result: .word 0
		
/* Snumbers is the "array," terminated by a zero of the student numbers  */
Snumbers: .word 10392584, 423195, 644370, 496059, 296800
        .word 265133, 68943, 718293, 315950, 785519
        .word 982966, 345018, 220809, 369328, 935042
        .word 467872, 887795, 681936, 0

/* Grades is the corresponding "array" with the grades, in the same order*/
Grades: .word 99, 68, 90, 85, 91, 67, 80
        .word 66, 95, 91, 91, 99, 76, 68  
        .word 69, 93, 90, 72