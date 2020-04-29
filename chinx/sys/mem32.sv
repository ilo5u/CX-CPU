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
    input wire rst,
    input wire ce,
    input wire [`MEM_OPND_WIDTH - 1:0] opnd,
    input wire [`ADDR_WIDTH - 1:0] addr_i,
    input wire [`DATA_WIDTH - 1:0] data_i,

    inout [`IO_PORT_WIDTH - 1:0] iodata0,
    inout [`IO_PORT_WIDTH - 1:0] iodata1,
    inout [`IO_PORT_WIDTH - 1:0] iodata2,
    inout [`IO_PORT_WIDTH - 1:0] iodata3,

    output reg [`DATA_WIDTH - 1:0] data_o
);
wire [5:0] caddr_w = addr_i[7:2];
wire [1:0] sel_w = addr_i[1:0];

wire ce0_w = (caddr_w == 6'd0) & (sel_w == 2'd0) 
    & (opnd == `MEM_OPND_BYTE || opnd == `MEM_OPND_BYTEU);
wire ce1_w = (caddr_w == 6'd0) & (sel_w == 2'd1) 
    & (opnd == `MEM_OPND_BYTE || opnd == `MEM_OPND_BYTEU);
wire ce2_w = (caddr_w == 6'd0) & (sel_w == 2'd2) 
    & (opnd == `MEM_OPND_BYTE || opnd == `MEM_OPND_BYTEU);
wire ce3_w = (caddr_w == 6'd0) & (sel_w == 2'd3) 
    & (opnd == `MEM_OPND_BYTE || opnd == `MEM_OPND_BYTEU);

reg z0_r;
reg z1_r;
reg z2_r;
reg z3_r;
always_ff @(posedge clk)
if (rst == `LEV_H) begin
    z0_r <= `LEV_L;
    z1_r <= `LEV_L;
    z2_r <= `LEV_L;
    z3_r <= `LEV_L;
end else if (ce == `LEV_H && opnd == `MEM_OPND_SETIO)
case(sel_w)
2'b00: z0_r <= data_i[0];
2'b01: z1_r <= data_i[0];
2'b10: z2_r <= data_i[0];
default: z3_r <= data_i[0];
endcase
// Low  : Read 
// High : Write
wire [`IO_PORT_WIDTH - 1:0] dio0_w = (z0_r == `LEV_L) ? `IO_PORT_WIDTH'bz : data_i[7:0];
wire [`IO_PORT_WIDTH - 1:0] dio1_w = (z1_r == `LEV_L) ? `IO_PORT_WIDTH'bz : data_i[7:0];
wire [`IO_PORT_WIDTH - 1:0] dio2_w = (z2_r == `LEV_L) ? `IO_PORT_WIDTH'bz : data_i[7:0];
wire [`IO_PORT_WIDTH - 1:0] dio3_w = (z3_r == `LEV_L) ? `IO_PORT_WIDTH'bz : data_i[7:0];
CustomPort port_0(
    .clk(clk), 
    .ce(ce0_w),
    .z(z0_r),
    .dio_0(dio0_w),
    .dio_1(iodata0)
);
CustomPort port_1(
    .clk(clk), 
    .ce(ce1_w), 
    .z(z1_r), 
    .dio_0(dio1_w),
    .dio_1(iodata1)
);
CustomPort port_2(
    .clk(clk), 
    .ce(ce2_w), 
    .z(z2_r), 
    .dio_0(dio2_w),
    .dio_1(iodata2)
);
CustomPort port_3(
    .clk(clk), 
    .ce(ce3_w), 
    .z(z3_r), 
    .dio_0(dio3_w),
    .dio_1(iodata3)
);

wire we0_w = (caddr_w != 6'd0) & ce & (sel_w == 2'd0);
wire we1_w = (caddr_w != 6'd0) & ce
        & (
            ((sel_w == 2'd0) && (opnd == `MEM_OPND_HALF || opnd == `MEM_OPND_WORD))
            || (sel_w == 2'd1)
        );
wire we2_w = (caddr_w != 6'd0) & ce
        & ((sel_w == 2'd0 && opnd == `MEM_OPND_WORD)
            || (sel_w == 2'd2));
wire we3_w = (caddr_w != 6'd0) & ce
        & (
            ((sel_w == 2'd3) || (sel_w == 2'd2 && opnd == `MEM_OPND_HALF))
            || (opnd == `MEM_OPND_WORD)
        );

wire [7:0] data0_w;
ram8 chip0(
    .a(caddr_w),
    .d(data_i[7:0]),
    .clk(clk),
    .we(we0_w),
    .spo(data0_w)
);

wire [7:0] data1_w;
ram8 chip1(
    .a(caddr_w),
    .d((sel_w == 2'b01) ? data_i[7:0] : data_i[15:8]),
    .clk(clk),
    .we(we1_w),
    .spo(data1_w)
);

wire [7:0] data2_w;
ram8 chip2(
    .a(caddr_w),
    .d((sel_w == 2'b00) ? data_i[23:16] : data_i[7:0]),
    .clk(clk),
    .we(we2_w),
    .spo(data2_w)
);

wire [7:0] data3_w;
ram8 chip3(
    .a(caddr_w),
    .d((sel_w == 2'b11) ? data_i[7:0] : ((sel_w == 2'b10) ? data_i[15:8] : data_i[31:24])),
    .clk(clk),
    .we(we3_w),
    .spo(data3_w)
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

always_comb
case(opnd)
`MEM_OPND_HALF: data_o = (sel_w[1] == 1'b1) ? sexthalf1_w : sexthalf0_w;
`MEM_OPND_HALFU: data_o = (sel_w[1] == 1'b1) ? uexthalf1_w : uexthalf0_w;
`MEM_OPND_BYTE:
    case(sel_w)
    2'd0: data_o = sextbyte0_w;
    2'd1: data_o = sextbyte1_w;
    2'd2: data_o = sextbyte2_w;
    default: data_o = sextbyte3_w;
    endcase
`MEM_OPND_BYTEU:
    case(sel_w)
    2'd0: data_o = (caddr_w == 6'd0 && z0_r == `LEV_L) ? {24'd0, dio0_w} : uextbyte0_w;
    2'd1: data_o = (caddr_w == 6'd0 && z1_r == `LEV_L) ? {24'd0, dio1_w} : uextbyte1_w;
    2'd2: data_o = (caddr_w == 6'd0 && z2_r == `LEV_L) ? {24'd0, dio2_w} : uextbyte2_w;
    default: data_o = (caddr_w == 6'd0 && z3_r == `LEV_L) ? {24'd0, dio3_w} : uextbyte3_w;
    endcase
default: data_o = {data3_w, data2_w, data1_w, data0_w};
endcase

endmodule