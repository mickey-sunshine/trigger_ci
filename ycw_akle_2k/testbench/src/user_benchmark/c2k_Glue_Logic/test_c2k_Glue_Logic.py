import cocotb
from cocotb.clock import Clock

# from cocotb.triggers import Timer, RisingEdge, FallingEdge, Event
from cocotb.triggers import Timer
from cocotb.triggers import ValueChange


async def RisingEdge(signal):
    await ValueChange(signal)
    # if not rising edge, keep waiting
    while signal.value != 1:
        await ValueChange(signal)


async def FallingEdge(signal):
    await ValueChange(signal)
    # if not falling edge, keep waiting
    while signal.value != 0:
        await ValueChange(signal)


DEBUG_MODE = 0


def custom_assert(condition, message="Assertion failed"):
    """
    自定义断言函数，根据 DEBUG_MODE 行为不同：
    - 调试模式：记录错误但不中断进程
    - 普通模式：抛出异常中断程序
    """
    if not condition:
        if DEBUG_MODE == 1:
            # 调试模式下，只记录错误并继续
            cocotb.log.error(f"Error (DEBUG MODE): {message}")
        else:
            # 普通模式下，中断程序
            raise AssertionError(message)


class TB:
    """testbench 类"""

    def __init__(self, dut):
        # 调试模式标志 - 可以通过环境变量设置

        self.dut = dut

    async def reset_dut(self):
        """复位DUT"""
        self.dut.rst_ni.value = 0
        await Timer(20, "ns")
        self.dut.rst_ni.value = 1
        await Timer(20, "ns")
        cocotb.log.info("DUT reset completed")

    async def setup_clock(self):
        """设置时钟信号"""
        clock = Clock(self.dut.clk_i, 10, "ns")  # 100MHz时钟
        cocotb.start_soon(clock.start())
        await Timer(1, "ns")  # 让时钟稳定

    async def wait_clocks(self, num_clocks):
        """等待指定数量的时钟周期"""
        for _ in range(num_clocks):
            await RisingEdge(self.dut.clk_i)


async def in1_gen(dut):
    """输入数据生成器"""
    while True:
        for i in range(20):
            await RisingEdge(dut.clk_i)
        dut.in1_i.value = not dut.in1_i.value


async def in3_gen(dut):
    """输入数据生成器"""
    while True:
        for i in range(30):
            await RisingEdge(dut.clk_i)
        dut.in3_i.value = not dut.in3_i.value
        for i in range(70):
            await RisingEdge(dut.clk_i)
        dut.in3_i.value = not dut.in3_i.value


cnt = 0


async def monitor_cnt(dut):
    """监控cnt"""
    global cnt
    while True:
        await RisingEdge(dut.in1_i)
        # cocotb.log.info("cnt: %d" % cnt)
        cnt += 1
        if cnt >= 10:
            cnt = 0


async def monitor_out(dut):
    """监控输出信号"""
    global cnt
    last_cnt = 0
    while True:
        await RisingEdge(dut.clk_i)
        await Timer(1, "ns")
        if last_cnt != cnt:
            await RisingEdge(dut.clk_i)
            await Timer(1, "ns")
            if cnt == 0:
                await RisingEdge(dut.clk_i)
                await Timer(1, "ns")
            last_cnt = cnt
        if dut.in3_i.value == 1:
            custom_assert(
                dut.out_o.value == 1,
                f"Output not equal to in3, exp:{dut.out_o.value}, dut:{dut.in3_i.value}",
            )
        elif cnt < 7:
            custom_assert(
                dut.out_o.value == dut.in1_i.value,
                f"Output not equal to in1, exp:{dut.out_o.value}, dut:{dut.in1_i.value}",
            )
        else:
            custom_assert(
                dut.out_o.value == dut.in2_i.value,
                f"Output not equal to in2, exp:{dut.out_o.value}, dut:{dut.in2_i.value}",
            )


@cocotb.test()
async def test_c2k_Glue_Logic(dut):
    """测试数码管输出功能"""
    cocotb.log.info("Starting SEG test")

    tb = TB(dut)

    # 初始化输入为低电平
    dut.clk_i.value = 0
    dut.rst_ni.value = 0
    dut.in1_i.value = 0
    dut.in2_i.value = 0
    dut.in3_i.value = 0

    # 启动时钟, 初始复位
    await tb.setup_clock()
    await tb.reset_dut()
    cocotb.start_soon(monitor_cnt(dut))
    cocotb.start_soon(monitor_out(dut))
    cocotb.start_soon(in1_gen(dut))
    await tb.wait_clocks(1000)
    cocotb.start_soon(in3_gen(dut))
    await tb.wait_clocks(1000)


# 测试运行器入口点
if __name__ == "__main__":
    print("CocoTB testbench for c2k_Glue_Logic module")
    print("Run with: cocotb")
