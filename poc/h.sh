#!/bin/bash

ini () {
    t=/tmp/cf.$$; mkdir -p $t
    trap 'rm -rf $t' 1 2 13 15
}

curl_raw () {
    curl_rc=0 # return code
    curl -s "$@"
    curl_rc=$?
}

curl_cash () {
    c=.c/c0
    if test ! -f $c; then mkdir -p .c; curl_raw "$@" > $c; fi
    cp $c $t/l
}

curl0 () { # fills $t/l; one request is cached
    ps="http://codeforces.com/api/problemset.problems"
    if test "$@" = "$ps"; then curl_cash "$@"; else curl_raw "$@" > $t/l; fi
}

api0 () {
    # sets curl_rc, $t/l: last; $t/r: result
    curl0 http://codeforces.com/api/$1
    status=`jq .status $t/l | tr -d '"'`
    echo '(h.sh) status:' $status 2>&1
    jq .result $t/l > $t/r
}

api () { # api m a=1 b=2 -> api0 m?a=1&b=2
    arg=`awk 'BEGIN {
           i = 1; a = ARGV[i++]
           sep = "?"
           while (i < ARGC) {
               a = a sep ARGV[i++]
               sep = "&"
           }
           print a
         }' "$@"`
    api0 $arg
}

jq0 () (jq --raw-output "$@" $t/r)

ini

# need
api problemset.problems
jq0 .problemStatistics[10].contestId
jq0 .problemStatistics[10].index
jq0 .problemStatistics[10].solvedCount
jq0          .problems[10].tags[]
jq0          .problems[10].name

api contest.status contestId=101 handle=tourist
jq0 .[].programmingLanguage

jq0 .[].id
jq0 .[].verdict $t/r
jq0 .[].problem.index       $t/r
jq0 .[].programmingLanguage $t/r

sed 100q $t/r

curl http://codeforces.com/contest/776/submission/24918716?mobile=true > d
