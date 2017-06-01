#!/bin/sh

# create a database of user's submissions

ini () {
    # handle
    # h=izrak
    h=tourist
    cc=$h.code # where to place code

    mg='!!#' # magic string for database
    t=/tmp/cf.$$; mkdir -p $t
    trap 'rm -rf $t' 1 2 13 15

    mkdir -p .c # cache
    mkdir -p .d # database
    mkdir -p  $cc
}

curl_raw () {
    curl_rc=0 # return code
    curl -s "$@"
    curl_rc=$?
}

curl_cache () {
    local c=.c/c0
    if test ! -f $c; then curl_raw "$@" > $c; fi
    cp $c $t/l
}

curl0 () { # fills $t/l; one request is cached
    local ps="http://codeforces.com/api/problemset.problems"
    if test "$@" = "$ps"; then curl_cache "$@"; else curl_raw "$@" > $t/l; fi
}

api0 () {
    # sets curl_rc, $t/l: last; $t/r: result
    curl0 http://codeforces.com/api/$1
    status=`jq .status $t/l | tr -d '"'`
    echo '(h.sh) status:' $status 1>&2
    jq .result $t/l > $t/r
}

api () { # better interface to api m a=1 b=2 -> api0 m?a=1&b=2
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

jq0 () {
    jq --ascii-output --raw-output "$@" $t/r
}

s2d () ( # stream to database (ignore nulls)
    ./s2d.awk mg=$1
)

stream_problemset () {
    # make a "stream" of all fields I need:
    # format of the stream:
    #
    # magic name
    # value
    # ...
    # value
    # magic name
    # value
    # ...
    local i
    f=contestId  ; echo $mg $f; jq0 .problemStatistics[].$f
    f=index      ; echo $mg $f; jq0 .problemStatistics[].$f
    f=solvedCount; echo $mg $f; jq0 .problemStatistics[].$f
    f=name       ; echo $mg $f; jq0          .problems[].$f
    for i in 0 1 2 3 4 5 6 7 8 9 10
    do
	f=tag$i  ; echo $mg $f; jq0          .problems[].tags[$i]
    done
}

stream_contest () { # see `stream_problemset`
    f=contestId           ; echo $mg $f; jq0 .[].problem.$f
    f=index               ; echo $mg $f; jq0 .[].problem.$f
    f=verdict             ; echo $mg $f; jq0 .[].$f
    f=id                  ; echo $mg $f; jq0 .[].$f
    f=programmingLanguage ; echo $mg $f; jq0 .[].$f
}

ini
api problemset.problems # make a database of all problems
stream_problemset | s2d $mg     > .d/d0

# make a database of all contests user took part
clist=`awk '/^contestId/ {print $2}' .d/d0 | sort -g | uniq`
for c in $clist; do
    api contest.status contestId=$c handle=$h
    if test ! $status = OK; then break; fi
    stream_contest | s2d $mg
done > .d/d1

# joint databases using two fields
./join2.awk  .d/d0 .d/d1 contestId index > .d/d3
./filter.awk .d/d3 verdict OK > .d/d.tmp && mv .d/d.tmp .d/d3

# add urls for the problem and for submissions
./url.awk    .d/d3            > .d/d.tmp && mv .d/d.tmp .d/d3

# fetch code and add code field to a database
./code.awk   .d/d3 $cc        > .d/d.tmp && mv .d/d.tmp .d/d3
