#!/bin/bash
# Preview Script for Rock 5B Plus (IMX415 4K 90fps)
# Configuration: Single ISP (rkisp0) processing Native 3864x2192 Resolution
# Note: Single ISP is used to avoid system crash in Dual ISP Unite Mode.

export DISPLAY=:0
echo "Starting Preview on Display :0..."

# Force VICAP to 3864x2192 (Native)
v4l2-ctl -d /dev/video0 --set-fmt-video=width=3864,height=2192,pixelformat=GB10

# Start ISP Preview (Scaling downstream or displaying native)
# Using kmssink for display
gst-launch-1.0 v4l2src device=/dev/video11 ! video/x-raw,format=NV12,width=3864,height=2192 ! kmssink
