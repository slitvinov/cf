#!/usr/bin/awk -f

# add urls

BEGIN {
    RS = ""; FS = "\n"

    prbfmt = "http://codeforces.com/contest/ %contestId% /problem/ %index%"
    subfmt = "http://codeforces.com/contest/ %contestId% /submission/ %id%"
}

{
    url() # set urls

    print
    print "submissionUrl" "\t" suburl
    print "problemUrl" "\t" prburl
    printf "\n"
}

function unformat(s) {
    gsub(/ %contestId% /, contestId, s)
    gsub(/ %id% /       , id       , s)
    gsub(/ %index% /    , iindex   , s)
    return s
}

function url() {
    contestId= field("contestId"); id = field("id"); iindex = field("index")
    suburl = unformat(subfmt)
    prburl = unformat(prbfmt)
}

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
