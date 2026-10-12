import cocotb
import logging
import random
from cocotb.clock import Clock
from cocotb.triggers import Timer, Event, ValueChange
from cocotb.types import LogicArray
from typing import List


# Rising edge check (custom helper to avoid importing cocotb RisingEdge)
async def wait_rising_edge(signal):
    """Wait for a rising edge on a signal"""
    await ValueChange(signal)
    while signal.value != 1:  # wait for signal to go high
        await ValueChange(signal)


# Falling edge check (custom helper)
async def wait_falling_edge(signal):
    """Wait for a falling edge on a signal"""
    await ValueChange(signal)
    while signal.value != 0:  # wait for signal to go low
        await ValueChange(signal)


# Configuration parameters
PD_SYS_CLK = 10
PD_POR_DLY = 23
PD_PWM_CTRL = 1000


async def config_logger(dut):
    # Configure python logging for cocotb
    # logging.getLogger("cocotb.gpi").setLevel(logging.ERROR)
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


FSM_UNDEF = 0
FSM_P = 1
FSM_P_0P = 2
FSM_0P = 3
FSM_0P_0N = 4
FSM_0N = 5
FSM_0_N = 6
FSM_N = 7

SIG_STATE_UNDEF = LogicArray("000000", range=6)
SIG_STATE_P = LogicArray("100011", range=6)
SIG_STATE_P_0P = LogicArray("100010", range=6)
SIG_STATE_0P = LogicArray("110100", range=6)
SIG_STATE_0P_0N = LogicArray("110110", range=6)
SIG_STATE_0N = LogicArray("110100", range=6)
SIG_STATE_0N_N = LogicArray("010100", range=6)
SIG_STATE_N = LogicArray("011100", range=6)

sig_loop_cnt = 0


def to_18bit_str(val: int) -> str:
    return format(val, "018b")


# 预定义序列（可选）
DEFAULT_SEQUENCE_VALS = [
    0b010100100010100011,
    0b011100110010100010,
    0b010100110110110010,
    0b110100110100110110,
    0b110110010100110100,
    0b110010011100010100,
    0b100010010100011100,
    0b100011110100010100,
    0b100010110110110100,
    0b110010110010110110,
    0b110110100010110010,
    0b110100100011100010,
]

DEFAULT_SEQUENCE = [to_18bit_str(v) for v in DEFAULT_SEQUENCE_VALS]


async def drive_sig_i_on_ctrl_pulse(
    dut,
    sequence: List[str] = None,
    period_cycles: int = 100,
    sig_name: str = "sig_i",
    ctrl_sig_name: str = "sig_ctrl_loop_start_i",
):
    """
    Subroutine: Drive `sig_i` on every pulse of `sig_ctrl_loop_start_i`.

    Behavior:
      - Generates a single-cycle pulse on `ctrl_sig_name` every `period_cycles` clocks.
      - On the high cycle of the pulse, updates `sig_name` to next value in `sequence`.
      - Sequence loops infinitely.

    Args:
        dut: DUT handle
        sequence: List of 18-bit binary strings (e.g., ['000...01', ...])
        period_cycles: Number of clock cycles between pulses (>=2)
        sig_name: Name of the signal to drive (must be 18-bit)
        ctrl_sig_name: Name of the control pulse signal (1-bit output)
    """
    if sequence is None:
        sequence = DEFAULT_SEQUENCE

    if period_cycles < 2:
        raise ValueError("period_cycles must be >= 2 to generate a clean pulse")

    sig = getattr(dut, sig_name)
    ctrl_sig = getattr(dut, ctrl_sig_name)

    idx = 0
    num_vals = len(sequence)

    cocotb.log.info(
        f"Starting {ctrl_sig_name} synchronized driver for {sig_name} "
        f"(period={period_cycles} cycles, seq_len={num_vals})"
    )

    # Wait for first clock edge to align
    await wait_rising_edge(dut.clk_i)

    while True:
        # Hold ctrl low for (period_cycles - 1) cycles
        for _ in range(period_cycles - 1):
            await wait_rising_edge(dut.clk_i)
            ctrl_sig.value = 0

        # Pulse high and update sig_i
        await wait_rising_edge(dut.clk_i)
        ctrl_sig.value = 1
        sig.value = LogicArray(sequence[idx])
        idx = (idx + 1) % num_vals

        # Return ctrl to low
        await wait_rising_edge(dut.clk_i)
        ctrl_sig.value = 0


@cocotb.test()
async def test_ae_case3(dut):
    """Test shutdown control"""
    cocotb.log.info(
        "-------------------------------- Simulation Start --------------------------------"
    )
    await config_logger(dut)
    cocotb.start_soon(generate_sys_clock(dut))  # system clock start
    cocotb.start_soon(generate_sys_rst_ni(dut))  # reset signal

    # start pwm control loop start generator

    cocotb.log.info("- Clock and reset generated.")

    # dut.sig_i.value = LogicArray(value=0, range=18)
    # cocotb.start_soon(drive_sig_i_on_ctrl_pulse(dut, sequence=DEFAULT_SEQUENCE, period_cycles=100))

    # await wait_rising_edge(dut.rst_ni)

    # await wait_rising_edge(dut.clk_i)

    # # initial values
    # dut.sig_off_i.value = LogicArray(value="111", range=3)
    # dut.sig_off_msk_i.value = LogicArray(value="100010001", range=9)
    # dut.sig_off_prot_mode_i.value = LogicArray(value="000", range=3)
    # dut.sig_off_trig_mode_i.value = LogicArray(value="000", range=3)
    # dut.sig_off_trig_pol_i.value = LogicArray(value="010101", range=6)
    # # dut.sig_ctrl_loop_start_i.value = LogicArray(value=0, range=1)

    # await Timer(7430, "ns")
    # dut.sig_off_i.value = LogicArray(value="110", range=3)
    # await Timer(1300, "ns")
    # # dut.sig_off_i.value = LogicArray(value='100', range=3)
    # await Timer(1500, "ns")
    # # dut.sig_off_i.value = LogicArray(value='000', range=3)
    # # dut.sig_off_i.value = LogicArray(value='110', range=3)

    # await Timer(3750, "ns")
    # # dut.sig_off_i.value = LogicArray(value='001', range=3)
    # await Timer(3230, "ns")
    # # dut.sig_off_i.value = LogicArray(value='011', range=3)
    # await Timer(4110, "ns")
    # dut.sig_off_i.value = LogicArray(value="111", range=3)

    # await Timer(10, "us")
    cocotb.log.info(
        "--------------------------------  Simulation end  --------------------------------"
    )
