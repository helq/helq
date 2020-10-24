#!/usr/bin/env bash

# Licensed under CC0 (Public Domain): https://creativecommons.org/publicdomain/zero/1.0/

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 song_name split_time"
    exit 1
fi

# name file to split
name="$1"
# splitting time in seconds
splitLen=$2

totalTime="$(ffprobe -i "$name" -show_format 2> /dev/null | sed -n 's/duration=//p')"
numOfSplits="$(printf '%.0f\n' $[ totalTime / splitLen ])"

for i in {0..$numOfSplits}; do
    start=$[ splitLen * i ]

    num=$(printf '%02d' $[i+1])
    new_name="${name%.*}_${num}.${name//*.}"

    ffmpeg -i "$name" -acodec copy -vcodec copy \
           -t $splitLen -ss $start \
           -metadata "track=$[i+1]" \
           "$new_name"
done
