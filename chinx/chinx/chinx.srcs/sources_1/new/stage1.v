`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Beijing University of Posts and Telecommunications
// Engineer: Cheng Xin
// 
// Create Date: 2020/03/25
// Design Name: 
// Module Name: chinx_stage1
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

module chinx_stage1(
    input wire clk,
    input wire rst,
    input wire [`BRANCH_SRC_WIDTH - 1:0] bsrc_i, // select the next pc value
    input wire [`ADDR_WIDTH - 1:0] epc_i, // epc used for stall pipeline
    input wire [`ADDR_WIDTH - 1:0] baddr_i, // branch address

    output wire [`ADDR_WIDTH - 1:0] pc_o, // pc in IF stage
    output wire [`INSTR_WIDTH - 1:0] instr_o // instruction in IF stage
);

wire [`ADDR_WIDTH - 1:0] pci_w; // connect nextpc and pc
wire [`ADDR_WIDTH - 1:0] pco_w; // connect pc and instrmem and accu
chinx_pc pc(.clk(clk),
            .rst(rst),
            .pc_i(pci_w),
            .pc_o(pco_w));
// fetch instruction
rom32 instrmem(.a(pco_w), .spo(instr_o));
// pca_w = pco_w + 1
wire [`ADDR_WIDTH - 1:0] pca_w;
add1 follow(.A(pco_w), .S(pca_w));
// select the branch address or pc+1 as the next pc
chinx_mux4 #(`ADDR_WIDTH) nextpc(.sel_i(bsrc_i),
                  .data0_i(pca_w),
                  .data1_i(baddr_i),
                  .data2_i(epc_i),
                  .data3_i(epc_i),
                  .data_o(pci_w));
// send out current pc value
assign pc_o = pco_w;

endmodule
