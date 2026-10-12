import random
import cocotb
from cocotb.clock import Clock

# from cocotb.triggers import Timer, RisingEdge, FallingEdge
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


@cocotb.test()
async def test_C2000_PWM_rstp(dut):
    """
    Cocotb 测试用例：验证 C2000_test 模块中 PWM 产生的正确性。
    """

    # 时钟：周期 10ns（100MHz）
    cocotb.start_soon(Clock(dut.clk_i, 10, "ns").start())

    # 复位信号
    dut.rst_i.value = 1
    dut.e0.value = 0
    dut.e1.value = 0
    await Timer(20, "ns")  # 保持复位至少两个周期
    dut.rst_i.value = 0
    await RisingEdge(dut.clk_i)  # 等待一个上升沿，确保复位完成

    # 让模块稳定几个周期
    for _ in range(5):
        await RisingEdge(dut.clk_i)

    # FSM 状态定义（测试内使用）
    OPENED = 0  # 已打开
    CLOSING = 1  # 正在关闭
    CLOSED = 3  # 已关闭
    OPENING = 2  # 正在打开
    current_state = OPENED

    # 检查复位后 PWM 输出应该是低（没有活动 PWM）
    assert (
        int(dut.pwm_opening.value) == 0 and int(dut.pwm_closing.value) == 0
    ), "复位后 PWM 输出应该为低电平"

    # 辅助函数：在指定状态下测量一定时钟周期内 PWM 的高电平个数
    async def measure_pwm_cycles(duration_cycles, state_to_measure):
        high_count = 0
        total_count = 0
        for _ in range(duration_cycles):
            await RisingEdge(dut.clk_i)
            total_count += 1
            if state_to_measure == OPENING:
                if int(dut.pwm_opening.value) == 1:
                    high_count += 1
            elif state_to_measure == CLOSING:
                if int(dut.pwm_closing.value) == 1:
                    high_count += 1
        return high_count, total_count

    # 根据 FSM 逻辑更新当前状态（仅用于测试代码验证，实际 DUT 内部状态不可直接读取）
    def fsm_next_state(curr, e0_val, e1_val):
        if curr == OPENED:
            return CLOSING if e0_val == 1 else OPENED
        elif curr == CLOSING:
            if e1_val == 0:
                return CLOSING
            else:
                return CLOSED if e0_val == 0 else OPENING
        elif curr == CLOSED:
            return OPENING if e0_val == 1 else CLOSED
        elif curr == OPENING:
            if e1_val == 0:
                return OPENING
            else:
                return OPENED if e0_val == 0 else CLOSING
        return OPENED

    # 记录期望占空比（MATCH1_VAL=65, LOAD_VAL=100）
    expected_duty = 65 / 100.0  # 约0.65

    # ==== 测试序列开始 ====

    # 1. 从 OPENED 转到 CLOSING
    dut.e0.value = 1
    dut.e1.value = 0
    await RisingEdge(dut.clk_i)  # 状态应变为 CLOSING
    current_state = CLOSING
    # 拉低 e0，保持 CLOSING 状态
    dut.e0.value = 0

    # 测量 CLOSING 状态下的 PWM (pwm_closing)
    # measure_cycles = random.randint(200, 400)
    measure_cycles = 300
    print(f"CLOSING:{measure_cycles}")
    high, total = await measure_pwm_cycles(measure_cycles, CLOSING)
    duty = high / total if total > 0 else 0
    assert (
        abs(duty - expected_duty) < 0.05
    ), f"CLOSING 状态下 PWM 占空比 {duty:.2f} 与预期 {expected_duty:.2f} 相差过大"

    # 转换到 CLOSED (设置 e1=1)
    dut.e1.value = 1
    await RisingEdge(dut.clk_i)  # 状态应变为 CLOSED
    current_state = CLOSED

    # 在 CLOSED 状态保持一段随机周期，不应有 PWM 输出
    # hold_cycles = random.randint(50, 100)
    hold_cycles = 50
    for _ in range(hold_cycles):
        await RisingEdge(dut.clk_i)
    assert (
        int(dut.pwm_opening.value) == 0 and int(dut.pwm_closing.value) == 0
    ), "CLOSED 状态下 PWM 输出应当为低电平"

    # 2. 从 CLOSED 转到 OPENING (设置 e0=1)
    dut.e0.value = 1
    dut.e1.value = 0
    await RisingEdge(dut.clk_i)  # 状态应变为 OPENING
    current_state = OPENING
    dut.e0.value = 0

    # 测量 OPENING 状态下的 PWM (pwm_opening)
    # measure_cycles = random.randint(200, 400)
    measure_cycles = 200
    print(f"OPENING:{measure_cycles}")
    high, total = await measure_pwm_cycles(measure_cycles, OPENING)
    duty = high / total if total > 0 else 0
    assert (
        abs(duty - expected_duty) < 0.05
    ), f"OPENING 状态下 PWM 占空比 {duty:.2f} 与预期 {expected_duty:.2f} 相差过大"

    # 3. 从 OPENING 转到 OPENED (设置 e1=1, e0=0)
    dut.e1.value = 1
    await RisingEdge(dut.clk_i)  # 状态应变为 OPENED
    current_state = OPENED

    # 在 OPENED 状态保持一段周期，不应有 PWM 输出
    # hold_cycles = random.randint(50, 100)
    hold_cycles = 60
    for _ in range(hold_cycles):
        await RisingEdge(dut.clk_i)
    assert (
        int(dut.pwm_opening.value) == 0 and int(dut.pwm_closing.value) == 0
    ), "OPENED 状态下 PWM 输出应当为低电平"

    # 结束时记录
    await RisingEdge(dut.clk_i)
    cocotb.log.info("PWM 生成测试完成")
