`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/04/01 11:05:25
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


module toplev_tb();

reg clk;
initial begin 
    clk = 0;
    forever #5 clk = ~clk;
end

reg rwe;
initial begin
    rwe = 1;
    forever #15 rwe = ~rwe;
end

reg [7:0] addr;
reg [31:0] in;
initial begin
    addr = 0;
    forever #30 addr = addr + 4;
end

initial begin
    in = 0;
    forever #30 in = in + 1;
end

wire [31:0] out;

chinx_ram32 #(3,8,32) ram32(
.ramclk(clk),
.ce(1'b1),
.rwe(rwe),
.opnd(3'd0),
.addr_i(addr),
.data_i(in),
.data_o(out));
endmodule
