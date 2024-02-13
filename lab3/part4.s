# the DE1-SoC is faster than CPUlator
.global _start
_start:

    /* Load the address of TEST_NUM into a register */
    movia r4, TEST_NUM

    /* Initialize LargestOnes and LargestZeroes in r7 and r8 */
    movi r7, 0
    movi r8, 0

loop:
    /* Load the word from TEST_NUM into r6 */
    ldw r6, (r4)
    beq r6, r0, end  /* if the word is 0, branch to end */

    /* Call the ONES subroutine to count ones and zeros */
    call ONES

    /* Update LargestOnes and LargestZeroes if necessary */
    ble r7, r2, update_largest_ones
    ble r8, r3, update_largest_zeroes
    br skip_update

update_largest_ones:
    /* Update LargestOnes with the current count */
    mov r7, r2

update_largest_zeroes:
    /* Update LargestZeroes with the current count */
    mov r8, r3

skip_update:
    /* Move to the next 32-bit word */
    addi r4, r4, 4
    br loop

end:
    /* Store the largest ones and zeroes count */
    movia r5, LargestOnes
    stw r7, (r5)
    movia r9, LargestZeroes
    stw r8, (r9)
   
    /* Extract low-order 10 bits of LargestOnes and LargestZeroes for LED display */
    andi r7, r7, 1023
    andi r8, r8, 1023 #1111111111 in bitwise binary therefore when using AND it onlly displays the lower 10 bits and sets the rest to 0
   
    .equ LEDs, 0xFF200000
    movia r25, LEDs
    movia r11, 32000

display_loop:
    /* Display LargestOnes on LEDs */
    stwio r7, (r25)
    movia r11, 32000000
    /* Call delay subroutine */
    call delay_loop

    /* Display LargestZeroes on LEDs */
    stwio r8, (r25)
    movia r11, 32000000
    /* Call delay subroutine */
    call delay_loop

    /* Loop back to display again */
    br display_loop

DELAY:
    /* Initialize delay counter (adjust r11 for the desired delay length) */
    movia r11, 32000  /* Example delay value, adjust based on testing */

delay_loop: #waste time
    subi r11, r11, 1
    bne r11, r0, delay_loop
    ret
   
ONES:
    /* Initialize the counters in r2 (ones) and r3 (zeroes) to 0 */
    movi r2, 0
    movi r3, 0

    /* Initialize the loop counter in r10 to 32 */
    movi r10, 32

count_loop:
    /* Check if the loop counter is zero */
    beq r10, r0, return_from_ones

    /* Check the least significant bit (LSB) of r6 */
    andi r11, r6, 1 #checks to see if the lsb is 1, if yes set r11 to 1
    xori r12, r11, 1 #checks to see if r11 is 1, if yes, set r12 to 0

    /* If LSB is 1, increment the ones counter in r2 */
    add r2, r2, r11

    /* Increment the zeroes counter in r3 */
    add r3, r3, r12

    /* Shift r6 to the right, bringing the next bit to LSB */
    srli r6, r6, 1

    /* Decrement the loop counter in r10 */
    subi r10, r10, 1

    /* Loop back to check the next bit */
    br count_loop

return_from_ones:
    ret

.data
TEST_NUM: .word 0x4a01fead, 0xF677D671, 0xDC9758D5, 0xEBBD45D2, 0x8059519D, 0x76D8F0D2, 0xB98C9BB5, 0xD7EC3A9E, 0xD9BADC01, 0x89B377CD, 0
LargestOnes: .word 0
LargestZeroes: .word 0