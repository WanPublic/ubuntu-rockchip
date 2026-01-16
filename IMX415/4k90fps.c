/*
 * IMX415-AAQR All-pixel scan 
 * CSI-2_4lane 
 * 37.125MHz INCK (Input Clock) - Matches RK3588 CLK_MIPI_CAMARAOUT_M3
 * AD:10bit 
 * Output:10bit 
 * 2376Mbps/lane
 * Master Mode 
 * 90fps 
 * 1H period: 5.0us (366 clocks)
 * VMAX: 2250 lines (0x8CA)
 * Based on: IMX415-AAQR-C.PDF Register Setting Table (P54-55, P77-78)
 * 2026-01-16: Initial version with 37.125MHz INCK configuration
 */
static __maybe_unused const struct regval imx415_linear_10bit_4k90fps_2376M_regs[] = {
	// ===== 基本控制寄存器 =====
	{0x3002, 0x00},	// XMSTA - Master mode start register
	                // PDF: Not in table, standard initialization
	
	{0x3008, 0x7F}, // BCWAIT_TIME[7:0] - Black clamp wait time, depends on INCK
	                // PDF P77: 37.125MHz=07Fh (27MHz=05Dh, 74.25MHz=0FFh)
	                // *** 使用37.125MHz配置 0x7F ***
	
	{0x300A, 0x5B},	// CPWAIT_TIME[7:0] - Charge pump wait time, depends on INCK
	                // PDF P77: 37.125MHz=05Bh (27MHz=042h, 74.25MHz=0B6h)
	                // *** 使用37.125MHz配置 0x5B ***
	
	// ===== 图像模式设置 =====
	{0x301C, 0x00},	// WINMODE[3:0] - Window mode setting
	                // PDF P54: 0h = All-pixel mode (全像素模式)
	
	{0x3022, 0x00}, // ADDMODE[1:0] - Binning mode setting
	                // PDF P54: 0h = All-pixel mode (全像素模式，无binning)
	
	// ===== 帧时序参数 =====
	{0x3024, 0xCA}, // VMAX[7:0] - Vertical max period (frame length in lines)
	{0x3025, 0x08}, // VMAX[15:8]
	{0x3026, 0x00}, // VMAX[19:16]
	                // PDF P54: 90fps列 VMAX=8CAh (2250 lines)
	                // 完整值: 0x08CA = 2250 lines
	
	{0x3028, 0x6E}, // HMAX[7:0] - Horizontal max period (line length in clocks)
	{0x3029, 0x01}, // HMAX[15:8]
	                // PDF P54: 90fps列 HMAX=16Eh (366 clocks = 5.0μs @ pixel clock)
	                // 完整值: 0x016E = 366 clocks
	
	{0x3030, 0x00},	// Bit[0]=HREVERSE (H readout direction), Bit[1]=VREVERSE (V direction)
	                // PDF P54: HREVERSE=0 (Normal), VREVERSE=0 (Normal)
	                // 0h: 两个方向都正常
	
	// ===== 数据位宽设置 =====
	{0x3031, 0x00},	// ADBIT[1:0] - AD conversion bit depth
	                // PDF P54: 90fps列 0h = 10bit AD conversion
	                // 0: 10bit, 1: 12bit (11bit + digital dither)
	
	{0x3032, 0x00},	// MDBIT[0] - Output bit depth setting
	                // PDF P54: 90fps列 0h = 10bit output
	                // 0: 10bit output, 1: 12bit output
	
	{0x3033, 0x00},	// SYS_MODE[3:0] - Output interface mode (MIPI data rate)
	                // PDF P54: 90fps列 0h = 2376Mbps/lane
	                // 0:2376Mbps, 2:2079Mbps, 4:1782Mbps, 5:891Mbps, 7:594Mbps
	
	// ===== 曝光/增益 =====
	{0x3050, 0x08},	// SHR0[7:0] - Shutter (exposure) setting, lower byte
	                // PDF: Not specified in table, typical starting value
	
	{0x3090, 0x14},	// GAIN_PCG_0 - Analog gain setting
	                // PDF: Not specified in table, typical starting value (0x14 = ~1.25x gain)
	
	// ===== PLL/时钟配置 (INCK Selection) =====
	{0x3115, 0x00}, // INCKSEL1[7:0] - PLL frequency setting 1
	                // PDF P54: All modes 00h
	
	{0x3116, 0x24},	// INCKSEL2[7:0] - PLL frequency setting 2
	                // PDF P77: 37.125MHz=24h (27MHz=23h, 74.25MHz=28h)
	                // *** 使用37.125MHz配置 0x24 ***
	
	{0x3118, 0x00}, // INCKSEL3[7:0] - PLL frequency setting 3 (low byte)
	{0x3119, 0x01}, // INCKSEL3[10:8] - PLL frequency setting 3 (high bits)
	                // PDF P77: 37.125MHz=100h (27MHz=108h, 74.25MHz=100h)
	                // *** 使用37.125MHz配置 0x100 ***
	
	{0x311A, 0xE0}, // INCKSEL4[7:0] - PLL frequency setting 4 (low byte)
	{0x311B, 0x00}, // INCKSEL4[10:8] - PLL frequency setting 4 (high bits)
	                // PDF P54: Initial=0E0h, 27MHz=0E7h, 37.125MHz/74.25MHz=0E0h
	                // 使用初始值0x0E0
	
	{0x311E, 0x24},	// INCKSEL5[7:0] - PLL frequency setting 5
	                // PDF P77: 37.125MHz=24h (27MHz=23h, 74.25MHz=28h)
	                // *** 使用37.125MHz配置 0x24 ***
	
	// ===== 0x3200-0x3BFF 范围寄存器 =====
	// PDF P54: "Refer to Register Map" - 这些寄存器值与4k60fps.c相同
	{0x32D4, 0x21},	// Undocumented register from register map
	{0x32EC, 0xA1},	// Undocumented register from register map
	
	{0x344C, 0x2B}, // Undocumented registers from register map
	{0x344D, 0x01},
	{0x344E, 0xED},
	{0x344F, 0x01},
	{0x3450, 0xF6},
	{0x3451, 0x02},
	{0x3452, 0x7F},
	{0x3453, 0x03},
	
	{0x358A, 0x04},	// Undocumented register from register map
	{0x35A1, 0x02},	// Undocumented register from register map
	
	{0x35EC, 0x27}, // Undocumented registers from register map
	{0x35EE, 0x8D},
	{0x35F0, 0x8D},
	{0x35F2, 0x29},
	
	{0x36BC, 0x0C},	// Undocumented registers from register map
	{0x36CC, 0x53},
	{0x36CD, 0x00},
	{0x36CE, 0x3C},
	{0x36D0, 0x8C},
	{0x36D1, 0x00},
	{0x36D2, 0x71},
	{0x36D4, 0x3C},
	{0x36D6, 0x53},
	{0x36D7, 0x00},
	{0x36D8, 0x71},
	{0x36DA, 0x8C},
	{0x36DB, 0x00},
	
	{0x3701, 0x00},	// ADBIT1[7:0] - AD conversion bit setting (additional)
	                // Complements ADBIT register
	
	{0x3720, 0x00}, // Undocumented registers from register map
	{0x3724, 0x02},
	{0x3726, 0x02},
	{0x3732, 0x02},
	{0x3734, 0x03},
	{0x3736, 0x03},
	{0x3742, 0x03},
	
	{0x3862, 0xE0}, // Undocumented registers from register map
	{0x38CC, 0x30},
	{0x38CD, 0x2F},
	
	{0x395C, 0x0C}, // Undocumented register from register map
	
	{0x39A4, 0x07}, // Undocumented registers from register map
	{0x39A8, 0x32},
	{0x39AA, 0x32},
	{0x39AC, 0x32},
	{0x39AE, 0x32},
	{0x39B0, 0x32},
	{0x39B2, 0x2F},
	{0x39B4, 0x2D},
	{0x39B6, 0x28},
	{0x39B8, 0x30},
	{0x39BA, 0x30},
	{0x39BC, 0x30},
	{0x39BE, 0x30},
	{0x39C0, 0x30},
	{0x39C2, 0x2E},
	{0x39C4, 0x2B},
	{0x39C6, 0x25},
	
	{0x3A42, 0xD1}, // Undocumented registers from register map
	{0x3A4C, 0x77},
	{0x3AE0, 0x02},
	{0x3AEC, 0x0C},
	
	{0x3B00, 0x2E}, // Undocumented registers from register map
	{0x3B06, 0x29},
	{0x3B98, 0x25},
	{0x3B99, 0x21},
	{0x3B9B, 0x13},
	{0x3B9C, 0x13},
	{0x3B9D, 0x13},
	{0x3B9E, 0x13},
	
	{0x3BA1, 0x00}, // Undocumented registers from register map
	{0x3BA2, 0x06},
	{0x3BA3, 0x0B},
	{0x3BA4, 0x10},
	{0x3BA5, 0x14},
	{0x3BA6, 0x18},
	{0x3BA7, 0x1A},
	{0x3BA8, 0x1A},
	{0x3BA9, 0x1A},
	
	{0x3BAC, 0xED}, // Undocumented registers from register map
	{0x3BAD, 0x01},
	{0x3BAE, 0xF6},
	{0x3BAF, 0x02},
	{0x3BB0, 0xA2},
	{0x3BB1, 0x03},
	{0x3BB2, 0xE0},
	{0x3BB3, 0x03},
	{0x3BB4, 0xE0},
	{0x3BB5, 0x03},
	{0x3BB6, 0xE0},
	{0x3BB7, 0x03},
	{0x3BB8, 0xE0},
	{0x3BBA, 0xE0},
	{0x3BBC, 0xDA},
	{0x3BBE, 0x88},
	{0x3BC0, 0x44},
	{0x3BC2, 0x7B},
	{0x3BC4, 0xA2},
	{0x3BC8, 0xBD},
	{0x3BCA, 0xBD},
	
	// ===== MIPI CSI-2 接口配置 =====
	{0x4001, 0x03}, // LANEMODE[2:0] - Number of data lanes
	                // PDF P54: 3h = 4-lane mode
	
	{0x4004, 0x48},	// TXCLCKES_FREQ[7:0] - Escape mode clock frequency (low byte)
	{0x4005, 0x09},	// TXCLCKES_FREQ[15:8] - Escape mode clock frequency (high byte)
	                // PDF P77: 37.125MHz=0948h (27MHz=06C0h, 74.25MHz=1290h)
	                // *** 使用37.125MHz配置 0x0948 (2376 decimal) ***
	
	{0x400C, 0x01}, // INCKSEL6[0] - Input clock setting 6
	                // PDF P54: All modes 1h
	
	// ===== MIPI D-PHY 时序参数 (Global Timing) =====
	// 以下所有时序参数来自PDF P54-55，90fps (2376Mbps) 列
	
	{0x4018, 0xE7}, // TCLKPOST[7:0] - Clock post time (low byte)
	{0x4019, 0x00}, // TCLKPOST[15:8] - Clock post time (high byte)
	                // PDF P55: 90fps列 00E7h
	                // MIPI时序: Clock lane准备进入LP mode前保持HS的时间
	
	{0x401A, 0x8F}, // TCLKPREPARE[7:0] - Clock prepare time (low byte)
	{0x401B, 0x00}, // TCLKPREPARE[15:8] - Clock prepare time (high byte)
	                // PDF P55: 90fps列 008Fh
	                // MIPI时序: Clock lane进入HS mode前的准备时间
	
	{0x401C, 0x8F}, // TCLKTRAIL[7:0] - Clock trail time (low byte)
	{0x401D, 0x00}, // TCLKTRAIL[15:8] - Clock trail time (high byte)
	                // PDF P55: 90fps列 008Fh
	                // MIPI时序: Clock lane离开HS mode的拖尾时间
	
	{0x401E, 0x7F}, // TCLKZERO[7:0] - Clock zero time (low byte)
	{0x401F, 0x02}, // TCLKZERO[15:8] - Clock zero time (high byte)
	                // PDF P55: 90fps列 027Fh (639 decimal)
	                // MIPI时序: Clock lane HS-0状态的持续时间
	
	{0x4020, 0x97}, // THSPREPARE[7:0] - HS prepare time (low byte)
	{0x4021, 0x00}, // THSPREPARE[15:8] - HS prepare time (high byte)
	                // PDF P55: 90fps列 0097h (151 decimal)
	                // MIPI时序: Data lane进入HS mode前的准备时间
	
	{0x4022, 0x0F}, // THSZERO[7:0] - HS zero time (low byte)
	{0x4023, 0x01}, // THSZERO[15:8] - HS zero time (high byte)
	                // PDF P55: 90fps列 010Fh (271 decimal)
	                // MIPI时序: Data lane HS-0状态的持续时间
	
	{0x4024, 0x97}, // THSTRAIL[7:0] - HS trail time (low byte)
	{0x4025, 0x00}, // THSTRAIL[15:8] - HS trail time (high byte)
	                // PDF P55: 90fps列 0097h (151 decimal)
	                // MIPI时序: Data lane离开HS mode的拖尾时间
	
	{0x4026, 0xF7}, // THSEXIT[7:0] - HS exit time (low byte)
	{0x4027, 0x00}, // THSEXIT[15:8] - HS exit time (high byte)
	                // PDF P55: 90fps列 00F7h (247 decimal)
	                // MIPI时序: Data lane从HS mode退出到LP mode的时间
	
	{0x4028, 0x7F}, // TLPX[7:0] - LP time (low byte)
	{0x4029, 0x00}, // TLPX[15:8] - LP time (high byte)
	                // PDF P55: 90fps列 007Fh (127 decimal)
	                // MIPI时序: LP状态的传输时间单位
	
	{0x4074, 0x00}, // INCKSEL7[2:0] - Input clock setting 7
	                // PDF P54: All modes 0h
	
	{REG_NULL, 0x00}, // 寄存器列表结束标记
};
