回答你的问题：**通常情况下，你不需要修改 rkaiq 的源码（Service），也不需要为了“Untie 模式”重新去调优一套全新的 IQ 文件（tuning file）。**

但是，你需要根据 Untie（即 Split / 分离）模式的特性，修改**调用 rkaiq 的配置**（比如绑定的实体名称）以及检查 IQ 文件中的**分辨率限制**。

这里的“Untie 模式”通常指相对于 **Unite Mode**（双核合并模式，用于支持 8K 或超高帧率）的普通 **Split Mode**（双核独立模式，用于支持多摄）。

以下是具体分析：

### 1. rkaiq 服务 (Service / Application)

**结论：不需要改源码，但需要改调用参数。**

rkaiq 的核心库（`librkaiq.so`）和守护进程（`rkaiq_3A_server`）本身是通用的，它们会自动探测底层的 ISP 拓扑结构。

* **绑定的 Entity 名称变了**：
* **Unite Mode**：rkaiq 通常绑定到一个名为 `rkisp_unite` 或类似的虚拟实体上，因为它将两个物理 ISP 核视为一个逻辑设备。
* **Untie/Split Mode**：物理 ISP 被拆分，rkaiq 需要分别绑定到具体的物理节点，例如 `rkisp0_vir0` (对应 ISP0) 或 `rkisp1_vir0` (对应 ISP1)。
* **你需要做的**：如果你是自己写 App 调用 rkaiq，在调用 `rkaiq_uapi_sysctl_init` 或 `rkaiq_init` 时，传入的 `sns_entity_name` 或 `isp_entity_name` 需要改成 Split 模式下对应的名称（可以通过 `media-ctl -p` 查看当前的拓扑结构名称）。



### 2. IQ 文件 (Tuning File)

**结论：参数值（算法）不需要改，但 Sensor Info（分辨率上限）可能需要检查。**

IQ 文件（XML/JSON）本质上描述的是**传感器（Sensor）和镜头（Lens）的光学特性**（如噪声分布、色彩矩阵 CCM、镜头阴影 LSC 等）。无论 ISP 是合并工作还是独立工作，你的传感器和镜头并没有变，所以绝大多数画质参数是通用的。

* **不需要改的部分**：
* **AE/AWB/AF 算法参数**：光感特性不变。
* **ISP 模块参数**（Denoise, Sharpen, Gamma）：ISP 硬件逻辑没变，只是吞吐量变了。


* **可能需要微调的部分 (Edge Cases)**：
* **Max Resolution (最大分辨率)**：在 Unite 模式下，ISP 处理能力更强（例如支持 8K）；在 Untie 模式下，单个 ISP 核的处理能力减半（通常单核最大支持 4K 或 5000px 宽）。如果你的 IQ 文件里定义了某些只有 Unite 模式才能跑到的超高分辨率/帧率配置，可能需要调整 `sensor_info` 部分。
* **HDR 模式**：某些复杂的 HDR 模式（如 DOL-HDR 3帧）在 Split 模式下可能会因为带宽或算力受限而表现不同，极少数情况下需要针对 Split 模式单独微调 HDR 的融合参数。



### 3. 底层驱动 (DTS & Kernel)

这是真正需要“修改”的地方（虽然不是 rkaiq 层面的）：

* **Device Tree (DTS)**：必须从 `rockchip,hw = <&rkisp_unite>;` 修改为独立的 ISP 配置，并将 MIPI DPHY 节点配置为 split 模式（如 `csi2_dphy1` 和 `csi2_dphy2` 分开使用）。
* **ISP 资源分配**：确保你的摄像头连接到了正确的物理 DPHY 和 ISP 通道。

### 总结建议

如果你只是从“单摄高性能（Unite）”切换到“双摄独立（Untie/Split）”，**直接复用原有的 IQ 文件即可**。

**操作步骤：**

1. **修改 DTS**：配置 ISP 为 Split 模式。
2. **检查拓扑**：重启板子，运行 `media-ctl -p -d /dev/media0`。
3. **确认名称**：找到你的 Sensor 链接到的 ISP 实体名称（例如 `rkisp0_vir0`）。
4. **启动 rkaiq**：让 rkaiq 指向这个新的实体名称加载原有的 IQ 文件。