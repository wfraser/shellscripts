#!/bin/bash

if [ "$1" == "" ]; then
    echo "usage: $0 </dev/pts/\$n>"
    echo "shows who's using a given terminal and what command they're running"
    exit
fi

#esc='s/ /\\\\ /;s/\\t/\\\\t/'

function escape() {
    exec sed 's/ /\\ /'
}

for file in /proc/*/fd/0; do
    if [ $(readlink $file) == "$1" ]; then
        pid=$(echo $file | sed -r 's/^\/proc\/([^\/]+)\/fd\/0$/\1/')
        [ $pid == "self" ] && continue
        uid=$(awk '/^Uid:/{print $2}' /proc/$pid/status)
        gid=$(awk '/^Gid:/{print $2}' /proc/$pid/status)

        user=$(awk 'BEGIN{FS=":"} {if($3=="'$uid'") { print $1; exit; } }' /etc/passwd)
        group=$(awk 'BEGIN{FS=":"} {if($3=="'$gid'") { print $1; exit; } }' /etc/group)

        [ "$user" == "" ] && user=$uid
        [ "$group" == "" ] && group=$gid

        cwd=$(readlink /proc/$pid/cwd | escape)
        exe=$(readlink /proc/$pid/exe | escape)

        args=$(sed -r 's/ /\\ /g;s/\x0/ /g' < /proc/$pid/cmdline)

        echo "$pid $user:$group $cwd $exe $args"
    fi;
done

