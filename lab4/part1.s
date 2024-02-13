.global _start
.equ KEY_BASE, 0xFF200050			# base address of KEYS parallel port
.equ LEDS, 0xFF200000				# base address of LEDS
_start:
	movia r8, KEY_BASE
	movia r9, LEDS
	movi r10, 0
	movi r14, 1
	movi r15, 2
	movi r16, 4
	movi r17, 8
	movi r18, 0						# post key 3 flag
	movi r19, 15					# top limit for incrementing
	movi r20, 0						# last state checker

poll:
	mov r20, r10					# get the state
	ldwio r10, 0(r8)				# load data register 
	andi r10, r10, 0xF				# select all lower 4 bits (KEY 0-3)
	beq r18, r14, reset_display		# flag for if key 3 has just been pressed
	beq r10, r14, check_key0
	beq r10, r15, check_key1
	beq r10, r16, check_key2
	beq r10, r17, check_key3
	br poll

check_key0:
    # key 0 pressed: set LEDs to 1
    movi r12, 1                 	# value to set on LEDs (binary: 0000000001)
    stwio r12, (r9)             	# set LEDs to 1
	br poll

check_key1:
    # key 1 pressed: increment LEDs (up to 15)
    ldwio r12, 0(r9)            	# load current value from LEDs
	beq r12, r19, poll				# do not go over 15
	beq r10, r20, poll				# if same state as last, keep looping
    addi r12, r12, 1            	# increment value
    stwio r12, (r9)             	# update LEDs
    br poll

check_key2:
    # Key 2 pressed: Decrement LEDs (down to 1)
    ldwio r12, 0(r9)             	# load current value from LEDs
	beq r10, r20, poll				# if same state as last, keep looping
	beq r12, r14, poll				# do not go below 1
	beq r12, r0, poll				# do not go below 0 if starting with 0
    subi r12, r12, 1             	# decrement value
    stwio r12, (r9)             	# update LEDs
    br poll

check_key3:
    # key 3 pressed: turn off all LEDs    
    movi r12, 0						# value to set on LEDs (binary: 0000000000)
    stwio r12, 0(r9)				# turn off all LEDs
	movi r18, 1						# set key 3 pressed flag to true
    br poll
	
reset_display:
    # any other key pressed after key 3: set LEDs to 1
	movi r18, 0
	ldwio r10, 0(r8)				# load data register 
	andi r10, r10, 0xF				# select all lower 4 bits (KEY 0-3)
	beq r10, r0, reset_display		# loop until a key is pressed
	beq r10, r17, reset_display		# if key 3 is pressed, cont looping
    movi r12, 1                  	# value to set on LEDs (binary: 0000000001)
    stwio r12, 0(r9)				# set LEDs to 1
    br post_key3_loop

post_key3_loop:
	mov r20, r10					# get the state
	ldwio r10, 0(r8)				# load data register 
	andi r10, r10, 0xF				# select all lower 4 bits (KEY 0-3)
	bne r20, r10, poll
	br post_key3_loop
