`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/04/23 13:00:09
// Design Name: 
// Module Name: CustomClockGen
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


module CustomClockGen(
    input wire clk,
    output wire clk_0,
    output reg  clk_1
);
assign clk_0 = clk;
reg clk_r;
initial begin
    clk_r = 1'b1;
end

always_ff @(negedge clk) begin
    clk_1 <= clk_r;
    if (clk_r == 1'b1)
        clk_r <= 1'b0;
    else
        clk_r <= 1'b1;
end
endmodule
