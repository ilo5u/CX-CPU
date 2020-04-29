`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/03/27 15:23:33
// Design Name: 
// Module Name: chinx_es32
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

module chinx_sext8(
    input wire [7:0] imm8_i,
    output wire [31:0] imm32_o
);
assign imm32_o = (imm8_i[7] == 1'b1) ? {24'hff_ffff, imm8_i} : {24'd0, imm8_i};
endmodule

module chinx_sext16(
    input wire [15:0] imm16_i,
    output wire [31:0] imm32_o
);
assign imm32_o = (imm16_i[15] == 1'b1) ? {16'hffff, imm16_i} : {16'd0, imm16_i};
endmodule