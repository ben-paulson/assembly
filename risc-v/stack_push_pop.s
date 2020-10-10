#------------------------------------
# Several ways to push/pop from stack
#------------------------------------
.text

push_low1:      addi        sp, sp, -4      # Adjust sp first
                sw          x10, 0(sp)      # Push after

pop_low1:       lw          x10, 0(sp)      # Pop first
                addi        sp, sp, 4       # Adjust sp after

push_low2:      sw          x10, -4(sp)     # Push first
                addi        sp, sp, -4      # Adjust sp after

pop_low2:       addi        sp, sp, 4       # Adjust sp first
                sw          x10, -4(sp)     # Pop after

push_high1:     addi        sp, sp, 4       # Grow to higher addresses
                sw          x10, 0(sp)      # Push after adjusting sp

pop_high1:      lw          x10, 0(sp)      # Pop first
                addi        sp, sp, -4      # Adjust back downward for pop

push_high2:     sw          x10, 4(sp)      # Push first
                addi        sp, sp, 4       # Adjust after

pop_high2:      addi        sp, sp, -4      # Adjust first
                lw          x10, 0(sp)      # Pop after
