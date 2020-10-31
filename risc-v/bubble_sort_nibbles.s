#--------------------------------------
# Sorts the nibbles in x25 from largest
# (leftmost) to smallest (rightmost).
# 
# 1. Store nibbles as bytes in memory
# 2. Do the sorting in memory (so that
#    the subroutine could be easily
#    adapted to sort more than 8 
#    numbers at a time).
# 3. Load nibbles back into x25
#--------------------------------------

sort_nibbles:
init:           addi        sp, sp, -32             # Adjust sp
                sw          x15, 0(sp)              # Push x15
                sw          x16, 4(sp)              # Push x16
                sw          x17, 8(sp)              # Push x17
                sw          x18, 12(sp)             # Push x18
                sw          x19, 16(sp)             # Push x19
                sw          x20, 20(sp)             # Push x20
                sw          x21, 24(sp)             # Push x21
                sw          x22, 28(sp)             # Push x22
                li          x15, 0x00006000         # Arbitrary data address
                li          x16, 8                  # Number of nibbles

store:          beqz        x16, sort_init1         # If done storing all nibbles
                andi        x17, x25, 0xF           # Mask lower nibble
                sb          x17, 0(x15)             # Store nibble in data memory
                srli        x25, x25, 4             # Shift to next nibble
                addi        x15, x15, 1             # Go to next byte
                addi        x16, x16, -1            # One less nibble to store
                j           store                   # Do it again

sort_init1:     li          x16, 8                  # Restore number of nibbles
                li          x18, 0                  # Loop counter #1
sort_init2:     li          x19, 0                  # Loop counter #2
                li          x15, 0x00006000         # Restore addr of stored data
sort_out:       beq         x18, x16, load          # Done sorting
                addi        x20, x16, -1            # Form second loop bound
                sub         x20, x20, x18           # Finish second loop bound
                addi        x18, x18, 1             # Increment outer loop counter
sort_in:        beq         x19, x20, sort_init2    # If inner loop finishes
                lbu         x21, 0(x15)             # Load first number
                lbu         x22, 1(x15)             # Load next number
                bleu        x22, x21, admin         # Do not swap
                sb          x21, 1(x15)             # Swap if this nibble is...
                sb          x22, 0(x15)             # ...greater or equal next nibble
admin:          addi        x15, x15, 1             # Go to addr of next nibble
                addi        x19, x19, 1             # Increment inner loop counter
                j           sort_in                 # Repeat inner loop

load:           beqz        x16, done               # Done after loading all
                lbu         x17, 0(x15)             # Load a nibble
                slli        x25, x25, 4             # Make space for new nibble
                or          x25, x25, x17           # Combine new nibble
                addi        x16, x16, -1            # Decrement counter
                addi        x15, x15, 1             # Go to next nibble
                j           load                    # Load next nibble

done:           lw          x22, 28(sp)             # Pop x22
                lw          x21, 24(sp)             # Pop x21
                lw          x20, 20(sp)             # Pop x20
                lw          x19, 16(sp)             # Pop x19
                lw          x18, 12(sp)             # Pop x18
                lw          x17, 8(sp)              # Pop x17
                lw          x16, 4(sp)              # Pop x16
                lw          x15, 0(sp)              # Pop x15
                addi        sp, sp, 32              # Restore sp
                ret                                 # Finished
