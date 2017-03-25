#!/usr/bin/awk -f

function kv(s) { # split into [k]ey and [v]alue
    k = v = s
    sub(   /\t.*/, "", k)
    sub(/^.*\t/  , "", v)
}

function field(k0,  i) {
    for (i = 1; i <= NF; i++) {
	kv($i)
	if (k == k0) return v
    }
}

BEGIN {
    RS = ""; FS = "\n"

    i = 2
    k0 = ARGV[i++] # "verdict"
    v0 = ARGV[i++] # "OK"

    ARGC = 2
}

{
    if (field(k0) != v0) next
    print
    printf "\n"
}
