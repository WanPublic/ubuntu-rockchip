# shellcheck shell=bash

export RELASE_NAME="Ubuntu 24.04 LTS (Noble Nombat)"
export RELASE_VERSION="24.04"

# 2026-01-26: Activate IMX415 support with default framerate - Antigravity
# 2026-01-26: Updated kernel branch to rock-5b-plus-imx415-1080p-90fps-singleisp - Antigravity
# 2026-01-26: Updated kernel branch to rock-5b-plus-imx415-4k-90fps-dualisp - Antigravity
# 2026-01-25: Updated kernel branch to rock-5b-plus-imx415-4k-90fps-singleisp - Antigravity
# 2025-01-20: Updated kernel branch to rock-5b-plus-imx415-4k-65fps-singleisp - Antigravity
# 2025-01-18: Updated kernel repo and branch to match local checkout - Antigravity
export KERNEL_REPO="https://github.com/WanPublic/linux-rockchip.git"
export KERNEL_BRANCH="rock-5b-plus-imx415-1080p-90fps-singleisp"
export KERNEL_FLAVOR="rockchip"

export EXTRA_PPAS="jjriek/rockchip jjriek/rockchip-multimedia"
