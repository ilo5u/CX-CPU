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

module chinx_cop(
    input wire clk,
    input wire [`ADDR_WIDTH - 1:0] pc,
    output reg [`ADDR_WIDTH - 1:0] epc
);

always @(posedge clk) begin
    epc <= pc;
end

endmodule