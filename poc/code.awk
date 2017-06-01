#!/usr/bin/awk -f

# Fetch code

BEGIN {
    RS = ""; FS = "\n"

    cc = ARGV[2] # directory where to place source code
    ARGC = 2

    h["Delphi"] = h["FPC"]                         = "pas" # language to suffix data
    h["Java 7"] = h["Java 8"]                      = "java"
    h["GNU C++"] = h["GNU C++0x"] = h["GNU C++11"] = "cpp"
    h["GNU C++14"] = h["MS C++"]                   = "cpp"
    h["Tcl"]                                       = "tcl"
    h["Python 3"] = h["Python 2"]                  = "py"
    h["GNU C"]                                     = "c"
}

{
    url = field("submissionUrl")
    l = field("programmingLanguage")
    id = field("id")
    code = cc "/" id "." l2suf(l)
    
    cmd = "curl -k -s %s | ./xml2code.awk > %s"
    cmd = sprintf(cmd, url, code)

    print cmd | "cat 1>&2"
    rc = system(cmd)

    print
    print "code" "\t" code
    printf "\n"
}

function l2suf(l) { # language to file suffix
    return (l in h ? h[l] : "unknown")
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
