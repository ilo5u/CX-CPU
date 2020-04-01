`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/03/28
// Design Name: 
// Module Name: chinx_hilo
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

module chinx_hilo(
    input wire clk,
    input wire we,
    input wire [`HILO_WIDTH - 1:0] hi_i,
    input wire [`HILO_WIDTH - 1:0] lo_i,
    output wire [`HILO_WIDTH - 1:0] hi_o,
    output wire [`HILO_WIDTH - 1:0] lo_o
);

reg [`HILO_WIDTH - 1:0] hi_r;
reg [`HILO_WIDTH - 1:0] lo_r;

always @(posedge clk) begin
    if (we == `LEV_H) begin
        hi_r <= hi_i;
        lo_r <= lo_i;
    end
end

assign hi_o = hi_r;
assign lo_o = lo_r;

endmodule