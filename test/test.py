# test.py
# TinyTapeout-style cocotb testbench for tt_um_AXI_arbiter via tb.v

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer


def pack_ui_in(mode: int, awvalid: int) -> int:
    """
    tt_um_AXI_arbiter 매핑에 맞게 ui_in 값 구성:
      ui_in[0]   = mode
      ui_in[6:1] = AWVALID[5:0]
      ui_in[7]   = 0 (unused)
    """
    val = 0
    val |= (mode & 0x1)            # bit 0
    val |= (awvalid & 0x3F) << 1   # bits 6:1
    return val


@cocotb.test()
async def test_axi_arbiter(dut):
    """
    tb_AXI_arbiter.v에서 하던 패턴을
    TinyTapeout tb + tt_um_AXI_arbiter 구조에 맞춰서 재현한 테스트.
    dut = tb (tb.v)
    """

    dut._log.info("AXI_arbiter TT wrapper test start")

    # 초기값
    dut.clk.value    = 0
    dut.rst_n.value  = 0   # active-low reset (리셋 상태)
    dut.ena.value    = 0
    dut.ui_in.value  = 0
    dut.uio_in.value = 0

    # always #5 clk = ~clk;  → 10ns 주기
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    mode    = 0
    awvalid = 0

    def drive_inputs():
        dut.ui_in.value = pack_ui_in(mode, awvalid)

    drive_inputs()

    # #10 rst = 1; (원래 tb의 의미를 rst_n 기준으로 옮기면)
    await Timer(10, units="ns")
    dut.rst_n.value = 1   # reset 해제
    dut.ena.value   = 1
    dut._log.info("t=10ns: rst_n=1 (reset released), ena=1")

    # #100 rst = 0; mode = 0; // Fixed Priority
    await Timer(100, units="ns")
    mode    = 0
    awvalid = 0
    drive_inputs()
    dut._log.info("t=110ns: mode=0 (Fixed Priority)")

    # #100 AWVALID = 6'b01_0101;
    await Timer(100, units="ns")
    awvalid = 0b010101
    drive_inputs()
    dut._log.info("t=210ns: AWVALID=010101")
    dut._log.info(f"M_sel = {int(dut.M_sel.value):06b}")

    # #30 AWVALID = 6'b01_0100;
    await Timer(30, units="ns")
    awvalid = 0b010100
    drive_inputs()
    dut._log.info("t=240ns: AWVALID=010100")
    dut._log.info(f"M_sel = {int(dut.M_sel.value):06b}")

    # #40 AWVALID = 6'b01_0010;
    await Timer(40, units="ns")
    awvalid = 0b010010
    drive_inputs()
    dut._log.info("t=280ns: AWVALID=010010")
    dut._log.info(f"M_sel = {int(dut.M_sel.value):06b}")

    # #40 AWVALID = 6'b01_0001;
    await Timer(40, units="ns")
    awvalid = 0b010001
    drive_inputs()
    dut._log.info("t=320ns: AWVALID=010001")
    dut._log.info(f"M_sel = {int(dut.M_sel.value):06b}")

    # #50 begin AWVALID = 0; mode = 1; rst = 1; end
    await Timer(50, units="ns")
    awvalid = 0
    mode    = 1         # LRG Scheme
    drive_inputs()
    dut.rst_n.value = 0  # 다시 reset assert
    dut._log.info("t=370ns: mode=1 (LRG), AWVALID=0, rst_n=0 (reset asserted)")

    # #100 rst = 0;
    await Timer(100, units="ns")
    dut.rst_n.value = 1
    drive_inputs()
    dut._log.info("t=470ns: rst_n=1 (reset released, LRG mode 유지)")

    # #100 AWVALID = 6'b00_0010;
    await Timer(100, units="ns")
    awvalid = 0b000010
    drive_inputs()
    dut._log.info("t=570ns: AWVALID=000010 (M1)")
    dut._log.info(f"M_sel = {int(dut.M_sel.value):06b}")

    # #100 AWVALID = 0;
    await Timer(100, units="ns")
    awvalid = 0
    drive_inputs()
    dut._log.info("t=670ns: AWVALID=000000")

    # #100 AWVALID = 6'b01_0010;
    await Timer(100, units="ns")
    awvalid = 0b010010
    drive_inputs()
    dut._log.info("t=770ns: AWVALID=010010 (M4)")
    dut._log.info(f"M_sel = {int(dut.M_sel.value):06b}")

    # #100 AWVALID = 0;
    await Timer(100, units="ns")
    awvalid = 0
    drive_inputs()
    dut._log.info("t=870ns: AWVALID=000000")

    # #100 AWVALID = 6'b10_0010;
    await Timer(100, units="ns")
    awvalid = 0b100010
    drive_inputs()
    dut._log.info("t=970ns: AWVALID=100010 (M5)")
    dut._log.info(f"M_sel = {int(dut.M_sel.value):06b}")

    # #100 AWVALID = 0;
    await Timer(100, units="ns")
    awvalid = 0
    drive_inputs()
    dut._log.info("t=1070ns: AWVALID=000000")

    # #100 AWVALID = 6'b00_1010;
    await Timer(100, units="ns")
    awvalid = 0b001010
    drive_inputs()
    dut._log.info("t=1170ns: AWVALID=001010 (M3)")
    dut._log.info(f"M_sel = {int(dut.M_sel.value):06b}")

    # #100 $finish;
    await Timer(100, units="ns")
    dut._log.info("AXI_arbiter TT test finished")
