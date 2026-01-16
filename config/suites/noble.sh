# shellcheck shell=bash

export RELASE_NAME="Ubuntu 24.04 LTS (Noble Nombat)"
export RELASE_VERSION="24.04"

# 2026-01-16: 将 KERNEL_BRANCH 修改为 noble，初始环境搭建
export KERNEL_REPO="https://github.com/WanPublic/linux-rockchip.git"
export KERNEL_BRANCH="noble"
export KERNEL_FLAVOR="rockchip"

export EXTRA_PPAS="jjriek/rockchip jjriek/rockchip-multimedia"
