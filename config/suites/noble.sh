# shellcheck shell=bash

export RELASE_NAME="Ubuntu 24.04 LTS (Noble Nombat)"
export RELASE_VERSION="24.04"

# 2026-01-16: 将 KERNEL_BRANCH 修改为 noble，初始环境搭建
# 2026-01-16: 切换到 orange-pi-5-plus-imx415-4k-65fps-singleisp 分支进行编译
export KERNEL_REPO="https://github.com/WanPublic/linux-rockchip.git"
export KERNEL_BRANCH="orange-pi-5-plus-imx415-4k-65fps-singleisp"
export KERNEL_FLAVOR="rockchip"

export EXTRA_PPAS="jjriek/rockchip jjriek/rockchip-multimedia"
