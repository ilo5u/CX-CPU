`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/03/30
// Design Name: 
// Module Name: chinx_cop
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

module mem32_tb();

reg clk;
initial begin
    clk = 0;
    forever #2 clk = ~clk;
end

reg ce;
initial begin
    ce = 0;
    forever #6 ce = ~ce;
end

reg [7:0] addr;
initial begin
    addr = 0;
    forever #12 addr = addr + 4;
end

reg [31:0] data;
initial begin
    data = 0;
    forever #12 data = data + 4;
end

wire [31:0] dout;

chinx_mem32 mem32(
    .clk(clk),
    .ce(ce),
    .opnd(3'b000),
    .addr_i(addr),
    .data_i(data),
    .data_o(dout)
);

endmodule