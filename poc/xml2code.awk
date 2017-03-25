#!/usr/bin/awk -f

# get code from submission url

BEGIN {
    q = "\"" # quatation mark
    p = "<pre class=\"prettyprint" # begin pattern

    cr = "\r"
}

{
    if (NF > 0) s = s RS
    s = s $0
}

END {
    n = length(s)
    i = index(s, p)

    for ( ; i <= n; i++) {
	if (ch(s, i) ==   q) do i++; while (i <= n && ch(s, i) != q)
	if (ch(s, i) == ">") break
    }

    lo = i + 1 # code start
    for ( ; i <= n; i++)
	if (ch(s, i) == "<") break

    hi = i - 1 # code ends

    c = substr(s, lo, hi - lo + 1)
    c = unescape(c)
    print c
}

function unescape(c,   i, n, ans) {
    gsub(/\r/    ,  ""  , c) # windows

    gsub(/&quot;/,   q  , c) # xml
    gsub(/&apos;/, "'"  , c)
    gsub(/&lt;/  , "<"  , c)
    gsub(/&gt;/  , ">"  , c)
    gsub(/&amp;/ , "\\&", c)
    gsub(/&nbsp;/, " "  , c)

    gsub(/&#39;/ , "'", c) # html
    return c
}

function ch(s, i) { # charachter
    return substr(s, i, 1)
}
