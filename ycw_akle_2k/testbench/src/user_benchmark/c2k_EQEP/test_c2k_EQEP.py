import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, Event

# from cocotb.triggers import Timer, RisingEdge, FallingEdge, Event

from cocotb.triggers import ValueChange

# from signal_trace import trace_all_ports


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
CNT_MAX_VAL = 32  # 转一圈的计数最大值
WDT_MAX_VAL = 10  # 看门狗复位所需qclk_o的周期


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


async def encoder_signal_generator(dut, dir_done_event, direction=0):
    """模拟增量式光电编码器 A、B、I 三路输出信号

    Args:
        dut: cocotb DUT 实例
        direction: 旋转方向, 1: 顺时针; 0:逆时针
    """
    period_ns = 400  # 每个 A/B 方波周期 = 200 ns
    steps_per_rev = int(CNT_MAX_VAL / 4)  # 模拟每圈有 CNT_MAX_VAL 个脉冲

    dut.EQEP_A_i.value = 0
    dut.EQEP_B_i.value = 0
    dut.EQEP_I_i.value = 0

    for step in range(steps_per_rev):
        # --- 每圈输出一次 I 脉冲 ---
        if step == int(steps_per_rev / 2):
            dut.EQEP_I_i.value = 1

        if direction == 1:
            # --- 顺时针：A 相领先 B 相 90° ---
            dut.EQEP_A_i.value = 1
            await Timer(period_ns / 4, "ns")

            dut.EQEP_B_i.value = 1
            await Timer(period_ns / 4, "ns")

            dut.EQEP_A_i.value = 0
            dut.EQEP_I_i.value = 0
            await Timer(period_ns / 4, "ns")

            dut.EQEP_B_i.value = 0
            await Timer(period_ns / 4, "ns")

        else:
            # --- 逆时针：B 相领先 A 相 90° ---
            dut.EQEP_B_i.value = 1
            await Timer(period_ns / 4, "ns")

            dut.EQEP_A_i.value = 1
            await Timer(period_ns / 4, "ns")

            dut.EQEP_B_i.value = 0
            dut.EQEP_I_i.value = 0
            await Timer(period_ns / 4, "ns")

            dut.EQEP_A_i.value = 0
            await Timer(period_ns / 4, "ns")

    dir_done_event.set()
    dut._log.info("Done")


async def encoder_monitor(dut, dir_done_event, target):
    """监测编码器信号，直到 dir_done_event 触发"""
    dut._log.info("Monitor started")
    while not dir_done_event.is_set():
        await Timer(40, "ns")
        custom_assert(dut.dir_o.value == target, "Direction does not match expected direction")

    dut._log.info("Monitor stopped (detected dir_done_event).")


async def wdt_test(dut):
    "测试看门狗功能"
    wdt_cnt = 0
    cocotb.log.info("[WDT] start compare watchdog")
    while True:
        await FallingEdge(dut.clk_i)
        # cocotb.log.info(f"wdt_cnt={wdt_cnt}")
        if dut.qclk_o.value == 0:
            wdt_cnt += 1
        else:
            wdt_cnt = 0
        if wdt_cnt > WDT_MAX_VAL:
            custom_assert(dut.wdt_o.value == 1, "WDT should be active")
            wdt_cnt = 0


async def cnt_test(dut, cnt_done_event):
    "测试计数功能"
    # 先等待一次计数器复位, 确保计数能对上
    cnt = 0
    last_index = 0
    await FallingEdge(dut.qclk_o)
    while dut.pcnt_pos.core.rst_i.value == 1:
        # cocotb.log.info(f"cnt:{cnt}, q_o:{int(dut.pcnt_pos.core.q_o.value)}")
        await FallingEdge(dut.qclk_o)
    cocotb.log.info("[CNT] start compare counter")

    while not cnt_done_event.is_set():
        await FallingEdge(dut.qclk_o)
        await Timer(1, "ns")
        if dut.EQEP_I_i.value == 1:  # index 复位
            if last_index == 1:
                last_index = 0
                continue
            if dut.dir_o.value == 1:
                cnt = 0
            else:
                cnt = CNT_MAX_VAL
            last_index = 1
        elif dut.rst_ni.value == 0:  # reset 复位
            cnt = 0
        elif dut.error_o.value == 1:  # error 复位
            cnt = 0
        if dut.dir_o.value == 1:  # 正转
            cnt += 1
        else:  # 反转
            cnt -= 1
            if cnt < 0:
                cnt = CNT_MAX_VAL
        # cocotb.log.info(f"cnt:{cnt}, dir:{dut.dir_o.value}, q_o:{int(dut.pcnt_pos.core.q_o.value)}")
        custom_assert(
            cnt == int(dut.pcnt_pos.core.q_o.value),
            f"position count error,expect:{cnt},actual:{int(dut.pcnt_pos.core.q_o.value)}",
        )


@cocotb.test()
async def test_direction(dut):
    """测试旋转方向监测功能"""
    cocotb.log.info("Starting edge detection test")

    tb = TB(dut)

    # trace_all_ports(dut, clk=dut.clk_i)

    # 初始化输入为低电平
    dut.clk_i.value = 0
    dut.rst_ni.value = 0
    dut.EQEP_A_i.value = 0
    dut.EQEP_B_i.value = 0
    dut.EQEP_I_i.value = 0

    dir_done_event = Event()
    cnt_done_event = Event()
    # 启动时钟, 初始复位
    await tb.setup_clock()
    await tb.reset_dut()

    # 启动看门狗监测器
    cocotb.start_soon(wdt_test(dut))
    # 启动计数器检测器
    # cocotb.start_soon(cnt_test(dut, cnt_done_event))

    # 启动 generator 和 monitor
    # 顺时针旋转测试
    cocotb.start_soon(encoder_monitor(dut, dir_done_event, 1))
    await encoder_signal_generator(dut, dir_done_event, 1)

    await tb.wait_clocks(40)

    # 逆时针旋转测试
    cocotb.start_soon(encoder_monitor(dut, dir_done_event, 0))
    await encoder_signal_generator(dut, dir_done_event, 0)

    await tb.wait_clocks(40)
    cnt_done_event.set()

    # 错误测试
    dut.EQEP_A_i.value = 0
    dut.EQEP_B_i.value = 0
    await tb.wait_clocks(5)
    dut.EQEP_A_i.value = 1
    dut.EQEP_B_i.value = 1
    await tb.wait_clocks(5)
    custom_assert(dut.error_o.value == 1, "Error test failed(00 -> 11)")

    dut.EQEP_A_i.value = 0
    dut.EQEP_B_i.value = 0
    await tb.wait_clocks(5)
    custom_assert(dut.error_o.value == 1, "Error test failed(11 -> 00)")

    dut.EQEP_A_i.value = 1
    dut.EQEP_B_i.value = 0
    await tb.wait_clocks(5)
    custom_assert(dut.error_o.value == 0, "Error test failed(00 -> 10)")

    dut.EQEP_A_i.value = 0
    dut.EQEP_B_i.value = 1
    await tb.wait_clocks(5)
    custom_assert(dut.error_o.value == 1, "Error test failed(10 -> 01)")

    dut.EQEP_A_i.value = 1
    dut.EQEP_B_i.value = 0
    await tb.wait_clocks(5)
    custom_assert(dut.error_o.value == 1, "Error test failed(01 -> 10)")

    dut.EQEP_A_i.value = 0
    dut.EQEP_B_i.value = 0
    await tb.wait_clocks(5)
    custom_assert(dut.error_o.value == 0, "Error test failed(10 -> 00)")

    await tb.wait_clocks(50)


# 测试运行器入口点
if __name__ == "__main__":
    print("CocoTB testbench for c2k_EQEP module")
    print("Run with: cocotb")
