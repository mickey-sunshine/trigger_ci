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


async def check_pwm(
    signal,
    cycles=1,
    expected_duty=None,
    expected_period=None,
    tolerance=0.05,
):
    """
    检查 PWM 波形占空比与周期。

    参数:
        signal: DUT 中的 PWM 信号（如 dut.pwm_out）
        clk:    时钟信号，用于同步（如 dut.clk）
        expected_duty: 预期占空比 (0~1)，None 则只测量不校验
        tolerance: 相对误差容差，例如 0.02 = ±2%
        cycles: 测量几个 PWM 周期（默认 1）

    返回:
        avg_period (ns), avg_duty (0~1)
    """

    periods = []
    duties = []

    for i in range(cycles):

        # --- 等待上升沿作为周期起点 ---
        await RisingEdge(signal)
        t_start = cocotb.utils.get_sim_time("ns")

        # --- 高电平开始计时 ---
        await FallingEdge(signal)
        t_high_end = cocotb.utils.get_sim_time("ns")

        high_time = t_high_end - t_start

        # --- 等待下一次上升沿，得到周期 ---
        await RisingEdge(signal)
        t_period_end = cocotb.utils.get_sim_time("ns")

        period = t_period_end - t_start
        duty = high_time / period

        periods.append(period)
        duties.append(duty)

    avg_period = int(sum(periods) / len(periods) / CLOCK_PERIOD)
    avg_duty = sum(duties) / len(duties)

    print_str = f"[PWM CHECK] period={avg_period} cycles, duty={avg_duty:.3f}"
    # --- 如果有期望占空比则进行检查 ---
    if expected_duty is not None:
        diff_duty = abs(avg_duty - expected_duty)
        print_str += f", expected={expected_duty:.3f}, diff={diff_duty:.3f}"
        custom_assert(
            diff_duty < tolerance,
            f"PWM duty mismatch! expected={expected_duty:.3f}, got={avg_duty:.3f}; diff_duty={diff_duty}, tolerance={tolerance}",
        )

    if expected_period is not None:
        diff_period = abs(avg_period - expected_period) / expected_period
        print_str += f", expected={expected_period:.3f}, diff={diff_period:.3f}"
        custom_assert(
            diff_period < tolerance,
            f"PWM period mismatch! expected={expected_period:.3f}, got={avg_period:.3f}; diff_period={diff_period}, tolerance={tolerance}",
        )

    cocotb.log.info(print_str)

    return avg_period, avg_duty


async def set_pwm(pwm_signal, UART, period=100, duty=0.5, check=False):
    """
    设置PWM的周期和占空比
    dut:    dut对象
    UART:   UART对象
    period: int, 单个周期时钟数量
    duty:   float,占空比
    """
    match1 = int(period) - 2  # 2个时钟周期处理
    match0 = int(period * (1 - duty)) - 2  # 2个时钟周期处理
    cocotb.log.info(f"Sending byte 0x{match0:02X} to DUT.rx (pcnt match0)")
    await UART.send_byte(match0)

    cocotb.log.info(f"Sending byte 0x{match1:02X} to DUT.rx (pcnt match1)")
    cocotb.log.info(f"set pwm: period:{period}, duty:{duty}")
    await UART.send_byte(match1)
    await FallingEdge(pwm_signal)
    if check == True:
        await check_pwm(signal=pwm_signal, cycles=10, expected_duty=duty, expected_period=period)


@cocotb.test()
async def test_ccb_single_8instra_pcnt32_sync(dut):
    """测试UART输出"""
    tb = TB(dut)
    dut.event_trig_i.value = "0"
    await tb.setup_clock()
    await tb.reset_dut()
    cocotb.log.info(f"skip test_ccb_single_8instra_pcnt32_sync")
    await tb.wait_clocks(500)
    dut.event_trig_i.value = "1"
    await tb.wait_clocks(500)


# 测试运行器入口点
if __name__ == "__main__":
    print("CocoTB testbench for ccb_single_8instra_pcnt32_sync module")
    print("Run with: cocotb")
