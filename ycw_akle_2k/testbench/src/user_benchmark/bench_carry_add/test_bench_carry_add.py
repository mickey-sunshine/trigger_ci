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
CLOCK_FREQ = 100000000  # 100MHz - Modify as needed
CLOCK_PERIOD_NS = 1000000000 / CLOCK_FREQ


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


def assert_debug(result, expect, mark=""):
    expect_str = str(expect)
    result_str = str(result)
    custom_assert(
        expect_str == result_str,
        f"DUT out mismatch({mark}): expect: {expect_str}, result: {result_str}",
    )


class TB:
    """Testbench 类"""

    def __init__(self, dut):
        self.dut = dut
        cocotb.start_soon(self.timeout())

    async def timeout(self, timeout_time=100000):
        """超时函数"""
        await Timer(timeout_time, "ns")
        raise TimeoutError("Timeout")

    async def reset_dut(self):
        """复位DUT"""
        self.dut.rst_ni.value = 0
        await Timer(CLOCK_PERIOD_NS * 2, "ns")
        self.dut.rst_ni.value = 1
        # await Timer(CLOCK_PERIOD_NS * 2, "ns")
        cocotb.log.info("DUT reset completed")

    async def setup_clock(self):
        """设置时钟信号"""
        clock = Clock(self.dut.clk_i, CLOCK_PERIOD_NS, "ns")  # 100MHz时钟 (10ns周期)
        cocotb.start_soon(clock.start())
        await Timer(1, "ns")  # 让时钟稳定

    async def wait_clocks(self, num_clocks):
        """等待指定数量的时钟周期"""
        await self.wait_posedge_clocks(num_clocks)

    async def wait_posedge_clocks(self, num_clocks):
        """等待指定数量的上升沿时钟周期"""
        for _ in range(num_clocks):
            await RisingEdge(self.dut.clk_i)
        await Timer(1, "ns")

    async def wait_negedge_clocks(self, num_clocks):
        """等待指定数量的下降沿时钟周期"""
        for _ in range(num_clocks):
            await FallingEdge(self.dut.clk_i)
        await Timer(1, "ns")


@cocotb.test()
async def test_bench_carry_add(dut):
    """Verify the registered adder and accumulator carry paths."""
    cocotb.log.info("Starting bench_carry_add test...")

    tb = TB(dut)

    # 初始化信号 - Modify signal names and initial values as needed
    dut.clk_i.value = 0
    dut.rst_ni.value = 0
    dut.en_i.value = 0
    dut.a_i.value = 0
    dut.b_i.value = 0

    # 启动时钟并复位
    await tb.setup_clock()
    await tb.wait_clocks(2)
    dut.rst_ni.value = 1
    await tb.wait_clocks(1)

    width = len(dut.a_i)
    mask = (1 << width) - 1

    assert_debug(dut.sum_o.value, f"{0:0{width}b}", "reset sum")
    assert_debug(dut.acc_o.value, f"{0:0{width}b}", "reset accumulator")

    dut.en_i.value = 1
    dut.a_i.value = mask
    dut.b_i.value = 1
    await tb.wait_clocks(1)
    assert_debug(dut.sum_o.value, f"{0:0{width}b}", "pipeline latency")

    dut.a_i.value = 1
    dut.b_i.value = 2
    await tb.wait_clocks(1)
    assert_debug(dut.sum_o.value, f"{0:0{width}b}", "wide carry add")
    assert_debug(dut.acc_o.value, f"{mask:0{width}b}", "first accumulator update")

    dut.a_i.value = 0
    dut.b_i.value = 0
    await tb.wait_clocks(1)
    assert_debug(dut.sum_o.value, f"{3:0{width}b}", "registered sum")
    assert_debug(dut.acc_o.value, f"{0:0{width}b}", "accumulator carry wrap")

    import random

    rng = random.Random(20260810)
    registered_a = 0
    registered_b = 0
    expected_acc = 0
    for index in range(10):
        a_value = rng.getrandbits(width)
        b_value = rng.getrandbits(width)
        expected_sum = (registered_a + registered_b) & mask
        expected_acc = (expected_acc + registered_a) & mask

        dut.a_i.value = a_value
        dut.b_i.value = b_value
        await tb.wait_clocks(1)

        assert_debug(dut.sum_o.value, f"{expected_sum:0{width}b}", f"random sum {index}")
        assert_debug(dut.acc_o.value, f"{expected_acc:0{width}b}", f"random accumulator {index}")
        registered_a = a_value
        registered_b = b_value

    expected_sum = (registered_a + registered_b) & mask
    expected_acc = (expected_acc + registered_a) & mask
    dut.a_i.value = 0
    dut.b_i.value = 0
    await tb.wait_clocks(1)
    assert_debug(dut.sum_o.value, f"{expected_sum:0{width}b}", "random sum flush")
    assert_debug(dut.acc_o.value, f"{expected_acc:0{width}b}", "random accumulator flush")

    dut.en_i.value = 0
    await tb.wait_clocks(1)
    assert_debug(dut.sum_o.value, f"{expected_sum:0{width}b}", "disabled sum hold")
    assert_debug(dut.acc_o.value, f"{expected_acc:0{width}b}", "disabled accumulator hold")


# 测试运行器入口点
if __name__ == "__main__":
    print("CocoTB testbench for bench_carry_add module")
    print("Run with: cocotb")
