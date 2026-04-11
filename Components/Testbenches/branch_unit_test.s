    li   x1, 7        # value A
    li   x2, 10       # value B
    li   x3, 0        # result reg

    blt  x1, x2, LESS  # if x1 < x2 -> taken
    li   x3, 2         # not-taken path
    j    END

LESS:
    li   x3, 1         # taken path

END:
    li   a7, 93
    li   a0, 0
