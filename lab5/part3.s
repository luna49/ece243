.section .exceptions, "ax"
                             # code not shown
	IRQ_HANDLER:
        # save registers on the stack (et, ra, ea, others as needed)
        subi    sp, sp, 48          # make room on the stack
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
		stw r3, 44(sp)

        rdctl   et, ctl4            # read exception type
        beq     et, r0, SKIP_EA_DEC # not external?
        subi    ea, ea, 4           # decrement ea by 4 for external interrupts

SKIP_EA_DEC:
        stw     ea, 12(sp)
        andi    r20, et, 0x2        # check if interrupt is from pushbuttons
        bne     r20, r0, callkey     # if not, ignore this interrupt
		andi    r20, et, 0x1        # check if interrupt is from pushbuttons
        bne     r20, r0, calltimer
		br END_ISR
callkey:
        call    KEY_ISR             # if yes, call the pushbutton ISR
		br END_ISR
calltimer:
        call    TIMER_ISR             # if yes, call the pushbutton ISR
		

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
		ldw r3, 44(sp)
        addi    sp, sp, 48          # restore stack pointer
        eret

.text
.global  _start
.equ KEYs, 0xff200050
.equ LED_BASE, 0xFF200000                # base address of LEDS
.equ TIMER, 0xff202000
.equ EDGE_CAPTURE, 0xFF20005C        # edge capture register address
.equ COUNTER_DELAY, 25000000           # 0.25

_start:
	movia sp, 0x20000    # initialize the stack pointer (used ininterrupt service routine)
	
    call    CONFIG_TIMER        # configure the Timer
    call    CONFIG_KEYS         # configure the KEYs port
    /* Enable interrupts in the NIOS-II processor */
	movi r5, 3
	wrctl ctl3, r5 		# ctl3 also called ienable reg - bit 1 enables interupts for IRQ1->buttons
	
	movi r4, 1
	wrctl ctl0, r4 		# ctl 0 also called status reg - bit 0 is Proc Interrupt Enable (PIE) bit; 
		# bit 1 is the User/Supervisor bit = 0 means supervisor
	  
    movia   r8, LED_BASE        # LEDR base address (0xFF200000)
    movia   r9, COUNT           # global variable
LOOP:
    ldw     r10, 0(r9)          # global variable
    stwio   r10, 0(r8)          # write to the LEDR lights
    br      LOOP

CONFIG_TIMER:
	movia r2, TIMER
	movi r4, 0x1          # Enable interrupt for the timer
	stwio r4, 0x8(r2)     # Turn on the interrupt mask register bit 0 for the timer
	stwio r0, 0(r2)         	# clear the TO (Time Out) bit in case it is on

	# for hardware timer delay
	movia      r8, COUNTER_DELAY    # load the delay value
	srli       r9, r8, 16           # shift right by 16 bits
	andi       r8, r8, 0xFFFF       # mask to keep the lower 16 bits
	stwio      r8, 0x8(r2)         # write to the timer period register (low)
	stwio      r9, 0xc(r2)         # write to the timer period register (high)
	movi       r8, 0b0111           # enable continuous mode and start timer
	stwio      r8, 0x4(r2)         # write to the timer control register to 
	stwio r0, (r2)
	
	ret

CONFIG_KEYS:
		movia r2, KEYs		# address of key pushbuttons in r2

		movi r4, 0xF		# need to affect bit 0 using r4 of several registers!

		stwio r4, 0xC(r2) 	# this clears the edge capture bit for KEY0 if it was on, writing into the edge capture register

		stwio r4, 8(r2)		# turn on the interrupt mask register bit 0 for KEY 0 so that this causes
		# an interrupt from the KEYs to go to the processor when button released
		ret

KEY_ISR:
	movia r2, RUN
	ldw r3, (r2)
	beq r3, r0, key1
	mov r3, r0
	stw r3, (r2)
	br return
key1:
	movi r3, 1
	stw r3, (r2)
return:
	movi r2, 0xF
	movia r3, KEYs
	stwio r2, 12(r3)
	ret
	
TIMER_ISR:
	movia r2, RUN
	ldw r3, (r2)
	movia r4, COUNT
	ldw r5, (r4)
	add r5, r3, r5
	stw r5, (r4)
	movia r2, TIMER
	movi r3, 0
	stwio r3, (r2)
	ret
	
.data
/* Global variables */
.global  COUNT
COUNT:  .word    0x0            # used by timer

.global  RUN                    # used by pushbutton KEYs
RUN:    .word    0x1            # initial value to increment COUNT

.end