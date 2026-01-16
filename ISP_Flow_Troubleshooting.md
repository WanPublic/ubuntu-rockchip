# IMX415 4K 90FPS ISP Pipeline 故障排查手册

本以此文档按照数据流处理顺序，逐步排查为何无法通过 ISP (`/dev/video11`) 获取图像。

## 核心数据流路径 (Data Pipeline)
1. **Sensor**: `imx415` (输出 Bayer RAW 数据)
2. **Physical Layer**: `rockchip-csi2-dphy0` (MIPI 电气信号接收)
3. **Protocol Layer**: `rockchip-mipi-csi2` (MIPI 协议解析)
4. **VICAP (Rkcif)**: `rkcif_mipi_lvds` (数据分发中心)
   - **分支 A (DDR Dump)**: -> `stream_cif_mipi_id0` -> `/dev/video0` (调试用，如果不禁用会占用带宽/资源)
   - **分支 B (ISP Path)**: -> `rkcif_mipi_lvds_sditf` -> `rkisp_vir0` (ISP 入口)
5. **ISP (Rkisp)**: `rkisp_vir0` (图像处理：去噪、白平衡、色彩转换)
   - **Output**: `rkisp_mainpath` -> `/dev/video11` (最终 NV12 图像)

---

## 排查步骤与状态记录

### 步骤 1: 检查 Sensor 到 VICAP 的基础链路 (Basic Link)
**目标**: 确认 Sensor 在工作，且数据能到达 VICAP。
**命令**: `v4l2-ctl -d /dev/video0 --stream-mmap --stream-count=1`
**状态**: ✅ **已通过** (帧率稳定在 90fps)。说明 Sensor -> VICAP 通路正常。

### 步骤 2: 检查 VICAP 路由冲突 (Routing Conflict)
**目标**: `/dev/video11` 报错 "Device busy" 通常是因为 VICAP 同时开启了分支 A (Dump) 和分支 B (ISP)。在 4K@90fps 高负载下，VICAP 可能不支持双路同时输出，或者驱动逻辑互斥。
**检查**: 查看 `media0` 拓扑中，`rockchip-mipi-csi2` 到 `stream_cif_mipi_id0` 是否被标记为 `[ENABLED]`。
**操作**: 必须先禁用分支 A，才能启用分支 B。
**执行结果**: 发现 `rkaiq_3A_server` 占用 `/dev/video0` (PID 431)。

### 步骤 3: 强制释放资源
**操作**: 
1. `killall rkaiq_3A_server` 杀死占用进程。
2. `fuser -v /dev/video0` 确认释放。
3. `media-ctl -d /dev/media0 -l '"rockchip-mipi-csi2":1 -> "stream_cif_mipi_id0":0 [0]'` 断开 video0 链路。

**当前状态**: 尽管执行了上述操作，`/dev/video11` 仍然报错 "Device or resource busy"。

### 结论与建议
1. **驱动层正常**: `imx415.c` 驱动修改已生效，Sensor 能够稳定输出 4K 90fps 数据。
2. **系统资源占用**: "Device busy" 是由于 RK3588 的 VICAP 硬件在处理高带宽数据时，无法同时满足 ISP 和 DDR Dump 的需求，或者系统状态未能正确复位。
3. **下一步**: 
   - 尝试在设备树中直接 `disabled` 掉 `stream_cif_mipi_id0` 相关的 endpoint，强制数据只走 ISP。
   - 检查 `rkaiq` 的启动参数，确保它初始化 ISP Pipeline 时使用正确的 sensor mode。
