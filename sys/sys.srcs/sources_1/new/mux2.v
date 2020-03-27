`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/03/25 14:21:17
// Design Name: 
// Module Name: chinx_mux2
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

module chinx_mux2(
    input wire sel_i,
    input wire [`DATA_WIDTH - 1:0] data0_i,
    input wire [`DATA_WIDTH - 1:0] data1_i,
    output wire [`DATA_WIDTH - 1:0] data_o
);
assign data_o = (sel_i == 1'b0) ? data0_i : data1_i;
endmodule
