import cocotb
from cocotb.clock import Clock

# from cocotb.triggers import Timer, RisingEdge, FallingEdge
from cocotb.triggers import Timer
from cocotb.handle import LogicArray
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


# 调试模式标志 - 可以通过环境变量设置
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
            cocotb.log.error(f"断言失败 (DEBUG MODE): {message}")
        else:
            # 普通模式下，中断程序
            raise AssertionError(message)


class TB:
    """testbench 类"""

    def __init__(self, dut):
        # 调试模式标志 - 可以通过环境变量设置
        self.dut = dut
        cocotb.start_soon(self.timeout())

    async def timeout(self, timeout_time=200000):
        """超时函数"""
        await Timer(timeout_time, "ns")
        raise TimeoutError("Timeout")

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
        await Timer(1, "ns")  # 错开时钟沿


@cocotb.test()
async def test_ccb_ECAP(dut):
    """测试边沿检测功能"""
    cocotb.log.info("Starting edge detection test")

    tb = TB(dut)
    await tb.setup_clock()

    # 初始化输入为低电平
    dut.in1_i.value = 0
    # dut.in2_i.value = 0
    await tb.reset_dut()

    await tb.wait_clocks(8)

    # 检测第一个上升沿
    cocotb.log.info("Testing rising edge detection")
    # 检查是否检测到上升沿事件
    dut.in1_i.value = 1
    await tb.wait_clocks(1)  # 等待边沿检测稳定
    expect = LogicArray(0b0100, 4)
    dutout = dut.event_ccb.value
    custom_assert(
        expect == dutout,
        f"1st Rising edge event should be detected, exp:{expect},dut:{dutout}",
    )
    await tb.wait_clocks(8)  # 等待寄存器写入
    ## 无法访问, 无法检查rdata
    # dutout = dut.rdata1_i.value
    # expect = LogicArray(11, 32)  # 2+8+1
    # custom_assert(
    #     expect == dutout,
    #     f"1st Rising edge counter(C1) should be detected, exp:{expect},dut:{dutout}",
    # )
    # dutout = dut.u_ccb.r1_reg.value
    # custom_assert(
    #     expect == dutout,
    #     f"1st Rising edge counter(R1) should be record, exp:{expect},dut:{dutout}",
    # )
    await tb.wait_clocks(11)

    # 检测第一个下降沿
    cocotb.log.info("Testing falling edge detection")
    # 检查是否检测到上升沿事件
    dut.in1_i.value = 0
    await tb.wait_clocks(1)  # 等待边沿检测稳定
    expect = LogicArray(0b1000, 4)
    dutout = dut.event_ccb.value
    custom_assert(
        expect == dutout,
        f"1st Falling edge event should be detected, exp:{expect},dut:{dutout}",
    )
    await tb.wait_clocks(8)  # 等待寄存器写入
    ## 无法访问, 无法检查rdata
    # dutout = dut.rdata0_i.value
    # expect0 = LogicArray(19, 32)  # 8+11
    # custom_assert(
    #     expect0 == dutout,
    #     f"1st Falling edge counter(C0) should be record, exp:{expect0},dut:{dutout}",
    # )
    # dutout = dut.u_ccb.r0_reg.value
    # custom_assert(
    #     expect0 == dutout,
    #     f"1st Falling edge counter(R0) should be record, exp:{expect0},dut:{dutout}",
    # )
    await tb.wait_clocks(32)

    # 检测第二个上升沿
    cocotb.log.info("Testing rising edge detection")
    # 检查是否检测到上升沿事件
    dut.in1_i.value = 1
    await tb.wait_clocks(1)  # 等待边沿检测稳定
    expect = LogicArray(0b0100, 4)
    dutout = dut.event_ccb.value
    custom_assert(
        expect == dutout,
        f"2st Rising edge event should be detected, exp:{expect},dut:{dutout}",
    )
    await tb.wait_clocks(8)  # 等待寄存器写入
    ## 无法访问, 无法检查rdata
    # dutout = dut.rdata1_i.value
    # expect1 = LogicArray(40, 32)  # 8+32
    # custom_assert(
    #     expect1 == dutout,
    #     f"2st Rising edge counter(C1) should be record, exp:{expect1},dut:{dutout}",
    # )
    # dutout = dut.u_ccb.r1_reg.value
    # custom_assert(
    #     expect1 == dutout,
    #     f"2st Rising edge counter(R1) should be record, exp:{expect1},dut:{dutout}",
    # )
    await tb.wait_clocks(27)

    # 检测第二个下降沿
    cocotb.log.info("Testing falling edge detection")
    # 检查是否检测到上升沿事件
    dut.in1_i.value = 0
    await tb.wait_clocks(1)  # 等待边沿检测稳定
    expect = LogicArray(0b0010, 4)
    dutout = dut.event_ccb.value
    custom_assert(
        expect == dutout,
        f"2st Falling edge event should be detected, exp:{expect},dut:{dutout}",
    )
    await tb.wait_clocks(8)  # 等待寄存器写入
    ## 无法访问, 无法检查rdata
    # dutout = dut.rdata0_i.value
    # expect2 = LogicArray(35, 32)  # 8+27
    # custom_assert(
    #     expect2 == dutout,
    #     f"2st Falling edge counter(C2) should be record, exp:{expect2},dut:{dutout}",
    # )
    # dutout = dut.u_ccb.r2_reg.value
    # custom_assert(
    #     expect2 == dutout,
    #     f"2st Falling edge counter(R2) should be record, exp:{expect2},dut:{dutout}",
    # )
    await tb.wait_clocks(10)

    # custom_assert(
    #     expect0 == dut.u_ccb.push_fifo_mem[0].value,
    #     f"fifo0 should be record, exp:{expect0},dut:{dut.u_ccb.push_fifo_mem[0].value}",
    # )
    # custom_assert(
    #     expect1 == dut.u_ccb.push_fifo_mem[1].value,
    #     f"fifo1 should be record, exp:{expect1},dut:{dut.u_ccb.push_fifo_mem[1].value}",
    # )
    # custom_assert(
    #     expect2 == dut.u_ccb.push_fifo_mem[2].value,
    #     f"fifo2 should be record, exp:{expect2},dut:{dut.u_ccb.push_fifo_mem[2].value}",
    # )
    # expect3 = LogicArray(0, 32)
    # custom_assert(
    #     expect3 == dut.u_ccb.push_fifo_mem[3].value,
    #     f"fifo3 should be record, exp:{expect3},dut:{dut.u_ccb.push_fifo_mem[3].value}",
    # )

    await tb.wait_clocks(2)
    expect = LogicArray(0x3E, 6)  # fifo full interrupt
    # custom_assert(
    #     expect == dut.u_ccb.interupt_r.value,
    #     f"interupt_r should be generated, exp:{expect},dut:{dut.u_ccb.interupt_r.value}",
    # )
    await tb.wait_clocks(1)
    expect = LogicArray(0x1, 6)  # user defined interrupt
    # custom_assert(
    #     expect == dut.u_ccb.interupt_r.value,
    #     f"interupt_r should be generated, exp:{expect},dut:{dut.u_ccb.interupt_r.value}",
    # )


# 测试运行器入口点
if __name__ == "__main__":
    print("CocoTB testbench for c2k_ECAP_pcnt module")
    print("Run with: cocotb")
