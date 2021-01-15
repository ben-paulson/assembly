#---------------------------------------------------------------------
# Matrix Addition: Using the arrays declared in the data segment
# below, the following result should be found:
# 
# [-3  3 -4]   [ 4  9  2]   [ 1  12  -2]
# [-3 -8  2] + [-2  9 -2] = [-5   1   0]
# [ 9  0 -7]   [ 0  1 -1]   [ 9   1  -8]
# [ 1 -3  5]   [ 3 -4 -1]   [ 4  -7   4]
#---------------------------------------------------------------------
.data
arr_a:      .word -3, 3, -4, -3, -8, 2, 9, 0, -7, 1, -3, 5
arr_b:      .word 4, 9, 2, -2, 9, -2, 0, 1, -1, 3, -4, -1
arr_r:      .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

.text
#---------------------------------------------------------------------
# Subroutine: main
# Perform matrix addition
#---------------------------------------------------------------------
main:       li      sp, 0x10000         # Initialize sp
            li      a2, 4               # M = 4
            li      a3, 3               # N = 3
            la      a4, arr_a           # Arg 3 = A[]
            la      a5, arr_b           # Arg 4 = B[]
            la      a6, arr_r           # Arg 5 = C[] (result)
            call    matadd              # C = A + B (args set up above)
fin:        j       fin                 # Stay here

#---------------------------------------------------------------------
# C function prototype for matadd:
# void matadd(int M, int N, const int A[], const int B[], int C[]);
# where A, B, C are MxN matrices, A and B are to be added, the result is C
#---------------------------------------------------------------------
matadd:     addi    sp, sp, -28         # Adjust sp
            sw      s0, 0(sp)           # Push s0
            sw      s1, 4(sp)           # Push s1
            sw      s2, 8(sp)           # Push s2
            sw      s3, 12(sp)          # Push s3
            sw      s4, 16(sp)          # Push s4
            sw      s5, 20(sp)          # Push s5
            sw      s6, 24(sp)          # Push s6

            mv      s0, x0              # Temporary row counter

for_row:    beq     s0, a2, done        # When row count reaches M
            mv      s1, x0              # Temporary col counter
for_col:    beq     s1, a3, upd_row
            
            # We want to get: arr[row * COLS + col]
            # First calculate row * COLS + col

            addi    sp, sp, -12         # Adjust sp
            sw      a2, 0(sp)           # Push a2
            sw      a3, 4(sp)           # Push a3
            sw      ra, 8(sp)           # Push ra
            mv      a2, s0              # First arg: row
                                        # 2nd arg already has N (# COLS)
            call    mul                 # Do the multiplication
            add     a0, a0, s1          # a0 = row * COLS + col (call it i)
            mv      a2, a0              # Put result in arg1 position
            li      a3, 4               # Put 4 in arg2 position
            call    mul                 # Multiply calculated index by 4 (for words)

            lw      ra, 8(sp)           # Pop ra
            lw      a3, 4(sp)           # Pop a3
            lw      a2, 0(sp)           # Pop a2
            addi    sp, sp, 12          # Restore sp

            add     s2, a4, a0          # Calculate address of val in A
            add     s3, a5, a0          # Calculate address of val in B
            add     s4, a6, a0          # Calculate address of val in C (result)
            lw      s5, 0(s2)           # s5 = a[i]
            lw      s6, 0(s3)           # s6 = b[i]
            add     s5, s5, s6          # s5 = a[i] + b[i]
            sw      s5, 0(s4)           # c[i] = a[i] + b[i]

upd_col:    addi    s1, s1, 1           # Go to next col
            j       for_col             # Back to inner loop
upd_row:    addi    s0, s0, 1           # Go to next row
            j       for_row             # Back go outer loop
done:       nop

            lw      s6, 24(sp)          # Pop s6
            lw      s5, 20(sp)          # Pop s5
            lw      s4, 16(sp)          # Pop s4
            lw      s3, 12(sp)          # Pop s3
            lw      s2, 8(sp)           # Pop s2
            lw      s1, 4(sp)           # Pop s1
            lw      s0, 0(sp)           # Pop s0
            addi    sp, sp, 28          # Adjust sp
            ret

#----------------------------------------------------------------------
# C function prototype for mul:
# int mul(int x, int y);
# Multiplies two numbers together, accounting for negatives
#----------------------------------------------------------------------
mul:        addi    sp, sp, -16          # Adjust sp
            sw      s0, 0(sp)           # Push s0
            sw      s1, 4(sp)           # Push s1
            sw      a2, 8(sp)           # Push arg 1
            sw      a3, 12(sp)          # Push arg 2
            
            li      t0, 0x80000000      # Bit mask for sign bit
            and     s0, a2, t0          # Mask sign bit of x
            and     s1, a3, t0          # Mask sign bit of y
            xor     s0, s0, s1          # Get sign of result

            mv      t0, x0              # Use t0 as loop counter
            mv      a0, x0              # Clear result
            bgtz    a2, chk_arg2        # If a2 is negative, negate counter
            neg     a2, a2              # Negate count amount
chk_arg2:   bgtz    a3, mul_loop        # If a3 is negative, negate it
            neg     a3, a3              # Negate a3
mul_loop:   beq     t0, a2, mul_sign    # When we have looped x times
            add     a0, a0, a3          # sum += y (x times) -> sum = x*y
            addi    t0, t0, 1           # Increment loop counter
            j       mul_loop            # Loop again

mul_sign:   beqz    s0, mul_done        # If sign is zero, we are done
            neg     a0, a0              # Otherwise negate result
mul_done:   lw      a3, 12(sp)          # Pop arg 2
            lw      a2, 8(sp)           # Pop arg 1
            lw      s1, 4(sp)           # Pop s1
            lw      s0, 0(sp)           # Pop s0
            addi    sp, sp, 16          # Adjust sp
            ret
