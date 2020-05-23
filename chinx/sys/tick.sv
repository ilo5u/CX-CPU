`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/04/21 11:57:40
// Design Name: 
// Module Name: chinx_tick
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


module chinx_tick(
    input wire clk,
    input wire rst,
    output reg ireq
);
// ticker would turn over signal of the 'ireq' pin
// every 20ms
localparam period = 50000;
reg [31:0] div;
always_ff @(posedge clk)
if (rst == 1'b1) begin
    div <= 0;
    ireq <= 1'b0;
end else if (div < period) begin
    div <= div + 1;
end else begin
    div <= 0;
    ireq <= ~ireq;
end
endmodule
