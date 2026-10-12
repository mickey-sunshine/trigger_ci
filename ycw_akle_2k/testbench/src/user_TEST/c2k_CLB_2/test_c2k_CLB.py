import cocotb
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


# 辅助函数：在指定状态下测量一定时钟周期内 PWM 的高电平个数
async def measure_pwm_cycles(dut, duration_cycles, state_to_measure):
    high_count = 0
    total_count = 0
    for _ in range(duration_cycles):
        await RisingEdge(dut.clk_i)
        total_count += 1
        if state_to_measure == OPENING:
            if int(dut.pwm_opening.value) == 1:
                high_count += 1
        elif state_to_measure == CLOSING:
            if int(dut.pwm_closing.value) == 1:
                high_count += 1
    return high_count, total_count


@cocotb.test()
async def test_c2k_CLB(dut):
    """
    Cocotb 测试用例：验证 c2k_CLB 模块中 PWM 产生的正确性。
    """
    tb = TB(dut)
    # 复位信号
    dut.clk_i.value = 0
    dut.rst_ni.value = 0
    dut.e0.value = 0
    dut.e1.value = 0

    await tb.setup_clock()
    await tb.reset_dut()

    # 让模块稳定几个周期
    await tb.wait_clocks(5)

    # 检查复位后 PWM 输出应该是低（没有活动 PWM）
    custom_assert(
        int(dut.pwm_opening.value) == 0 and int(dut.pwm_closing.value) == 0,
        "复位后 PWM 输出应该为低电平",
    )

    # 记录期望占空比（MATCH1_VAL=65, LOAD_VAL=100）
    expected_duty = 65 / 100.0  # 约0.65

    # ==== 测试序列开始 ====

    # 1. OPENED -> CLOSING (e0=1, e1=0)
    dut.e0.value = 1
    dut.e1.value = 0
    await tb.wait_clocks(20)
    custom_assert(
        str(dut.state.value) == CLOSING,
        f"OPENED -> CLOSING error, expected state: {CLOSING}, actual state: {dut.state.value}",
    )

    # 测量 CLOSING 状态下的 PWM (pwm_closing)
    measure_cycles = 300
    print(f"Measuring CLOSING state: {measure_cycles} cycles")
    high, total = await measure_pwm_cycles(dut, measure_cycles, CLOSING)
    duty = high / total if total > 0 else 0
    custom_assert(
        abs(duty - expected_duty) < 0.05,
        f"CLOSING state PWM duty cycle {duty:.2f} differs too much from expected {expected_duty:.2f}",
    )

    # 松开按键 无变化
    dut.e0.value = 0
    await tb.wait_clocks(20)
    custom_assert(
        str(dut.state.value) == CLOSING,
        f"OPENED -> CLOSING error, expected state: {CLOSING}, actual state: {dut.state.value}",
    )

    # 测量 CLOSING 状态下的 PWM (pwm_closing)
    measure_cycles = 300
    print(f"Measuring CLOSING state: {measure_cycles} cycles")
    high, total = await measure_pwm_cycles(dut, measure_cycles, CLOSING)
    duty = high / total if total > 0 else 0
    custom_assert(
        abs(duty - expected_duty) < 0.05,
        f"CLOSING state PWM duty cycle {duty:.2f} differs too much from expected {expected_duty:.2f}",
    )

    # 2. CLOSING -> CLOSED (设置 e1=1)
    dut.e1.value = 1
    await tb.wait_clocks(20)
    custom_assert(
        str(dut.state.value) == CLOSED,
        f"CLOSING -> CLOSED error, expected state: {CLOSED}, actual state: {dut.state.value}",
    )

    # 在 CLOSED 状态保持一段周期，不应有 PWM 输出
    for _ in range(200):
        await RisingEdge(dut.clk_i)
        custom_assert(
            int(dut.pwm_opening.value) == 0 and int(dut.pwm_closing.value) == 0,
            "CLOSED 状态下 PWM 输出应当为低电平",
        )

    # e1重新置0 无变化
    dut.e1.value = 0
    await tb.wait_clocks(20)
    custom_assert(
        str(dut.state.value) == CLOSED,
        f"CLOSING -> CLOSED error, expected state: {CLOSED}, actual state: {dut.state.value}",
    )

    # 在 CLOSED 状态保持一段周期，不应有 PWM 输出
    for _ in range(200):
        await RisingEdge(dut.clk_i)
        custom_assert(
            int(dut.pwm_opening.value) == 0 and int(dut.pwm_closing.value) == 0,
            "CLOSED 状态下 PWM 输出应当为低电平",
        )

    # 3. CLOSED -> OPENING (e0=1, e1=0)
    dut.e0.value = 1
    await tb.wait_clocks(20)
    custom_assert(
        str(dut.state.value) == OPENING,
        f"CLOSED -> OPENING error, expected state: {OPENING}, actual state: {dut.state.value}",
    )

    # 测量 OPENING 状态下的 PWM (pwm_closing)
    measure_cycles = 300
    print(f"Measuring OPENING state: {measure_cycles} cycles")
    high, total = await measure_pwm_cycles(dut, measure_cycles, OPENING)
    duty = high / total if total > 0 else 0
    custom_assert(
        abs(duty - expected_duty) < 0.05,
        f"OPENING state PWM duty cycle {duty:.2f} differs too much from expected {expected_duty:.2f}",
    )

    # 松开按键 无变化
    dut.e0.value = 0
    await tb.wait_clocks(20)
    custom_assert(
        str(dut.state.value) == OPENING,
        f"CLOSED -> OPENING error, expected state: {OPENING}, actual state: {dut.state.value}",
    )

    # 测量 OPENING 状态下的 PWM (pwm_closing)
    measure_cycles = 300
    print(f"Measuring OPENING state: {measure_cycles} cycles")
    high, total = await measure_pwm_cycles(dut, measure_cycles, OPENING)
    duty = high / total if total > 0 else 0
    custom_assert(
        abs(duty - expected_duty) < 0.05,
        f"OPENING state PWM duty cycle {duty:.2f} differs too much from expected {expected_duty:.2f}",
    )

    # 4. OPENING -> OPENED (设置 e1=1)
    dut.e1.value = 1
    await tb.wait_clocks(20)
    custom_assert(
        str(dut.state.value) == OPENED,
        f"OPENING -> OPENED error, expected state: {OPENED}, actual state: {dut.state.value}",
    )

    # 在 OPENED 状态保持一段周期，不应有 PWM 输出
    for _ in range(200):
        await RisingEdge(dut.clk_i)
        custom_assert(
            int(dut.pwm_opening.value) == 0 and int(dut.pwm_closing.value) == 0,
            "OPENED 状态下 PWM 输出应当为低电平",
        )

    # e1重新置0 无变化
    dut.e1.value = 0
    await tb.wait_clocks(20)
    custom_assert(
        str(dut.state.value) == OPENED,
        f"OPENING -> OPENED error, expected state: {OPENED}, actual state: {dut.state.value}",
    )

    # 在 OPENED 状态保持一段周期，不应有 PWM 输出
    for _ in range(200):
        await RisingEdge(dut.clk_i)
        custom_assert(
            int(dut.pwm_opening.value) == 0 and int(dut.pwm_closing.value) == 0,
            "OPENED 状态下 PWM 输出应当为低电平",
        )

    # 5. JUMPING (e0=1, e1=1)
    dut.e0.value = 1
    dut.e1.value = 1
    await tb.wait_clocks(10)
    for _ in range(10):
        for _ in range(10):
            await RisingEdge(dut.clk_i)
        custom_assert(
            str(dut.state.value) == CLOSING,
            f"OPENING -> CLOSING error, expected state: {CLOSING}, actual state: {dut.state.value}",
        )
        for _ in range(10):
            await RisingEdge(dut.clk_i)
        custom_assert(
            str(dut.state.value) == OPENING,
            f"CLOSING -> OPENING error, expected state: {OPENING}, actual state: {dut.state.value}",
        )

    # 结束时记录
    cocotb.log.info("PWM generation test completed successfully")
