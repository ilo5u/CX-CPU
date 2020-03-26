`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/03/26
// Design Name: 
// Module Name: chinx_accu
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

module chinx_emit(
    input wire clk,
    input wire rst,
    input wire busy,
    input wire flush,

    input wire [`BUS_WIDTH - 1:0] pc_i,
    input wire [`BUS_WIDTH - 1:0] instr_i,

    output reg [`REG_ADDR_WIDTH - 1:0] ra_o,
    output reg [`REG_ADDR_WIDTH - 1:0] rb_o,
    output reg [`REG_ADDR_WIDTH - 1:0] rc_o,

    output reg [`IMM_WIDTH - 1:0] imm_o,
    output reg [`BADDR_WIDTH - 1:0] baddr_o,

    output reg immext_o, // signed or unsigned

    output reg wbe_o, // write back to register files
    output reg memce_o, // need MEM stage
    output reg memop_o, // load or store memory

    output reg [`ALU_SRC_WIDTH - 1:0] alusrca_o, // Rb, Rc, ExtImm
    output reg [`ALU_SRC_WIDTH - 1:0] alusrcb_o, // Rb, Rc, ExtImm

    // Arith: ADD, SUB, MUL, EXT
    // Logic: AND, OR, XOR, NOT
    output reg [`ALU_RES_WIDTH - 1:0] alures_o,

    // Branch
    output reg be_o,

    output reg stall
);

// Arith and Logic operations (ALO)
localparam ALO_BEGIN = `INSTR_OPC_WIDTH'h01;
localparam ADD = `INSTR_OPC_WIDTH'h02;

localparam ALO_SIMM = `INSTR_OPC_WIDTH'h08;
localparam ADDI = `INSTR_OPC_WIDTH'h09;

localparam ALO_UIMM = `INSTR_OPC_WIDTH'h10;
localparam ORI = `INSTR_OPC_WIDTH'h11;
localparam ALO_END = `INSTR_OPC_WIDTH'h1F;

// Brach operations (BRO)
localparam BRO_BEGIN = `INSTR_OPC_WIDTH'h20;
localparam RET = `INSTR_OPC_WIDTH'h21;
localparam JR = `INSTR_OPC_WIDTH'h22;
localparam BRO_END = `INSTR_OPC_WIDTH'h2F;

// Load and Store operations (LSO)
localparam LSO_BEGIN = `INSTR_OPC_WIDTH'h30;
localparam LW = `INSTR_OPC_WIDTH'h31;
localparam LSO_STORE = `INSTR_OPC_WIDTH'h38;
localparam SW = `INSTR_OPC_WIDTH'h39;
localparam LSO_END = `INSTR_OPC_WIDTH'h3F;

wire [`INSTR_OPC_WIDTH - 1:0] opcode_w = instr_i[31:26];
wire [`REG_ADDR_WIDTH - 1:0] ra_w = instr_i[25:21];
wire [`REG_ADDR_WIDTH - 1:0] rb_w = instr_i[20:16];
wire [`REG_ADDR_WIDTH - 1:0] rc_w = instr_i[15:11];
wire [`IMM_WIDTH - 1:0] imm_w = instr_i[15:0];
wire [`BADDR_WIDTH - 1:0] baddr_w = instr_i[25:0];

reg [`REG_ADDR_WIDTH - 1:0] conflict_r; // used for lw and mul operation

reg load_r;

always @(posedge clk) begin
    if (rst == `LEV_H) begin
        // output signals
        ra_o <= `REG_ADDR_WIDTH'd31;
        rb_o <= `REG_ADDR_WIDTH'd0;
        rc_o <= `REG_ADDR_WIDTH'd0;
        imm_o <= `IMM_WIDTH'd0;
        baddr_o <= `BADDR_WIDTH'd0;
        immext_o <= `LEV_L;
        wbe_o <= `LEV_L;
        memce_o <= `LEV_L;
        memop_o <= `MEM_LOAD;

        // internal signals
        conflict_r <= `REG_ADDR_WIDTH'd0;
    end else if (flush == `LEV_H) begin
        // dismiss the write effects
        wbe_o <= `LEV_L;
    end else begin
        ra_o <= ra_w;
        rb_o <= rb_w;
        rc_o <= rc_w;
        imm_o <= imm_w;
        if ((opcode_w > ALO_BEGIN) && (opcode_w < ALO_END)) begin
            // add,addi,ori
            // all operations need to write back
            wbe_o <= `LEV_H;
            // no load and store operations
            memce_o <= `LEV_L;
            memop_o <= `MEM_LOAD;

            // set the extension model of immediate number
            immext_o <= (opcode_w < ALO_UIMM) ? `EXT_SIGNED : `EXT_UNSIGNED;

            // set the data flow sources of ALU
            alusrca_o <= `ALU_SRC_RB;
            alusrcb_o <= (opcode_w < ALO_SIMM) ? `ALU_SRC_RC : `ALU_SRC_IMM;

            alures_o <= (opcode_w == ADD || opcode_w == ADDI) ? `ALU_RES_ADD
                : `ALU_RES_OR;

            // do not branch
            be_o <= `LEV_L;
            
            load_r <= ~load_r;
            if (busy == `LEV_H && load_r == `LEV_H) begin
                // load operation will occupy the WB stage
                stall <= `LEV_H;
            end else if (busy == `LEV_H && ra_w == conflict_r ) begin
                // WAW conflict
                stall <= `LEV_H;
            end else begin
                stall <= `LEV_L; // no load or store or multiply operations before
                conflict_r <= `REG_ADDR_WIDTH'd0; // release
            end
        end else if ((opcode_w > BRO_BEGIN) && (opcode_w < BRO_END)) begin
            // ret,jr
            // no operations need to write back, but pc register in Co-processor
            wbe_o <= `LEV_L;
            // no load and store operations
            memce_o <= `LEV_L;
            memop_o <= `MEM_LOAD;

            // set the extension model of immediate number
            immext_o <= `EXT_SIGNED;

            // set the data flow sources and result of ALU
            alusrca_o <= `ALU_SRC_RB;
            alusrcb_o <= `ALU_SRC_IMM;
            alures_o <= `ALU_RES_ADD;

            // branch
            be_o <= `LEV_H;
        end else if ((opcode_w > LSO_BEGIN) && (opcode_w < LSO_END)) begin
            // lw,sw
            // load operations need to write back
            wbe_o <= (opcode_w < LSO_STORE) ? `LEV_H : `LEV_L;
            // load and store operations
            memce_o <= `LEV_H;
            memop_o <= (opcode_w < LSO_STORE) ? `MEM_LOAD : `MEM_STORE;

            // set the extension model of immediate number
            immext_o <= `EXT_SIGNED;

            // set the data flow sources and result of ALU
            alusrca_o <= `ALU_SRC_RB;
            alusrcb_o <= `ALU_SRC_IMM;
            alures_o <= `ALU_RES_ADD;

            // do not branch
            be_o <= `LEV_L;
            
            if (busy == `LEV_H) begin
                stall <= `LEV_H;
            end else begin
                stall <= `LEV_L; // no load or store or multiply operations before
                conflict_r <= (opcode_w < LSO_STORE) ? 
                    `REG_ADDR_WIDTH'd0 : ra_w; // release
                load_r <= `LEV_L;
            end
        end
    end
end

endmodule