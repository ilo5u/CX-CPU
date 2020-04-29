`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/04/21 12:15:39
// Design Name: 
// Module Name: CustomIntr
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

module CustomIntr(
    input wire clk,
    input wire rst,
    input wire ir0,
    input wire ir1,
    input wire mask,
    output wire ireq,
    output reg [1:0] ivec
);
reg ir0_r;
reg ir1_r;
always_ff @(posedge clk) begin
    if (rst == 1'b1) begin
        ir0_r <= 1'b0;
        ir1_r <= 1'b0;
        ivec <= 2'b00;
    end else begin
        ir0_r <= ir0;
        ir1_r <= ir1;
        case (mask)
        1'b0: begin
            priority if (ir0 == 1'b1 && ir0_r == 1'b0)
                ivec <= 2'b01;
            else if (ir1 == 1'b1 && ir1_r == 1'b0)
                ivec <= 2'b10;
            else
                ivec <= 2'b00;
        end
        default: ivec <= 2'b00;
        endcase
    end
end
assign ireq = ivec[0] | ivec[1];
endmodule
