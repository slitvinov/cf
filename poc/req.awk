#!/usr/bin/awk -f

# return fields from a data base

BEGIN {
    sep = " " # output separator
    RS = ""; FS = "\n"
    nf = 0
    for (i = 2; i < ARGC; i++)
	ff[++nf] = ARGV[i]
    ARGC = 2
}

{
    for (i = 1; i <= nf; i++) {
	if (i > 1) printf "%s", sep
	printf "%s", field(ff[i])
    }
    printf "\n"
}

function field(k0,   i, v, k) { # [k]ey, [v]alue
    for (i = 1; i <= NF; i++) {
	k = v = $i
	sub(   /\t.*/, "", k)
	sub(/^.*\t/  , "", v)
	if (k == k0) return v
    }
}
