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


async def pcnt_test(dut, tb):
    """测试PWM输出功能"""
    global match_value
    global event_pcnt
    event_pcnt = 0
    counter = 0
    exp = 0
    match_value = 100
    gpio_exp = 1
    while True:
        if dut.counter_en_i.value == 0 or event_pcnt == 1:
            await tb.wait_clocks(1)
            continue

        if dut.rst_ni.value == 0:
            counter = 0
        else:
            if dut.direction_i.value == 1:
                # 向下计数
                counter += -1
                if counter <= 0 or event_pcnt == 1:
                    counter = match_value + 1
                    exp = 1
            else:
                # 向上计数
                counter += 1
                if counter > match_value or event_pcnt == 1:
                    counter = 0
                    exp = 1

        # cocotb.log.info(f"counter:{counter},event:{event_pcnt}")
        if exp == 1:
            get = dut.interrupt_o.value
            custom_assert(
                str(exp) == str(get), f"interrupt error: exp:{exp}, got:{get}, counter:{counter}"
            )
            gpio_exp = 1 - gpio_exp
            exp = 0
        else:
            get = dut.interrupt_o.value
            custom_assert(
                str(exp) == str(get), f"interrupt error: exp:{exp}, got:{get}, counter:{counter}"
            )
        await tb.wait_clocks(1)
        gpio_get = dut.gpio_o.value
        custom_assert(
            str(gpio_get) == str(gpio_exp),
            f"gpio_o error: exp:{gpio_exp}, got:{gpio_get}, counter:{counter}",
        )


@cocotb.test()
async def test_c2k_timer_ccb(dut):
    global match_value
    global event_pcnt
    event_pcnt = 0
    tb = TB(dut)

    # 初始化输入为低电平
    dut.clk_i.value = 0
    dut.rst_ni.value = 0
    dut.event_trig_i.value = 0
    dut.counter_en_i.value = 0
    dut.direction_i.value = 0
    # 启动时钟, 初始复位
    await tb.setup_clock()
    cocotb.start_soon(pcnt_test(dut, tb))
    await tb.reset_dut()
    dut.counter_en_i.value = 1

    cocotb.log.info("test1: interrupt_o test")
    for i in range(3):
        await tb.wait_clocks(230)
        dut.direction_i.value = 1
        await tb.wait_clocks(175)
        dut.direction_i.value = 0
    await tb.wait_clocks(10)

    cocotb.log.info("test2: event_trig test")
    dut.event_trig_i.value = "10"
    await tb.wait_clocks(1)
    dut.event_trig_i.value = "00"
    match_value = 20
    event_pcnt = 1
    dut.counter_en_i.value = 0
    await tb.wait_clocks(8)  # 等待ccb指令执行
    dut.counter_en_i.value = 1
    event_pcnt = 0
    await tb.wait_clocks(230)
    dut.direction_i.value = 1
    await tb.wait_clocks(155)
    dut.direction_i.value = 0
    await tb.wait_clocks(10)


# 测试运行器入口点
if __name__ == "__main__":
    print("CocoTB testbench for c2k_timer_ccb module")
    print("Run with: cocotb")
