`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/03/27 15:23:33
// Design Name: 
// Module Name: chinx_stage2
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

module chinx_stage2(
    input clk,
    input mulclk,
    input ramclk,
    input rst,

    input wire [`ADDR_WIDTH - 1:0] pc_i,
    input wire [`INS_WIDTH - 1:0] instr_i,

    input wire [`DATA_WIDTH - 1:0] load_i,

    output wire [`ADDR_WIDTH - 1:0] addr_o,
    output wire [`DATA_WIDTH - 1:0] store_o,
    output wire stall
);

chinx_emit emit(
    
);

endmodule
