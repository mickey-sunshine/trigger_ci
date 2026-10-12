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
CLOCK_PERIOD = 10


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

    async def timeout(self, timeout_time=400000):
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


def check_outputs(dut, expected_a, expected_b, label):
    actual_a = str(dut.EPWM_2A_o.value)
    actual_b = str(dut.EPWM_2B_o.value)
    expected = (str(expected_a), str(expected_b))
    actual = (actual_a, actual_b)

    custom_assert(
        actual == expected,
        f"{label}: expected A/B={expected_a}/{expected_b}, " f"got {actual_a}/{actual_b}",
    )
    cocotb.log.info(f"PASS: {label} A/B={actual_a}/{actual_b}")


def check_outputs_known(dut, label):
    actual_a = str(dut.EPWM_2A_o.value)
    actual_b = str(dut.EPWM_2B_o.value)
    custom_assert(
        actual_a in ("0", "1") and actual_b in ("0", "1"),
        f"{label}: X/Z output A/B={actual_a}/{actual_b}",
    )


async def measure_pulse(dut, signal, active_level, label):
    active_cycle = None
    idle_cycle = None

    for cycle in range(40):
        await RisingEdge(dut.clk_i)
        await Timer(1, "ns")

        check_outputs_known(dut, label)
        value = str(signal.value)
        is_active = value == str(active_level)

        if is_active and active_cycle is None:
            active_cycle = cycle
        elif not is_active and active_cycle is not None and idle_cycle is None:
            idle_cycle = cycle

    custom_assert(
        active_cycle is not None and idle_cycle is not None and idle_cycle - active_cycle == 11,
        f"{label}: invalid pulse, active={active_cycle}, idle={idle_cycle}",
    )
    cocotb.log.info(f"PASS: {label} active={active_cycle}, idle={idle_cycle}, width=11 cycles")


@cocotb.test()
async def test_ae_case1(dut):
    """Check the reset polarity and the two edge-triggered output pulses."""
    tb = TB(dut)

    dut.clk_i.value = 0
    dut.rst_ni.value = 1
    dut.epwm_1a_i.value = 0
    dut.epwm_1b_i.value = 0

    clock = Clock(dut.clk_i, 5, "ns")
    cocotb.start_soon(clock.start())
    await Timer(1, "ns")

    dut.rst_ni.value = 0
    await Timer(1, "ns")
    check_outputs(dut, 0, 1, "asynchronous reset output polarity")

    await tb.wait_clocks(3)
    dut.rst_ni.value = 1
    await tb.wait_clocks(10)
    check_outputs(dut, 0, 1, "idle output polarity")

    dut.epwm_1a_i.value = 1
    await measure_pulse(dut, dut.EPWM_2A_o, 1, "channel A pulse")
    check_outputs(dut, 0, 1, "channel A returns idle after PCNT match")

    dut.epwm_1b_i.value = 1
    await measure_pulse(dut, dut.EPWM_2B_o, 0, "channel B active-low pulse")
    check_outputs(dut, 0, 1, "both channels return idle")

    dut.rst_ni.value = 0
    await Timer(1, "ns")
    check_outputs(dut, 0, 1, "asynchronous reset after activity")
