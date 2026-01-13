---
trigger: always_on
---

1. 每次对话 use context7
2. 本机为编译机器，ubuntu 24.04  X86架构。账号wanpublic，密码和sudo密码都为wanpublic2025
3. 编译成果安装目标机器10.5.0.202，账号密码和本机一样，orange pi 5 plus ubuntu24.04
4. 只编译orange pi 5 plus，ubuntu 24.04 noble
5. 不要使用脚本，直接修改文件代码，直接终端操作
6. 每次编译新的分支都要修改noble.sh
7. 编译前提交commit到分支 并使用脚本编译 sudo ./build.sh --board=orangepi-5-plus --suite=noble --kernel-only
8. 使用中文反馈
9. 工具层分支一直在orange-pi-5-plus-imx415-90fps下操作
10. 内核层分支根据不同的分辨率和帧率创建不同的分支