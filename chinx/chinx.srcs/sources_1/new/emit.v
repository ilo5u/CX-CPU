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
//    input wire [`ADDR_WIDTH - 1:0] pc_i,
    input wire [`INSTR_WIDTH - 1:0] instr_i,
    // from HI/LO register
    input wire [`HILO_WIDTH - 1:0] hi_i,
    input wire [`HILO_WIDTH - 1:0] lo_i,
    // interruption
    input wire ireq_i,
    // input wire zerof,
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
    // output reg memop_o, // load or store memory, replaced by memce_o
    output reg [`MEM_OPND_WIDTH - 1:0] memod_o, // word, half, halfu, byte, byteu

    output reg [`ALU_SRC_WIDTH - 1:0] alusrca_o, // Rb, Rc, ExtImm
    output reg [`ALU_SRC_WIDTH - 1:0] alusrcb_o, // Rb, Rc, ExtImm
    // Arith: ADD, SUB, MEM, EXT
    // Logic: AND, OR, XOR, NOT
    output reg [`ALU_RES_WIDTH - 1:0] alures_o,
    // Branch
    // may stall the pipeline
    // by sending this signal to stage1
    output reg [`BRANCH_SRC_WIDTH - 1:0] bsrc_o,
    // handle interruption
    output reg irep_o,
//    output reg [`ADDR_WIDTH - 1:0] pc_o,
    // Load/Store cache
    output reg stasrc_o,
    output reg stdsrc_o
    // handle the effects when stall the pipeline
//    output reg [`INSTR_WIDTH - 1:0] instr_o
);

// Arith and Logic operations (ALO)
localparam NOP = `INSTR_OPC_WIDTH'h00;
localparam ALO_BEGIN = `INSTR_OPC_WIDTH'h01;
localparam ADD = `INSTR_OPC_WIDTH'h02;
localparam SUB = `INSTR_OPC_WIDTH'h03;
localparam MUL = `INSTR_OPC_WIDTH'h04;
localparam ALO_SIMM = `INSTR_OPC_WIDTH'h08;
localparam ADDI = `INSTR_OPC_WIDTH'h09;
localparam LUI = `INSTR_OPC_WIDTH'h0a;
localparam SLL = `INSTR_OPC_WIDTH'h0b;
localparam MTHI = `INSTR_OPC_WIDTH'h0e;
localparam MTLO = `INSTR_OPC_WIDTH'h0f;
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
// decode instruction
wire [`INSTR_OPC_WIDTH - 1:0] opcode_w = instr_i[31:26];
wire [`REG_ADDR_WIDTH - 1:0] ra_w = instr_i[25:21];
wire [`REG_ADDR_WIDTH - 1:0] rb_w = instr_i[20:16];
wire [`REG_ADDR_WIDTH - 1:0] rc_w = instr_i[15:11];
wire [`INSTR_IMM_WIDTH - 1:0] imm_w = instr_i[15:0];
// wire [`INSTR_BADDR_WIDTH - 1:0] baddr_w = instr_i[25:0];
// handle conflicts when emit 
// parallel operations with load/store operation
reg [`REG_ADDR_WIDTH - 1:0] conflict_r; // used for lw and mul operation
reg ls_busy_r;
reg ls_period_r;
reg ls_op_r;
// handle branch effects
// reg br_flush_r;
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
        memod_o <= `MEM_OPND_WORD;
        alusrca_o <= `ALU_SRC_R0;
        alusrcb_o <= `ALU_SRC_R1;
        alures_o <= `ALU_RES_ADD;
        irep_o <= `LEV_L;
        bsrc_o <= `BRANCH_SRC_NOOP;
        // internal signals
        conflict_r <= `REG_ZERO;
        ls_busy_r <= `LEV_L;
        ls_period_r <= `LEV_L;
        ls_op_r <= `MEM_LOAD;
    end else begin
        if (ireq_i == `LEV_H) begin
            // ls_period_r <= ~ls_period_r;
            // interruption
            // if there are load/store instructions running now
            // wait for it
            bsrc_o <= (ls_busy_r == `LEV_H) ? `BRANCH_SRC_EPC : `BRANCH_SRC_IPC;
            // TO DO
            if (ls_busy_r == `LEV_H && ls_period_r == `LEV_H && ls_op_r == `MEM_LOAD) begin
                wbe_o <= `LEV_H;
                ls_op_r <= `MEM_STORE;
            end else if (ls_busy_r == `LEV_H && ls_period_r == `LEV_H && ls_op_r == `MEM_STORE) begin
                wbe_o <= `LEV_L;
                memce_o <= `LEV_L;
                ls_busy_r <= `LEV_L;
                // restore current environment
                irep_o <= `LEV_H;
            end else if (ls_busy_r == `LEV_H && ls_period_r == `LEV_L) begin
                wbe_o <= `LEV_L;
                ls_period_r <= `LEV_H;
            end else begin
                // restore current environment
                irep_o <= `LEV_H;
            end
        end else if ((opcode_w == NOP) ||
            (opcode_w > ALO_BEGIN) && (opcode_w < ALO_END)) begin
            ls_period_r <= ~ls_period_r; // used when load/store is running
            // add,addi,ori
            // set the data flow from regfiles
            waddr_o <= (ls_busy_r == `LEV_H && ls_period_r == `LEV_H) ? // load
                conflict_r : ra_w;
            raddr0_o <= rb_w;
            raddr1_o <= rc_w;
            // all operations need to write back
            // wbe_o <= `LEV_H;
            // no load and store operations
            memce_o <= (ls_busy_r == `LEV_H && ls_period_r == `LEV_L && ls_op_r == `MEM_STORE) ?
                `LEV_H : `LEV_L;
            stasrc_o <= (ls_busy_r == `LEV_H && ls_period_r == `LEV_L) ?
                `STA_SRC_CACHE : `STA_SRC_ALU;
            stdsrc_o <= (ls_busy_r == `LEV_H && ls_period_r == `LEV_L) ?
                `STD_SRC_CACHE : `STD_SRC_DATA0;
            // set the extension model of immediate number
            immext_o <= (opcode_w < ALO_UIMM) ? `EXT_SIGNED : `EXT_UNSIGNED;
            imm_o <= (opcode_w == MTHI) ? hi_i : ((opcode_w == MTLO) ?
                lo_i : imm_w);
            // set the data flow of sources sent to ALU
            alusrca_o <= `ALU_SRC_R0;
            alusrcb_o <= (opcode_w < ALO_SIMM) ? `ALU_SRC_R1 : `ALU_SRC_IMM;
            // set the data flow of ALU result
            alures_o <= (ls_busy_r == `LEV_H && ls_period_r == `LEV_H && ls_op_r == `MEM_LOAD) ?
                `ALU_RES_MEM : ((opcode_w == ADD || opcode_w == ADDI) ?
                    `ALU_RES_ADD : ((opcode_w == MTHI || opcode_w == MTLO) ?
                    `ALU_RES_EXT : `ALU_RES_OR));
            if (ls_busy_r == `LEV_H && ls_period_r == `LEV_H && ls_op_r == `MEM_LOAD) begin
                // load operation will occupy the WB stage
                // stall the stage1 to keep the epc value
                wbe_o <= `LEV_H;
                bsrc_o <= `BRANCH_SRC_EPC;
                ls_busy_r <= `LEV_L;
                ls_op_r <= `MEM_STORE;
            end else if (ls_busy_r == `LEV_H && ra_w == conflict_r) begin
                // WAW conflict
                // stall the stage1 to keep the epc value
                wbe_o <= `LEV_L;
                bsrc_o <= `BRANCH_SRC_EPC;
            end else if (ls_busy_r == `LEV_H && rb_w == conflict_r) begin
                // RAW conflict
                // stall the stage1 to keep the epc value
                wbe_o <= `LEV_L;
                bsrc_o <= `BRANCH_SRC_EPC;
            end else if (ls_busy_r == `LEV_H && rc_w == conflict_r
                && (opcode_w < ALO_SIMM)) begin
                // RAW conflict
                // stall the stage1 to keep the epc value
                wbe_o <= `LEV_L;
                bsrc_o <= `BRANCH_SRC_EPC;
            end else begin
                wbe_o <= `LEV_H;
                bsrc_o <= `BRANCH_SRC_NOOP; // no load/store operations before or no conflict
                conflict_r <= `REG_ADDR_WIDTH'd0; // release
            end
        end else if ((opcode_w > BRO_BEGIN) && (opcode_w < BRO_END)) begin
            ls_period_r <= ~ls_period_r;
            ls_busy_r <= (ls_busy_r == `LEV_H && ls_period_r == `LEV_H) ?
                `LEV_L : ls_busy_r;
            // ret,jr
            // no operations need to write back, but pc register in Co-processor
            // except that the load operation is done
            wbe_o <= (ls_busy_r == `LEV_H && ls_period_r == `LEV_H && ls_op_r == `MEM_LOAD) ? // load
                `LEV_H : `LEV_L;
            waddr_o <= conflict_r;
            // set the data flow from regfiles
            raddr0_o <= ra_w;
            raddr1_o <= rb_w;
            // no load and store operations
            memce_o <= (ls_busy_r == `LEV_H && ls_period_r == `LEV_L && ls_op_r == `MEM_STORE) ?
                `LEV_H : `LEV_L;
            stasrc_o <= (ls_busy_r == `LEV_H && ls_period_r == `LEV_L) ?
                `STA_SRC_CACHE : `STA_SRC_ALU;
            stdsrc_o <= (ls_busy_r == `LEV_H && ls_period_r == `LEV_L) ?
                `STD_SRC_CACHE : `STD_SRC_DATA0;
            // set the extension model of immediate number
            immext_o <= `EXT_SIGNED;
            imm_o <= imm_w;
            // set the data flow sources and result of ALU
            alusrca_o <= `ALU_SRC_R0;
            alusrcb_o <= `ALU_SRC_IMM;
            alures_o <= (ls_busy_r == `LEV_H && ls_period_r == `LEV_H && ls_op_r == `MEM_LOAD) ?
                `ALU_RES_MEM : `ALU_RES_ADD;
            // branch
            bsrc_o <= `BRANCH_SRC_JUMP;
        end else if ((opcode_w > LSO_BEGIN) && (opcode_w < LSO_END)) begin
            // lw,sw
            // load operations need to write back
            // wbe_o <= (opcode_w < LSO_STORE) ? `LEV_H : `LEV_L;
            // but not the next period
            // except that the last load operation is done
            wbe_o <= (ls_busy_r == `LEV_H && ls_period_r == `LEV_H && ls_op_r == `MEM_LOAD) ? // load
                `LEV_H : `LEV_L;
            waddr_o <= conflict_r;
            // set the data flow from regfiles
            raddr0_o <= ra_w;
            raddr1_o <= rb_w;
            // load and store operations
            memce_o <= (ls_busy_r == `LEV_H && ls_period_r == `LEV_L) ?
                memce_o : ((opcode_w < LSO_STORE) ? `LEV_L : `LEV_H);
            memod_o <= `MEM_OPND_WORD;
            stasrc_o <= ((ls_busy_r == `LEV_H && ls_period_r == `LEV_L)
                || (ls_busy_r == `LEV_H && ls_period_r == `LEV_H && ls_op_r == `MEM_LOAD)) ?
                `STA_SRC_CACHE : `STA_SRC_ALU;
            stdsrc_o <= (ls_busy_r == `LEV_H && ls_period_r == `LEV_L) ?
                `STD_SRC_CACHE : `STD_SRC_DATA0;
            // set the extension model of immediate number
            immext_o <= `EXT_SIGNED;
            imm_o <= imm_w;
            // set the data flow sources and result of ALU
            alusrca_o <= `ALU_SRC_R1;
            alusrcb_o <= `ALU_SRC_IMM;
            alures_o <= (ls_busy_r == `LEV_H && ls_period_r == `LEV_H && ls_op_r == `MEM_LOAD) ?
                `ALU_RES_MEM : `ALU_RES_ADD;
            if (ls_busy_r == `LEV_H && ls_period_r == `LEV_L) begin
                // the last load/store is runnig now
                bsrc_o <= `BRANCH_SRC_EPC;
                ls_period_r <= `LEV_H;
            end else if (ls_busy_r == `LEV_H && ls_period_r == `LEV_H && ls_op_r == `MEM_LOAD) begin
                // the last load/store is runnig now
                bsrc_o <= `BRANCH_SRC_EPC;
                ls_period_r <= `LEV_H;
                ls_op_r <= `MEM_STORE;
            end else begin
                // the last load/store operation is done
                bsrc_o <= `BRANCH_SRC_NOOP;
                conflict_r <= (opcode_w < LSO_STORE) ? 
                    ra_w : `REG_ADDR_WIDTH'd0; // hold
                ls_period_r <= `LEV_L;
                ls_busy_r <= `LEV_H;
                ls_op_r <= (opcode_w < LSO_STORE) ? `MEM_LOAD : `MEM_STORE;
            end
        end
    end
end
//assign pc_o = pc_i;
endmodule