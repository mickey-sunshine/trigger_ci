import cocotb
from cocotb.clock import Clock

# from cocotb.triggers import RisingEdge, FallingEdge, Timer
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


async def timer_delay_ps(delay_time):
    """
    等待指定时间
    """
    await Timer(delay_time, "ps")


@cocotb.test()
async def test_clb_local_clk(dut):
    """Test clb_local_clk module"""

    # 启动主时钟 (clk_i = 10ns 周期)
    cocotb.start_soon(Clock(dut.clk_i, 10, "ns").start())

    # 初始化信号
    dut.rst_ni.value = 0
    dut.A_i.value = 0
    dut.B_i.value = 0

    # 等待几个周期，确保复位
    for _ in range(2):
        await RisingEdge(dut.clk_i)

    # 释放复位
    dut.rst_ni.value = 1
    await RisingEdge(dut.clk_i)

    # 测试 1: A_i = 1，B_i = 1
    await timer_delay_ps(200)
    dut.A_i.value = 1
    dut.B_i.value = 1
    await RisingEdge(dut.clk_i)  # 等待正常时钟上升沿
    await RisingEdge(dut.clk_i)  # 等待正常时钟上升沿
    custom_assert(dut.C_o.value == 1, f"C_o should be 1, got {dut.C_o.value}")

    # 等待反相信号上升沿 (clk_local 上升沿 = clk_i 下降沿)
    await FallingEdge(dut.clk_i)
    custom_assert(
        (dut.C_local_clk_o.value == 1),
        f"C_local_clk_o should be 1, got {dut.C_local_clk_o.value}",
    )

    # 测试 2: B_i = 0 (触发 rst_local 复位)
    await timer_delay_ps(200)
    dut.B_i.value = 0
    await RisingEdge(dut.clk_i)
    custom_assert(
        (dut.C_local_rst_o.value == 0),
        f"C_local_rst_o should be 0, got {dut.C_local_rst_o.value}",
    )

    # 测试 3: 再次释放 rst_local
    await timer_delay_ps(200)
    dut.B_i.value = 1
    dut.A_i.value = 0
    await RisingEdge(dut.clk_i)
    custom_assert(dut.C_local_rst_o.value == 0, f"C_local_rst_o should be 0 after A_i=0")

    # 改变 A_i，观察输出
    await timer_delay_ps(200)
    dut.A_i.value = 1
    await RisingEdge(dut.clk_i)
    await RisingEdge(dut.clk_i)
    custom_assert(
        (dut.C_local_rst_o.value == 1),
        "C_local_rst_o should follow A_i after rst_local release",
    )

    cocotb.log.info("All tests passed!")
