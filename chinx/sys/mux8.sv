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

module chinx_mux8 #(parameter MAX_DATA_WIDTH = 32)(
    input wire [2:0] sel_i,
    input wire [MAX_DATA_WIDTH - 1:0] data0_i,
    input wire [MAX_DATA_WIDTH - 1:0] data1_i,
    input wire [MAX_DATA_WIDTH - 1:0] data2_i,
    input wire [MAX_DATA_WIDTH - 1:0] data3_i,
    input wire [MAX_DATA_WIDTH - 1:0] data4_i,
    input wire [MAX_DATA_WIDTH - 1:0] data5_i,
    input wire [MAX_DATA_WIDTH - 1:0] data6_i,
    input wire [MAX_DATA_WIDTH - 1:0] data7_i,
    output reg [MAX_DATA_WIDTH - 1:0] data_o
);
always_comb
case(sel_i)
3'b000 : data_o = data0_i;
3'b001 : data_o = data1_i;
3'b010 : data_o = data2_i;
3'b011 : data_o = data3_i;
3'b100 : data_o = data4_i;
3'b101 : data_o = data5_i;
3'b110 : data_o = data6_i;
default: data_o = data7_i;
endcase
endmodule
