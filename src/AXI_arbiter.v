`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/23 16:04:36
// Design Name: 
// Module Name: AXI_arbiter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



// States for Priority
`define M0 3'd0
`define M1 3'd1
`define M2 3'd2
`define M3 3'd3
`define M4 3'd4
`define M5 3'd5

module AXI_arbiter(rst, mode, clk, AWVALID, M_sel);
    input rst;
    input mode;
    input clk;
    input [5:0] AWVALID;
    output reg [5:0] M_sel;
    
    wire [5:0] M_sel0, M_sel1;
    
    fixed_priority u0 (.rst(rst), .clk(clk), .AWVALID(AWVALID), .M_sel(M_sel0));
    LRG u1 (.rst(rst), .clk(clk), .AWVALID(AWVALID), .M_sel(M_sel1));
    
    always @ (posedge clk)
    begin
        if (mode == 1'b0) // Fixed Priority : default
            M_sel <= M_sel0;
        else if (mode == 1'b1) // LRG Scheme
            M_sel <= M_sel1;
    end
endmodule

module fixed_priority (rst, clk, AWVALID, M_sel);
    input rst, clk;
    input [5:0] AWVALID; // AWVALID[N] : Master N
    output reg [5:0] M_sel; // Selected Master
    
    reg [3:0] aging_cnt [5:0];
    reg [2:0] state, n_state;
    
    parameter n = 9;
    
    integer i;
        
    always @ (posedge clk)
    begin
        if (rst)
            for (i = 0; i < 6 ; i = i + 1)
                aging_cnt[i] <= 4'd0;
        else
            for (i = 1; i < 6; i = i + 1) // M0 is Highest Priority in defualt, no need to Aging
            begin
                if ((AWVALID[i] == 1'b1) && (M_sel[i] != 1'b1))
                    aging_cnt[i] <= aging_cnt[i] + 1'b1;
                else
                    aging_cnt[i] <= 4'd0; 
            end
    end
    
    // FSM for an Signal       
    // 1. Sequential Part
    always @ (posedge clk)
    begin
        if (rst)
            state <= `M0;
        else
            state <= n_state;
    end
    
    // 2. Combinational Part
    always @ (*)
    begin
        case (state)
            `M0 : begin
                           if ((aging_cnt[1] > n) && (aging_cnt[1] > aging_cnt[2]) && (aging_cnt[1] > aging_cnt[3]) && (aging_cnt[1] > aging_cnt[4]) && (aging_cnt[1] > aging_cnt[5]))
                               n_state = `M1;
                           else if ((aging_cnt[2] > n) && (aging_cnt[2] > aging_cnt[1]) && (aging_cnt[2] > aging_cnt[3]) && (aging_cnt[2] > aging_cnt[4]) && (aging_cnt[2] > aging_cnt[5]))
                               n_state = `M2;
                           else if ((aging_cnt[3] > n) && (aging_cnt[3] > aging_cnt[1]) && (aging_cnt[3] > aging_cnt[2]) && (aging_cnt[3] > aging_cnt[4]) && (aging_cnt[3] > aging_cnt[5]))
                               n_state = `M3;
                           else if ((aging_cnt[4] > n) && (aging_cnt[4] > aging_cnt[1]) && (aging_cnt[4] > aging_cnt[2]) && (aging_cnt[4] > aging_cnt[3]) && (aging_cnt[4] > aging_cnt[5]))
                               n_state = `M4;
                           else if ((aging_cnt[5] > n) && (aging_cnt[5] > aging_cnt[1]) && (aging_cnt[5] > aging_cnt[2]) && (aging_cnt[5] > aging_cnt[3]) && (aging_cnt[5] > aging_cnt[4]))
                               n_state = `M5;
                           else
                               n_state = `M0;
                       end
            `M1 : begin 
                           if ((aging_cnt[2] > n) && (aging_cnt[2] > aging_cnt[1]) && (aging_cnt[2] > aging_cnt[3]) && (aging_cnt[2] > aging_cnt[4]) && (aging_cnt[2] > aging_cnt[5]))
                               n_state = `M2;
                           else if ((aging_cnt[3] > n) && (aging_cnt[3] > aging_cnt[1]) && (aging_cnt[3] > aging_cnt[2]) && (aging_cnt[3] > aging_cnt[4]) && (aging_cnt[3] > aging_cnt[5]))
                               n_state = `M3;
                           else if ((aging_cnt[4] > n) && (aging_cnt[4] > aging_cnt[1]) && (aging_cnt[4] > aging_cnt[2]) && (aging_cnt[4] > aging_cnt[3]) && (aging_cnt[4] > aging_cnt[5]))
                               n_state = `M4;
                           else if ((aging_cnt[5] > n) && (aging_cnt[5] > aging_cnt[1]) && (aging_cnt[5] > aging_cnt[2]) && (aging_cnt[5] > aging_cnt[3]) && (aging_cnt[5] > aging_cnt[4]))
                               n_state = `M5;
                           else if (!AWVALID[1])
                               n_state = `M0;
                           else
                               n_state = `M1;                         
                       end
            `M2 : begin 
                           if ((aging_cnt[1] > n) && (aging_cnt[1] > aging_cnt[2]) && (aging_cnt[1] > aging_cnt[3]) && (aging_cnt[1] > aging_cnt[4]) && (aging_cnt[1] > aging_cnt[5]))
                               n_state = `M1;
                           else if ((aging_cnt[3] > n) && (aging_cnt[3] > aging_cnt[1]) && (aging_cnt[3] > aging_cnt[2]) && (aging_cnt[3] > aging_cnt[4]) && (aging_cnt[3] > aging_cnt[5]))
                               n_state = `M3;
                           else if ((aging_cnt[4] > n) && (aging_cnt[4] > aging_cnt[1]) && (aging_cnt[4] > aging_cnt[2]) && (aging_cnt[4] > aging_cnt[3]) && (aging_cnt[4] > aging_cnt[5]))
                               n_state = `M4;
                           else if ((aging_cnt[5] > n) && (aging_cnt[5] > aging_cnt[1]) && (aging_cnt[5] > aging_cnt[2]) && (aging_cnt[5] > aging_cnt[3]) && (aging_cnt[5] > aging_cnt[4]))
                               n_state = `M5;
                           else if (!AWVALID[2])
                               n_state = `M0;
                           else
                               n_state = `M2;                         
                       end
            `M3 : begin 
                           if ((aging_cnt[1] > n) && (aging_cnt[1] > aging_cnt[2]) && (aging_cnt[1] > aging_cnt[3]) && (aging_cnt[1] > aging_cnt[4]) && (aging_cnt[1] > aging_cnt[5]))
                               n_state = `M1;
                           else if ((aging_cnt[2] > n) && (aging_cnt[2] > aging_cnt[1]) && (aging_cnt[2] > aging_cnt[3]) && (aging_cnt[2] > aging_cnt[4]) && (aging_cnt[2] > aging_cnt[5]))
                               n_state = `M2;
                           else if ((aging_cnt[4] > n) && (aging_cnt[4] > aging_cnt[1]) && (aging_cnt[4] > aging_cnt[2]) && (aging_cnt[4] > aging_cnt[3]) && (aging_cnt[4] > aging_cnt[5]))
                               n_state = `M4;
                           else if ((aging_cnt[5] > n) && (aging_cnt[5] > aging_cnt[1]) && (aging_cnt[5] > aging_cnt[2]) && (aging_cnt[5] > aging_cnt[3]) && (aging_cnt[5] > aging_cnt[4]))
                               n_state = `M5;
                           else if (!AWVALID[3])
                               n_state = `M0;
                           else
                               n_state = `M3;
                       end
            `M4 : begin 
                           if ((aging_cnt[1] > n) && (aging_cnt[1] > aging_cnt[2]) && (aging_cnt[1] > aging_cnt[3]) && (aging_cnt[1] > aging_cnt[4]) && (aging_cnt[1] > aging_cnt[5]))
                               n_state = `M1;
                           else if ((aging_cnt[2] > n) && (aging_cnt[2] > aging_cnt[1]) && (aging_cnt[2] > aging_cnt[3]) && (aging_cnt[2] > aging_cnt[4]) && (aging_cnt[2] > aging_cnt[5]))
                               n_state = `M2;
                           else if ((aging_cnt[3] > n) && (aging_cnt[3] > aging_cnt[1]) && (aging_cnt[3] > aging_cnt[2]) && (aging_cnt[3] > aging_cnt[4]) && (aging_cnt[3] > aging_cnt[5]))
                               n_state = `M3;
                           else if ((aging_cnt[5] > n) && (aging_cnt[5] > aging_cnt[1]) && (aging_cnt[5] > aging_cnt[2]) && (aging_cnt[5] > aging_cnt[3]) && (aging_cnt[5] > aging_cnt[4]))
                               n_state = `M5;
                           else if (!AWVALID[4])
                               n_state = `M0;
                           else
                               n_state = `M4;
                       end
            `M5 : begin 
                           if ((aging_cnt[1] > n) && (aging_cnt[1] > aging_cnt[2]) && (aging_cnt[1] > aging_cnt[3]) && (aging_cnt[1] > aging_cnt[4]) && (aging_cnt[1] > aging_cnt[5]))
                               n_state = `M1;
                           else if ((aging_cnt[2] > n) && (aging_cnt[2] > aging_cnt[1]) && (aging_cnt[2] > aging_cnt[3]) && (aging_cnt[2] > aging_cnt[4]) && (aging_cnt[2] > aging_cnt[5]))
                               n_state = `M2;
                           else if ((aging_cnt[3] > n) && (aging_cnt[3] > aging_cnt[1]) && (aging_cnt[3] > aging_cnt[2]) && (aging_cnt[3] > aging_cnt[4]) && (aging_cnt[3] > aging_cnt[5]))
                               n_state = `M3;
                           else if ((aging_cnt[4] > n) && (aging_cnt[4] > aging_cnt[1]) && (aging_cnt[4] > aging_cnt[2]) && (aging_cnt[4] > aging_cnt[3]) && (aging_cnt[4] > aging_cnt[5]))
                               n_state = `M4;
                           else if (!AWVALID[5])
                               n_state = `M0;
                           else
                               n_state = `M5;                               
                       end
            default : n_state = `M0;
        endcase
    end
    
    // 3. Output Part
    always @ (*)
    begin
        case (state)
            `M0 : begin 
                           if (AWVALID[0])
                               M_sel = 6'b00_0001;
                           else if (AWVALID[1])
                               M_sel = 6'b00_0010;
                           else if (AWVALID[2])
                               M_sel = 6'b00_0100;
                           else if (AWVALID[3])
                               M_sel = 6'b00_1000;
                           else if (AWVALID[4])
                               M_sel = 6'b01_0000;
                           else if (AWVALID[5])
                               M_sel = 6'b10_0000;
                           else
                               M_sel = 6'b00_0000;                   
                       end
            `M1 : begin 
                           if (AWVALID[1])
                               M_sel = 6'b00_0010;
                           else if (AWVALID[0])
                               M_sel = 6'b00_0001;
                           else if (AWVALID[2])
                               M_sel = 6'b00_0100;
                           else if (AWVALID[3])
                               M_sel = 6'b00_1000;
                           else if (AWVALID[4])
                               M_sel = 6'b01_0000;
                           else if (AWVALID[5])
                               M_sel = 6'b10_0000;
                           else
                               M_sel = 6'b00_0000;                         
                       end
            `M2 : begin 
                           if (AWVALID[2])
                               M_sel = 6'b00_0100;
                           else if (AWVALID[0])
                               M_sel = 6'b00_0001;
                           else if (AWVALID[1])
                               M_sel = 6'b00_0010;
                           else if (AWVALID[3])
                               M_sel = 6'b00_1000;
                           else if (AWVALID[4])
                               M_sel = 6'b01_0000;
                           else if (AWVALID[5])
                               M_sel = 6'b10_0000;
                           else
                               M_sel = 6'b00_0000;                       
                       end
            `M3 : begin 
                           if (AWVALID[3])
                               M_sel = 6'b00_1000;
                           else if (AWVALID[0])
                               M_sel = 6'b00_0001;
                           else if (AWVALID[1])
                               M_sel = 6'b00_0010;
                           else if (AWVALID[2])
                               M_sel = 6'b00_0100;
                           else if (AWVALID[4])
                               M_sel = 6'b01_0000;
                           else if (AWVALID[5])
                               M_sel = 6'b10_0000;
                           else
                               M_sel = 6'b00_0000;                   
                       end
            `M4 : begin 
                           if (AWVALID[4])
                               M_sel = 6'b01_0000;
                           else if (AWVALID[0])
                               M_sel = 6'b00_0001;
                           else if (AWVALID[1])
                               M_sel = 6'b00_0010;
                           else if (AWVALID[2])
                               M_sel = 6'b00_0100;
                           else if (AWVALID[3])
                               M_sel = 6'b00_1000;
                           else if (AWVALID[5])
                               M_sel = 6'b10_0000;
                           else
                               M_sel = 6'b00_0000;                   
                       end       
            `M5 : begin 
                           if (AWVALID[5])
                               M_sel = 6'b10_0000;
                           else if (AWVALID[0])
                               M_sel = 6'b00_0001;
                           else if (AWVALID[1])
                               M_sel = 6'b00_0010;
                           else if (AWVALID[2])
                               M_sel = 6'b00_0100;
                           else if (AWVALID[3])
                               M_sel = 6'b00_1000;
                           else if (AWVALID[4])
                               M_sel = 6'b01_0000;
                           else
                               M_sel = 6'b00_0000;                   
                       end                       
            default : M_sel = 6'b00_0000;           
        endcase
    end
endmodule

module LRG(rst, clk, AWVALID, M_sel);
    input rst, clk;
    input [5:0] AWVALID;
    output reg [5:0] M_sel;
    
    // One-Hot Encoding
    reg [5:0] priority0;
    reg [5:0] priority1;
    reg [5:0] priority2;
    reg [5:0] priority3;
    reg [5:0] priority4;
    reg [5:0] priority5;    

    always @ (posedge clk)
    begin
        if (rst)
            M_sel <= 6'b0;
        else if (M_sel == 6'b0) begin
             if (AWVALID & priority0)
                M_sel <= priority0;
            else if (AWVALID & priority1)
                M_sel <= priority1;
            else if (AWVALID & priority2)
                M_sel <= priority2;
            else if (AWVALID & priority3)
                M_sel <= priority3;
            else if (AWVALID & priority4)
                M_sel <= priority4;
            else if (AWVALID & priority5)
                M_sel <= priority5;
        end
        else if (!(AWVALID & M_sel))
            M_sel <= 6'b00_0000;
    end
            
    always @ (posedge clk)
    begin
        if (rst) begin // Default : M0 > M1 > M2 > M3 > M4 > M5
            priority0 <= 6'b00_0001;
            priority1 <= 6'b00_0010;
            priority2 <= 6'b00_0100;
            priority3 <= 6'b00_1000;
            priority4 <= 6'b01_0000;
            priority5 <= 6'b10_0000;
        end
        else if (M_sel == 6'b0) begin
            if (AWVALID & priority0) begin // If PR0 Granted => PR1~PR5 Shift to High Priority, PR0 Go Lowest
                priority0 <= priority1;
                priority1 <= priority2;
                priority2 <= priority3;
                priority3 <= priority4;
                priority4 <= priority5;
                priority5 <= priority0;
            end
            else if (AWVALID & priority1) begin // If PR1 Granted => PR2~PR5 Shift to High Priority, PR1 Go Lowest
                priority1 <= priority2;
                priority2 <= priority3;
                priority3 <= priority4;
                priority4 <= priority5;
                priority5 <= priority1;
            end
            else if (AWVALID & priority2) begin // If PR2 Granted => PR3~PR5 Shift to High Priority, PR2 Go Lowest
                priority2 <= priority3;
                priority3 <= priority4;
                priority4 <= priority5;
                priority5 <= priority2;
            end
            else if (AWVALID & priority3) begin // If PR3 Granted => PR4~PR5 Shift to High Priority, PR3 Go Lowest
                priority3 <= priority4;
                priority4 <= priority5;
                priority5 <= priority3;
            end
            else if (AWVALID & priority4) begin // If PR4 Granted => PR5 Shift to High Priority, PR4 Go Lowest
                priority4 <= priority5;
                priority5 <= priority4;
            end
        end // If PR5 Granted => PR5 Maintain to PR5
    end

endmodule