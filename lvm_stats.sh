#!/bin/bash

sudo pvdisplay | awk '
BEGIN {
    n = 0;
    sz = 0;
    alloc = 0;
    free = 0;
    dev = "";
}

/---/ {
    n++;
    if (n>1) {
        print "Device:   ", dev;
        print "Free:     ", free*sz/1024, "GiB";
        print "Allocated:", alloc*sz/1024,"GiB";
        print "---";
    }
    sz = 0;
    alloc = 0;
    free = 0;
    dev = "";
}

/PV Name/ {
    dev = $(NF);
}

/PE Size/ {
    sz = $(NF-1);
}

/Free PE/ {
    free = $(NF);
}

/Allocated PE/ {
    alloc = $(NF);
}

END {
    print "Device:   ", dev;
    print "Free:     ", free*sz/1024, "GiB";
    print "Allocated:", alloc*sz/1024,"GiB";
}'
