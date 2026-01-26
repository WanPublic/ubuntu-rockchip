#!/bin/bash
# 2026-01-26: Global Deploy and Test Script for Rock 5B Plus IMX415 Dual ISP
# Following User Rule 12

HOST=10.5.0.127
USER=wanpublic
PASS=wanpublic2025
DEB_DIR="/home/wanpublic/ubuntu-rockchip/build"

echo "=== 1. Installing to Target Machine ==="
# Find latest kernel debs
LATEST_DEBS=$(ls -t $DEB_DIR/*.deb | head -n 4)
if [ -z "$LATEST_DEBS" ]; then
    echo "Error: No deb packages found in $DEB_DIR"
    exit 1
fi

echo "Copying packages: $LATEST_DEBS"
sshpass -p $PASS scp -o StrictHostKeyChecking=no $LATEST_DEBS $USER@$HOST:~/ 

echo "Installing packages on target..."
sshpass -p $PASS ssh $USER@$HOST "sudo dpkg -i ~/*.deb"

echo "=== 2. Rebooting Target Machine ==="
sshpass -p $PASS ssh $USER@$HOST "sudo reboot"

echo "Waiting 30 seconds for reboot..."
sleep 30

# Wait for SSH to be back
until sshpass -p $PASS ssh -o ConnectTimeout=2 $USER@$HOST "uptime" > /dev/null 2>&1
do
    echo "Target still down, waiting..."
    sleep 5
done

echo "=== 3. Testing Camera Startup ==="
DEVICES=$(sshpass -p $PASS ssh $USER@$HOST "v4l2-ctl --list-devices")
echo "Available Devices:"
echo "$DEVICES"

# Identify ISP device (Should be rkisp_mainpath on rkisp0-vir0)
ISP_DEV=$(echo "$DEVICES" | grep -A1 "rkisp_mainpath (platform:rkisp0-vir0)" | tail -n1 | tr -d '\t ')
if [ -z "$ISP_DEV" ]; then
    echo "Error: ISP Device not found!"
    exit 1
fi
echo "Using ISP Device: $ISP_DEV"

# 4. Configure Media Pipeline if necessary
# For Rock 5B Plus CAM1: imx415 is usually on v4l-subdevX
# We need to ensure the link is enabled. 
# media-ctl -d /dev/media0 -l '"rkcif_mipi_lvds4":0 -> "rkisp-isp-subdev":0 [1]'
sshpass -p $PASS ssh $USER@$HOST "sudo media-ctl -d /dev/media0 -l '\"rkcif-mipi-lvds4\":0 -> \"rkisp-isp-subdev\":0 [1]'"

echo "=== 4. Testing Actual Framerate ==="
# Try to capture 900 frames and measure time
sshpass -p $PASS ssh $USER@$HOST "v4l2-ctl -d $ISP_DEV --set-fmt-video=width=3840,height=2160,pixelformat=NV12 --stream-mmap --stream-count=900"

echo "=== 5. ISP Pipeline & Preview Address ==="
echo "ISP Pipeline: imx415 -> csi2_dphy3 -> mipi4_csi2 -> rkcif_mipi_lvds4 -> rkisp0_vir0 (Dual ISP Unite Mode)"
echo "Preview Command: gst-launch-1.0 v4l2src device=$ISP_DEV ! video/x-raw,format=NV12,width=3840,height=2160,framerate=90/1 ! autovideosink"

echo "=== 6. Previewing on Display :0 ==="
sshpass -p $PASS ssh $USER@$HOST "export DISPLAY=:0 && gst-launch-1.0 v4l2src device=$ISP_DEV ! video/x-raw,format=NV12,width=3840,height=2160,framerate=90/1 ! fpsdisplaysink text-overlay=false video-sink=autovideosink sync=false" &
