# IMX415 驱动修改总结 - 60fps/90fps 支持

## 修改概述

本次修改为 IMX415 驱动添加了 4K@60fps 和 4K@90fps 的支持，基于 Sunnic 官方寄存器配置文档。

---

## 修改前后对照

### 1. MIPI 频率定义 (第 65-70 行范围)

**修改前:**
```c
#define MIPI_FREQ_1188M			1188000000
#define MIPI_FREQ_891M			891000000
#define MIPI_FREQ_446M			446000000
#define MIPI_FREQ_743M			743000000
#define MIPI_FREQ_297M			297000000
```

**修改后:**
```c
#define MIPI_FREQ_2376M			2376000000LL  // 新增: 90fps 需要
#define MIPI_FREQ_1440M			1440000000    // 新增: 60fps 需要
#define MIPI_FREQ_1188M			1188000000
#define MIPI_FREQ_891M			891000000
#define MIPI_FREQ_446M			446000000
#define MIPI_FREQ_743M			743000000
#define MIPI_FREQ_297M			297000000
```

---

### 2. 最大像素率 (第 74 行)

**修改前:**
```c
#define IMX415_MAX_PIXEL_RATE		(MIPI_FREQ_891M / 10 * 2 * IMX415_4LANES)
```

**修改后:**
```c
#define IMX415_MAX_PIXEL_RATE		(MIPI_FREQ_2376M / 10 * 2 * IMX415_4LANES)
```

**说明:** 更新最大像素率以支持 90fps 的高速数据传输。

---

### 3. 时钟频率定义 (第 77-79 行)

**修改前:**
```c
#define IMX415_XVCLK_FREQ_37M		37125000
#define IMX415_XVCLK_FREQ_27M		27000000
```

**修改后:**
```c
#define IMX415_XVCLK_FREQ_37M		37125000
#define IMX415_XVCLK_FREQ_27M		27000000
#define IMX415_XVCLK_FREQ_24M		24000000  // 新增: 60fps 需要 24MHz 时钟
```

---

### 4. 新增寄存器配置数组 (在约 686 行后插入)

新增以下 4 个寄存器配置数组:

#### 4.1 `imx415_global_10bit_3864x2192_60fps_regs[]`
- 60fps 全局寄存器配置
- 输入时钟: 24MHz
- MIPI 速率: 1440Mbps
- 关键寄存器:
  - `0x3008 = 0x54` (BCWAIT_TIME)
  - `0x3118 = 0xB4` (INCKSEL3)
  - `0x311A = 0xFC` (INCKSEL4)

#### 4.2 `imx415_linear_10bit_3864x2192_60fps_1440M_regs[]`
- 60fps 模式寄存器配置
- 关键寄存器:
  - `0x3024 = 0xCB` (VMAX)
  - `0x3028 = 0x15` (HMAX)
  - `0x3033 = 0x08` (SYS_MODE)

#### 4.3 `imx415_global_10bit_3864x2192_90fps_regs[]`
- 90fps 全局寄存器配置
- 输入时钟: 27MHz
- MIPI 速率: 2376Mbps
- 关键寄存器:
  - `0x3008 = 0x5D` (BCWAIT_TIME)
  - `0x3118 = 0x08, 0x3119 = 0x01` (INCKSEL3 = 0x108)
  - `0x311A = 0xE7` (INCKSEL4)

#### 4.4 `imx415_linear_10bit_3864x2192_90fps_2376M_regs[]`
- 90fps 模式寄存器配置
- 关键寄存器:
  - `0x3024 = 0xCE` (VMAX)
  - `0x3028 = 0x6E, 0x3029 = 0x01` (HMAX = 0x016E)
  - `0x3033 = 0x00` (SYS_MODE - 最高速模式)

---

### 5. link_freq_items 数组 (约第 1665-1673 行)

**修改前:**
```c
static const s64 link_freq_items[] = {
	MIPI_FREQ_297M,
	MIPI_FREQ_446M,
	MIPI_FREQ_743M,
	MIPI_FREQ_891M,
	MIPI_FREQ_1188M,
};
```

**修改后:**
```c
static const s64 link_freq_items[] = {
	MIPI_FREQ_297M,
	MIPI_FREQ_446M,
	MIPI_FREQ_743M,
	MIPI_FREQ_891M,
	MIPI_FREQ_1188M,
	MIPI_FREQ_1440M,	/* index 5: for 60fps mode */
	MIPI_FREQ_2376M,	/* index 6: for 90fps mode */
};
```

---

### 6. supported_modes 数组 (约第 1422 行后插入)

新增两个模式配置:

#### 60fps 模式
```c
{
	.bus_fmt = MEDIA_BUS_FMT_SGBRG10_1X10,
	.width = 3864,
	.height = 2192,
	.max_fps = {
		.numerator = 10000,
		.denominator = 600000,  // 60fps
	},
	.exp_def = 0x08cb - 0x08,
	.hts_def = 0x015 * IMX415_4LANES * 2,
	.vts_def = 0x08cb,
	.global_reg_list = imx415_global_10bit_3864x2192_60fps_regs,
	.reg_list = imx415_linear_10bit_3864x2192_60fps_1440M_regs,
	.hdr_mode = NO_HDR,
	.mipi_freq_idx = 5,	/* MIPI_FREQ_1440M */
	.bpp = 10,
	.vc[PAD0] = 0,
	.xvclk = IMX415_XVCLK_FREQ_24M,
},
```

#### 90fps 模式
```c
{
	.bus_fmt = MEDIA_BUS_FMT_SGBRG10_1X10,
	.width = 3864,
	.height = 2192,
	.max_fps = {
		.numerator = 10000,
		.denominator = 900000,  // 90fps
	},
	.exp_def = 0x08ce - 0x08,
	.hts_def = 0x016e * IMX415_4LANES * 2,
	.vts_def = 0x08ce,
	.global_reg_list = imx415_global_10bit_3864x2192_90fps_regs,
	.reg_list = imx415_linear_10bit_3864x2192_90fps_2376M_regs,
	.hdr_mode = NO_HDR,
	.mipi_freq_idx = 6,	/* MIPI_FREQ_2376M */
	.bpp = 10,
	.vc[PAD0] = 0,
	.xvclk = IMX415_XVCLK_FREQ_27M,
},
```

---

## 技术参数对比

| 参数 | 30fps | 60fps | 90fps |
|------|-------|-------|-------|
| **输入时钟 (XVCLK)** | 37.125 MHz | 24 MHz | 27 MHz |
| **MIPI 数据速率** | 891 Mbps | 1440 Mbps | 2376 Mbps |
| **SYS_MODE (0x3033)** | 0x05 | 0x08 | 0x00 |
| **VMAX** | 0x08CA | 0x08CB | 0x08CE |
| **HMAX** | 0x044C | 0x0015 | 0x016E |
| **INCKSEL3 (0x3118)** | 0xC0 | 0xB4 | 0x0108 |
| **INCKSEL4 (0x311A)** | - | 0xFC | 0xE7 |
| **BCWAIT_TIME (0x3008)** | 0x7F | 0x54 | 0x5D |
| **CPWAIT_TIME (0x300A)** | 0x5B | 0x3B | 0x42 |
| **mipi_freq_idx** | 1 | 5 | 6 |

---

## 设备树配置说明

对于不同帧率，设备树中的时钟配置需要相应调整:

### 30fps (默认)
```dts
clocks = <&cru CLK_MIPI_CAMARAOUT_M3>;  // 37.125MHz
```

### 60fps
需要配置 24MHz 时钟输入

### 90fps
需要配置 27MHz 时钟输入 (设备树已支持)

---

## 注意事项

1. **硬件要求**: 90fps 模式需要 DCPHY 支持 2376Mbps 的高速传输
2. **时钟配置**: 不同帧率需要不同的输入时钟频率
3. **散热考虑**: 高帧率运行会增加功耗和发热
4. **兼容性**: 需要确保目标平台的 ISP 和 CIF 能够处理对应的数据率

---

## 参考文档

- sunnic_IMX415_RegisterSetting_Ver10.0_20230906_No1(4K60FPS).ism
- sunnic_IMX415_RegisterSetting_Ver10.0_20231206_No1(4K 90FPS).ism
