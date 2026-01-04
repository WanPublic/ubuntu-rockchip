#!/bin/bash

DEVICE=/dev/video11

echo "Checking available formats:"
v4l2-ctl -d $DEVICE --list-formats-ext

echo ""
echo "=========================================="
echo "Testing Original 4K 30fps Mode"
echo "=========================================="
# Force 4K resolution which maps to the first supported mode
v4l2-ctl -d $DEVICE --set-fmt-video=width=3840,height=2160,pixelformat=NV12
sleep 1
# Verify what we got
current_fmt=$(v4l2-ctl -d $DEVICE --get-fmt-video)
echo "$current_fmt"

# Record
echo "Recording 4K 30fps to /tmp/test_4k.mp4..."
timeout 6 gst-launch-1.0 v4l2src device=$DEVICE num-buffers=100 ! video/x-raw,format=NV12,width=3840,height=2160,framerate=30/1 ! queue ! mpph264enc ! h264parse ! mp4mux ! filesink location=/tmp/test_4k.mp4
ls -lh /tmp/test_4k.mp4

echo ""
echo "=========================================="
echo "Testing New 1080p 60fps Mode"
echo "=========================================="
# Force 1080p resolution. Since we have multiple 1080p modes, driver selection depends on logic.
# Our new mode is 1944x1097 binning. Original 1080p mode is also 1944x1097.
# However, we want 60fps.
v4l2-ctl -d $DEVICE --set-fmt-video=width=1920,height=1080,pixelformat=NV12
# Set frame interval to 60fps to force selection of our new mode
v4l2-ctl -d $DEVICE --set-parm=60
sleep 1
# Verify what we got
current_fmt=$(v4l2-ctl -d $DEVICE --get-fmt-video)
echo "$current_fmt"

# Record
echo "Recording 1080p 60fps to /tmp/test_1080p60.mp4..."
timeout 6 gst-launch-1.0 v4l2src device=$DEVICE num-buffers=200 ! video/x-raw,format=NV12,width=1920,height=1080,framerate=60/1 ! queue ! mpph264enc ! h264parse ! mp4mux ! filesink location=/tmp/test_1080p60.mp4
ls -lh /tmp/test_1080p60.mp4
