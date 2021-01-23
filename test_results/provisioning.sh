#!/bin/bash
set -euo pipefail

# when instance starts up yum does some jobs in the
# background and is not usable, check and only run command
# when its finished
echo 'Checking yum lock'
if test -f "/var/run/yum/pid"; then
  echo 'yum lock is held, try again in a bit'
  exit 1
fi

# Switch to be on cuda 11
sudo rm -rf /usr/local/cuda
sudo ln -s /usr/local/cuda-11.0 /usr/local/cuda

# install opencv for development
sudo yum install opencv-devel.x86_64 -y

# make sure we are in home directory
cd ~

# Get darknet
git clone https://github.com/AlexeyAB/darknet.git

# Modify Makefile
cd darknet
sed -i 's/^GPU=0/GPU=1/' Makefile
sed -i 's/^CUDNN=0/CUDNN=1/' Makefile
sed -i 's/^CUDNN_HALF=0/CUDNN_HALF=1/' Makefile
sed -i 's/^OPENCV=0/OPENCV=1/' Makefile

# remove default arch lines
sed -i -E '/(^ARCH=|^\s+-gencode)/d' Makefile

# uncomment the tesla v100 compile flag
sed -i -E '/^# Tesla V100/{n;s/# // }' Makefile

make


# downloads the weights file for v4
wget https://github.com/AlexeyAB/darknet/releases/download/darknet_yolo_v3_optimal/yolov4.weights


# images need to be copied over to data/obj/img1.jpg, data/obj/img2.jpg...
wget -O frames.zip https://crunchypartoftheegg.s3.amazonaws.com/assets/ying_day2_40mins_all_frames_smaller.zip
mkdir data/obj
tar -C data/obj -xf frames.zip


# download training weights!
wget https://github.com/AlexeyAB/darknet/releases/download/darknet_yolo_v3_optimal/yolov4.conv.137


# Copy config files
mv ../artifacts/train.txt data/train.txt
mv "../artifacts/test.txt" "data/test.txt"
mv "../artifacts/testing.txt" "data/"
mv "../artifacts/obj.data" "data/obj.data"
mv "../artifacts/obj.names" "data/obj.names"
mv "../artifacts/yolov4-yingdance.cfg" "cfg/yolov4-yingdance.cfg"

tar -C "data/obj" -xf "../artifacts/updated-annotationsnov28.zip"


# Command that runs training, displaying losses on port 8090
# ./darknet detector train data/obj.data cfg/yolov4-yingdance.cfg yolov4.conv.137 -dont_show -mjpeg_port 8090 -map


# Batch testing, output to result.json
# ./darknet detector test data/obj.data cfg/yolov4-yingdance.cfg backup/yolov4-yingdance_last.weights -dont_show -out result.json < data/testing.txt

