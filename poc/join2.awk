#!/usr/bin/awk -f

# join to databases based on two fields

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

function get_id() {
    return field(k1) SUBSEP field(k2)
}

function rsplit1(   id, i, j) { # keys and values: `kkv(id, j)'
			        # number of fields `nn(id)'
    id = get_id()
    j = 0 # number of field
    for (i = 1; i <= NF; i++) {
	kv($i)
	if (k == k1 || k == k2) continue
	j++
	kkv[id, j] = $i
    }
    nn[id] = j
}

function read1() {
    while (getline < file1 > 0)
	rsplit1()
}

function append(   i, id, n) {
    id = get_id()
    if (!(id in nn)) return
    print
    for (i = 1; i < nn[id]; i++) print kkv[id, i]
    printf "\n"
}

function read2() {
    while (getline < file2 > 0) append()
}

BEGIN {
    RS = ""; FS = "\n"

    i = 1
    file1 = ARGV[i++] # ".d/d0"
    file2 = ARGV[i++] # ".d/d1"

    k1 = ARGV[i++] # "index"
    k2 = ARGV[i++] # "contestId"

    read1()
    read2()
}
