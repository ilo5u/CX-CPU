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
    input wire clk, // 5MHz
    input wire rst, // active high
    // io ports
    inout [7:0] io0,
    inout [7:0] io1,
    inout [7:0] io2,
    inout [7:0] io3
);
 
 wire sysclk;
 wire memclk;
 cgen clock_gen(
    .clk(clk),
    .clk_0(sysclk),
    .clk_1(memclk)
 );

wire tikclk = sysclk;
wire ir0_w;
chinx_tick tick(
    .clk(tikclk),
    .rst(rst),
    .ireq(ir0_w)
);
wire ireq_w;
wire [`INTR_VEC_WIDTH - 1:0] ivec_w;
wire irep_w;
chinx_intr intr(
    .clk(sysclk),
    .rst(rst),
    .mask(irep_w),
    .ir0(ir0_w),
    .ir1(1'b0),
    .ireq(ireq_w),
    .ivec(ivec_w)
);

wire intrf_w;
wire [`ADDR_WIDTH - 1:0] pc_w;
wire [`ADDR_WIDTH - 1:0] epco_w;
wire [`ADDR_WIDTH - 1:0] ipco_w;
wire [`ADDR_WIDTH - 1:0] rpco_w;
chinx_cop cop(
    .clk(sysclk),
    .rst(rst),
    .pc(pc_w),
    .ireq(ireq_w),
    .ivec(ivec_w),
    .irep(irep_w),
    .intrf(intrf_w),
    .ipc(ipco_w),
    .rpc(rpco_w),
    .epc(epco_w)
);

wire [`BRANCH_SRC_WIDTH - 1:0] bsrc_w;
wire [`ADDR_WIDTH - 1:0] bpc_w;
wire [`INSTR_WIDTH - 1:0] instr_w;
chinx_stage1 stage1(
    .clk(sysclk),
    .rst(rst),
    .bsrc_i(bsrc_w),
    .epc_i(epco_w),
    .ipc_i(ipco_w),
    .rpc_i(rpco_w),
    .baddr_i(bpc_w),
    .pc_o(pc_w),
    .instr_o(instr_w)
);

wire we_w;
wire [`MEM_OPND_WIDTH - 1:0] opnd_w;
wire [`DATA_WIDTH - 1:0] load_w;
wire [`DATA_WIDTH - 1:0] data_w;
wire [`ADDR_WIDTH - 1:0] addr_w;
chinx_stage2 stage2(
    .clk(sysclk),
    .rst(rst),
    .pc_i(pc_w),
    .instr_i(instr_w),
    .ireq_i(intrf_w),
    .we_o(we_w),
    .opnd_o(opnd_w),
    .load_i(load_w),
    .addr_o(addr_w),
    .data_o(data_w),
    .bsrc_o(bsrc_w),
    .irep_o(irep_w),
    .bpc_o(bpc_w)
);

chinx_mem32 mem32(
    .clk(memclk),
    .rst(rst),
    .ce(we_w),
    .opnd(opnd_w),
    .addr_i(addr_w),
    .data_i(data_w),
    .iodata0(io0),
    .iodata1(io1),
    .iodata2(io2),
    .iodata3(io3),
    .data_o(load_w)
);

endmodule