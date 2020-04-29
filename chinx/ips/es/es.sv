`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/04/20 14:36:37
// Design Name: 
// Module Name: CustomES
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

module CustomES32(
    input wire [1:0] SEL,
    input wire [31:0] A,
    input wire [15:0] B,
    output reg [31:0] S
);
wire [1:0] shift_w = B[1:0];

localparam ELOS = 0;
localparam ELOU = 1;
localparam EHIZ = 2;
localparam SHFT = 3;

always_comb
case (SEL)
ELOS:
    case (B[15])
    1'b0: S = {16'd0, B};
    default: S = {16'hffff, B};
    endcase
ELOU: S = {16'd0, B};
EHIZ: S = {B, 16'd0};
default:
    case (shift_w)
    2'b00: S = A;
    2'b01: S = {A[30:0], 1'd0};
    2'b10: S = {A[29:0], 2'd0};
    default: S = {A[28:0], 3'd0};
    endcase
endcase
endmodule
