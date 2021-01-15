#!/bin/bash
set -euox pipefail

# Couldn't do read -r because it interacted very weirdly with ffmpeg, this is a workaround
lines=(`cat "frame_offsets.txt"`)

for line in "${lines[@]}"; do
  echo $line
  output_filename=smaller-frames/${line//./_}.jpg
  echo $output_filename
  ffmpeg -hide_banner -loglevel warning -ss $line -y -i day2-40min.mp4 -vframes 1 -q:v 1 -vf scale=960:-1 $output_filename
done
