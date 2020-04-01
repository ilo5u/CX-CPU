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

module chinx_ext32(
    input wire immext_i,
    input wire [`INSTR_IMM_WIDTH - 1:0] imm16_i,
    output wire [`DATA_WIDTH - 1:0] imm32_o
);

assign imm32_o = (immext_i == `EXT_SIGNED && imm16_i[15] == 1'b1) ?
    {16'hffff, imm16_i} : {16'h0000, imm16_i};

endmodule