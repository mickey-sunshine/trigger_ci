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
        await Timer(CLOCK_PERIOD_NS * 20, "ns")
        self.dut.rst_ni.value = 0
        await Timer(CLOCK_PERIOD_NS * 20, "ns")
        self.dut.rst_ni.value = 1
        # await Timer(CLOCK_PERIOD_NS * 2, "ns")
        cocotb.log.info("DUT reset completed")

    async def setup_clock(self):
        """设置时钟信号"""
        clock = Clock(self.dut.clk_i, CLOCK_PERIOD_NS, "ns")  # 100MHz时钟 (10ns周期)
        clock1 = Clock(self.dut.clk_ccb_i, CLOCK_PERIOD_NS, "ns")  # 100MHz时钟 (10ns周期)
        cocotb.start_soon(clock.start())
        cocotb.start_soon(clock1.start())
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
async def test_ccb_parallel_event(dut):
    """ccb_parallel_event test function"""
    cocotb.log.info("Starting ccb_parallel_event test...")

    tb = TB(dut)

    # 初始化信号 - Modify signal names and initial values as needed
    dut.clk_i.value = 0
    dut.clk_ccb_i.value = 0
    dut.rst_ni.value = 1
    dut.event_trig_i.value = 0
    # 启动时钟并复位
    await tb.setup_clock()
    await tb.reset_dut()

    await tb.wait_clocks(10)
    cocotb.log.info("Test1 started")
    for i in range(4):
        dut.event_trig_i.value = 1 << i
        await tb.wait_clocks(1)
        dut.event_trig_i.value = 0
        await tb.wait_clocks(2)

    for i in range(4):
        dut.event_trig_i.value = 1 << (3 - i)
        await tb.wait_clocks(1)
        dut.event_trig_i.value = 0
        await tb.wait_clocks(2)

    await tb.wait_clocks(150)

    for i in range(4):
        dut.event_trig_i.value = 1 << (3 - i)
        await tb.wait_clocks(1)
        dut.event_trig_i.value = 0
        await tb.wait_clocks(2)

    for i in range(4):
        dut.event_trig_i.value = 1 << i
        await tb.wait_clocks(1)
        dut.event_trig_i.value = 0
        await tb.wait_clocks(2)

    await tb.wait_clocks(150)
    cocotb.log.info("Test1 completed")

    await tb.wait_clocks(10)
    cocotb.log.info("Test2 start")
    for i in range(2):
        for i in range(1, 4):
            dut.event_trig_i.value = 1 << i | 0b0001
            await tb.wait_clocks(1)
            dut.event_trig_i.value = 0b0001
            await tb.wait_clocks(2)
    await tb.wait_clocks(200)
    cocotb.log.info("Test2 completed")

    await tb.wait_clocks(10)
    cocotb.log.info("Test3 start")
    for i in range(1, 4):
        dut.event_trig_i.value = 1 << i | 0b1010
        await tb.wait_clocks(1)
        dut.event_trig_i.value = 0b1010
        await tb.wait_clocks(2)
    await tb.wait_clocks(200)
    cocotb.log.info("Test3 completed")

    await tb.wait_clocks(10)
    cocotb.log.info("Test4 start")
    for i in range(2):
        for i in range(1, 4):
            dut.event_trig_i.value = 1 << i | 0b1010
            await tb.wait_clocks(1)
            dut.event_trig_i.value = 0b1010
            await tb.wait_clocks(2)
    await tb.wait_clocks(120)
    cocotb.log.info("Test4 completed")


# 测试运行器入口点
if __name__ == "__main__":
    print("CocoTB testbench for ccb_parallel_event module")
    print("Run with: cocotb")
