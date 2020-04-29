`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/04/20 12:39:56
// Design Name: 
// Module Name: CustomALU
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

module CustomALU #(parameter SEL_WIDTH = 3, DATA_WIDTH = 32, HILO_WIDTH = 16)(
    input wire [SEL_WIDTH - 1:0] SEL,
    input wire [DATA_WIDTH - 1:0] A,
    input wire [DATA_WIDTH - 1:0] B,
    output reg [DATA_WIDTH - 1:0] S
);

localparam ADD = 0;
localparam SUB = 1;
localparam MUL = 2;
localparam PAS = 3;
localparam AND = 4;
localparam OR = 5;
localparam XOR = 6;
localparam NOT = 7;

wire [DATA_WIDTH - 1:0] add_w;
adder ADDer(
    .A(A),
    .B(B),
    .S(add_w)
);

wire [DATA_WIDTH - 1:0] sub_w;
suber SUBer(
    .A(A),
    .B(B),
    .S(sub_w)
);

wire [DATA_WIDTH - 1:0] mul_w;
muler MULer(
    .A(A[HILO_WIDTH - 1:0]),
    .B(B[HILO_WIDTH - 1:0]),
    .P(mul_w)
);

always_comb
case (SEL)
ADD: S = add_w;
SUB: S = sub_w;
MUL: S = mul_w;
PAS: S = A;
AND: S = A & B;
OR:  S = A | B;
XOR: S = ((~A) & B) | (A | (~B));
default: S = ~A;
endcase

endmodule
