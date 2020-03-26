`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/03/26
// Design Name: 
// Module Name: chinx_ls
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

module chinx_ls(
    input wire clk,
    input wire rst,

    input wire memce_i,
    input wire memop_i,

    input wire [`BUS_WIDTH - 1:0] addr_i,
    input wire [`BUS_WIDTH - 1:0] load_i,
    input wire [`BUS_WIDTH - 1:0] store_i,

    output reg [`BUS_WIDTH - 1:0] addr_o,
    output reg [`BUS_WIDTH - 1:0] store_o,
    output reg [`BUS_WIDTH - 1:0] load_o,

    output reg rwe
);

reg tick_r;

always @(posedge clk) begin
    if (rst == `LEV_H) begin
        tick_r <= `LEV_L;
    end else if (memce_i == `LEV_H && tick_r == `LEV_L) begin
        tick_r <= ~tick_r;
        // need to load or store
        addr_o <= addr_i;
        load_o <= load_i;
        store_o <= store_i;
    end else if (tick_r == `LEV_H) begin
        tick_r <= ~tick_r;
    end
end

endmodule