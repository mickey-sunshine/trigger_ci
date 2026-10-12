from os import wait
import cocotb
from cocotb.clock import Clock

from cocotb.triggers import Timer

# from cocotb.triggers import RisingEdge, FallingEdge
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
CLOCK_FREQ = 100000000
CLOCK_PERIOD = 1000000000 / CLOCK_FREQ


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

    async def timeout(self, timeout_time=100000):
        """超时函数"""
        await Timer(timeout_time, "ns")
        raise TimeoutError("Timeout")

    async def reset_dut(self):
        """复位DUT"""
        self.dut.rst_ni.value = 0
        await Timer(CLOCK_PERIOD * 2, "ns")
        self.dut.rst_ni.value = 1
        # await Timer(CLOCK_PERIOD * 2, "ns")
        cocotb.log.info("DUT reset completed")

    async def setup_clock(self):
        """设置时钟信号"""
        clock = Clock(self.dut.clk_i, CLOCK_PERIOD, "ns")  # 100MHz时钟
        cocotb.start_soon(clock.start())
        await Timer(1, "ns")  # 让时钟稳定

    async def wait_clocks(self, num_clocks):
        """等待指定数量的时钟周期"""
        for _ in range(num_clocks):
            await RisingEdge(self.dut.clk_i)
        await Timer(1, "ns")  # 错开时钟沿


async def trigger_event(tb, event_name):
    tb.dut.event_trig_i.value = 1 << event_name
    await tb.wait_clocks(1)
    tb.dut.event_trig_i.value = 0


@cocotb.test()
async def test_cnt32_add_sub_shift(dut):
    cocotb.log.info("Starting cnt32 test...")

    tb = TB(dut)

    dut.clk_i.value = 0
    dut.rst_ni.value = 0
    dut.enable_i.value = 0
    dut.event_trig_i.value = 0
    # Start clock and reset
    await tb.setup_clock()
    # test1 add
    await tb.reset_dut()
    dut.enable_i.value = "0001"
    await trigger_event(tb, 0)
    await tb.wait_clocks(10)
    await trigger_event(tb, 0)
    await tb.wait_clocks(6)
    await trigger_event(tb, 0)
    await tb.wait_clocks(20)
    # test2 sub
    await tb.reset_dut()
    dut.enable_i.value = "0010"
    await tb.wait_clocks(30)
    await trigger_event(tb, 1)
    await tb.wait_clocks(20)
    await trigger_event(tb, 1)
    await tb.wait_clocks(50)
    # test3 shift right
    await tb.reset_dut()
    dut.enable_i.value = "0100"
    await tb.wait_clocks(80)
    await trigger_event(tb, 2)
    await tb.wait_clocks(10)
    await trigger_event(tb, 2)
    await tb.wait_clocks(100)
    # test3 shift left
    await tb.reset_dut()
    dut.enable_i.value = "1000"
    await tb.wait_clocks(10)
    await trigger_event(tb, 3)
    await tb.wait_clocks(10)
    await trigger_event(tb, 3)
    await tb.wait_clocks(100)
