/*
 * tt_um_AXI_arbiter.v
 *
 * TinyTapeout wrapper for AXI_arbiter
 *
 * ui_in[0]   : mode (0: fixed priority, 1: LRG)
 * ui_in[6:1] : AWVALID[5:0]
 * uo_out[5:0]: M_sel[5:0]
 */

`default_nettype none

module tt_um_AXI_arbiter (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path (unused)
    output wire [7:0] uio_out,  // IOs: Output path (unused)
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset (global)
);

    //----------------------------------------------------------------
    // Reset 변환 (TT는 active-low, AXI_arbiter는 active-high라고 가정)
    //----------------------------------------------------------------
    wire rst = ~rst_n;  // rst_n == 0 → rst == 1

    //----------------------------------------------------------------
    // ui_in → 내부 신호 매핑
    //----------------------------------------------------------------
    wire       mode    = ui_in[0];     // mode
    wire [5:0] AWVALID = ui_in[6:1];   // AWVALID[5:0]

    //----------------------------------------------------------------
    // DUT: AXI_arbiter 인스턴스
    //----------------------------------------------------------------
    wire [5:0] M_sel;

    AXI_arbiter u_axi_arbiter (
        .rst    (rst),
        .mode   (mode),
        .clk    (clk),
        .AWVALID(AWVALID),
        .M_sel  (M_sel)
    );

    //----------------------------------------------------------------
    // 출력 매핑
    //----------------------------------------------------------------
    // M_sel을 uo_out[5:0]으로 내보내고, 나머지 비트는 0
    assign uo_out[5:0] = M_sel;
    assign uo_out[7:6] = 2'b00;

    //----------------------------------------------------------------
    // 사용하지 않는 양방향 IO는 전부 입력 모드 + 0
    //----------------------------------------------------------------
    assign uio_out = 8'h00;
    assign uio_oe  = 8'h00;

    //----------------------------------------------------------------
    // avoid linter warnings about unused pins
    //----------------------------------------------------------------
    // ena, ui_in[7], uio_in[*] 등이 아직 안 쓰이고 있으니 묶어서 "사용" 처리
    wire _unused_pins = &{ena, ui_in[7], uio_in};

endmodule  // tt_um_AXI_arbiter

`default_nettype wire
