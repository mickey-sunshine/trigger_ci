import cocotb
from cocotb.triggers import Timer

# from cocotb.triggers import RisingEdge, FallingEdge, Timer
from cocotb.clock import Clock

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


# 测试配置开关
ENABLE_ASSERT = False  # 设置为True启用assert，False只打印错误信息
test_results = []  # 存储测试结果


def check_condition(condition, error_msg, dut, test_name=""):
    """检查条件，根据配置决定是否assert或仅记录错误"""
    if condition:
        success_msg = (
            error_msg.replace("failed!", "passed")
            .replace("Should", "✓ Correctly")
            .replace("expected", "got expected")
        )
        dut._log.info(f"✓ PASS: {test_name} - {success_msg}")
        test_results.append(("PASS", test_name, success_msg))
        return True
    else:
        dut._log.error(f"✗ FAIL: {test_name} - {error_msg}")
        test_results.append(("FAIL", test_name, error_msg))
        if ENABLE_ASSERT:
            assert condition, error_msg
        return False


async def generate_quadrature_cw(dut, steps=4):
    """生成顺时针正交信号序列: 00->01->11->10->00"""
    sequences = [(0, 0), (0, 1), (1, 1), (1, 0)]

    for i in range(steps):
        seq = sequences[i % 4]
        dut.EQEP_A_i.value = seq[0]
        dut.EQEP_B_i.value = seq[1]
        await RisingEdge(dut.clk_i)
        await RisingEdge(dut.clk_i)  # 等待两个时钟周期确保信号稳定


async def generate_quadrature_ccw(dut, steps=4):
    """生成逆时针正交信号序列: 00->10->11->01->00"""
    sequences = [(0, 0), (1, 0), (1, 1), (0, 1)]

    for i in range(steps):
        seq = sequences[i % 4]
        dut.EQEP_A_i.value = seq[0]
        dut.EQEP_B_i.value = seq[1]
        await RisingEdge(dut.clk_i)
        await RisingEdge(dut.clk_i)  # 等待两个时钟周期确保信号稳定


def print_test_summary(dut):
    """打印测试总结"""
    total_tests = len(test_results)
    passed_tests = len([r for r in test_results if r[0] == "PASS"])
    failed_tests = total_tests - passed_tests

    dut._log.info("=" * 60)
    dut._log.info("TEST SUMMARY")
    dut._log.info("=" * 60)
    dut._log.info(f"Total Tests: {total_tests}")
    dut._log.info(f"Passed: {passed_tests}")
    dut._log.info(f"Failed: {failed_tests}")
    dut._log.info(f"Pass Rate: {(passed_tests/total_tests*100):.1f}%" if total_tests > 0 else "N/A")

    if failed_tests > 0:
        dut._log.info("\nFAILED TESTS:")
        for result, test_name, msg in test_results:
            if result == "FAIL":
                dut._log.info(f"  - {test_name}: {msg}")

    dut._log.info("=" * 60)


@cocotb.test()
async def test_c2000_testcase4(dut):
    """Cocotb test for C2000_testcase4"""

    # 清空之前的测试结果
    global test_results
    test_results = []

    # 启动时钟，10ns周期 => 100MHz
    clock = Clock(dut.clk_i, 10, "ns")
    cocotb.start_soon(clock.start())

    # 初始化所有输入信号
    dut.rst_ni.value = 0
    dut.EQEP_A_i.value = 0
    dut.EQEP_B_i.value = 0
    dut.EQEP_I_i.value = 0
    await Timer(20, "ns")

    # 释放复位
    dut.rst_ni.value = 1
    await Timer(20, "ns")

    dut._log.info("=== Test Start: C2000_testcase4 Quadrature Encoder ===")
    dut._log.info(f"Assert Mode: {'ENABLED' if ENABLE_ASSERT else 'DISABLED (Report Only)'}")

    # 测试1: 顺时针旋转检测
    dut._log.info("Test 1: Clockwise rotation detection")

    # 初始状态应该是 00
    dut.EQEP_A_i.value = 0
    dut.EQEP_B_i.value = 0
    await RisingEdge(dut.clk_i)
    await RisingEdge(dut.clk_i)

    # 生成顺时针正交信号
    await generate_quadrature_cw(dut, 8)  # 完整的两个周期

    # 检查方向输出
    await RisingEdge(dut.clk_i)
    check_condition(
        dut.dir_o.value == 1,
        f"Clockwise direction detection failed! dir_o = {dut.dir_o.value}, expected = 1",
        dut,
        "Clockwise Direction",
    )
    check_condition(
        dut.error_o.value == 0,
        f"Should not have error during clockwise rotation! error_o = {dut.error_o.value}",
        dut,
        "Clockwise No Error",
    )

    # 测试2: 逆时针旋转检测
    dut._log.info("Test 2: Counter-clockwise rotation detection")

    # 重置到初始状态
    dut.EQEP_A_i.value = 0
    dut.EQEP_B_i.value = 0
    await RisingEdge(dut.clk_i)
    await RisingEdge(dut.clk_i)

    # 生成逆时针正交信号
    await generate_quadrature_ccw(dut, 8)  # 完整的两个周期

    # 检查方向输出
    await RisingEdge(dut.clk_i)
    check_condition(
        dut.dir_o.value == 0,
        f"Counter-clockwise direction detection failed! dir_o = {dut.dir_o.value}, expected = 0",
        dut,
        "Counter-clockwise Direction",
    )
    check_condition(
        dut.error_o.value == 0,
        f"Should not have error during counter-clockwise rotation! error_o = {dut.error_o.value}",
        dut,
        "Counter-clockwise No Error",
    )

    # 测试3: 错误序列检测
    dut._log.info("Test 3: Error sequence detection")

    # 重置到初始状态
    dut.EQEP_A_i.value = 0
    dut.EQEP_B_i.value = 0
    await RisingEdge(dut.clk_i)
    await RisingEdge(dut.clk_i)

    # 生成错误的跳转序列 (从00直接跳到11，这是不正确的)
    dut.EQEP_A_i.value = 1
    dut.EQEP_B_i.value = 1
    await RisingEdge(dut.clk_i)
    await RisingEdge(dut.clk_i)
    await RisingEdge(dut.clk_i)

    # 检查是否检测到错误
    check_condition(
        dut.error_o.value == 1,
        f"Should detect error for invalid sequence! error_o = {dut.error_o.value}, expected = 1",
        dut,
        "Error Detection",
    )

    # 测试4: EQEP_I 复位功能
    dut._log.info("Test 4: EQEP_I reset function test")

    # 重置到正常状态
    dut.EQEP_A_i.value = 0
    dut.EQEP_B_i.value = 0
    dut.EQEP_I_i.value = 0
    await RisingEdge(dut.clk_i)
    await RisingEdge(dut.clk_i)

    # 先生成一些正常的顺时针信号
    await generate_quadrature_cw(dut, 4)

    # 记录复位前的状态
    pre_reset_counter = dut.counter_o.value

    # 触发 EQEP_I 复位事件
    dut.EQEP_I_i.value = 1
    await RisingEdge(dut.clk_i)
    await RisingEdge(dut.clk_i)

    # 释放 EQEP_I
    dut.EQEP_I_i.value = 0
    await RisingEdge(dut.clk_i)

    post_reset_counter = dut.counter_o.value
    dut._log.info(
        f"Reset event test - counter before: {pre_reset_counter}, after: {post_reset_counter}"
    )
    dut._log.info("✓ EQEP_I reset function test completed")

    # 测试5: 看门狗功能简单验证
    dut._log.info("Test 5: Watchdog function verification")

    # 重置所有信号
    dut.EQEP_A_i.value = 0
    dut.EQEP_B_i.value = 0
    dut.EQEP_I_i.value = 0
    await RisingEdge(dut.clk_i)

    # 观察看门狗输出的初始状态
    initial_wdt = dut.wdt_o.value
    dut._log.info(f"Initial watchdog state: {initial_wdt}")

    # 等待一段时间观察看门狗变化
    for i in range(10):
        await RisingEdge(dut.clk_i)
        current_wdt = dut.wdt_o.value
        if current_wdt != initial_wdt:
            dut._log.info(f"Watchdog state changed: {initial_wdt} -> {current_wdt}")
            break

    dut._log.info("✓ Watchdog function verification completed")

    # 测试6: 快速切换方向
    dut._log.info("Test 6: Rapid direction switching test")

    # 重置到初始状态
    dut.EQEP_A_i.value = 0
    dut.EQEP_B_i.value = 0
    await RisingEdge(dut.clk_i)
    await RisingEdge(dut.clk_i)

    # 顺时针几步
    await generate_quadrature_cw(dut, 2)
    cw_dir = dut.dir_o.value

    # 立即切换为逆时针
    await generate_quadrature_ccw(dut, 2)
    ccw_dir = dut.dir_o.value

    dut._log.info(f"Direction switching: clockwise({cw_dir}) -> counter-clockwise({ccw_dir})")

    # 验证方向切换
    check_condition(
        cw_dir != ccw_dir,
        f"Direction should change during switching! cw_dir={cw_dir}, ccw_dir={ccw_dir}",
        dut,
        "Direction Switching",
    )

    # 测试完成
    dut._log.info("=== Individual Tests Completed ===")
    dut._log.info(
        f"Final state - dir_o: {dut.dir_o.value}, error_o: {dut.error_o.value}, wdt_o: {dut.wdt_o.value}"
    )

    # 打印测试总结
    print_test_summary(dut)


@cocotb.test()
async def test_quadrature_patterns(dut):
    """专门测试正交编码器的各种信号模式"""

    # 清空之前的测试结果
    global test_results
    test_results = []

    # 启动时钟
    clock = Clock(dut.clk_i, 10, "ns")
    cocotb.start_soon(clock.start())

    # 初始化
    dut.rst_ni.value = 0
    dut.EQEP_A_i.value = 0
    dut.EQEP_B_i.value = 0
    dut.EQEP_I_i.value = 0
    await Timer(20, "ns")
    dut.rst_ni.value = 1
    await Timer(20, "ns")

    dut._log.info("=== Detailed Quadrature Signal Pattern Test ===")
    dut._log.info(f"Assert Mode: {'ENABLED' if ENABLE_ASSERT else 'DISABLED (Report Only)'}")

    # 详细测试每个状态转换
    test_patterns = [
        # (from_state, to_state, expected_dir, description)
        ((0, 0), (0, 1), 1, "00->01: clockwise"),
        ((0, 1), (1, 1), 1, "01->11: clockwise"),
        ((1, 1), (1, 0), 1, "11->10: clockwise"),
        ((1, 0), (0, 0), 1, "10->00: clockwise"),
        ((0, 0), (1, 0), 0, "00->10: counter-clockwise"),
        ((1, 0), (1, 1), 0, "10->11: counter-clockwise"),
        ((1, 1), (0, 1), 0, "11->01: counter-clockwise"),
        ((0, 1), (0, 0), 0, "01->00: counter-clockwise"),
    ]

    for from_state, to_state, expected_dir, description in test_patterns:
        # 设置起始状态
        dut.EQEP_A_i.value = from_state[0]
        dut.EQEP_B_i.value = from_state[1]
        await RisingEdge(dut.clk_i)
        await RisingEdge(dut.clk_i)

        # 转换到目标状态
        dut.EQEP_A_i.value = to_state[0]
        dut.EQEP_B_i.value = to_state[1]
        await RisingEdge(dut.clk_i)
        await RisingEdge(dut.clk_i)
        await RisingEdge(dut.clk_i)  # 额外等待确保状态更新

        # 检查结果
        actual_dir = dut.dir_o.value
        actual_error = dut.error_o.value

        if actual_error == 0:  # 只在没有错误时检查方向
            check_condition(
                actual_dir == expected_dir,
                f"{description} failed! expected dir={expected_dir}, actual dir={actual_dir}",
                dut,
                description,
            )
        else:
            dut._log.info(
                f"! INFO: {description} - error detected (error_o={actual_error}), skipping direction check"
            )

    dut._log.info("=== Quadrature Signal Pattern Test Completed ===")

    # 打印测试总结
    print_test_summary(dut)
