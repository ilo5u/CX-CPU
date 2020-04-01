`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/03/26
// Design Name: 
// Module Name: chinx_alu
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

module chinx_alu(
    input wire [`ALU_SRC_WIDTH - 1:0] alusrca_i,
    input wire [`ALU_SRC_WIDTH - 1:0] alusrcb_i,
    input wire [`DATA_WIDTH - 1:0] rdata0_i,
    input wire [`DATA_WIDTH - 1:0] rdata1_i,
    input wire [`DATA_WIDTH - 1:0] load_i,
    input wire [`DATA_WIDTH - 1:0] extimm_i,
    input wire [`ADDR_WIDTH - 1:0] pc_i,
    
    input wire [`ALU_RES_WIDTH - 1:0] alures_i,
    output wire [`DATA_WIDTH - 1:0] result_o,
    output wire [`HILO_WIDTH - 1:0] lo_o,
    output wire [`HILO_WIDTH - 1:0] hi_o
);

wire [`DATA_WIDTH - 1:0] a_w;
chinx_mux4 #(`DATA_WIDTH) alusrca(
    .sel_i(alusrca_i),
    .data0_i(rdata0_i),
    .data1_i(rdata1_i),
    .data2_i(extimm_i),
    .data3_i({24'd0, pc_i}),
    .data_o(a_w)
);

wire [`DATA_WIDTH - 1:0] b_w;
chinx_mux4 #(`DATA_WIDTH) alusrcb(
    .sel_i(alusrcb_i),
    .data0_i(rdata0_i),
    .data1_i(rdata1_i),
    .data2_i(extimm_i),
    .data3_i({24'd0, pc_i}),
    .data_o(b_w)
);

wire [`DATA_WIDTH - 1:0] add_w;
adder ADD(
    .A(a_w),
    .B(b_w),
    .S(add_w)
);

wire [`DATA_WIDTH - 1:0] sub_w;
suber SUB(
    .A(a_w),
    .B(b_w),
    .S(sub_w)
);

wire [`DATA_WIDTH - 1:0] mul_w;
muler MUL(
    .A(a_w[`HILO_WIDTH - 1:0]),
    .B(b_w[`HILO_WIDTH - 1:0]),
    .P(mul_w)
);

chinx_mux8 result(
    .sel_i(alures_i),
    .data0_i(add_w),
    .data1_i(sub_w),
    .data2_i(load_i),
    .data3_i(extimm_i),
    .data4_i(a_w & b_w),
    .data5_i(a_w | b_w),
    .data6_i(((~a_w) & b_w) | (a_w & (~b_w))),
    .data7_i(~a_w),
    .data_o(result_o)
);

assign lo_o = mul_w[15:0];
assign hi_o = mul_w[31:16];

endmodule