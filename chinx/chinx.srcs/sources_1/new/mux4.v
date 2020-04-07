`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/03/25 14:21:17
// Design Name: 
// Module Name: chinx_mux4
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

module chinx_mux4 #(parameter MUX_DATA_WIDTH = 8)(
    input wire [1:0] sel_i,
    input wire [MUX_DATA_WIDTH - 1:0] data0_i,
    input wire [MUX_DATA_WIDTH - 1:0] data1_i,
    input wire [MUX_DATA_WIDTH - 1:0] data2_i,
    input wire [MUX_DATA_WIDTH - 1:0] data3_i,
    output wire [MUX_DATA_WIDTH - 1:0] data_o
);
assign data_o = (sel_i == 2'b00) ? data0_i :
    ((sel_i == 2'b01) ? data1_i : 
    ((sel_i == 2'b10) ? data2_i : data3_i));
endmodule
