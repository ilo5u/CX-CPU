`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/03/28
// Design Name: 
// Module Name: chinx_pipeline
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

module chinx_pipeline(
    input wire clk,
    input wire rst,
    output wire [`ADDR_WIDTH - 1:0] pc,
    output wire [`INSTR_WIDTH - 1:0] instr
);
reg ramclk;
always @(posedge clk) begin
    if (rst == `LEV_H) begin
        ramclk <= `LEV_L;
    end else begin
        ramclk <= ~ramclk;
    end
end

wire [`ADDR_WIDTH - 1:0] pc_w;
wire [`ADDR_WIDTH - 1:0] epco_w;
chinx_cop cop(
    .clk(clk),
    .pc(pc_w),
    .epc(epco_w)
);

wire [`BRANCH_SRC_WIDTH - 1:0] bsrc_w;
wire [`ADDR_WIDTH - 1:0] baddr_w;
wire [`INSTR_WIDTH - 1:0] instr_w;
chinx_stage1 stage1(
    .clk(clk),
    .rst(rst),
    .bsrc_i(bsrc_w),
    .epc_i(epco_w),
    .baddr_i(baddr_w),
    .pc_o(pc_w),
    .instr_o(instr_w)
);
assign pc = pc_w;
assign instr = instr_w;

wire memce_w;
wire memop_w;
wire [`MEM_OPND_WIDTH - 1:0] memod_w;
wire [`DATA_WIDTH - 1:0] load_w;
wire [`DATA_WIDTH - 1:0] store_w;
wire [`ADDR_WIDTH - 1:0] lsaddr_w;
chinx_stage2 stage2(
    .clk(clk),
    .rst(rst),
    .pc_i(pc_w),
    .instr_i(instr_w),
    .memce_o(memce_w),
    .memop_o(memop_w),
    .memod_o(memod_w),
    .load_i(load_w),
    .addr_o(lsaddr_w),
    .store_o(store_w),
    .bsrc_o(bsrc_w),
//    .pc_o(epci_w),
    .baddr_o(baddr_w)
);

//chinx_ram ram32(
//    .ramclk(ramclk),
//    .ce(memce_w),
//    .rwe(memop_w),
//    .opnd(memod_w),
//    .addr_i(lsaddr_w),
//    .data_i(store_w),
//    .data_o(load_w)
//);

wire [7:0] data0_w;
ram8 chip0(
    .a(lsaddr_w[7:2]),
    .d(store_w[7:0]),
    .clk(ramclk),
    .we(memop_w & (lsaddr_w[1:0] == 2'b00)),
    .qspo(data0_w)
);
wire [7:0] data1_w;
ram8 chip1(
    .a(lsaddr_w[7:2]),
    .d((lsaddr_w[1:0] == 2'b01) ? store_w[7:0] : store_w[15:8]),
    .clk(ramclk),
    .we(memop_w
        & (((lsaddr_w[1:0] == 2'b00) && (memod_w == `MEM_OPND_HALF || memod_w == `MEM_OPND_WORD))
            || (lsaddr_w[1:0] == 2'b01))),
    .qspo(data1_w)
);
wire [7:0] data2_w;
ram8 chip2(
    .a(lsaddr_w[7:2]),
    .d((lsaddr_w[1:0] == 2'b00) ? store_w[23:16] : store_w[7:0]),
    .clk(ramclk),
    .we(memop_w
        & ((lsaddr_w[1:0] == 2'b00 && memod_w == `MEM_OPND_WORD)
            || (lsaddr_w[1:0] == 2'b10))),
    .qspo(data2_w)
);
wire [7:0] data3_w;
ram8 chip3(
    .a(lsaddr_w[7:2]),
    .d((lsaddr_w[1:0] == 2'b11) ? store_w[7:0] : ((lsaddr_w[1:0] == 2'b10) ? store_w[15:8] : store_w[31:24])),
    .clk(ramclk),
    .we(memop_w
        & (((lsaddr_w[1:0] == 2'b11) || (lsaddr_w[1:0] == 2'b10 && memod_w == `MEM_OPND_HALF))
            | (memod_w == `MEM_OPND_WORD))),
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

wire [31:0] extbyte0_w;
chinx_sext8 extbyte0(
    .imm8_i(data0_w),
    .imm32_o(extbyte0_w)
);
wire [31:0] extbyte1_w;
chinx_sext8 extbyte1(
    .imm8_i(data1_w),
    .imm32_o(extbyte1_w)
);
wire [31:0] extbyte2_w;
chinx_sext8 extbyte2(
    .imm8_i(data2_w),
    .imm32_o(extbyte2_w)
);
wire [31:0] extbyte3_w;
chinx_sext8 extbyte3(
    .imm8_i(data3_w),
    .imm32_o(extbyte3_w)
);


endmodule