---
trigger: always_on
---

1. 每次对话 use context7
2. 本机为编译机器，ubuntu 24.04  X86架构。账号wanpublic，密码和sudo密码都为wanpublic2025
3. 编译成果安装目标机器10.5.0.127，账号密码和本机一样，rock 5b plus ubuntu24.04
4. 只编译rock 5b plus，ubuntu 24.04 noble
5. 不要使用脚本，直接修改文件代码，直接终端操作
6. 每次编译新的分支都要修改noble.sh
7. 编译前提交commit到分支 并使用脚本编译 sudo ./build.sh --board=rock-5b-plus --suite=noble --kernel-only
8. 使用中文反馈，使用中文展示thought
9. 工具层分支一直在rock-5b-plus-imx415-90fps下操作
10. 代码修改都要加入注释，老的注释要读取并修改，用注释记录修改历史
11. 内核层源码https://github.com/WanPublic/linux-rockchip/，根据需要再切换分支
12. 每次编译完成后执行以下步骤：1.安装到目标机器。2.重启目标机器（等待30秒）。3.测试摄像头是否正确启动。4.如果摄像头正确启动则测试实际帧率。5.如果摄像头正确启动则告知isp处理链路和预览地址。6.在display：0上预览视频