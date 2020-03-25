`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/03/25 14:21:17
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
    input wire stall,

    input wire be_i,
    input wire [`BUS_WIDTH - 1:0] baddr_i,

    output wire [`BUS_WIDTH - 1:0] pc_o
);

wire [`BUS_WIDTH - 1:0] pci_w;
wire [`BUS_WIDTH - 1:0] pco_w;

chinx_pc pc(.clk(clk),
            .rst(rst),
            .stall(stall),
            .pc_i(pci_w),
            .pc_o(pco_w));

wire [`BUS_WIDTH - 1:0] pca_w;

chinx_accu accu(.num_i(pco_w), .num_o(pca_w));

chinx_mux2 nextpc(.sel_i(be_i),
                  .data0_i(pca_w),
                  .data1_i(baddr_i),
                  .data_o(pci_w));

assign pc_o = pco_w;

endmodule
