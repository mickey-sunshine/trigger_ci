import random
import cocotb
from cocotb.triggers import Timer, Event
from cocotb.types import LogicArray

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


async def pwm1_generator(dut, comb_done_event):
    """PWM1信号生成器"""
    cocotb.log.info("Starting test mode:00")
    dut.mode_i.value = LogicArray("00")
    for _ in range(100):
        dut.pwm1a_i.value = random.randint(0, 1)
        dut.pwm1b_i.value = random.randint(0, 1)
        await Timer(10, "ns")

    cocotb.log.info("Starting test mode:01")
    dut.mode_i.value = LogicArray("01")
    for _ in range(100):
        dut.pwm1a_i.value = random.randint(0, 1)
        dut.pwm1b_i.value = random.randint(0, 1)
        await Timer(10, "ns")

    cocotb.log.info("Starting test mode:10")
    dut.mode_i.value = LogicArray("10")
    for _ in range(100):
        dut.pwm1a_i.value = random.randint(0, 1)
        dut.pwm1b_i.value = random.randint(0, 1)
        await Timer(10, "ns")

    cocotb.log.info("Test done")
    comb_done_event.set()


async def pwm1o_monitor(dut, comb_done_event):
    """测试组合逻辑输出"""
    while not comb_done_event.is_set():
        await Timer(100, "ps")
        out_a = int(dut.pwm1a_i.value)
        out_b = int(dut.pwm1b_i.value)
        if dut.mode_i.value == "00":
            pass
        elif dut.mode_i.value == "01":
            if dut.pwm1a_i.value == 0 and dut.pwm1b_i.value == 0:
                out_a = 1
                out_b = 1
        elif dut.mode_i.value == "10":
            if dut.pwm1a_i.value == 1 and dut.pwm1b_i.value == 1:
                out_a = 0
                out_b = 0
        else:
            pass

        custom_assert(
            int(dut.pwm1a_m_o.value) == out_a,
            f"pwm1a_m_o error,expect:{out_a},actual:{int(dut.pwm1a_m_o.value)}",
        )
        custom_assert(
            int(dut.pwm1b_m_o.value) == out_b,
            f"pwm1b_m_o error,expect:{out_b},actual:{int(dut.pwm1b_m_o.value)}",
        )


@cocotb.test()
async def test_c2k_comb_logic(dut):
    """测试组合逻辑输出"""

    # 初始化输入为低电平

    dut.mode_i.value = 0
    dut.pwm1a_i.value = 0
    dut.pwm1b_i.value = 0
    await Timer(10, "ns")
    comb_logic_event = Event()

    cocotb.start_soon(pwm1o_monitor(dut, comb_logic_event))
    await pwm1_generator(dut, comb_logic_event)

    dut.mode_i.value = 0
    dut.pwm1a_i.value = 0
    dut.pwm1b_i.value = 0
    await Timer(100, "ns")


# 测试运行器入口点
if __name__ == "__main__":
    print("CocoTB testbench for clb_high_lut_usage module")
    print("Run with: cocotb")
