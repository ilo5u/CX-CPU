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
    input wire stall, // pipeline stall signal

    input wire be_i, // select the next pc value
    input wire [`ADDR_WIDTH - 1:0] baddr_i, // branch address

    output wire [`ADDR_WIDTH - 1:0] pc_o, // pc in IF stage
    output wire [`INSTR_WIDTH - 1:0] instr_o // instruction in IF stage
);

wire [`ADDR_WIDTH - 1:0] pci_w; // connect nextpc and pc
wire [`ADDR_WIDTH - 1:0] pco_w; // connect pc and instrmem and accu

chinx_pc pc(.clk(clk),
            .rst(rst),
            .stall(stall),
            .pc_i(pci_w),
            .pc_o(pco_w));
            
rom32 instrmem(.a(pco_w[8:0]), .spo(instr_o));

wire [`ADDR_WIDTH - 1:0] pca_w; // connect accu and mux2

// pca_w = pco_w + 1
chinx_accu accu(.num_i(pco_w), .num_o(pca_w));

// select the branch address or pc+1 as the next pc
chinx_mux2 nextpc(.sel_i(be_i),
                  .data0_i(pca_w),
                  .data1_i(baddr_i),
                  .data_o(pci_w));

// send out current pc value
assign pc_o = pco_w;

endmodule
