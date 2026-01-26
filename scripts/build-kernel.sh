#!/bin/bash

set -eE 
trap 'echo Error: in $0 on line $LINENO' ERR

if [ "$(id -u)" -ne 0 ]; then 
    echo "Please run as root"
    exit 1
fi

cd "$(dirname -- "$(readlink -f -- "$0")")" && cd ..
mkdir -p build && cd build

if [[ -z ${SUITE} ]]; then
    echo "Error: SUITE is not set"
    exit 1
fi

# shellcheck source=/dev/null
source "../config/suites/${SUITE}.sh"

# Clone or update the kernel repo
# 2025-01-18: Improved repo handling to avoid clone errors if directory exists - Antigravity
if [ ! -d linux-rockchip ]; then
    git clone --progress -b "${KERNEL_BRANCH}" "${KERNEL_REPO}" linux-rockchip --depth=2
fi

cd linux-rockchip
git checkout "${KERNEL_BRANCH}"

# shellcheck disable=SC2046
export $(dpkg-architecture -aarm64)
# 2025-01-18: Corrected ccache usage to avoid 'ccacheld' errors - Antigravity
# 2026-01-26: Enhanced ccache configuration for better cache hit rate - Antigravity
export CROSS_COMPILE="aarch64-linux-gnu-"
export CC="ccache aarch64-linux-gnu-gcc"
export CXX="ccache aarch64-linux-gnu-g++"
export HOSTCC="ccache gcc"
export HOSTCXX="ccache g++"
export LANG=C
# 设置 ccache 配置以优化缓存效果
export CCACHE_DIR="${CCACHE_DIR:-/home/wanpublic/.cache/ccache}"
export CCACHE_BASEDIR="$(pwd)"
export CCACHE_SLOPPINESS="pch_defines,time_macros,include_file_mtime,include_file_ctime"
export CCACHE_MAXSIZE="50G"
# 确保 ccache 目录存在
mkdir -p "${CCACHE_DIR}"

# Compile the kernel into a deb package
fakeroot debian/rules clean binary-headers binary-rockchip do_mainline_build=true
