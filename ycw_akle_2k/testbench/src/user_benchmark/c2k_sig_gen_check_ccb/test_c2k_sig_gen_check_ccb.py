# import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, Event, First

# from cocotb.triggers import RisingEdge, FallingEdge
from cocotb.types import LogicArray, Logic
from cocotb.handle import Force, Release
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
        return 0


async def interrupt_dect(tb, signal, num_clocks):
    """中断检测功能,
    在num_clocks个时钟周期内不会触发中断"""
    task1 = cocotb.start_soon(tb.wait_clocks(num_clocks))
    task2 = cocotb.start_soon(RisingEdge(signal))
    result1 = await First(task1, task2)

    # 如果在预计的周期到来之前触发了中断, 则报错
    custom_assert(result1 == 0, f"Unexpected Interrupt detected, return{result1}")


async def interrupt_check2(tb, signal1, signal2, num_clocks, sig1_state="0", sig2_state="0"):
    """
    在num_clocks个时钟周期内，两个信号都不应触发中断
    在num_clocks个时钟周期后，信号1和2应该是state状态
    """
    cocotb.start_soon(interrupt_dect(tb, signal1, num_clocks - 1))
    cocotb.start_soon(interrupt_dect(tb, signal2, num_clocks - 1))
    await tb.wait_clocks(num_clocks)
    exp = sig1_state
    get = signal1.value
    custom_assert(
        str(exp) == str(get),
        f"interrupt1_o mismatch! exp:{exp} get:{get}",
    )
    exp = sig2_state
    get = signal2.value
    custom_assert(
        str(exp) == str(get),
        f"interrupt2_o mismatch! exp:{exp} get:{get}",
    )


@cocotb.test()
async def test_c2k_sig_gen_check_ccb(dut):
    """信号生成和检查测试"""
    cocotb.log.info("Starting signal test")

    tb = TB(dut)

    # 初始化输入为低电平
    dut.clk_i.value = 0
    dut.rst_ni.value = 0
    dut.event_ccb_i.value = 0
    dut.pwm_err_i.value = 0
    dut.pwm_sel_i.value = 0
    # 启动时钟, 初始复位
    await tb.setup_clock()
    await tb.reset_dut()

    # 正常pwm波形, 无中断产生
    cocotb.log.info("Starting normal signal test")
    await interrupt_check2(tb, dut.interrupt1_o, dut.interrupt2_o, 800, "0", "0")

    # 强制pwm波形的占空比超出设定值
    cocotb.log.info("Starting interrupt1_o test")
    dut.pwm_sel_i.value = 1
    dut.pwm_err_i.value = Force(0)
    await interrupt_check2(tb, dut.interrupt1_o, dut.interrupt2_o, 200, "0", "0")
    dut.pwm_err_i.value = Force(1)
    await interrupt_check2(tb, dut.interrupt1_o, dut.interrupt2_o, 301, "1", "1")
    await tb.wait_clocks(1)
    await interrupt_check2(tb, dut.interrupt1_o, dut.interrupt2_o, 301, "1", "0")

    # 强制pwm波形的周期超出设定值
    cocotb.log.info("Starting interrupt2_o test")
    await interrupt_check2(tb, dut.interrupt1_o, dut.interrupt2_o, 200, "0", "1")
    await tb.wait_clocks(1)
    await interrupt_check2(tb, dut.interrupt1_o, dut.interrupt2_o, 101, "1", "0")

    dut.pwm_err_i.value = Force(0)
    await interrupt_check2(tb, dut.interrupt1_o, dut.interrupt2_o, 250, "0", "0")
    dut.pwm_err_i.value = Force(1)
    await interrupt_check2(tb, dut.interrupt1_o, dut.interrupt2_o, 251, "0", "1")

    # 正常pwm波形, 无中断产生
    dut.pwm_sel_i.value = 0
    dut.pwm_err_i.value = Release()
    cocotb.log.info("Starting normal signal test2")
    await interrupt_check2(tb, dut.interrupt1_o, dut.interrupt2_o, 800, "0", "0")

    cocotb.log.info("PCNT test1 finished, now starting CCB test")
    cocotb.log.info("CCB change on time: 300 -> 99")
    cocotb.log.info("    change period : 500 -> 350")
    # ccb将高电平时长从300变到99, 将周期从500变到350
    dut.event_ccb_i.value = LogicArray(0b0100, 4)
    await tb.wait_clocks(1)
    dut.event_ccb_i.value = 0

    # 原始pwm依旧正常生成, 200个低电平+200个高电平为一个周期
    for i in range(3):
        # 200个低电平+100个高电平周期后, 触发interrupt1
        await interrupt_check2(tb, dut.interrupt1_o, dut.interrupt2_o, 300, "1", "0")
        await tb.wait_clocks(1)
        # 又过50周期后, 周期超限(350), 触发interrupt2
        await interrupt_check2(tb, dut.interrupt1_o, dut.interrupt2_o, 50, "0", "1")
        # 又过50周期后, 高电平超限(100), 触发interrupt1
        await interrupt_check2(tb, dut.interrupt1_o, dut.interrupt2_o, 50, "1", "0")

    cocotb.log.info("CCB config PCNT test finished")


# 测试运行器入口点
if __name__ == "__main__":
    print("CocoTB testbench for c2k_sig_gen_check_ccb module")
    print("Run with: cocotb")
