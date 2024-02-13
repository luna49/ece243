.section .text
.global _start

_start:
    movi r3, 30        # register: count, 30
    movi r4, 0         # register: total, 0
    movi r5, 0         # register: comparison value, 0

loop:
    add r4, r4, r3     # add total, count, store in r1
    subi r3, r3, 1     # decrement and update count

    bne r5, r3, loop   # branch to loop if not equal to zero

    mov r12, r4        # put sum in r12

done:
    br done            # infinite loop
