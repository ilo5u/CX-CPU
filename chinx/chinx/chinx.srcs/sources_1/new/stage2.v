`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/03/27
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
    input rst,

    input wire [`ADDR_WIDTH - 1:0] pc_i,
    input wire [`INSTR_WIDTH - 1:0] instr_i,

    input wire ireq_i,
//    input wire [`ADDR_WIDTH - 1:0] epc_i,

    input wire [`DATA_WIDTH - 1:0] load_i,

    output wire [`ADDR_WIDTH - 1:0] addr_o,
    output wire [`DATA_WIDTH - 1:0] store_o,

    output wire memce_o,
    // output wire memop_o, // replaced by memce_o
    output wire [`MEM_OPND_WIDTH - 1:0] memod_o,
    
    output wire [`BRANCH_SRC_WIDTH - 1:0] bsrc_o,
    output wire irep_o,
    output wire [`ADDR_WIDTH - 1:0] baddr_o,
    output wire zerof_o
//    output wire [`ADDR_WIDTH - 1:0] pc_o
);

wire [`HILO_WIDTH - 1:0] hio_w;
wire [`HILO_WIDTH - 1:0] loo_w;
wire hle_w;
wire [`REG_ADDR_WIDTH - 1:0] waddr_w;
wire [`REG_ADDR_WIDTH - 1:0] raddr0_w;
wire [`REG_ADDR_WIDTH - 1:0] raddr1_w;
wire [`INSTR_IMM_WIDTH - 1:0] imm16_w;
wire immext_w;
wire wbe_w;
wire [`ALU_SRC_WIDTH - 1:0] alusrca_w;
wire [`ALU_SRC_WIDTH - 1:0] alusrcb_w;
wire [`ALU_RES_WIDTH - 1:0] alures_w;
wire stasrc_w;
wire stdsrc_w;
wire irep_w;
chinx_emit emit(
    .clk(clk),
    .rst(rst),
    .instr_i(instr_i),
    .hi_i(hio_w),
    .lo_i(loo_w),
    .ireq_i(ireq_i),
    .waddr_o(waddr_w),
    .raddr0_o(raddr0_w),
    .raddr1_o(raddr1_w),
    .imm_o(imm16_w),
    .immext_o(immext_w),
    .wbe_o(wbe_w),
    .hle_o(hle_w),
    .memce_o(memce_o),
    .memod_o(memod_o),
    .alusrca_o(alusrca_w),
    .alusrcb_o(alusrcb_w),
    .alures_o(alures_w),
    .bsrc_o(bsrc_o),
    .irep_o(irep_w),
    .stasrc_o(stasrc_w),
    .stdsrc_o(stdsrc_w)
);

wire [`DATA_WIDTH - 1:0] rdata0_w;
wire [`DATA_WIDTH - 1:0] rdata1_w;
wire [`DATA_WIDTH - 1:0] result_w;
chinx_regfiles regfiles(
    .clk(clk),
    .rst(rst),
    .raddr0_i(raddr0_w),
    .raddr1_i(raddr1_w),
    .we_i(wbe_w),
    .waddr_i(waddr_w),
    .wdata_i(result_w),
    .restore_i(irep_w),
    .rdata0_o(rdata0_w),
    .rdata1_o(rdata1_w)
);

reg [`ADDR_WIDTH - 1:0] sta_cache;
reg [`DATA_WIDTH - 1:0] std_cache;
always @(posedge clk) begin
    if (rst == `LEV_H) begin
        sta_cache <= `ADDR_WIDTH'd0;
        std_cache <= `DATA_WIDTH'd0;
    end else begin
        sta_cache <= result_w;
        std_cache <= rdata0_w;
    end
end

wire [`DATA_WIDTH - 1:0] imm32_w;
chinx_ext32 ext32(
    .immext_i(immext_w),
    .imm16_i(imm16_w),
    .imm32_o(imm32_w)
);

wire [`HILO_WIDTH - 1:0] lo_w;
wire [`HILO_WIDTH - 1:0] hi_w;
chinx_alu alu(
    .alusrca_i(alusrca_w),
    .alusrcb_i(alusrcb_w),
    .rdata0_i(rdata0_w),
    .rdata1_i(rdata1_w),
    .load_i(load_i),
    .extimm_i(imm32_w),
    .pc_i(pc_i),
    .alures_i(alures_w),
    .result_o(result_w),
    .lo_o(lo_w),
    .hi_o(hi_w)
);

chinx_hilo hilo(
    .clk(clk),
    .we(hle_w),
    .hi_i(hi_w),
    .lo_i(lo_w),
    .hi_o(hio_w),
    .lo_o(loo_w)
);

assign addr_o = (stasrc_w == `STA_SRC_CACHE) ? sta_cache : result_w;
assign store_o = (stdsrc_w == `STD_SRC_CACHE) ? std_cache : rdata0_w;
assign irep_o = irep_w;
assign baddr_o = result_w[`ADDR_WIDTH - 1:0];
assign zerof_o = (result_w == `DATA_WIDTH'd0) ? `LEV_H : `LEV_L;

endmodule
