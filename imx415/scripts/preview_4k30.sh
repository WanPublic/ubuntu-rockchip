#!/bin/bash
# 2026-01-26: IMX415 4K30fps Preview Script - Antigravity
# This script starts a 4K 30fps preview on Display :0.

DEVICE=${1:-/dev/video11}
WIDTH=3840
HEIGHT=2160
FPS=30

echo "Starting 4K30fps preview on $DEVICE..."
export DISPLAY=:0

# Ensure X11/Wayland permissions if necessary
xhost +local:root > /dev/null 2>&1

gst-launch-1.0 v4l2src device=$DEVICE ! \
    video/x-raw,format=NV12,width=$WIDTH,height=$HEIGHT,framerate=$FPS/1 ! \
    videoconvert ! \
    autovideosink
