`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/04/02
// Design Name: 
// Module Name: chinx_mem32
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

module chinx_mem32(
    input wire clk,
    input wire ce,
    input wire [`MEM_OPND_WIDTH - 1:0] opnd,
    input wire [`ADDR_WIDTH - 1:0] addr_i,
    input wire [`DATA_WIDTH - 1:0] data_i,
    output wire [`DATA_WIDTH - 1:0] data_o
);
wire [5:0] caddr_w = addr_i[7:2];
wire [1:0] sel_w = addr_i[1:0];

wire [7:0] data0_w;
ram8 chip0(
    .a(caddr_w),
    .d(data_i[7:0]),
    .clk(clk),
    .we(ce & (sel_w == 2'b00)),
    .qspo(data0_w)
);

wire [7:0] data1_w;
ram8 chip1(
    .a(caddr_w),
    .d((sel_w == 2'b01) ? data_i[7:0] : data_i[15:8]),
    .clk(clk),
    .we(ce
        & (((sel_w == 2'b00) && (opnd == `MEM_OPND_HALF || opnd == `MEM_OPND_WORD))
            || (sel_w == 2'b01))),
    .qspo(data1_w)
);

wire [7:0] data2_w;
ram8 chip2(
    .a(caddr_w),
    .d((sel_w == 2'b00) ? data_i[23:16] : data_i[7:0]),
    .clk(clk),
    .we(ce
        & ((sel_w == 2'b00 && opnd == `MEM_OPND_WORD)
            || (sel_w == 2'b10))),
    .qspo(data2_w)
);

wire [7:0] data3_w;
ram8 chip3(
    .a(caddr_w),
    .d((sel_w == 2'b11) ? data_i[7:0] : ((sel_w == 2'b10) ? data_i[15:8] : data_i[31:24])),
    .clk(clk),
    .we(ce
        & (((sel_w == 2'b11) || (sel_w == 2'b10 && opnd == `MEM_OPND_HALF))
            | (opnd == `MEM_OPND_WORD))),
    .qspo(data3_w)
);

wire [15:0] half0_w = {data1_w, data0_w};
wire [31:0] sexthalf0_w;
chinx_sext16 sexthalf0(
    .imm16_i(half0_w),
    .imm32_o(sexthalf0_w)
);
wire [31:0] uexthalf0_w = {16'h0000, half0_w};

wire [15:0] half1_w = {data3_w, data2_w};
wire [31:0] sexthalf1_w;
chinx_sext16 sexthalf1(
    .imm16_i(half1_w),
    .imm32_o(sexthalf1_w)
);
wire [31:0] uexthalf1_w = {16'h0000, half1_w};

wire [31:0] sextbyte0_w;
chinx_sext8 sextbyte0(
    .imm8_i(data0_w),
    .imm32_o(sextbyte0_w)
);
wire [31:0] uextbyte0_w = {24'h00_0000, data0_w};

wire [31:0] sextbyte1_w;
chinx_sext8 sextbyte1(
    .imm8_i(data1_w),
    .imm32_o(sextbyte1_w)
);
wire [31:0] uextbyte1_w = {24'h00_0000, data1_w};

wire [31:0] sextbyte2_w;
chinx_sext8 sextbyte2(
    .imm8_i(data2_w),
    .imm32_o(sextbyte2_w)
);
wire [31:0] uextbyte2_w = {24'h00_0000, data2_w};

wire [31:0] sextbyte3_w;
chinx_sext8 sextbyte3(
    .imm8_i(data3_w),
    .imm32_o(sextbyte3_w)
);
wire [31:0] uextbyte3_w = {24'h00_0000, data3_w};

assign data_o = (opnd == `MEM_OPND_HALF && sel_w == 2'b00) ?
    sexthalf0_w : ((opnd == `MEM_OPND_HALF && sel_w == 2'b10) ? 
    sexthalf1_w : ((opnd == `MEM_OPND_HALFU && sel_w == 2'b00) ?
    uexthalf0_w : ((opnd == `MEM_OPND_HALFU && sel_w == 2'b10) ?
    uexthalf1_w : ((opnd == `MEM_OPND_BYTE && sel_w == 2'b00) ?
    sextbyte0_w : ((opnd == `MEM_OPND_BYTE && sel_w == 2'b01) ?
    sextbyte1_w : ((opnd == `MEM_OPND_BYTE && sel_w == 2'b10) ?
    sextbyte2_w : ((opnd == `MEM_OPND_BYTE && sel_w == 2'b11) ?
    sextbyte3_w : ((opnd == `MEM_OPND_BYTEU && sel_w == 2'b00) ?
    uextbyte0_w : ((opnd == `MEM_OPND_BYTEU && sel_w == 2'b01) ?
    uextbyte1_w : ((opnd == `MEM_OPND_BYTEU && sel_w == 2'b10) ?
    uextbyte2_w : ((opnd == `MEM_OPND_BYTEU && sel_w == 2'b11) ?
    uextbyte3_w : {data3_w, data2_w, data1_w, data0_w})))))))))));

endmodule