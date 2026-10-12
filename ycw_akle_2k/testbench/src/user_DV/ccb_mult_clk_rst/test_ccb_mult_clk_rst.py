import cocotb
import random
from cocotb.clock import Clock
from cocotb.triggers import Timer

# from cocotb.triggers import Timer, RisingEdge, FallingEdge
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

    async def reset_dut(self, resets=["rst_ni"]):
        """复位DUT"""
        for reset in resets:
            getattr(self.dut, reset).value = 0
        await Timer(20, "ns")
        for reset in resets:
            getattr(self.dut, reset).value = 1
        await Timer(20, "ns")
        cocotb.log.info("DUT reset completed")

    async def setup_clocks(self, clocks=[("clk_i", 10)]):
        """设置时钟信号"""
        for name, freq in clocks:
            cocotb.start_soon(Clock(getattr(self.dut, name), freq, "ns").start())
        cocotb.log.info("clock setup completed")
        await Timer(1, "ns")  # 让时钟稳定

    async def wait_clocks(self, num_clocks, clk="clk_i"):
        """等待指定数量的时钟周期"""
        for _ in range(num_clocks):
            await RisingEdge(getattr(self.dut, clk))
        await Timer(1, "ns")  # 错开时钟沿


# 辅助函数：在指定状态下测量一定时钟周期内 PWM 的高电平个数
async def measure_pwm_cycles(dut, duration_cycles, expected_duty="0.5", tolerance="0.05"):
    high_count = 0
    total_count = 0
    for _ in range(duration_cycles):
        await RisingEdge(dut.clk2_i)
        total_count += 1
        if int(dut.pcnt_o.value) == 1:
            high_count += 1
    duty = high_count / total_count
    if expected_duty == 0:
        diff_duty = abs(duty - expected_duty)
    else:
        diff_duty = abs(duty - expected_duty) / expected_duty
    cocotb.log.info(f", expected={expected_duty:.3f}, diff={diff_duty:.3f}")
    custom_assert(
        diff_duty < tolerance,
        f"PWM duty mismatch! expected={expected_duty:.3f}, got={duty:.3f}; diff_duty={diff_duty}, tolerance={tolerance}",
    )


@cocotb.test()
async def test_ccb_mult_clk_rst(dut):
    """
    Cocotb 测试用例：验证 ccb_mult_clk_rst 模块中 PWM 产生的正确性。
    """
    tb = TB(dut)
    # 复位信号
    clock_list = [("clk1_i", 10), ("clk2_i", 15)]
    reset_list = ["rst1_ni", "rst2_ni"]

    dut.clk1_i.value = 0
    dut.clk2_i.value = 0
    dut.rst1_ni.value = 0
    dut.rst2_ni.value = 0
    dut.a_i.value = 0
    dut.b_i.value = 0
    await tb.setup_clocks(clock_list)
    await tb.reset_dut(reset_list)

    # 让模块稳定一段时间
    await Timer(100, "ns")

    # and2测试
    for i in range(100):
        if i > 50:  # 50周期后拉低rst2, 不应影响功能
            dut.rst2_ni.value = 0
        a = random.randint(0, 1)
        b = random.randint(0, 1)
        dut.a_i.value = a
        dut.b_i.value = b
        exp = a * b
        await Timer(1, "ns")
        get = dut.c_o.value
        custom_assert(str(get) == str(exp), f"and2 error: exp:{exp}, got:{get}")
        await tb.wait_clocks(1, "clk1_i")
        get = dut.d_o.value
        custom_assert(str(get) == str(exp), f"and2_latch error: exp:{exp}, got:{get}")

    # 拉低and2的复位
    dut.rst1_ni.value = 0
    for i in range(100):
        if i > 50:
            dut.rst2_ni.value = 1
        a = random.randint(0, 1)
        b = random.randint(0, 1)
        dut.a_i.value = a
        dut.b_i.value = b
        exp = a * b
        await Timer(1, "ns")
        get = dut.c_o.value
        custom_assert(str(get) == str(exp), f"and2 error: exp:{exp}, got:{get}")
        await tb.wait_clocks(1, "clk1_i")
        exp = 0
        get = dut.d_o.value
        custom_assert(str(get) == str(exp), f"and2_latch error: exp:{exp}, got:{get}")

    # pwm测试
    dut.a_i.value = 0
    dut.b_i.value = 0
    await measure_pwm_cycles(dut, 500, 0.5, 0.05)
    dut.rst2_ni.value = 0
    await measure_pwm_cycles(dut, 500, 0.0, 0.01)
    # 结束时记录
    cocotb.log.info("PWM generation test completed successfully")
