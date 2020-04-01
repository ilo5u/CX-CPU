`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/03/27
// Design Name: 
// Module Name: chinx_mux8
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

module chinx_mux8(
    input wire [2:0] sel_i,
    input wire [`DATA_WIDTH - 1:0] data0_i,
    input wire [`DATA_WIDTH - 1:0] data1_i,
    input wire [`DATA_WIDTH - 1:0] data2_i,
    input wire [`DATA_WIDTH - 1:0] data3_i,
    input wire [`DATA_WIDTH - 1:0] data4_i,
    input wire [`DATA_WIDTH - 1:0] data5_i,
    input wire [`DATA_WIDTH - 1:0] data6_i,
    input wire [`DATA_WIDTH - 1:0] data7_i,
    output wire [`DATA_WIDTH - 1:0] data_o
);
assign data_o = (sel_i == 3'b000) ? data0_i :
    ((sel_i == 3'b001) ? data1_i : 
    ((sel_i == 3'b010) ? data2_i :
    ((sel_i == 3'b011) ? data3_i :
    ((sel_i == 3'b100) ? data4_i :
    ((sel_i == 3'b101) ? data5_i :
    ((sel_i == 3'b110) ? data6_i : data7_i))))));
endmodule
