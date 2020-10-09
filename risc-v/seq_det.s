#---------------------------------------------------
# Checks if 100 values are in odd, even, odd... order
#----------------------------------------------------

seq_det:
init:       addi    sp, sp, -20     # Adjust sp for 5 values to be stored
            sw      x11, 0(sp)      # Push x11
            sw      x12, 4(sp)      # Push x12
            sw      x13, 8(sp)      # Push x13
            sw      x14, 12(sp)     # Push x14
            sw      x15, 16(sp)     # Push x15

            li      x11, 100        # Loop count
            li      x15, 1          # Return value, nonzero to start

load:       beqz    x11, done       # If checked all numbers 
            lw      x12, 0(x10)     # Load a value to x12
            andi    x13, x12, 1     # Get parity bit of number in x13
            andi    x14, x11, 1     # Get parity bit of loop count in x14
            addi    x10, x10, 4     # Go to next word (after getting parity)
            addi    x11, x11, -1    # Decrement loop cnt after getting its parity
            beqz    x14, chk_odd    # Starts with an odd check (if loop count is even)
            j       chk_evn         # Check for even if loop count is odd

chk_odd:    bnez    x13, load       # If parity is not zero, it's odd. check next
            mv      x15, x0         # Failed odd check. Load zero to return, be done
            j       done            #

chk_evn:    beqz    x13, load       # If parity is zero, it's even. check next
            mv      x15, x0         # Failed evn check. load zero to return, be done
            j       done            #

done:       mv      x10, x15        # Put result in x10 (zero if failed, nonzero if success)
            lw      x15, 16(sp)     # Pop x15
            lw      x14, 12(sp)     # Pop x14
            lw      x13, 8(sp)      # Pop x13
            lw      x12, 4(sp)      # Pop x12
            lw      x11, 0(sp)      # Pop x11
            addi    sp, sp, 20      # Restore stack pointer
            ret                     # Finished
