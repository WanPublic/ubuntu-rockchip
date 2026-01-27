#!/bin/bash
# 2026-01-26: IMX415 FPS Test Script - Antigravity
# This script tests the actual framerate of the IMX415 camera using GStreamer.

DEVICE=${1:-/dev/video11}
WIDTH=3840
HEIGHT=2160
FPS=30

echo "Testing FPS on $DEVICE with resolution ${WIDTH}x${HEIGHT}..."

gst-launch-1.0 v4l2src device=$DEVICE ! \
    video/x-raw,format=NV12,width=$WIDTH,height=$HEIGHT,framerate=$FPS/1 ! \
    fpsdisplaysink text-overlay=true signal-fps-measurements=true video-sink=fakesink sync=false
