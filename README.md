# connect_domain_fpga
图像连通域分析，FPGA实时实现。
理论可实现最多可实现32个连通域查找，目前分辨率在1080p以下（可通过修改Simple_dual_port_RAM.v中的深度增加分辨率）。
仿真文件使用matlab生成二值化图像，再将图像数据转换为XX.dat格式，提供给Vivado的testbench.sv读取。
为方便测试与观察，本次使用10*10大小的图片。
最终测试结果表明，verilog代码可以实现matlab中bwlabel()函数相同的功能。

![Uploading image.png…]()

在一帧视频传输结束后，在毫秒级内就可以完成查找计算连通域中心。
![image](https://github.com/user-attachments/assets/5c54dc03-0f39-4db6-8133-cb589438470e)
