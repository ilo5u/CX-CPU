`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/04/21 13:42:58
// Design Name: 
// Module Name: chinx_sys
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

module chinx_sys(
    input clk, // U18
    input rst, // N15 Active Low
    inout [2:0] switch,
    inout [3:0] led // [M14 M15 K16 J16] [0..3]
);
wire [7:0] io0 = {5'bz, switch};
wire [7:0] io1 = {4'bz, led};
wire [7:0] io2;
wire [7:0] io3;

reg [31:0] lower;
reg clk50khz;
initial begin
    lower = 0;
    clk50khz = 1'b0;
end
always_ff @(posedge clk) begin
    if (lower < 32'd500) begin
        lower <= lower + 1;
        clk50khz <= 1'b0;
    end else if (lower >= 32'd500 && lower < 32'd1000) begin
        lower <= lower + 1;
        clk50khz <= 1'b1;
    end else begin
        lower <= 0;
        clk50khz <= 1'b0;
    end
end

chinx_pipeline pipeline(
    .clk(clk50khz),
    .rst(~rst),
    .io0(io0),
    .io1(io1),
    .io2(io2),
    .io3(io3)
);

endmodule
