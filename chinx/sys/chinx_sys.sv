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
// A simple sample to test CHINX cpu.
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

// underclock 50MHz --> 500KHz
localparam splitter_low = 50;
localparam splitter_high = 100;
reg [7:0]  splitter_100s;
reg clk500khz;
initial begin
    splitter_100s = 0;
    clk500khz = 1'b0;
end
always_ff @(posedge clk) begin
    if (splitter_100s < splitter_low) begin
        splitter_100s <= splitter_100s + 1;
        clk500khz <= 1'b0;
    end else if (splitter_100s >= splitter_low && splitter_100s < splitter_high) begin
        splitter_100s <= splitter_100s + 1;
        clk500khz <= 1'b1;
    end else begin
        splitter_100s <= 0;
        clk500khz <= 1'b0;
    end
end
// frequency of system clock is 500KHz
chinx_pipeline pipeline(
    .clk(clk500khz),
    .rst(~rst),
    .io0(io0),
    .io1(io1),
    .io2(io2),
    .io3(io3)
);

endmodule
