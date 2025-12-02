`default_nettype none
`timescale 1ns/1ps

/*
testbench는 단순히 tt_um 모듈을 인스턴스하고
cocotb의 test.py에서 제어하기 편하게 신호를 꺼내두는 역할만 한다.
*/

module tb ();

    // VCD 덤프
    initial begin
        $dumpfile ("tb.vcd");
        $dumpvars (0, tb);
        #1;
    end

    // 입력/출력 와이어링
    reg        clk;
    reg        rst_n;
    reg        ena;
    reg  [7:0] ui_in;
    reg  [7:0] uio_in;

    wire [7:0] uo_out;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;

    // AXI_arbiter의 출력 M_sel을 보기 쉽게 alias
    wire [5:0] M_sel = uo_out[5:0];

    // Gate-level 테스트용 power pins (선택적)
`ifdef GL_TEST
    wire VPWR = 1'b1;
    wire VGND = 1'b0;
`endif

    // DUT 인스턴스: tt_um_AXI_arbiter
    tt_um_AXI_arbiter dut (
    `ifdef GL_TEST
        .VPWR      (VPWR),
        .VGND      (VGND),
    `endif
        .ui_in     (ui_in),    // Dedicated inputs
        .uo_out    (uo_out),   // Dedicated outputs
        .uio_in    (uio_in),   // IOs: Input path
        .uio_out   (uio_out),  // IOs: Output path
        .uio_oe    (uio_oe),   // IOs: Enable path (active high: 0=input, 1=output)
        .ena       (ena),      // enable - goes high when design is selected
        .clk       (clk),      // clock
        .rst_n     (rst_n)     // active-low reset
    );

endmodule
