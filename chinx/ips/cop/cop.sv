`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/04/20 14:57:27
// Design Name: 
// Module Name: CustomCop
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


module CustomCop #(parameter ADDR_WIDTH = 8)(
    input wire clk,
    input wire rst,
    input wire [ADDR_WIDTH - 1:0] pc,
    
    input wire ireq,
    input wire [1:0] ivec,
    input wire irep,
    
    output wire intrf,
    output reg [ADDR_WIDTH - 1:0] ipc,
    output reg [ADDR_WIDTH - 1:0] rpc,
    output reg [ADDR_WIDTH - 1:0] epc
);
reg [ADDR_WIDTH - 1:0] ivec_r[0:1];
always_ff @(posedge clk) begin
    epc <= pc;
end

always_ff @(posedge irep) begin
    rpc <= pc;
end

reg ireq_r;
reg [1:0] cnt_r; // request signal actives high for 3 cycles
reg intrf_r;

always_ff @(posedge clk) begin
    if (rst == 1'b1) begin
        ivec_r[0] <= 128;
        ivec_r[1] <= 192;
        ireq_r <= 1'b0;
        intrf_r <= 1'b0;
        cnt_r <= 2'b00;
    end else if (ireq_r == 1'b0 && ireq == 1'b1) begin
        ireq_r <= ireq;
        cnt_r <= 2'b00;
        case (ivec)
        2'b01: begin
            ipc <= ivec_r[0];
            intrf_r <= 1'b1;
        end
        2'b10: begin
            ipc <= ivec_r[1];
            intrf_r <= 1'b1;
        end
        2'b11: begin
            ipc <= ivec_r[0];
            intrf_r <= 1'b1;
        end
        default: begin
            ipc <= pc;
            intrf_r <= 1'b0;
        end
        endcase
    end else if (intrf_r == 1'b1 && cnt_r == 2'b00) begin
        ireq_r <= ireq;
        cnt_r <= 2'b01;
    end else if (intrf_r == 1'b1 && cnt_r == 2'b01) begin
        ireq_r <= ireq;
        cnt_r <= 2'b10;
    end else begin
        ireq_r <= ireq;
        intrf_r <= 1'b0;
    end
end
assign intrf = intrf_r & (~irep);

endmodule
