#!/usr/bin/awk -f

# stream to database converter (see main.sh)

$1 == mg {
    ff[nf++] = f = $2; i = 0; next
}

{
    aa[i++, f] = $0
}
		
END  {
    n = i
    for (i = 0; i < n; i++) { # record
	for (j = 0; j < nf; j ++) {
	    f = ff[j]; a = aa[i, f]
	    if (a == "null") continue
	    print f "\t" a
	}
	printf "\n"
    }
}
