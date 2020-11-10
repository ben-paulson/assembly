#--------------------------------------------
# Debounce a button (LSB of buttons addressed
# by port 0x11008004) by ensuring the value
# of the button is consistent for a certain
# amount of time 
#--------------------------------------------
.text
debounce:
init:           mv          x15, x0             # Most recent button value
                mv          x16, x0             # Previous button value
                mv          x17, x0             # Button value consistency count
                mv          x20, x0             # Debounced output
                li          x10, 0x11008004     # Buttons port address
                li          x11, 5              # (Arbitrary) number of loop cycles the
                                                # button value should be consistent
                                                # before it is "debounced"
                
db_cnt:         beqz        x11, upd_out        # Only update the output if consistent
                lw          x15, 0(x10)         # Current button value
                andi        x15, x15, 1         # Only need LSB of buttons
                beq         x15, x16, equal     # If current is same as previous
                li          x11, 6              # Reset with 1 greater than original loop cycles
equal:          addi        x11, x11, -1        # Decrement counter
                mv          x16, x15            # Store button value as previous value
                j           db_cnt              # Next check

upd_out:        mv          x20, x16            # Output previous value (same as current)
                li          x11, 5              # Reset count
                j           db_cnt              # Continue debouncing for next change
