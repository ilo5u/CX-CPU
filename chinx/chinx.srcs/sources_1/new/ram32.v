`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/03/27
// Design Name: 
// Module Name: chinx_ram32
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

module chinx_ram32(
    input wire ramclk,
    input wire ce,
    input wire rwe,
    input wire [`MEM_OPND_WIDTH - 1:0] opnd,

    input wire [`ADDR_WIDTH - 1:0] addr_i,
    input wire [`DATA_WIDTH - 1:0] data_i,

    output reg [`DATA_WIDTH - 1:0] data_o
);

localparam word = `MEM_OPND_WIDTH'd0;
localparam half = `MEM_OPND_WIDTH'd1;
localparam halfu = `MEM_OPND_WIDTH'd2;
localparam byte = `MEM_OPND_WIDTH'd3;
localparam byteu = `MEM_OPND_WIDTH'd4;

reg [7:0] block[0:255];

always @(posedge ramclk) begin
    if (ce == `LEV_H) begin
        if (rwe == `LEV_L) begin
        case (opnd)
        half: data_o <= (block[addr_i+1][7] == 1'b1) ?
            {16'hffff, block[addr_i+1], block[addr_i]} : {16'h0000, block[addr_i+1], block[addr_i]};
        halfu: data_o <= {16'h0000, block[addr_i+1], block[addr_i]};
        byte: data_o <= (block[addr_i][7] == 1'b1) ?
            {24'hff_ffff, block[addr_i]} : {24'h00_0000, block[addr_i]};
        byteu: data_o <= {24'h00_0000, block[addr_i]};
        default: data_o <= {block[addr_i+3], block[addr_i+2], block[addr_i+1], block[addr_i]};
        endcase
        end else begin
        case (opnd)
        half: begin
            block[addr_i] <= data_i[7:0];
            block[addr_i+1] <= data_i[15:8];
        end
        byte: begin
            block[addr_i] <= data_i[7:0];
        end
        default: begin
            block[addr_i] <= data_i[7:0];
            block[addr_i+1] <= data_i[15:8];
            block[addr_i+2] <= data_i[23:16];
            block[addr_i+3] <= data_i[31:24];
        end
        endcase
        end
    end
end

endmodule