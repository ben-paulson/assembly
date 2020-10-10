#-------------------------------------------------------------------------------
# Subroutine bin_to_bcd:
# Converts a binary number in x10 to a 4-digit BCD number in the lower 4 nibbles
# of x11. It assumes that the binary number will not exceed 9999.
#-------------------------------------------------------------------------------
bin_to_bcd:
init:           addi        sp, sp, -12             # Prepare stack pointer for 3 pushes
                sw          x12, 0(sp)              # Push x12
                sw          x13, 4(sp)              # Push x13
                sw          x14, 8(sp)              # Push x14
                mv          x12, x10                # Copy x10 to x12
                mv          x13, x0                 # Clear digit counter
                li          x14, 1000               # Load branch check value

do_1000s:       blt         x12, x14, load_100s     # If number is less than 1000
                addi        x13, x13, 1             # Add 1 to the 1000s digit
                sub         x12, x12, x14           # Subtract 1000
                j           do_1000s                # Check the 1000s digit again

load_100s:      li          x14, 100                # Load new branch check value
                mv          x13, x11                # Put the thousands digit in x11
                slli        x11, x11, 12            # Shift 1000s digit to correct place
                mv          x13, x0                 # Clear digit counter
do_100s:        blt         x12, x14, load_10s      # Done if number < 100
                addi        x13, x13, 1             # Add 1 to 100s digit
                sub         x12, x12, x14           # Subtract 100
                j           do_100s                 # Check 100s digit again

load_10s:       li          x14, 10                 # New branch check val
                slli        x13, x13, 8             # Put 100s digit in the correct place
                or          x11, x11, x13           # Combine 1000s and 100s digits in x11
                mv          x13, x0                 # Clear digit counter
do_10s:         blt         x12, x14, load_1s       # Done if number < 10
                addi        x13, x13, 1             # Add 1 to 10s digit
                sub         x12, x12, x14           # Subtract 10
                j           do_10s                  # Check 10s digit again

load_1s:        slli        x13, x13, 4             # Put 10s digit in correct place
                or          x11, x11, x13           # Combine 1000s, 100s, and 10s
                mv          x13, x0                 # Clear digit counter
do_1s:          beqz        x12, done               # Done if number is zero
                addi        x13, x13, 1             # Add 1 to 1s digit
                addi        x12, x12, -1            # Subtract 1
                j           do_1s                   # Check 1s digit again

done:           lw          x14, 8(sp)              # Pop x14
                lw          x13, 4(sp)              # Pop x13
                lw          x12, 0(sp)              # Pop x12
                addi        sp, sp, 12              # Reset stack pointer
                ret                                 # Finished
