#!/bin/bash

if [[ $ARGC != 2 ]]; then
    echo -e "usage: $0 <srcdir> <dstdir>"
    echo -e "\tconverts all .flac files in <srcdir> to .mp3 in <dstdir>, renaming file.flac as __file.mp3"
    exit
fi

srcdir=$1
dstdir=$2

echo "srcdir($srcdir)"
echo "dstdir($dstdir)"

find "$srcdir" -name '*.flac' -print0 | xargs -0 -L1 -P0 bash -c 'srcdir=$0; dstdir=$1; old=$2; new=$(echo $old | sed -r "s/\.flac$/.mp3/; s/^.*\/([^/]+)$/__\1/"); echo -e "converting $old\n\t$dstdir/$new"; sox "$old" "$dstdir/$new"; echo "$dstdir/$new done"' "$srcdir" "$dstdir"

