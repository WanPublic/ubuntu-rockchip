# shellcheck shell=bash

export RELASE_NAME="Ubuntu 24.04 LTS (Noble Nombat)"
export RELASE_VERSION="24.04"

# 2026-01-16: 将 KERNEL_BRANCH 修改为 noble，初始环境搭建
# 2026-01-16: 切换到 orange-pi-5-plus-imx415-4k-65fps-singleisp 分支进行编译
# 2026-01-16: 切换到 orange-pi-5-plus-imx415-4k-90fps-singleisp 分支进行 4K 90fps 开发
# 2026-01-16: 切换到 orange-pi-5-plus-imx415-4k-90fps-dualisp 分支进行 4K 90fps dual isp 开发
export KERNEL_REPO="https://github.com/WanPublic/linux-rockchip.git"
# 2026-01-17: 切换到 orange-pi-5-plus-imx415-4k-90fps-singleisp 分支进行内核编译
# 2026-01-30: 切换到 orange-pi-5-plus-imx415-1080P-90ps-singleisp 分支进行 1080p 90fps 编译测试
export KERNEL_BRANCH="orange-pi-5-plus-imx415-1080P-90ps-singleisp"
export KERNEL_FLAVOR="rockchip"

export EXTRA_PPAS="jjriek/rockchip jjriek/rockchip-multimedia"
