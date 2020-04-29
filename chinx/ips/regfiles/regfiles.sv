`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/04/20 13:48:39
// Design Name: 
// Module Name: CustomRegfiles
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

module CustomRegfiles #(parameter ADDR_WIDTH = 5, DATA_WIDTH = 32, NUM = 32)(
    input wire clk,
    input wire rst,
    
    input wire [ADDR_WIDTH - 1:0] raddr0_i,
    input wire [ADDR_WIDTH - 1:0] raddr1_i,
    
    input wire we_i,
    input wire [ADDR_WIDTH - 1:0] waddr_i,
    input wire [DATA_WIDTH - 1:0] wdata_i,
    // record interruption effects
    input wire be_i,
    
    output reg [DATA_WIDTH - 1:0] rdata0_o,
    output reg [DATA_WIDTH - 1:0] rdata1_o
);

reg [DATA_WIDTH - 1:0] files[0:NUM - 1];
integer i = 0;
initial begin
    for (i = 0; i < NUM; i = i + 1)
        files[i] <= 0;
end
// restore regfiles when interruption occured
reg [DATA_WIDTH - 1:0] backup[0:NUM - 1];
initial begin
    for (i = 0; i < NUM; i = i + 1)
        backup[i] <= 0;
end
reg be_r;

localparam ZERO = 0;
localparam TICK = 24;
localparam GP = 28;
localparam SP = 29;
localparam FP = 30;
localparam RA = 31;

localparam RESET = 2'b00;
localparam WBACK = 2'b01;
localparam RESTOR = 2'b10;
localparam BACKUP = 2'b11;
reg [1:0] sel;
always_comb
case (rst)
1'b1: sel <= RESET;
default:
case (we_i == 1'b1)
1'b1: sel <= (waddr_i != ZERO) ? WBACK : BACKUP;
default:
sel <= (be_i == 1'b0 && be_r == 1'b1) ? RESTOR : BACKUP;
endcase 
endcase

always_ff @(posedge clk) begin
    be_r <= be_i;
    case (sel)
    RESET: begin
        files[ZERO] <= 0;
        files[RA] <= 0;
        files[TICK] <= 0;
        files[SP] <= 128;
        files[GP] <= 128;
        files[FP] <= 128;
        files[1] <= 0;
        files[2] <= 0;
        files[3] <= 0;
        files[4] <= 0;
        files[5] <= 0;
        files[6] <= 0;
        files[7] <= 0;
        files[8] <= 0;
        files[9] <= 0;
        files[10] <= 0;
        files[11] <= 0;
        files[12] <= 0;
        files[13] <= 0;
        files[14] <= 0;
        files[15] <= 0;
        files[16] <= 0;
        files[17] <= 0;
        files[18] <= 0;
        files[19] <= 0;
        files[20] <= 0;
        files[21] <= 0;
        files[22] <= 0;
        files[23] <= 0;
        files[25] <= 0;
        files[26] <= 0;
        files[27] <= 0;
        backup[0] <= 0;
        backup[1] <= 0;
        backup[2] <= 0;
        backup[3] <= 0;
        backup[4] <= 0;
        backup[5] <= 0;
        backup[6] <= 0;
        backup[7] <= 0;
        backup[8] <= 0;
        backup[9] <= 0;
        backup[10] <= 0;
        backup[11] <= 0;
        backup[12] <= 0;
        backup[13] <= 0;
        backup[14] <= 0;
        backup[15] <= 0;
        backup[16] <= 0;
        backup[17] <= 0;
        backup[18] <= 0;
        backup[19] <= 0;
        backup[20] <= 0;
        backup[21] <= 0;
        backup[22] <= 0;
        backup[23] <= 0;
        backup[24] <= 0;
        backup[25] <= 0;
        backup[26] <= 0;
        backup[27] <= 0;
        backup[28] <= 128;
        backup[29] <= 128;
        backup[30] <= 128;
        backup[31] <= 0;
    end
    WBACK: files[waddr_i] <= wdata_i;
    RESTOR: begin
    files[1] <= backup[1];
    files[2] <= backup[2];
    files[3] <= backup[3];
    files[4] <= backup[4];
    files[5] <= backup[5];
    files[SP] <= backup[SP];
    files[GP] <= backup[GP];
    files[FP] <= backup[FP];
    files[RA] <= backup[RA];
    end
    default: begin
    backup[1] <= files[1];
    backup[2] <= files[2];
    backup[3] <= files[3];
    backup[4] <= files[4];
    backup[5] <= files[5];
    backup[SP] <= files[SP];
    backup[GP] <= files[GP];
    backup[FP] <= files[FP];
    backup[RA] <= files[RA];
    end
    endcase
end
assign rdata0_o = files[raddr0_i];
assign rdata1_o = files[raddr1_i];
endmodule
