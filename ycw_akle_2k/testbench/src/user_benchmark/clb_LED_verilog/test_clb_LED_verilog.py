import random
import cocotb
from cocotb.clock import Clock

# from cocotb.triggers import Timer, RisingEdge, FallingEdge, Event
from cocotb.triggers import Timer
from cocotb.types import LogicArray, Logic
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
LED_CODE = [
    0xC0,
    0xF9,
    0xA4,
    0xB0,
    0x99,
    0x92,
    0x82,
    0xF8,
    0x80,
    0x90,
    0x88,
    0x83,
    0xC6,
    0xA1,
    0x86,
    0x8E,
    0xBF,
]


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


async def test_single_data(dut, data):
    """单组数据测试"""
    data_list = []
    for i in range(4):
        data_list.append(data >> (i * 4) & 0xF)
    cocotb.log.info(f"Testing data: {data_list}")
    for i in range(4):  # 4个数据
        bits = bin(LED_CODE[data_list[i]])[2:]
        cocotb.log.info(f"data_list[{i}] = {hex(data_list[i])}, SEG code:{bits}")
        for j in range(8):  # 8个数据位
            # 先从LED编码中取出数据位，再将其转成二进制，再提取出一位
            await RisingEdge(dut.sclk_o)
            expect = bin(LED_CODE[data_list[i]])[2:][j]
            # cocotb.log.info(f"exp:{expect},dut:{str(dut.dio_o.value)}")
            custom_assert(
                str(dut.dio_o.value) == expect,
                f"dio_o data error! exp:{expect},dut:{str(dut.dio_o.value)}",
            )
        for j in range(4):  # 4个空周期
            await RisingEdge(dut.sclk_o)
            custom_assert(
                str(dut.dio_o.value) == Logic(0),
                f"dio_o  clk error! exp:{Logic(0)},dut:{str(dut.dio_o.value)}",
            )
        sel = LogicArray(1 << (3 - i), 4)
        for j in range(4):  # 4个sel选择位
            await RisingEdge(dut.sclk_o)
            # cocotb.log.info(f"sel:{sel}, sel[j]:{sel[j]}")
            custom_assert(
                str(dut.dio_o.value) == str(sel[j]),
                f"dio_o  sel error! exp:{sel[j]},dut:{str(dut.dio_o.value)}",
            )
    await FallingEdge(dut.sclk_o)
    custom_assert(
        str(dut.rclk_o.value) == Logic(1),
        f"rclk_o error! exp:{Logic(1)},dut:{str(dut.rclk_o.value)}",
    )


@cocotb.test()
async def test_clb_LED(dut):
    """测试数码管输出功能"""
    cocotb.log.info("Starting SEG test")

    tb = TB(dut)

    # 初始化输入为低电平
    dut.clk_i.value = 0
    dut.rst_ni.value = 0
    dut.seg_data_i.value = LogicArray(0x0000, 16)

    # 启动时钟, 初始复位
    await tb.setup_clock()
    await tb.reset_dut()
    data = 0
    for _ in range(10):
        data = random.randint(0, 0xFFFF)
        cocotb.log.info(f"test data:{data:04x}")
        dut.seg_data_i.value = LogicArray(data, 16)
        await test_single_data(dut, data)
        # for _ in range(4):
        #     await tb.wait_clocks(170)
    await tb.wait_clocks(500)


# 测试运行器入口点
if __name__ == "__main__":
    print("CocoTB testbench for clb_LED_pcnt module")
    print("Run with: cocotb")
