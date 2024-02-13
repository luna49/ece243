.global _start
.equ KEY_BASE, 0xFF200050            # base address of KEYS parallel port
.equ LEDS, 0xFF200000                # base address of LEDS
.equ EDGE_CAPTURE, 0xFF20005C        # edge capture register address
.equ COUNTER_DELAY, 500000           # change to 10,000,000 for DE1 board

_start:
    movia r8, KEY_BASE
    movia r9, LEDS
    movia r10, EDGE_CAPTURE

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
	call DO_DELAY              		# delay approximately 0.25 seconds
	ldwio r13, 0(r9)           		# load current LED value
	addi r13, r13, 1           		# increment LED value
	andi r13, r13, 255				# limit to 255 max
	stwio r13, 0(r9)           		# update LEDs
	ldwio r11, 0(r10)				# load edge capture register
	stwio r11, 0(r10)				# store edge capture register
	bne r11, r0, change_r12			# key was pressed
	bne r12, r0, counter_loop  		# continue counting if the key is still pressed
    br loop
	
change_r12:
    movi r12, 0						# change value back to 0
    br loop

DO_DELAY:
    movia r8, COUNTER_DELAY
    sub_loop:
        subi r8, r8, 1
        bne r8, r0, sub_loop
    ret