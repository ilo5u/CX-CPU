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

reg rst;
initial begin
    rst = 0;
    #3 rst = ~rst;
    #4 rst = ~rst;
end

reg clk;
initial begin
    clk = 0;
    forever #2 clk = ~clk;
end

reg ireq;
reg [`INTR_VEC_WIDTH - 1:0] ivec;
initial begin
    ireq = 0;
    ivec = 0;
end

wire [`ADDR_WIDTH - 1:0] pc;
wire [`DATA_WIDTH - 1:0] instr;

chinx_pipeline pipeline(
    .clk(clk),
    .rst(rst),
    .ireq(ireq),
    .ivec(ivec),
    .pc(pc),
    .instr(instr)
);

endmodule
