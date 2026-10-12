import cocotb
from cocotb.clock import Clock
import random

# from cocotb.triggers import Timer, RisingEdge, FallingEdge, Event
from cocotb.triggers import Timer
from cocotb.triggers import ValueChange
from cocotb.types import LogicArray


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
async def test_many_io(dut):
    """测试many_io输出"""
    cocotb.log.info("Starting many_io test")

    tb = TB(dut)

    # 初始化输入为低电平
    dut.clk_i.value = 0
    dut.rst_ni.value = 0
    dut.input1_i.value = 0
    bit_width = len(dut.input1_i.value)
    # 启动时钟, 初始复位
    await tb.setup_clock()
    await tb.reset_dut()

    for _ in range(500):
        await FallingEdge(dut.clk_i)
        exp = random.getrandbits(bit_width)
        dut.input1_i.value = exp
        await tb.wait_clocks(1)
        get = str(dut.output1_o.value)
        exp = format(exp, f"0{bit_width}b")
        custom_assert(
            exp == get,
            f"dut out error! dut:{get} != exp:{exp}",
        )
    dut.rst_ni.value = 0
    for _ in range(500):
        await FallingEdge(dut.clk_i)
        exp = random.getrandbits(bit_width)
        dut.input1_i.value = exp
        await tb.wait_clocks(1)
        get = str(dut.output1_o.value)
        exp = format(0, f"0{bit_width}b")
        custom_assert(
            exp == get,
            f"dut out error! dut:{get} != exp:{exp}",
        )

    await tb.wait_clocks(10)


# 测试运行器入口点
if __name__ == "__main__":
    print("CocoTB testbench for many_io module")
    print("Run with: cocotb")
