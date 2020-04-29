`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/04/20 14:29:52
// Design Name: 
// Module Name: CustomPort
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


module CustomPort(
    input wire clk,
    input wire ce,
    input wire z,
    inout [7:0] dio_0,
    inout [7:0] dio_1
);
reg [7:0] data;
always_ff @(posedge clk) begin
    if (ce == 1'b1)
        data <= (z == 1'b0) ? dio_1 : dio_0;
end
// 0: 0->1
// 1: 0<-1
assign dio_0 = (z == 1'b0) ? data : 8'bz;
assign dio_1 = (z == 1'b0) ? 8'bz : data;
endmodule
