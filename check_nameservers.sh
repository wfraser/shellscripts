#!/bin/bash

query=${1-codewise.org.}
record=${2-any}

# make sure the name ends in .
query=$(echo $query | sed -r 's/([^.])$/\1./')

# if no args, run "codewise.org. a"
if [[ $1 == "" ]]; then
    record="a"
fi

# find the lowest zone with a nameserver record
zone=$(dig $query ns +trace | grep NS | tail -1 | cut -f1)

# look up nameservers for that zone
servers=$(dig $zone ns +short)

# for padding
maxlen=$(echo $servers | awk '{max=0; for (i=1; i<=NF; i++) { if (length($(i)) > max) max = length($(i)); } print max}')

echo "checking \"$query $record\" in $zone's nameservers"
for ns in $servers; do
    printf "%-${maxlen}s : " $ns
    out=(dig @$ns $query $record +short)

    if [[ $out == "" ]]; then
        echo "NOT FOUND"
    else
        echo -n $out
        echo -n ", "
        # print the soa serial number
        dig @$ns $zone soa +short | cut -d' ' -f3
    fi
done
