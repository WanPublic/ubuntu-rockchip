# IMX415 驱动修改总结 - 高帧率模式支持

## 修改概述

本次修改为 IMX415 驱动添加了以下高帧率模式的支持：
- **1080p (1944x1097) @ 90fps** - 2x2 binning 模式
- **4K (3864x2192) @ 60fps** - 全像素扫描模式
- **4K (3864x2192) @ 90fps** - 全像素扫描模式

基于 Sunnic 官方寄存器配置文档和现有驱动结构。

---

## 已有的寄存器配置

驱动中已包含以下寄存器配置（由之前的修改添加）：

### 1. 1080p 90fps (binning 模式)
- 数组名: `imx415_linear_10bit_1932x1096_446M_90fps_regs[]`
- 时钟: 27MHz
- MIPI 速率: 891Mbps (446MHz Link Freq)
- VMAX: 0x8CA = 2250
- HMAX: 0x226 = 550

### 2. 4K 60fps
- 数组名: `imx415_linear_10bit_3864x2192_720M_60fps_regs[]`
- 时钟: 24MHz
- MIPI 速率: 1440Mbps (720MHz Link Freq)
- VMAX: 0x8CB = 2251
- HMAX: 0x215 = 533

### 3. 4K 90fps
- 数组名: `imx415_linear_10bit_3864x2192_1188M_90fps_regs[]`
- 时钟: 27MHz
- MIPI 速率: 2376Mbps (1188MHz Link Freq)
- VMAX: 0x8CE = 2254
- HMAX: 0x16E = 366

---

## 本次修改内容

### 1. 更新最大像素率 (第 75 行)

**修改前:**
```c
#define IMX415_MAX_PIXEL_RATE		(MIPI_FREQ_720M / 10 * 2 * IMX415_4LANES)
```

**修改后:**
```c
#define IMX415_MAX_PIXEL_RATE		(MIPI_FREQ_1188M / 10 * 2 * IMX415_4LANES)
```

**说明:** 更新最大像素率以支持 4K 90fps 的 2376Mbps 数据传输。

---

### 2. 在 supported_modes 数组中添加新模式

在 `supported_modes[]` 数组中添加了三个新模式：

#### 2.1 1080p 90fps (binning 模式)
```c
{
	.bus_fmt = MEDIA_BUS_FMT_SGBRG10_1X10,
	.width = 1944,
	.height = 1097,
	.max_fps = {
		.numerator = 10000,
		.denominator = 900000,  // 90fps
	},
	.exp_def = 0x08CA - 0x08,
	.hts_def = 0x0226 * IMX415_4LANES * 2,
	.vts_def = 0x08CA,
	.global_reg_list = imx415_global_10bit_3864x2192_regs,
	.reg_list = imx415_linear_10bit_1932x1096_446M_90fps_regs,
	.hdr_mode = NO_HDR,
	.mipi_freq_idx = 1,  /* MIPI_FREQ_446M */
	.bpp = 10,
	.vc[PAD0] = 0,
	.xvclk = IMX415_XVCLK_FREQ_27M,
},
```

#### 2.2 4K 60fps
```c
{
	.bus_fmt = MEDIA_BUS_FMT_SGBRG10_1X10,
	.width = 3864,
	.height = 2192,
	.max_fps = {
		.numerator = 10000,
		.denominator = 600000,  // 60fps
	},
	.exp_def = 0x08CB - 0x08,
	.hts_def = 0x0215 * IMX415_4LANES * 2,
	.vts_def = 0x08CB,
	.global_reg_list = imx415_global_10bit_3864x2192_regs,
	.reg_list = imx415_linear_10bit_3864x2192_720M_60fps_regs,
	.hdr_mode = NO_HDR,
	.mipi_freq_idx = 5,  /* MIPI_FREQ_720M */
	.bpp = 10,
	.vc[PAD0] = 0,
	.xvclk = IMX415_XVCLK_FREQ_24M,
},
```

#### 2.3 4K 90fps
```c
{
	.bus_fmt = MEDIA_BUS_FMT_SGBRG10_1X10,
	.width = 3864,
	.height = 2192,
	.max_fps = {
		.numerator = 10000,
		.denominator = 900000,  // 90fps
	},
	.exp_def = 0x08CE - 0x08,
	.hts_def = 0x016E * IMX415_4LANES * 2,
	.vts_def = 0x08CE,
	.global_reg_list = imx415_global_10bit_3864x2192_regs,
	.reg_list = imx415_linear_10bit_3864x2192_1188M_90fps_regs,
	.hdr_mode = NO_HDR,
	.mipi_freq_idx = 4,  /* MIPI_FREQ_1188M */
	.bpp = 10,
	.vc[PAD0] = 0,
	.xvclk = IMX415_XVCLK_FREQ_27M,
},
```

---

## 当前支持的所有模式

| 模式 | 分辨率 | 帧率 | 时钟 | MIPI 速率 | mipi_freq_idx |
|------|--------|------|------|-----------|---------------|
| 4K Linear | 3864x2192 | 30fps | 37.125MHz | 891Mbps | 1 (MIPI_FREQ_446M) |
| 4K HDR2 | 3864x2192 | 30fps | 37.125MHz | 1485Mbps | 2 (MIPI_FREQ_743M) |
| 1080p | 1944x1097 | 60fps | 24MHz | 1440Mbps | 5 (MIPI_FREQ_720M) |
| **1080p** | **1944x1097** | **90fps** | **27MHz** | **891Mbps** | **1 (MIPI_FREQ_446M)** |
| **4K** | **3864x2192** | **60fps** | **24MHz** | **1440Mbps** | **5 (MIPI_FREQ_720M)** |
| **4K** | **3864x2192** | **90fps** | **27MHz** | **2376Mbps** | **4 (MIPI_FREQ_1188M)** |
| 1080p | 1944x1097 | 30fps | 37.125MHz | 594Mbps | 0 (MIPI_FREQ_297M) |

---

## link_freq_items 数组

当前 `link_freq_items[]` 数组定义:
```c
static const s64 link_freq_items[] = {
	MIPI_FREQ_297M,   // index 0
	MIPI_FREQ_446M,   // index 1
	MIPI_FREQ_743M,   // index 2
	MIPI_FREQ_891M,   // index 3
	MIPI_FREQ_1188M,  // index 4
	MIPI_FREQ_720M,   // index 5
};
```

---

## 技术参数对比

| 参数 | 1080p 90fps | 4K 60fps | 4K 90fps |
|------|-------------|----------|----------|
| **分辨率** | 1944x1097 | 3864x2192 | 3864x2192 |
| **输入时钟 (XVCLK)** | 27 MHz | 24 MHz | 27 MHz |
| **MIPI 数据速率** | 891 Mbps | 1440 Mbps | 2376 Mbps |
| **Link Freq** | 446 MHz | 720 MHz | 1188 MHz |
| **SYS_MODE (0x3033)** | 0x05 | 0x08 | 0x00 |
| **VMAX** | 0x08CA | 0x08CB | 0x08CE |
| **HMAX** | 0x0226 | 0x0215 | 0x016E |
| **ADBIT (输入)** | 10bit | 10bit | 10bit |
| **MDBIT (输出)** | 12bit | 10bit | 10bit |
| **模式** | Binning 2x2 | All-pixel | All-pixel |

---

## 设备树配置说明

### 27MHz 时钟 (用于 1080p 90fps 和 4K 90fps)
设备树已配置 27MHz 时钟支持。

### 24MHz 时钟 (用于 4K 60fps)
需要确保设备树支持 24MHz 时钟输入。

---

## 注意事项

1. **硬件要求**: 
   - 4K 90fps 模式需要 DCPHY 支持 2376Mbps 的高速传输
   - 确保 CSI 接口支持所需的带宽

2. **时钟配置**: 
   - 不同帧率需要不同的输入时钟频率
   - 27MHz: 1080p 90fps, 4K 90fps
   - 24MHz: 4K 60fps

3. **散热考虑**: 高帧率运行会增加功耗和发热

4. **兼容性**: 需要确保目标平台的 ISP 和 CIF 能够处理对应的数据率

---

## 参考文档

- `sensor_imx415_mipi.c` - Sigmastar 参考驱动
- `sunnic_IMX415_RegisterSetting_Ver10.0_20230906_No1(4K60FPS).ism`
- `sunnic_IMX415_RegisterSetting_Ver10.0_20231206_No1(4K 90FPS).ism`

---

## 更新历史

- **2026-01-05**: 添加 1080p 90fps、4K 60fps、4K 90fps 模式到 supported_modes 数组
- **2026-01-04**: 添加寄存器配置数组
