.global _start
.equ KEY_BASE, 0xFF200050            # base address of KEYS parallel port
.equ LEDS, 0xFF200000                # base address of LEDS
.equ EDGE_CAPTURE, 0xFF20005C        # edge capture register address
.equ COUNTER_DELAY, 25000000           # change to 10,000,000 for DE1 board
.equ TIMER_BASE, 0xFF202000			 # base address of hardware timer

_start:
    movia r14, KEY_BASE
    movia r15, LEDS
    movia r10, EDGE_CAPTURE
	movia r20, TIMER_BASE
	stwio r0, 0(r20)         	# clear the TO (Time Out) bit in case it is on

	movia      r8, COUNTER_DELAY    # load the delay value
	srli       r9, r8, 16           # shift right by 16 bits
	andi       r8, r8, 0xFFFF       # mask to keep the lower 16 bits
	stwio      r8, 0x8(r20)         # write to the timer period register (low)
	stwio      r9, 0xc(r20)         # write to the timer period register (high)
	movi       r8, 0b0110           # enable continuous mode and start timer
	stwio      r8, 0x4(r20)         # write to the timer control register to 
	# and go into continuous mode

	movia r21, LEDS

loop:
    ldwio r11, 0(r10)            	# load edge capture register
    andi r11, r11, 0xF            	# mask lower 4 bits (KEY 0-3)
    beq r11, r0, loop        		# continue looping if no key is pressed

    # key pressed, reset edge capture register to avoid missing future button presses
    stwio r11, 0(r10)

    # start/stop counter based on KEY press
    beq r11, r0, loop        		# if no key pressed, continue looping
    mov r12, r11                  	# copy key value to r12

counter_loop:
	br ploop
next:
	ldwio r13, 0(r15)           		# load current LED value
	addi r13, r13, 1           		# increment LED value
	andi r13, r13, 255				# limit to 255 max
	stwio r13, 0(r15)           		# update LEDs
	
	ldwio r11, 0(r10)				# load edge capture register
	stwio r11, 0(r10)				# store edge capture register
	bne r11, r0, change_r12			# key was pressed
	bne r12, r0, counter_loop  		# continue counting if the key is still pressed
    br loop
	
change_r12:
    movi r12, 0						# change value back to 0
    br loop

ploop:
	ldwio r8, 0x0(r20)         # read the timer status register
	andi r8, r8, 0b1          # mask the TO bit
	beq r8, r0, ploop     		# if TO bit is 0, wait
	stwio r0, 0x0(r20)         # clear the TO bit
	br next