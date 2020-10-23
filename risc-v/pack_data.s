#-------------------------------------
# Subroutine packs word data into byte
# data from one address to another.
#-------------------------------------
pack:
init:       addi        sp, sp, -16         # Adjust sp to push 4 words
            sw          x15, 0(sp)          # Push x15
            sw          x20, 4(sp)          # Push x20
            sw          x25, 8(sp)          # Push x25
            sw          x30, 12(sp)         # Push x30

loop:       beqz        x25, done           # Check loop counter
            lw          x30, 0(x15)         # Get a word value
            sb          x30, 0(x25)         # Store it as a byte
            addi        x25, x25, -1        # Decr loop counter
            addi        x15, x15, 4         # Go to next word
            addi        x25, x25, 1         # Go to next byte
            j           loop                # Do it again

done:       lw          x30, 12(sp)         # Pop x30
            lw          x25, 8(sp)          # Pop x25
            lw          x20, 4(sp)          # Pop x20
            lw          x15, 0(sp)          # Pop x15
            addi        sp, sp, 16          # Adjust sp
