# Example array with N = 8 words
.data
arr:    .word 0x0, 0x1, 0x2, 0x5, 0x3, 0xA, 0x34, 0x2

.text
max:    addi    sp, sp, -12     # Adjust sp
        sw      a2, 0(sp)       # Push argument #1
        sw      a3, 4(sp)       # Push argument #2
        sw      s0, 8(sp)       # Push s0
        beqz    a3, done        # When we have searched N numbers
        lw      s0, 0(a2)       # Load value at pointer a (arg 1)
        ble     s0, a0, chk     # Do nothing if value <= max
        mv      a0, s0          # Update max if value > max
chk:    addi    a3, a3, -1      # One less number left to check
        j       loop            # Do it again
done:   lw      s0, 8(sp)       # Pop s0
        lw      a3, 4(sp)       # Pop arg 2
        lw      a2, 0(sp)       # Pop arg 1
        addi    sp, sp, 12      # adjust sp
        ret                     # Return
        
