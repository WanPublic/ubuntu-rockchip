#!/bin/bash
# Debug script for Rock 5B Plus IMX415 4K 90fps Preview
# Purpose: Manually configure pipeline with cropping to avoid ISP alignment crash

HOST=10.5.0.127
PASS=wanpublic2025

echo "=== Diagnosis Start ==="

# 1. Check Connectivity
sshpass -p $PASS ssh -o StrictHostKeyChecking=no wanpublic@$HOST "uptime"
if [ $? -ne 0 ]; then
    echo "Error: Board not reachable. Please reboot manually."
    exit 1
fi

# 2. Identify Devices
echo "--- Identify Devices ---"
DEVICES=$(sshpass -p $PASS ssh wanpublic@$HOST "v4l2-ctl --list-devices")
VICAP_DEV=$(echo "$DEVICES" | grep -A1 "rkcif (platform:rkcif-mipi-lvds2)" | tail -n1 | tr -d '\t ')
ISP_DEV=$(echo "$DEVICES" | grep -A1 "rkisp_mainpath (platform:rkisp0-vir0)" | tail -n1 | tr -d '\t ')

echo "VICAP Device: $VICAP_DEV"
echo "ISP Device:   $ISP_DEV"

if [ -z "$VICAP_DEV" ] || [ -z "$ISP_DEV" ]; then
    echo "Error: Could not find video devices."
    exit 1
fi

# 3. Configure VICAP (Sensor Input -> Memory)
# Sensor outputs 3864x2192 (Native)
# we must capture this FULL size on the sink pad, but CROP for the video node output
echo "--- Configure VICAP ---"
sshpass -p $PASS ssh wanpublic@$HOST "v4l2-ctl -d $VICAP_DEV --set-fmt-video=width=3864,height=2192,pixelformat=GB10"

# Apply Crop: 3864 -> 3840 (Aligns to 16/32 for Dual ISP)
echo "--- Applying Crop $VICAP_DEV (3864 -> 3840) ---"
sshpass -p $PASS ssh wanpublic@$HOST "v4l2-ctl -d $VICAP_DEV --set-selection=target=crop,top=0,left=0,width=3840,height=2160"

# 4. Configure ISP (Memory -> ISP -> Memory)
# Input should be 3840x2160 (from VICAP Crop)
echo "--- Configure ISP $ISP_DEV ---"
sshpass -p $PASS ssh wanpublic@$HOST "v4l2-ctl -d $ISP_DEV --set-fmt-video=width=3840,height=2160,pixelformat=NV12"

# 5. Capture Test
echo "--- Starting ISP Capture Test (60 frames) ---"
sshpass -p $PASS ssh wanpublic@$HOST "v4l2-ctl -d $ISP_DEV --stream-mmap --stream-count=60 --verbose"

echo "=== Diagnosis Complete ==="
