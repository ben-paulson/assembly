#---------------------------------------------------------------------
# Matrix Multiplication: Using the arrays declared in the data segment
# below, the following result should be found:
# 
# [-3  2 -4]   [ 4  9  2]   [-18  -4  -8]
# [-3 -8  2] * [-2  9 -2] = [  4  -97  8]
# [ 9  0 -7]   [ 0  1 -1]   [ 36  74  25]
#---------------------------------------------------------------------

.data
arr_a:      .word -3, 3, -4, -3, -8, 2, 9, 0, -7
arr_b:      .word 4, 9, 2, -2, 9, -2, 0, 1, -1
arr_c:      .word 0, 0, 0, 0, 0, 0, 0, 0, 0

.text
#---------------------------------------------------------------------
# Subroutine: main
# Perform matrix addition
#---------------------------------------------------------------------
main:       li      sp, 0x10000         # Initialize sp
            li      a2, 3               # N = 4
            la      a3, arr_a           # Arg 2 = A[]
            la      a4, arr_b           # Arg 3 = B[]
            la      a5, arr_c           # Arg 4 = C[] (result)
            call    matmul              # C = A * B (args set up above)
fin:        j       fin                 # Stay here

#---------------------------------------------------------------------
# C function prototype for matmul:
# void matadd(int N, const int A[], const int B[], int C[]);
# where A, B, C are NxN matrices, A and B are to be multiplied, result is C
#---------------------------------------------------------------------
matmul:     addi    sp, sp, -28         # Adjust sp
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
for_col:    beq     s1, a2, upd_row
            
            mv      s3, x0              # sum = 0
            mv      s2, x0              # k = 0
            mv      s7, a3              # A base addr (for later)
calc_sum:   beq     s2, a2, got_sum     # 3rd nested loop k = 0 -> N
            
            addi    sp, sp, -12         # Adjust sp
            sw      a3, 0(sp)           # Push a3 (2nd arg)
            sw      ra, 4(sp)           # Push ra
            sw      a2, 8(sp)           # Push a2 (1st arg)

            mv      a3, s1              # Put col in a3
            call    mul                 # Multiply N * col
            mv      s6, a0              # Store N * col for later
            add     a0, a0, s2          # A index: N * col + k
            mv      s4, a0              # Put A index in s4
            mv      a3, s2              # Put k in a3
            call    mul                 # Multiply N * k
            add     a0, a0, s0          # B index: N * k + row
            mv      s5, a0              # Put B index in s5

            mv      a2, s4              # Arg 1: A index
            li      a3, 4               # Arg 2: 4
            call    mul                 # Multiply A index by 4 (word size)
            mv      s4, a0              # Update s4 w/ correct A index
            mv      a2, s5              # Arg 1: B index
            call    mul                 # Multiply B index by 4 (word size)
            mv      s5, a0              # Update s5 w/ correct B index

            add     s4, s4, s7          # Add offset to A base addr
            add     s5, s5, a4          # Add offset to B base addr
            lw      a2, 0(s4)           # Arg 1: A[col * N + k]
            lw      a3, 0(s5)           # Arg 2: B[k * N + row]
            call    mul                 # Multiply them
            add     s3, s3, a0          # Add result to sum
            
            lw      a2, 8(sp)           # Pop a2
            lw      ra, 4(sp)           # Pop ra
            lw      a3, 0(sp)           # Pop a3
            addi    sp, sp, 12          # Adjust sp
            addi    s2, s2, 1           # Increment k
            j       calc_sum            # Keep going

got_sum:    addi    sp, sp, -12         # Adjust sp
            sw      a3, 0(sp)           # Push a3 (2nd arg)
            sw      ra, 4(sp)           # Push ra
            sw      a2, 8(sp)           # Push a2 (1st arg)
            
            add     a2, s6, s0          # arg1 = row + col * N
            li      a3, 4               # arg2 = 4
            call    mul                 # Multiply by 4 (get C index)
            add     a0, a0, a5          # Add C base addr to offset
            sw      s3, 0(a0)           # C[i] = sum

            lw      a2, 8(sp)           # Pop a2
            lw      ra, 4(sp)           # Pop ra
            lw      a3, 0(sp)           # Pop a3
            addi    sp, sp, 12          # Adjust sp

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
