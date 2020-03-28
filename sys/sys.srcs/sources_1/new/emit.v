`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/03/26
// Design Name: 
// Module Name: chinx_emit
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

    input wire [`ADDR_WIDTH - 1:0] pc_i,
    input wire [`INS_WIDTH - 1:0] instr_i,
    // from HI/LO register
    input wire [`DATA_WIDTH - 1:0] hi_i,
    input wire [`DATA_WIDTH - 1:0] lo_i,
    // from load operation
    input wire [`DATA_WIDTH - 1:0] load_i,
    // write back to regfiles
    output reg [`REG_ADDR_WIDTH - 1:0] waddr_o,
    output reg [`REG_ADDR_WIDTH - 1:0] raddr0_o,
    output reg [`REG_ADDR_WIDTH - 1:0] raddr1_o,
    // handle the 16-bit immediate number
    output reg [`INSTR_IMM_WIDTH - 1:0] imm_o,
    output reg immext_o, // signed or unsigned

    output reg wbe_o, // write back to register files
    output reg hle_o, // write back to HI/LO register
    output reg memce_o, // need MEM stage [validate for 2 periods]
    output reg memop_o, // load or store memory
    output reg [`MEM_OPND_WIDTH - 1:0] memod_o, // word, half, halfu, byte, byteu

    output reg [`ALU_SRC_WIDTH - 1:0] alusrca_o, // Rb, Rc, ExtImm
    output reg [`ALU_SRC_WIDTH - 1:0] alusrcb_o, // Rb, Rc, ExtImm

    // Arith: ADD, SUB, MUL, EXT
    // Logic: AND, OR, XOR, NOT
    output reg [`ALU_RES_WIDTH - 1:0] alures_o,

    // Branch
    output reg be_o,

    // stall the pipeline
    // by sending this signal to stage1
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
wire [`INSTR_IMM_WIDTH - 1:0] imm_w = instr_i[15:0];
wire [`INSTR_BADDR_WIDTH - 1:0] baddr_w = instr_i[25:0];

// handle conflicts when emit 
// parallel operations with load/store operation
reg [`REG_ADDR_WIDTH - 1:0] conflict_r; // used for lw and mul operation
reg ls_busy_r;
reg ls_period_r;

// handle branch effects
reg br_flush_r;

always @(posedge clk) begin
    if (rst == `LEV_H) begin
        // output signals
        waddr_o <= `REG_RA;
        raddr0_o <= `REG_ZERO;
        raddr1_o <= `REG_ZERO;
        imm_o <= `INSTR_IMM_WIDTH'd0;
        immext_o <= `EXT_SIGNED;
        wbe_o <= `LEV_L;
        hle_o <= `LEV_L;
        memce_o <= `LEV_L;
        memop_o <= `MEM_LOAD;
        memod_o <= `MEM_OPND_WORD;
        alusrca_o <= `ALU_SRC_R0;
        alusrcb_o <= `ALU_SRC_R1;
        alures_o <= `ALU_RES_ADD;
        be_o <= `LEV_L;
        stall <= `LEV_L;
        // internal signals
        conflict_r <= `REG_ZERO;
        ls_busy_r <= `LEV_L;
        ls_period_r <= `LEV_L;
        br_flush_r <= `LEV_L;
    // end else if (flush == `LEV_H) begin
    //     // dismiss the write effects
    //     wbe_o <= `LEV_L;
    end else if (br_flush_r == `LEV_H) begin
        br_flush_r <= `LEV_L;
        // dismiss the write effects
        wbe_o <= `LEV_L;
        be_o <= `LEV_L;
    end else begin
        imm_o <= imm_w;
        if ((opcode_w > ALO_BEGIN) && (opcode_w < ALO_END)) begin
            ls_period_r <= ~ls_period_r; // used when load/store is running
            // add,addi,ori
            // set the data flow from regfiles
            waddr_o <= (ls_busy_r == `LEV_H && ls_period_r == `LEV_H) ? // load
                conflict_r : ra_w;
            raddr0_o <= rb_w;
            raddr1_o <= rc_w;
            // all operations need to write back
            wbe_o <= `LEV_H;
            // no load and store operations
            memce_o <= `LEV_L;
            // set the extension model of immediate number
            immext_o <= (opcode_w < ALO_UIMM) ? `EXT_SIGNED : `EXT_UNSIGNED;
            // set the data flow of sources sent to ALU
            alusrca_o <= `ALU_SRC_R0;
            alusrcb_o <= (opcode_w < ALO_SIMM) ? `ALU_SRC_R1 : `ALU_SRC_IMM;
            // set the data flow of ALU result
            alures_o <= (opcode_w == ADD || opcode_w == ADDI) ?
                `ALU_RES_ADD : `ALU_RES_OR;
            // do not branch
            be_o <= `LEV_L;
            if (ls_busy_r == `LEV_H && ls_period_r == `LEV_H) begin
                // load operation will occupy the WB stage
                // stall the stage1 to keep the pc value
                stall <= `LEV_H;
                ls_busy_r <= `LEV_L;
            end else if (ls_busy_r == `LEV_H && ra_w == conflict_r ) begin
                // WAW conflict
                // stall the stage1 to keep the pc value
                stall <= `LEV_H;
            end else begin
                stall <= `LEV_L; // no load/store operations before or no conflict
                conflict_r <= `REG_ADDR_WIDTH'd0; // release
            end
        end else if ((opcode_w > BRO_BEGIN) && (opcode_w < BRO_END)) begin
            ls_period_r <= ~ls_period_r;
            ls_busy_r <= (ls_busy_r == `LEV_H && ls_period_r == `LEV_H) ?
                `LEV_L : ls_busy_r;
            // ret,jr
            // no operations need to write back, but pc register in Co-processor
            // except that the load operation is done
            wbe_o <= (ls_busy_r == `LEV_H && ls_period_r == `LEV_H) ? // load
                `LEV_H : `LEV_L;
            waddr_o <= conflict_r;
            // no load and store operations
            memce_o <= `LEV_L;
            // set the extension model of immediate number
            immext_o <= `EXT_SIGNED;
            // set the data flow sources and result of ALU
            alusrca_o <= `ALU_SRC_R1;
            alusrcb_o <= `ALU_SRC_IMM;
            alures_o <= `ALU_RES_ADD;
            // branch
            be_o <= `LEV_H;
            br_flush_r <= `LEV_H;
        end else if ((opcode_w > LSO_BEGIN) && (opcode_w < LSO_END)) begin
            // lw,sw
            // load operations need to write back
            // wbe_o <= (opcode_w < LSO_STORE) ? `LEV_H : `LEV_L;
            // but not the next period
            // except that the last load operation is done
            wbe_o <= (ls_busy_r == `LEV_H && ls_period_r == `LEV_H) ? // load
                `LEV_H : `LEV_L;
            waddr_o <= conflict_r;
            // load and store operations
            memce_o <= `LEV_H;
            memop_o <= (opcode_w < LSO_STORE) ? `MEM_LOAD : `MEM_STORE;
            memod_o <= `MEM_OPND_WORD;
            // set the extension model of immediate number
            immext_o <= `EXT_SIGNED;
            // set the data flow sources and result of ALU
            alusrca_o <= `ALU_SRC_R1;
            alusrcb_o <= `ALU_SRC_IMM;
            alures_o <= `ALU_RES_ADD;
            // do not branch
            be_o <= `LEV_L;
            if (ls_busy_r == `LEV_H && ls_period_r == `LEV_L) begin
                // the last load/store is runnig now
                stall <= `LEV_H;
                ls_period_r = `LEV_H;
            end else begin
                // the last load/store operation is done
                stall <= `LEV_L;
                conflict_r <= (opcode_w < LSO_STORE) ? 
                    `REG_ADDR_WIDTH'd0 : ra_w; // release
                ls_period_r <= `LEV_L;
                ls_busy_r <= `LEV_H;
            end
        end
    end
end

endmodule