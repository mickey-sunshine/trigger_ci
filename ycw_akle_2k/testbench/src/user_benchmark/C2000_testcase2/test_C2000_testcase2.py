import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer

# from cocotb.triggers import RisingEdge, FallingEdge, Timer
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


@cocotb.test()
async def test_c2000_testcase2(dut):
    """Cocotb test for C2000_testcase2"""

    # 启动时钟，10ns周期 => 100MHz
    clock = Clock(dut.clk_i, 10, "ns")
    cocotb.start_soon(clock.start())

    # 初始化
    dut.rst_ni.value = 0
    dut.in1_i.value = 0
    dut.in2_i.value = 0
    dut.sel_i.value = 0
    await Timer(22, "ns")
    dut.rst_ni.value = 1
    await Timer(22, "ns")

    # 选择 in1_i 作为输入源
    dut._log.info("Using INPUT_SEL=0 (in1_i)")

    # 模拟上升沿 in1_i
    dut.in1_i.value = 1
    await RisingEdge(dut.clk_i)
    await Timer(2, "ns")
    # 检查 rising_edge 事件输出

    assert dut.event_o.value[1] == 1, "Rising edge event_o[1] not set!"

    # 模拟下降沿 in1_i
    dut.in1_i.value = 0
    await RisingEdge(dut.clk_i)
    await Timer(2, "ns")
    # 检查 falling_edge 和其他事件
    assert dut.event_o.value[0] or dut.event_o.value[2], "Falling edge events not triggered!"

    # 检查 counter_o 是否变动
    await RisingEdge(dut.clk_i)
    await Timer(2, "ns")
    await Timer(10, "ns")
    dut._log.info(f"counter_o = {str(dut.counter_o.value)}")
