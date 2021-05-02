#!/bin/bash

#bash -c 'gst-launch-1.0 v4l2src device=/dev/video0 ! "image/jpeg, width=1920, height=1080,type=video,framerate=30/1" ! rtpjpegpay ! queue ! udpsink host=192.168.31.157 port=5600'
#bash -c 'gst-launch-1.0  v4l2src device=/dev/video0 ! "image/jpeg, width=640, height=480, type=video,framerate=30/1" ! jpegdec ! videoscale ! videoconvert ! x264enc pass=quant ! rtph264pay ! udpsink host=192.168.31.157 port=5600'

if  lsof -Pi :8555 -sTCP:LISTEN -t >/dev/null ; then  echo "already running" ; elif [ -c /dev/video0 ] ; then  v4l2rtspserver -H 480 -W 640 -F 25 -P 8555 /dev/video0 ; else echo "Device error"; fi
