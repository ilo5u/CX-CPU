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
    input wire clk,
    input wire rst,

    input wire [`ADDR_WIDTH - 1:0] pc_i,
    input wire [`INSTR_WIDTH - 1:0] instr_i,

    input wire ireq_i,

    input wire [`DATA_WIDTH - 1:0] load_i,

    output wire [`ADDR_WIDTH - 1:0] addr_o,
    output wire [`DATA_WIDTH - 1:0] data_o,

    output wire we_o,
    output wire [`MEM_OPND_WIDTH - 1:0] opnd_o,
    
    output wire [`BRANCH_SRC_WIDTH - 1:0] bsrc_o,
    output wire irep_o,
    output reg [`ADDR_WIDTH - 1:0] bpc_o
);

wire [`REG_ADDR_WIDTH - 1:0] waddr_w;
wire [`REG_ADDR_WIDTH - 1:0] raddr0_w;
wire [`REG_ADDR_WIDTH - 1:0] raddr1_w;
wire [`INSTR_IMM_WIDTH - 1:0] imm16_w;
wire [`ES_WIDTH - 1:0] immes_w;
wire wbe_w;
wire [`ALU_SRC_WIDTH - 1:0] alusrca_w;
wire [`ALU_SRC_WIDTH - 1:0] alusrcb_w;
wire [`ALU_RES_WIDTH - 1:0] alures_w;
wire irep_w;
wire addrfix_w;
wire we_w;
wire [`MEM_OPND_WIDTH - 1:0] opnd_w;
wire cache_w;
chinx_emit emit(
    .clk(clk),
    .rst(rst),
    .instr_i(instr_i),
    .ireq_i(ireq_i),
    .waddr_o(waddr_w),
    .raddr0_o(raddr0_w),
    .raddr1_o(raddr1_w),
    .imm_o(imm16_w),
    .immes_o(immes_w),
    .wbe_o(wbe_w),
    .memce_o(we_w),
    .memod_o(opnd_w),
    .alusrca_o(alusrca_w),
    .alusrcb_o(alusrcb_w),
    .alures_o(alures_w),
    .bsrc_o(bsrc_o),
    .irep_o(irep_w),
    .addrfix_o(addrfix_w),
    .cache_o(cache_w)
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
    .be_i(irep_w),
    .rdata0_o(rdata0_w),
    .rdata1_o(rdata1_w)
);
// memory access signal caches
// last for two periods
reg we;
reg [`MEM_OPND_WIDTH - 1:0] opnd;
reg [`ADDR_WIDTH - 1:0] addr;
reg [`DATA_WIDTH - 1:0] data;
reg period;
always_ff @(posedge clk) begin
    if (rst == `LEV_H) begin
        we <= `LEV_L;
        opnd <= `MEM_OPND_WORD;
        addr <= `ADDR_WIDTH'd0;
        data <= `DATA_WIDTH'd0;
        period <= `LEV_L;
    end else if (cache_w == `LEV_H) begin
        we <= we_w;
        opnd <= opnd_w;
        addr <= (addrfix_w == `LEV_L) ? 
            result_w[`ADDR_WIDTH - 1:0] : result_w[`ADDR_WIDTH - 1:0] + `ADDR_WIDTH'd4;
        data <= rdata0_w;
        period <= `LEV_L;
    end else if (period == `LEV_L) begin
        period <= `LEV_H;
    end else begin
        we <= `LEV_L;
        opnd <= `MEM_OPND_WORD;
        addr <= `ADDR_WIDTH'd0;
        data <= `DATA_WIDTH'd0;
        period <= `LEV_L;
    end
end

wire [`DATA_WIDTH - 1:0] imm32_w;
chinx_es32 es32(
    .SEL(immes_w),
    .A(rdata1_w),
    .B(imm16_w),
    .S(imm32_w)
);

wire [`DATA_WIDTH - 1:0] a_w;
chinx_mux4 #(32) a(
    .sel_i(alusrca_w),
    .data0_i(rdata0_w),
    .data1_i(rdata1_w),
    .data2_i(imm32_w),
    .data3_i(load_i),
    .data_o(a_w)
);
wire [`DATA_WIDTH - 1:0] b_w;
chinx_mux4 #(32) b(
    .sel_i(alusrcb_w),
    .data0_i(rdata0_w),
    .data1_i(rdata1_w),
    .data2_i(imm32_w),
    .data3_i(load_r),
    .data_o(b_w)
);
chinx_alu alu(
    .SEL(alures_w),
    .A(a_w),
    .B(b_w),
    .S(result_w)
);
// generate memory access signals
assign we_o = we;
assign opnd_o = opnd;
assign addr_o = addr;
assign data_o = data;
// generate interrup response signal
assign irep_o = irep_w;
// generate BPC
wire [`ADDR_WIDTH - 1:0] baddr_w;
add8 baddr(
    .A(pc_i),
    .B(imm32_w[`ADDR_WIDTH - 1:0]),
    .S(baddr_w)
);
always_comb
case (bsrc_o)
`BRANCH_SRC_BNE: bpc_o = (result_w == `DATA_WIDTH'd0) ? pc_i : baddr_w;
`BRANCH_SRC_BEQ: bpc_o = (result_w == `DATA_WIDTH'd0) ? baddr_w : pc_i;
`BRANCH_SRC_BLE: bpc_o = (result_w == `DATA_WIDTH'd0 || result_w[`DATA_WIDTH - 1] == `LEV_H) ? baddr_w : pc_i;
default: bpc_o = result_w[`ADDR_WIDTH - 1:0];
endcase

endmodule
