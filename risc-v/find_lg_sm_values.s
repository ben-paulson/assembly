#----------------------------------------------------
# Finds the largest and smallest values in the
# chunk of memory starting at the address in x30.
# The values are unsigned bytes. The number of values
# is given by the value in x10. The result is stored
# as two contiguous words at the address in x8.
#----------------------------------------------------
find_lg_sm:
init:           addi        sp, sp, -20         # Prepare sp for 5 values
                sw          x15, 0(sp)          # Push x15
                sw          x16, 4(sp)          # Push x16
                sw          x17, 8(sp)          # Push x17
                sw          x30, 12(sp)         # Push x30
                sw          x10, 16(sp)         # Push x10
                lbu         x17, 0(x30)         # Get first value
                mv          x15, x17            # Use first value as both largest
                mv          x16, x17            # and smallest

find:           beqz        x10, done           # Check loop counter
                lbu         x17, 0(x30)         # Load a value
                blt         x16, x17, small     # Found new smallest
                bgt         x16, x17, large     # Found new largest
                j           loop_mod            # If neither new max or min

small:          mv          x16, x17            # Put value in "smallest" reg
                j           loop_mod            # Continue...

large:          mv          x15, x17            # Put value in "largest" reg

loop_mod:       addi        x10, x10, -1        # Decrement loop counter
                addi        x30, x30, 1         # Increment address to next value
                j           find                # Go back to process next value

done:           sw          x16, 0(x8)          # Output smallest value
                sw          x15, 4(x8)          # Output largest value
                lw          x10, 16(sp)         # Pop x10
                lw          x30, 12(sp)         # Pop x30
                lw          x17, 8(sp)          # Pop x17
                lw          x16, 4(sp)          # Pop x16
                lw          x15, 0(sp)          # Pop x15
                addi        sp, sp, 20          # Restore sp
                ret                             # Finished
