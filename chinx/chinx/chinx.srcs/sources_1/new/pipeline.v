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
    input wire ireq,
    input wire [`INTR_VEC_WIDTH - 1:0] ivec,
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

wire irep_w;
wire zerof_w;
wire intrf_w;
wire [`ADDR_WIDTH - 1:0] pc_w;
wire [`ADDR_WIDTH - 1:0] epco_w;
wire [`ADDR_WIDTH - 1:0] ipco_w;
wire [`ADDR_WIDTH - 1:0] rpco_w;
chinx_cop cop(
    .clk(clk),
    .rst(rst),
    .pc(pc_w),
    .ireq(ireq),
    .ivec(ivec),
    .irep(irep_w),
    // .zerof(zerof_w),
    .intrf(intrf_w),
    .ipc(ipco_w),
    .rpc(rpco_w),
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
    .ipc_i(ipco_w),
    .rpc_i(rpco_w),
    .baddr_i(baddr_w),
    .pc_o(pc_w),
    .instr_o(instr_w)
);
assign pc = pc_w;
assign instr = instr_w;

wire memce_w;
wire [`MEM_OPND_WIDTH - 1:0] memod_w;
wire [`DATA_WIDTH - 1:0] load_w;
wire [`DATA_WIDTH - 1:0] store_w;
wire [`ADDR_WIDTH - 1:0] lsaddr_w;
chinx_stage2 stage2(
    .clk(clk),
    .rst(rst),
    .pc_i(pc_w),
    .instr_i(instr_w),
    .ireq_i(intrf_w),
    .memce_o(memce_w),
    .memod_o(memod_w),
    .load_i(load_w),
    .addr_o(lsaddr_w),
    .store_o(store_w),
    .bsrc_o(bsrc_w),
    .irep_o(irep_w),
//    .pc_o(epci_w),
    .baddr_o(baddr_w),
    .zerof_o(zerof_w)
);

chinx_mem32 mem32(
    .clk(ramclk),
    .ce(memce_w),
    .opnd(memod_w),
    .addr_i(lsaddr_w),
    .data_i(store_w),
    .data_o(load_w)
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

endmodule