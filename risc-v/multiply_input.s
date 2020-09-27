#---------------------------------------------
# Reads data from the input port addressed by
# 0xC000_0012, multiplies it by 3, and outputs
# the result to the output port addressed by
# 0xC000_0033. Ignoring register overflow.
#---------------------------------------------
.text
init:   li      x10, 0xC0000012     # Input port
        li      x11, 0xC0000033     # Output port

mult:   lw      x15, 0(x11)         # Load input data to x15
        add     x16, x15, x15       # Add to itself (mult by 2)
        add     x16, x16, x15       # Add again (times 3), store in x16
        sw      x16, 0(x11)         # Output
        j       mult                # Jump to start again
