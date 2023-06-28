# 说明
## 1. 文件简述
- sfuntmpl.m: MATLAB官方 s-function 模版
  plant.m: 非线性 s-function 模型
  plant_dis.m 非线性 s-function 模型，支持输入干扰项
  SMC.m: 非线性HSMC控制器

- procedure.mlx: 实验公式推导及过程
  param.m: 运行实验所需要的参数

- SIM_linear.slx: 线性系统的LQR与线性HSMC仿真
  SIM_nonlinear_LQR.slx: 非线性系统的LQR仿真
  SIM_nonlinear_LQR_dis.slx: 非线性系统的LQR仿真，支持输入干扰项

- SIM_nonlinear.slx: 非线性系统的非线性HSMC仿真
  SIM_nonlinear_mix.slx: 非线性系统的线性HSMC仿真
  SIM_nonlinear_mix_dis.slx: 非线性系统的线性HSMC仿真，支持输入干扰项

sfunc_test: 该文件夹下包含了LQR，SMC，HSMC的控制器简单测试
- ref.m: SMC测试中的追踪目标 
- ctrl.m: SMC控制器
- plant.m: 质量-弹簧系统模型
- HSMC_test_ctrl.m: HSMC控制器

- parameter.m: 运行测试所需要的参数

- LQR_test.slx: 质量-弹簧模型的LQR仿真
- SMC_test.slx 质量-弹簧模型的SMC仿真
- HSMC_test.slx: 一级倒立摆的HSMC仿真

pic: 该文件夹下包含了实验仿真结果的导出图片与部分论文中用到的图片

> 注：实验使用的MATLAB版本为2023a，为保证兼容性, v2016文件夹内包含了导出的2016版本的SIMUKLINK模型文件。

---
## 2. 实验步骤
### 2.1 控制器测试实验
1. 在MATLAB中切换目录至 sfunc_test
2. 打开parameter.m并运行
3. 打开 LQR_tes.slx 进行质量-弹线性簧模型的LQR仿真
4. 打开 SMC_test.slx 进行质量-非线性弹簧模型的SMC仿真
5. 打开 HSMC_test.slx 进行一级倒立摆的HSMC仿真

### 2.2 基于二级倒立摆的两轮自平衡机器人的控制实验
1. 在MATLAB中切换目录至外层文件夹
2. 打开param.m并运行 （可根据需求更改 Disturbance栏内的干扰细节）
3. 打开 SIM_linear.slx 进行线性系统的LQR与线性HSMC仿真
4. 打开 SIM_nonlinear_LQR.slx 进行非线性系统的LQR仿真，无干扰
5. 打开 SIM_nonlinear_LQR_dis.slx 进行非线性系统的LQR仿真，伴随输入干扰项
6. 打开 SIM_nonlinear.slx 进行非线性系统的非线性HSMC仿真，无干扰
7. 打开 SIM_nonlinear_mix.slx 进行非线性系统的线性HSMC仿真，无干扰
8. SIM_nonlinear_mix_dis.slx 进行非线性系统的线性HSMC仿真，伴随输入干扰项



