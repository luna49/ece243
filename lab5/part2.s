/******************************************************************************
 * Write an interrupt service routine
 *****************************************************************************/
.section .exceptions, "ax"

/*  When the interrupt happens an we arrive here, several things are done automatically by the hardware:
		1) register r29 ea <- pc at instruction when interrupt happens
		2) register ctl1 <- ctl0  (i.e. a copy is made)   (could also say estatus <- status)
		3) ctl0 (status) bit 0 (PIE) <- 0, to disable all interrupts
		4) ctl0 (status) bit 1  (User/supervisor) <- 0 - put into supervisor mode
*/ 

IRQ_HANDLER:
        # save registers on the stack (et, ra, ea, others as needed)
        subi    sp, sp, 44          # make room on the stack
        stw     et, 0(sp)
        stw     ra, 4(sp)
        stw     r20, 8(sp)
		stw r2, 16(sp)
		stw r4, 20(sp)
		stw r5, 24(sp)
		stw r7, 28(sp)
		stw r9, 32(sp)
		stw r10, 36(sp)
		stw r11, 40(sp)

        rdctl   et, ctl4            # read exception type
        beq     et, r0, SKIP_EA_DEC # not external?
        subi    ea, ea, 4           # decrement ea by 4 for external interrupts

SKIP_EA_DEC:
        stw     ea, 12(sp)
        andi    r20, et, 0x2        # check if interrupt is from pushbuttons
        beq     r20, r0, END_ISR    # if not, ignore this interrupt
        call    KEY_ISR             # if yes, call the pushbutton ISR

END_ISR:
        ldw     et, 0(sp)           # restore registers
        ldw     ra, 4(sp)
        ldw     r20, 8(sp)
        ldw     ea, 12(sp)
		ldw r2, 16(sp)
		ldw r4, 20(sp)
		ldw r5, 24(sp)
		ldw r7, 28(sp)
		ldw r9, 32(sp)
		ldw r10, 36(sp)
		ldw r11, 40(sp)
        addi    sp, sp, 44          # restore stack pointer
        eret                        # return from exception

/*********************************************************************************
 * set where to go upon reset
 ********************************************************************************/
.section .reset, "ax"
        movia   r8, _start
        jmp    r8

/*********************************************************************************
 * Main program
 ********************************************************************************/
.text
.global  _start
.equ KEYs, 0xff200050
.equ HEX_BASE1, 0xff200020
.equ HEX_BASE2, 0xff200030
_start:
        /*
        1. Initialize the stack pointer
        2. set up keys to generate interrupts
        3. enable interrupts in NIOS II
        */
		movia sp, 0x20000    # initialize the stack pointer (used ininterrupt service routine)
      
		movia r2, KEYs		# address of key pushbuttons in r2

		movi r4, 0xF		# need to affect bit 0 using r4 of several registers!

		stwio r4, 0xC(r2) 	# this clears the edge capture bit for KEY0 if it was on, writing into the edge capture register

		stwio r4, 8(r2)		# turn on the interrupt mask register bit 0 for KEY 0 so that this causes
		# an interrupt from the KEYs to go to the processor when button released

		movi r5, 0x2			# need to turn on bit 1 below

		wrctl ctl3, r5 		# ctl3 also called ienable reg - bit 1 enables interupts for IRQ1->buttons

		wrctl ctl0, r4 		# ctl 0 also called status reg - bit 0 is Proc Interrupt Enable (PIE) bit; 
		# bit 1 is the User/Supervisor bit = 0 means supervisor
	  
IDLE:   					# this is a do-nothing loop, except can keep an eye on r2 & r4

		br  IDLE
		
KEY_ISR:
		subi sp, sp, 8 # save any registers the INT handler touches; below uses r2 and r4, so need 8 bytes
		stw r3, 0(sp)  # make sure you understand that how this pushes r3 and r6 onto the stack
		stw r6, 4(sp)

		movia r10, HEX_BASE1    # address of HEX displays
		ldwio r6, 0(r10) 	# can also load the current state of LED register!
		
		movia r3, KEYs 
		ldwio r9, 12(r3)
		andi r9, r9, 0x1
		bne r9, r0, check0
		ldwio r9, 12(r3)
		andi r9, r9, 0x2
		bne r9, r0, check1
		ldwio r9, 12(r3)
		andi r9, r9, 0x4
		bne r9, r0, check2
		ldwio r9, 12(r3)
		andi r9, r9, 0x8
		bne r9, r0, check3
		
check0:
		subi sp, sp, 4
		stw ra, (sp)
		ldwio r8, (r10)
		andi r8, r8, 0b00000001
		beq r8, r0, disp0
		
		movi r4, 16
		br check0pt2
disp0:
		movi r4, 0	# blank
		
check0pt2:
		movi r5, 0
		call HEX_DISP
		movia r8, HEX_BASE1
		ldw ra, (sp)
		addi sp, sp, 4
		
		movi r6, 15
		stwio r6, 12(r3) # clear the edge bit that caused the int
		br finish
check1:
		subi sp, sp, 4
		stw ra, (sp)
		ldwio r8, (r10)
		andi r8, r8, 768
		beq r8, r0, disp1
		
		movi r4, 16
		br check1pt2
disp1:
		movi r4, 1
		
check1pt2:
		movi r5, 1
		call HEX_DISP
		movia r8, HEX_BASE1
		ldw ra, (sp)
		addi sp, sp, 4
		
		movi r6, 15
		stwio r6, 12(r3) # clear the edge bit that caused the int
		br finish
check2:
		subi sp, sp, 4
		stw ra, (sp)
		ldwio r8, (r10)
		movia r11, 196608
		and r8, r8, r11
		beq r8, r0, disp2
		
		movi r4, 16
		br check2pt2
disp2:
		movi r4, 2
		
check2pt2:
		movi r5, 2
		call HEX_DISP
		movia r8, HEX_BASE1
		ldw ra, (sp)
		addi sp, sp, 4
		
		movi r6, 15
		stwio r6, 12(r3) # clear the edge bit that caused the int
		br finish
		
check3:
		subi sp, sp, 4
		stw ra, (sp)
		ldwio r8, (r10)
		movia r11, 50331648
		and r8, r8, r11
		beq r8, r0, disp3
		
		movi r4, 16
		br check3pt2
disp3:
		movi r4, 3
		
check3pt2:
		movi r5, 3
		call HEX_DISP
		movia r8, HEX_BASE1
		ldw ra, (sp)
		addi sp, sp, 4
		
		movi r6, 15
		stwio r6, 12(r3) # clear the edge bit that caused the int	
finish:
ldw r6, 4(sp) # restore those two registers from stack by popping:
ldw r3, 0(sp)
addi sp, sp, 8

subi ea, ea, 4  #  Need to go back an re-execute the interrupted instruction - move back
		#  1 instruction (4 bytes) from where the pc was  
	
ret

/*    Subroutine to display a four-bit quantity as a hex digits (from 0 to F) 
      on one of the six HEX 7-segment displays on the DE1_SoC.
*
 *    Parameters: the low-order 4 bits of register r4 contain the digit to be displayed
		  if bit 4 of r4 is a one, then the display should be blanked
 *    		  the low order 3 bits of r5 say which HEX display (right to left) number 0-5 to put the digit on
 *    Returns: r2 = bit pattern that is written to HEX display
 */

HEX_DISP:
		movia    r8, BIT_CODES         	# starting address of the bit codes
	    andi     r6, r4, 0x10	   		# get bit 4 of the input into r6
	    beq      r6, r0, not_blank 
	    mov      r2, r0
	    br       DO_DISP
not_blank:  
		andi     r4, r4, 0x0f	   		# r4 is only 4-bit
        add      r4, r4, r8            	# add the offset to the bit codes
        ldb      r2, 0(r4)             	# index into the bit codes

#Display it on the target HEX display
DO_DISP:    
			movia    r8, HEX_BASE1         # load address
			movi     r6,  4
			blt      r5,r6, FIRST_SET      # hex4 and hex 5 are on 0xff200030
			sub      r5, r5, r6            # if hex4 or hex5, we need to adjust the shift
			addi     r8, r8, 0x0010        # we also need to adjust the address
FIRST_SET:
			slli     r5, r5, 3             # hex*8 shift is needed
			addi     r7, r0, 0xff          # create bit mask so other values are not corrupted
			sll      r7, r7, r5 
			addi     r4, r0, -1
			xor      r7, r7, r4  
    		sll      r4, r2, r5            # shift the hex code we want to write
			ldwio    r5, 0(r8)             # read current value       
			and      r5, r5, r7            # and it with the mask to clear the target hex
			or       r5, r5, r4	           # or with the hex code
			stwio    r5, 0(r8)		       # store back
END:			
			ret
			
BIT_CODES:  .byte     0b00111111, 0b00000110, 0b01011011, 0b01001111
			.end
