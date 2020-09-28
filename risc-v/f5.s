.text
init:       li      x0,4        # initialize register
            li      x1,8        #
            li      x2,12       #

main:       add     x3,x7,x8    # do something meaningful
            sub     x6,x8,x9    #
            sra     x3,x7,x8    #
            j       main        # repeat doing meaningful things
