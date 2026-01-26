# IMX415 4K 90FPS 调试文档

## 问题描述
在 IMX415 4K 90fps 模式下，RAW 捕获成功（90fps），但通过 ISP 处理后无法获取画面（Timeout）。

## 环境基础信息收集

### 1. 设备与驱动信息
- **目标机器**: Rock 5B Plus (RK3588)
- **内核版本**: `6.1.0-1027-rockchip`
- **ISP 版本**: ISP 3.0
- **Sensor**: Sony IMX415
- **驱动源码**: 已替换为 `orange-pi-5-plus-imx415-4k-90fps-singleisp` 分支版本。

### 2. 视频管道 (Media Pipeline)
- **路径**: `imx415 -> csi2_dphy0 -> mipi2_csi2 -> rkcif_mipi_lvds2 -> rkisp0_vir0`
- **格式**:
    - Sensor: `3864x2192` SGBRG10
    - CIF/ISP: `3840x2160` (Crop 12,16)

## 排查进展 (2026-01-26)

### 1. 突破性进展：RAW 链路通畅
- **现象**: 使用 `v4l2-ctl -d /dev/video0` 可以稳定获取 **90.00 fps** 的 RAW10 数据流。
- **结论**: 
    - Sensor 寄存器配置正确，时钟 (INCK 37.125MHz) 与 90fps 输出匹配。
    - MIPI DPHY 与 CIF 硬件链路能够支持 2376Mbps 的超高带宽。

### 2. ISP 捕获失败分析
- **现象**: `/dev/video11` 捕获超时，`dmesg` 报 `rkisp_stream_stop timeout`。
- **实测时钟频率 (流开启时)**:
    - `clk_isp0_core`: **702 MHz** (已由驱动自动提升至最高)
    - `clk_isp0_core_marvin`: 702 MHz
    - `clk_isp0_core_vicap`: 702 MHz
- **理论瓶颈分析**:
    - **吞吐量需求**: 4K (3840x2160) @ 90fps = **746,496,000 像素/秒**。
    - **ISP 能力**: 即使工作在 702MHz 频率，ISP 理论上也只能处理 **702 MPix/s**。
    - **结论**: **Single ISP 模式下，702MHz 频率完全无法满足 4K 90fps 的实时处理需求**。数据在进入 ISP 内部处理流水线之前就会发生溢出，导致无法输出完整的一帧，从而触发 V4L2 超时。

### 3. 信号质量与数据完整性
- **现象**: `dmesg` 出现 `mipi2-csi2-hw ERR1:0x1000000 (crc,vc: 0)`。
- **分析**: 2376Mbps 的速率对物理布线和信号完整性要求极高。CRC 错误表示数据包受损。CIF 节点能够捕获 RAW 数据可能是因为其容错机制较高，但损坏的数据会导致 ISP 状态机复位或丢弃帧，进一步确认了 4K 90fps 在当前硬件/链路配置下的极端性。

## 下一步行动计划

### 1. 尝试开启 Dual ISP (Unite Mode)
- **目标**: 将 4K 图像切分为左右两半，由两个 ISP 同时处理。
- **优势**: 两个 ISP 各自处理 1920x2160 @ 90fps，总和处理能力翻倍，解决 702MHz 的性能瓶颈。
- **操作**: 修改设备树，启用 `rkisp0_vir0` 的 Unite 模式并绑定 `rkisp_unite`。

### 2. 优化 DPHY 物理参数
- 微调 `dcphy_param` 寄存器配置，尝试消除 CRC 错误，提高信号稳定性。

### 3. 对比测试 1080P 90fps
- 验证在同样是 90fps 但像素总量降低的情况下，ISP 是否能正常工作，以排除 ISP 确实是因为像素吞吐量过载而挂掉。
