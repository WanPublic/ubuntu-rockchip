# IMX415 4K 90fps High Performance (Unite Mode) Plan

## 目标
配置 RK3588 的 Dual ISP (Unite Mode) 以支持 IMX415 传感器的单摄高性能模式 (4K 90fps)。
Unite Mode 允许两个 ISP 核心合并处理单一高带宽视频流，解决单核 ISP 在高帧率下的性能瓶颈。

## 当前状态
- **Sensor**: IMX415 (连接在 `csi2_dphy0` / `mipi2_csi2`)
- **ISP 配置**: 目前使用的是 `rkisp0_vir1` (单核模式)，仅启用了 `rkisp0`。
- **瓶颈**: 4K 90fps 数据率极高，单 ISP 可能无法实时处理或丢帧，且无法充分利用 RK3588 性能。

## 修改计划

我们将修改设备树文件 `arch/arm64/boot/dts/rockchip/rk3588-orangepi-5-plus-camera1.dtsi`。

### 1. 启用第二个 ISP 核心 (Physical Nodes)
RK3588 有两个物理 ISP 核心 (`rkisp0` 和 `rkisp1`)。Unite 模式需要两者同时工作（或由 Unite 封装管理硬件）。我们需要确保 `rkisp1` 被启用。

```dts
// 在文件头部或适当位置添加
&rkisp1 {
    status = "okay";
};

&isp1_mmu {
    status = "okay";
};
```

### 2. 启用 Unite 虚拟节点
`rkisp_unite` 是负责管理双核协同工作的虚拟节点。

```dts
&rkisp_unite {
    status = "okay";
};

&rkisp_unite_mmu {
    status = "okay";
};
```

### 3. 配置 ISP 虚拟节点 (Virtual Node)
我们将切换主虚拟节点配置，通常 Unite 模式建议使用 `rkisp0_vir0`（或配置当前的 `rkisp0_vir1` 指向 Unite 硬件）。为了符合标准做法，建议使用 `rkisp0_vir0` 并声明 `rockchip,hw` 属性。

需要禁用原本的单核配置（如果存在冲突），并建立新的连接。

```dts
// 禁用单核虚拟节点（可选，或者重用它）
&rkisp0_vir1 {
    status = "disabled"; 
};

// 启用并配置 Unite 节点
&rkisp0_vir0 {
    status = "okay";
    rockchip,hw = <&rkisp_unite>; // 关键：指定由 Unite 硬件驱动
    
    port {
        #address-cells = <1>;
        #size-cells = <0>;
        
        // 接收来自 VICAP (rkcif) 的数据
        isp0_in_vir0: endpoint@0 {
            reg = <0>;
            remote-endpoint = <&mipi2_lvds_sditf>;
        };
    };
};
```

### 4. 更新 VICAP (RKCIF) 路由
将 VICAP 的输出重定向到新的 ISP 虚拟节点 endpoint。

```dts
&rkcif_mipi_lvds2_sditf {
    status = "okay";
    port {
        mipi2_lvds_sditf: endpoint {
            // 修改这里指向新的 ISP 节点
            remote-endpoint = <&isp0_in_vir0>;
        };
    };
};
```

## 验证步骤
1. 编译并烧录新内核。
2. 启动后检查 Media Topology:
   ```bash
   media-ctl -p -d /dev/media0
   ```
   应能看到 `rkisp_unite` 相关实体或拓扑结构变化。
3. 抓图测试:
   ```bash
   v4l2-ctl -d /dev/video11 --set-fmt-video=width=3840,height=2160,pixelformat=NV12 --stream-mmap --stream-count=100
   ```
