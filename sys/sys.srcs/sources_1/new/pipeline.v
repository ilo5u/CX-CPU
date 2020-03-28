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
    output wire [`INSTR_WIDTH - 1:0] instr,
    output wire stall
);

wire ramclk;
wire mulclk;
clock_gen gen(
    .reset(1'b0),
    .clk_in1(clk),
    .clk_out1(ramclk),
    .clk_out2(mulclk),
    .locked()
);

wire stall_w;
wire be_w;
wire [`ADDR_WIDTH - 1:0] baddr_w;
wire [`ADDR_WIDTH - 1:0] pc_w;
wire [`INSTR_WIDTH - 1:0] instr_w;
chinx_stage1 stage1(
    .clk(clk),
    .rst(rst),
    .stall(stall_w),
    .be_i(be_w),
    .baddr_i(baddr_w),
    .pc_o(pc_w),
    .instr_o(instr_w)
);
assign pc = pc_w;
assign instr = instr_w;
assign stall = stall_w;

wire memce_w;
wire memop_w;
wire [`MEM_OPND_WIDTH - 1:0] memod_w;
wire [`DATA_WIDTH - 1:0] load_w;
wire [`DATA_WIDTH - 1:0] store_w;
wire [`ADDR_WIDTH - 1:0] lsaddr_w;
chinx_stage2 stage2(
    .clk(clk),
    .mulclk(mulclk),
    .rst(rst),
    .pc_i(pc_w),
    .instr_i(instr_w),
    .memce_o(memce_w),
    .memop_o(memop_w),
    .memod_o(memod_w),
    .load_i(load_w),
    .addr_o(lsaddr_w),
    .store_o(store_w),
    .be_o(be_w),
    .baddr_o(baddr_w),
    .stall(stall_w)
);

chinx_ram32 ram32(
    .ramclk(ramclk),
    .ce(memce_w),
    .rwe(memop_w),
    .opnd(memod_w),
    .addr_i(lsaddr_w),
    .data_i(store_w),
    .data_o(load_w)
);

endmodule