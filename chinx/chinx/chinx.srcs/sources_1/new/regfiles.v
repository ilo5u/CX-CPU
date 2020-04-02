`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/03/27
// Design Name: 
// Module Name: chinx_regfiles
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

module chinx_regfiles(
    input wire clk,
    input wire rst,

    input wire [`REG_ADDR_WIDTH - 1:0] raddr0_i,
    input wire [`REG_ADDR_WIDTH - 1:0] raddr1_i,

    input wire we_i,
    input wire [`REG_ADDR_WIDTH - 1:0] waddr_i,
    input wire [`DATA_WIDTH - 1:0] wdata_i,
    // record interruption effects
    input wire ftob_i,
    input wire btof_i,
    input wire [`DATA_WIDTH - 1:0] return_i,
    output wire [`DATA_WIDTH - 1:0] return_o,

    output wire [`DATA_WIDTH - 1:0] rdata0_o,
    output wire [`DATA_WIDTH - 1:0] rdata1_o
);

reg [`DATA_WIDTH - 1:0] files[`REG_NUM - 1:0];
integer i = 0;
initial begin
    for (i = 0; i < `REG_NUM; i = i + 1)
        files[i] <= `DATA_WIDTH'd404;
end

reg [`DATA_WIDTH - 1:0] lr;
reg [`DATA_WIDTH - 1:0] backup[`REG_NUM - 1:0];
initial begin
    lr <= `DATA_WIDTH'd108;
    for (i = 0; i < `REG_NUM; i = i + 1)
        backup[i] <= `DATA_WIDTH'd108;
end

always @(negedge clk) begin
    if (rst == `LEV_H) begin
        files[`REG_ZERO] <= `DATA_WIDTH'd0;
    end else if (we_i == `LEV_H && waddr_i != `REG_ZERO) begin
        files[waddr_i] <= wdata_i;
    end else if (ftob_i == `LEV_H) begin
        backup[0] <= files[0];
        backup[1] <= files[1];
        backup[2] <= files[2];
        backup[3] <= files[3];
        backup[4] <= files[4];
        backup[5] <= files[5];
        // set ir
        ir <= return_i;
    end else if (btof_i == `LEV_H) begin
        files[0] <= backup[0];
        files[1] <= backup[1];
        files[2] <= backup[2];
        files[3] <= backup[3];
        files[4] <= backup[4];
        files[5] <= backup[5];
    end
end

assign rdata0_o = (we_i == `LEV_H && waddr_i == raddr0_i) ? 
    wdata_i : files[raddr0_i];
assign rdata1_o = (we_i == `LEV_H && waddr_i == raddr1_i) ?
    wdata_i : files[raddr1_i];
assign return_o = ir;

endmodule