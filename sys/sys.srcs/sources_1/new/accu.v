`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/03/25
// Design Name: 
// Module Name: chinx_accu
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

module chinx_accu(
    input wire [`BUS_WIDTH - 1:0] num_i,
    output wire [`BUS_WIDTH - 1:0] num_o
);
assign num_o = num_i + 1;
endmodule