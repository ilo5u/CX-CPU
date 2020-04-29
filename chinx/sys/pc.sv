`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/03/25 10:32:09
// Design Name: 
// Module Name: chinx_pc
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

module chinx_pc(
    input wire clk,
    input wire rst,
    input wire [`ADDR_WIDTH - 1:0] pc_i,
    output reg [`ADDR_WIDTH - 1:0] pc_o
);

always_ff @(posedge clk) begin
    if (rst == `LEV_H) begin
        pc_o <= `ADDR_WIDTH'd0;
    end else begin
        pc_o <= pc_i;
    end
end

endmodule
