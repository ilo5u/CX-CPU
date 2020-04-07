`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/03/30
// Design Name: 
// Module Name: chinx_cop
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

module chinx_cop(
    input wire clk,
    input wire rst,
    input wire [`ADDR_WIDTH - 1:0] pc,

    input wire ireq,
    input wire [`INTR_VEC_WIDTH - 1:0] ivec,
    input wire irep,

    output wire intrf,
    output reg [`ADDR_WIDTH - 1:0] ipc,
    output reg [`ADDR_WIDTH - 1:0] rpc,
    output reg [`ADDR_WIDTH - 1:0] epc
);

localparam if_bit = 1;
//localparam zf_bit = 0;
reg [1:0] state_r; // zf, if
reg [`ADDR_WIDTH - 1:0] ivec_r[0:1];

always @(posedge clk) begin
    epc <= pc;
end

always @(posedge irep) begin
    rpc <= pc;
end

always @(posedge clk) begin
    if (rst == `LEV_H) begin
        ivec_r[0] <= `ADDR_WIDTH'd128;
        ivec_r[1] <= `ADDR_WIDTH'd192;
        state_r <= {`LEV_L, `LEV_L};
    end else if (ireq == `LEV_H && ivec[0] == `LEV_H && state_r[if_bit] == `LEV_L) begin
        ipc <= ivec_r[0];
        state_r[if_bit] <= `LEV_H;
    end else if (ireq == `LEV_H && ivec[1] == `LEV_H && state_r[if_bit] == `LEV_L) begin
        ipc <= ivec_r[1];
        state_r[if_bit] <= `LEV_H;
    end
end

assign intrf = state_r[if_bit] & (~irep);

endmodule