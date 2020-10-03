#-----------------------------------------
# Reads ten unsigned words from the input
# associated with the port_id 0xC000_CCCC
# then divides by 2 until the sum can be
# represented by a 16-bit number.
#-----------------------------------------

sum_10:
init:       addi    sp, sp, -16         # Save registers used (except x30)
            sw      x10, 0(sp)          # Push x10
            sw      x11, 4(sp)          # Push x11
            sw      x12, 8(sp)          # Push x12
            sw      x13, 12(sp)         # Push x13

            li      x10, 10             # Loop counter
            li      x11, 0xC000CCCC     # Input port

read:       beq     x10, x0, divide     # Check loop counter
            lw      x12, 0(x11)         # Load input
            add     x30, x30, x12       # Add input to total
            addi    x10, x10, -1        # Decrement loop counter
            j       read                # Jump back to read again

divide:     srli    x13, x30, 16        # Get upper 2 bytes of sum in x13
            beq     x13, x0, done       # Done if upper 2 bytes are 0
            srli    x30, x30, 1         # Otherwise divide by 2
            j       divide              # Then check again

done:       lw      x13, 12(sp)         # Pop x13
            lw      x12, 8(sp)          # Pop x8
            lw      x11, 4(sp)          # Pop x11
            lw      x10, 0(sp)          # Pop x10
            addi    sp, sp, 16          # Return stack pointer to start
            ret                         # Finished
