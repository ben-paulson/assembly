#------------------------------------------
# Reads data from the input port addressed
# by 0xC000_0012, negates it, adds 0x047,
# then outputs the value to the output port
# addressed by 0xC000_00AA.
#------------------------------------------
.text
init:   li      x10, 0xC0000012     # Input port
        li      x11, 0xC00000AA     # Output port

work:   lw      x15, 0(x10)         # Load input data to x15
        xori    x16, x15, -1        # Invert the bits, store in x16
        addi    x16, x16, 1         # Add 1 to complete inversion
        addi    x16, x16, 0x047     # Add 0x047
        sw      x16, 0(x11)         # Store in output
        j       work                # Jump to work, restart process
