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
    input wire clk, // 50mhz
    input wire rst, // active high
    // io ports
    inout [7:0] io0,
    inout [7:0] io1,
    inout [7:0] io2,
    inout [7:0] io3
);

// wire sysclk;
// wire memclk;
// wire tikclk;
// clock_gen cgen(
//     .clk_in1(clk),
//     .clk_out1(sysclk),
//     .clk_out2(memclk)
// );
 
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
wire [`ADDR_WIDTH - 1:0] baddr_w;
wire [`INSTR_WIDTH - 1:0] instr_w;
chinx_stage1 stage1(
    .clk(sysclk),
    .rst(rst),
    .bsrc_i(bsrc_w),
    .epc_i(epco_w),
    .ipc_i(ipco_w),
    .rpc_i(rpco_w),
    .baddr_i(baddr_w),
    .pc_o(pc_w),
    .instr_o(instr_w)
);

wire memce_w;
wire [`MEM_OPND_WIDTH - 1:0] memod_w;
wire [`DATA_WIDTH - 1:0] load_w;
wire [`DATA_WIDTH - 1:0] store_w;
wire [`ADDR_WIDTH - 1:0] lsaddr_w;
chinx_stage2 stage2(
    .clk(sysclk),
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
    .baddr_o(baddr_w)
);

chinx_mem32 mem32(
    .clk(memclk),
    .rst(rst),
    .ce(memce_w),
    .opnd(memod_w),
    .addr_i(lsaddr_w),
    .data_i(store_w),
    .iodata0(io0),
    .iodata1(io1),
    .iodata2(io2),
    .iodata3(io3),
    .data_o(load_w)
);

endmodule