import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer

# from cocotb.triggers import Timer, RisingEdge, FallingEdge
from cocotb.triggers import ValueChange
from cocotb.handle import Logic, LogicArray


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


# Debug mode flag - can be set via environment variable
DEBUG_MODE = 0
# FSM 状态定义（测试内使用）
OPENED = "00"  # 已打开
CLOSING = "01"  # 正在关闭
CLOSED = "11"  # 已关闭
OPENING = "10"  # 正在打开


def custom_assert(condition, message="Assertion failed"):
    """
    Custom assert function that behaves differently based on DEBUG_MODE:
    - Debug mode: log error but don't terminate process
    - Normal mode: interrupt program (raise exception)
    """
    if not condition:
        if DEBUG_MODE == 1:
            # In debug mode, just log the error and continue
            cocotb.log.error(f"ASSERTION FAILED (DEBUG MODE): {message}")
        else:
            # In normal mode, interrupt the program
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


async def out0_check(tb, dut):
    while True:
        exp = dut.rst_ni.value
        got = dut.out0_o.value
        custom_assert(str(exp) == str(got), f"out0_o error,exp:{exp},got:{got}")
        await tb.wait_clocks(1)


async def out1_check(tb, dut):
    while True:
        exp = dut.in1_i.value
        got = dut.out1_o.value
        custom_assert(str(exp) == str(got), f"out1_o error,exp:{exp},got:{got}")
        await tb.wait_clocks(1)


async def out2_check(tb, dut):
    while True:
        exp = dut.in1_i.value & dut.rst_ni.value
        got = dut.out2_o.value
        custom_assert(str(exp) == str(got), f"out2_o error,exp:{exp},got:{got}")
        await tb.wait_clocks(1)


async def out3_check(tb, dut):
    cnt = 1
    while True:
        if dut.rst_ni.value == 0:
            cnt = -1
        cnt = (cnt + 1) % 8
        exp = Logic(cnt >> 2) & Logic(str(dut.rst_ni.value))
        # cocotb.log.info(f"cnt:{cnt},exp:{exp},got:{Logic(cnt >> 2)}")
        got = dut.out3_o.value
        custom_assert(str(exp) == str(got), f"out3_o error,exp:{exp},got:{got}")

        await tb.wait_clocks(1)


async def out4_check(tb, dut):
    while True:
        exp = ~(dut.match1.value) & dut.rst_ni.value
        got = dut.out4_o.value
        custom_assert(str(exp) == str(got), f"out4_o error,exp:{exp},got:{got}")
        await tb.wait_clocks(1)


async def out5_check(tb, dut):
    while True:
        exp = ~(dut.match1_d1.value) & dut.rst_ni.value
        got = dut.out5_o.value
        custom_assert(str(exp) == str(got), f"out5_o error,exp:{exp},got:{got}")
        await tb.wait_clocks(1)


async def out6_check(tb, dut):
    while True:
        exp = ~(dut.match1_d1.value) & dut.rst_ni.value & ~(dut.match1.value)
        got = dut.out6_o.value
        custom_assert(str(exp) == str(got), f"out6_o error,exp:{exp},got:{got}")
        await tb.wait_clocks(1)


async def pcnt_check(tb, dut):
    cnt = 2
    while True:
        if dut.out5_o.value == 0:
            cnt = -1
            if dut.rst_ni.value == 0:
                cnt = cnt + 1
        # cocotb.log.info(f"cnt:{cnt}")
        if cnt == 5:
            exp = 1
            got = dut.match0.value
            custom_assert(str(exp) == str(got), f"match0 error,exp:{exp},got:{got}")
        if cnt == 10:
            exp = 1
            got = dut.match1.value
            custom_assert(str(exp) == str(got), f"match1 error,exp:{exp},got:{got}")
        await tb.wait_clocks(1)
        cnt = cnt + 1


async def gen_inputs(tb, dut):
    while True:
        dut.in1_i.value = random.randint(0, 1)
        await tb.wait_clocks(1)


@cocotb.test()
async def test_local_reset_gen_test(dut):
    """
    Cocotb 测试用例：验证 local_reset_gen_test 模块产生各种可能的复位信号的正确性
    """
    tb = TB(dut)
    # 复位信号
    dut.clk_i.value = 0
    dut.rst_ni.value = 0
    dut.in1_i.value = 0

    await tb.setup_clock()
    await tb.reset_dut()
    # 让模块稳定几个周期

    cocotb.start_soon(gen_inputs(tb, dut))
    cocotb.start_soon(out0_check(tb, dut))
    cocotb.start_soon(out1_check(tb, dut))
    cocotb.start_soon(out2_check(tb, dut))
    cocotb.start_soon(out3_check(tb, dut))
    cocotb.start_soon(out4_check(tb, dut))
    cocotb.start_soon(out5_check(tb, dut))
    cocotb.start_soon(out6_check(tb, dut))
    cocotb.start_soon(pcnt_check(tb, dut))
    await tb.wait_clocks(100)
    await tb.reset_dut()
    await tb.wait_clocks(100)

    # 结束时记录
    cocotb.log.info("PWM generation test completed successfully")
