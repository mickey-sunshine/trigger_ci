import cocotb
import logging
import random
from cocotb.clock import Clock

# from cocotb.triggers import Timer, RisingEdge, Event
from cocotb.triggers import Timer, Event, ValueChange
from cocotb.types import LogicArray
from cocotb.utils import get_sim_time


async def RisingEdge(signal):
    await ValueChange(signal)
    # if not rising edge, keep waiting
    while signal.value != 1:
        await ValueChange(signal)


# Configuration parameters
PD_SYS_CLK = 10
PD_POR_DLY = 23
PD_PWM_CTRL = 1000


off_pwm_tmp = 0b000


async def config_logger(dut):
    # Configure python logging for cocotb
    logging.getLogger("cocotb").setLevel(logging.INFO)


async def generate_sys_clock(dut):
    """Generate system clock"""
    sys_clock = Clock(dut.clk_i, PD_SYS_CLK, "ns")
    cocotb.start_soon(sys_clock.start())


async def generate_sys_rst_ni(dut):
    """Generate system reset signal"""
    t_por_dly = Timer(PD_POR_DLY, "ns")

    dut.rst_ni.value = 0
    await t_por_dly
    dut.rst_ni.value = 1


async def generate_pwm_ctrl_loop_start_i(dut):
    """Generate pwm control loop start signal: pulse once every PD_PWM_CTRL clocks"""
    while True:
        # drive low for PD_PWM_CTRL-1 cycles
        for _ in range(PD_PWM_CTRL - 1):
            await RisingEdge(dut.clk_i)
            dut.pwm_ctrl_loop_start_i.value = LogicArray("0")
        # last cycle: pulse high for one clk
        await RisingEdge(dut.clk_i)
        dut.pwm_ctrl_loop_start_i.value = LogicArray("1")
        # ensure low again next cycle
        await RisingEdge(dut.clk_i)
        dut.pwm_ctrl_loop_start_i.value = LogicArray("0")


def check_pwm_known(dut):
    actual_bits = str(dut.pwm_o.value)
    assert all(bit in "01" for bit in actual_bits), f"X/Z detected on pwm_o: {actual_bits}"


def check_output(dut, expected, label):
    check_pwm_known(dut)
    actual = int(str(dut.pwm_o.value), 2)
    assert actual == expected, f"{label}: expected=0x{expected:05x}, actual=0x{actual:05x}"
    cocotb.log.info(f"PASS: {label} output=0x{actual:05x}")


def protected_group(pwm):
    result = pwm & 0b110110
    if pwm & 0b000010 and pwm & 0b000001 and not pwm & 0b001000:
        result |= 0b000001
    if pwm & 0b000100 and pwm & 0b001000 and not pwm & 0b000001:
        result |= 0b001000
    return result


def pack_groups(groups):
    return groups[0] | (groups[1] << 6) | (groups[2] << 12)


async def wait_cycles(dut, count):
    for _ in range(count):
        await RisingEdge(dut.clk_i)
        await Timer(1, "ns")
        if str(dut.rst_ni.value) == "1":
            check_pwm_known(dut)


@cocotb.test()
async def test_ae_case2(dut):
    """Check protected PWM mapping and asynchronous reset behavior."""
    await config_logger(dut)

    dut.clk_i.value = 0
    dut.rst_ni.value = 1
    # dut.off_pwm_prot_mode_i.value = 0
    # dut.off_pwm_trig_mode_i.value = 0
    # dut.off_pwm_trig_pol_i.value = 0
    # dut.pwm_ctrl_loop_start_i.value = 0
    # dut.off_pwm_msk_i.value = 0
    dut.off_pwm_i.value = 0
    dut.pwm_i.value = 0

    clock = Clock(dut.clk_i, 5, "ns")
    cocotb.start_soon(clock.start())

    await Timer(1, "ns")
    dut.rst_ni.value = 0
    await wait_cycles(dut, 3)
    check_output(dut, 0, "asynchronous reset clears all PWM outputs")

    dut.rst_ni.value = 1
    await wait_cycles(dut, 8)

    first_groups = (0b110111, 0b101110, 0b011011)
    dut.off_pwm_i.value = 0b111
    dut.pwm_i.value = pack_groups(first_groups)
    expected = pack_groups(tuple(protected_group(group) for group in first_groups))
    await wait_cycles(dut, 90)
    check_output(dut, expected, "steady-state protected PWM mapping")

    second_groups = (0b001101, 0b110011, 0b100110)
    dut.pwm_i.value = pack_groups(second_groups)
    expected = pack_groups(tuple(protected_group(group) for group in second_groups))
    await wait_cycles(dut, 90)
    check_output(dut, expected, "second protected PWM transition")

    dut.rst_ni.value = 0
    await Timer(1, "ns")
    check_output(dut, 0, "asynchronous reset after activity")
