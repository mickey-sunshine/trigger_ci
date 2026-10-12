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


class LFSR16:
    def __init__(self, seed):
        # 等价于 reset 时 lfsr <= seed
        self.lfsr = seed & 0xFFFF

    def step(self, start):
        """
        对应一个 posedge clk
        """
        if start:
            # feedback = lfsr[15] ^ lfsr[4] ^ lfsr[2] ^ lfsr[1]
            feedback = (
                ((self.lfsr >> 15) & 1)
                ^ ((self.lfsr >> 4) & 1)
                ^ ((self.lfsr >> 2) & 1)
                ^ ((self.lfsr >> 1) & 1)
            )

            # lfsr <= {lfsr[14:0], feedback} + 1
            shifted = ((self.lfsr << 1) & 0xFFFE) | feedback
            self.lfsr = (shifted + 1) & 0xFFFF

        return self.lfsr


async def gen_lfsr_outputs(dut, N, cycles, start=1):
    """
    :param N: GEN_LFSR 中实例数量
    :param cycles: 运行的时钟周期数
    :param start: 是否使能 start
    :return: 每周期的 rand_out 和 sum_out
    """
    lfsrs = [LFSR16(seed=i) for i in range(N)]
    for cycle in range(cycles):
        await RisingEdge(dut.clk_i)
        rand_out = []
        sum_out = []
        for i in range(N):
            val = lfsrs[i].step(start)
            rand_out.append(val)
            sum_out.append(val & 0x1)  # rand_out[i][0]

        exp = "".join(map(str, sum_out))[::-1]
        get = dut.sum_out.value
        # print(f"cycle: {cycle}, exp: {exp}, get: {get}")
        custom_assert(str(exp) == str(get), f"sum_out compare fail! exp:{exp} get:{get} ")


@cocotb.test()
async def test_clb_high_lut_usage(dut):
    """测试旋转方向监测功能"""
    cocotb.log.info("Starting edge detection test")

    tb = TB(dut)

    # 初始化输入为低电平
    dut.clk_i.value = 0
    dut.rst_ni.value = 0
    dut.start.value = 0

    # 启动时钟, 初始复位
    await tb.setup_clock()
    await tb.reset_dut()
    dut.start.value = 1
    await tb.wait_clocks(1)
    await gen_lfsr_outputs(dut, 5, 200)
    await tb.wait_clocks(50)


# 测试运行器入口点
if __name__ == "__main__":
    print("CocoTB testbench for clb_high_lut_usage module")
    print("Run with: cocotb")
