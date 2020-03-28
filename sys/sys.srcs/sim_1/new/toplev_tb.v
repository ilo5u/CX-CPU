`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/03/28 17:29:42
// Design Name: 
// Module Name: toplev_tb
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
`include "defines.vh"

module toplev_tb();

reg clk;
reg rst;
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end
initial begin
    rst = 0;
    #12 rst = ~rst;
    #15 rst = ~rst;
end
wire [`ADDR_WIDTH - 1:0] pc;
wire [`DATA_WIDTH - 1:0] instr;
wire stall;

chinx_pipeline pipeline(
    .clk(clk),
    .rst(rst),
    .pc(pc),
    .instr(instr),
    .stall(stall)
);

endmodule
