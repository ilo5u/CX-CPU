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

    output wire [`DATA_WIDTH - 1:0] rdata0_o,
    output wire [`DATA_WIDTH - 1:0] rdata1_o
);

reg [`DATA_WIDTH - 1:0] files[`REG_NUM - 1:0];

always @(negedge clk) begin
    if (rst == `LEV_H) begin
        files[`REG_ZERO] = `DATA_WIDTH'd0;
    end else if (we_i == `LEV_H && waddr_i != `REG_ZERO) begin
        files[waddr_i] = wdata_i;
    end
end

assign rdata0_o = (we_i == `LEV_H && waddr_i == raddr0_i) ? 
    wdata_i : files[raddr0_i];
assign rdata1_o = (we_i == `LEV_H && waddr_i == raddr1_i) ?
    wdata_i : files[raddr1_i];

endmodule