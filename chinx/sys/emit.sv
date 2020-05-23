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
    // outter drive signals
    input wire clk, // 50mhz
    input wire rst, // active high
    // input signals from IF stage
    input wire [`INSTR_WIDTH - 1:0] instr_i, // instruction
    // interruption request from C0
    input wire ireq_i,
    // addresses used for reading data from regfiles
    output reg [`REG_ADDR_WIDTH - 1:0] raddr0_o,
    output reg [`REG_ADDR_WIDTH - 1:0] raddr1_o,
    // handle the 16-bit immediate number
    output reg [`INSTR_IMM_WIDTH - 1:0] imm_o,
    output reg [`ES_WIDTH - 1:0] immes_o, // signed or unsigned
    // output signals to WB stage
    output reg [`REG_ADDR_WIDTH - 1:0] waddr_o,
    output reg wbe_o, // write back to register files
    // output signals for MEM stage
    output reg memce_o, // need MEM stage [active for 2 periods]
    output reg [`MEM_OPND_WIDTH - 1:0] memod_o, // word, half, halfu, byte, byteu
    // output signals for ALU operations
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
    output reg irep_o, // active when start the interruption program
    // Load/Store cache
    output reg addrfix_o, // addr = addr + 4 cause 'POP' operation
    output reg cache_o
);

// Arith and Logic operations (ALO)
localparam NOP = `INSTR_OPC_WIDTH'h00;
localparam ALO_BEGIN = `INSTR_OPC_WIDTH'h01;
localparam ADD = `INSTR_OPC_WIDTH'h02;
localparam SUB = `INSTR_OPC_WIDTH'h03;
localparam MUL = `INSTR_OPC_WIDTH'h04;
localparam AND = `INSTR_OPC_WIDTH'h05;
localparam OR = `INSTR_OPC_WIDTH'h06;
localparam XOR = `INSTR_OPC_WIDTH'h07;
localparam ALO_SIMM = `INSTR_OPC_WIDTH'h08;
localparam ADDI = `INSTR_OPC_WIDTH'h09;
localparam SUBI = `INSTR_OPC_WIDTH'h0a;
localparam LUI = `INSTR_OPC_WIDTH'h0f;
localparam ALO_UIMM = `INSTR_OPC_WIDTH'h10;
localparam ORI = `INSTR_OPC_WIDTH'h11;
localparam ANDI = `INSTR_OPC_WIDTH'h12;
localparam NOT = `INSTR_OPC_WIDTH'h13;
localparam SLL = `INSTR_OPC_WIDTH'h14;
localparam ALO_END = `INSTR_OPC_WIDTH'h1F;
// Brach operations (BRO)
localparam BRO_BEGIN = `INSTR_OPC_WIDTH'h20;
localparam RET = `INSTR_OPC_WIDTH'h21;
localparam JR = `INSTR_OPC_WIDTH'h22;
localparam BEQ = `INSTR_OPC_WIDTH'h23;
localparam BNE = `INSTR_OPC_WIDTH'h24;
localparam BLE = `INSTR_OPC_WIDTH'h25;
localparam CALL = `INSTR_OPC_WIDTH'h27;
localparam RETI = `INSTR_OPC_WIDTH'h28;
localparam BRO_END = `INSTR_OPC_WIDTH'h2F;
// Load and Store operations (LSO)
localparam LSO_BEGIN = `INSTR_OPC_WIDTH'h30;
localparam LW = `INSTR_OPC_WIDTH'h31;
localparam LH = `INSTR_OPC_WIDTH'h32;
localparam LB = `INSTR_OPC_WIDTH'h33;
localparam LHU = `INSTR_OPC_WIDTH'h34;
localparam LBU = `INSTR_OPC_WIDTH'h35;
localparam POP = `INSTR_OPC_WIDTH'h36;
localparam LSO_STORE = `INSTR_OPC_WIDTH'h38;
localparam SW = `INSTR_OPC_WIDTH'h39;
localparam SH = `INSTR_OPC_WIDTH'h3a;
localparam SB = `INSTR_OPC_WIDTH'h3b;
localparam SET = `INSTR_OPC_WIDTH'h3c;
localparam PUSH = `INSTR_OPC_WIDTH'h3d;
localparam LSO_END = `INSTR_OPC_WIDTH'h3e;
localparam HALT = `INSTR_OPC_WIDTH'h3f;
// decode instruction
wire [`INSTR_OPC_WIDTH - 1:0] opcode_w = instr_i[31:26];
wire [`REG_ADDR_WIDTH - 1:0] ra_w = instr_i[25:21];
wire [`REG_ADDR_WIDTH - 1:0] rb_w = instr_i[20:16];
wire [`REG_ADDR_WIDTH - 1:0] rc_w = instr_i[15:11];
wire [`INSTR_IMM_WIDTH - 1:0] imm_w = instr_i[15:0];
// handle conflicts when emit 
// parallel operations with load/store operation.
// 'conflict_r' is used for lw operation to dismiss the WAW or RAW conflict
reg [`REG_ADDR_WIDTH - 1:0] conflict_r; 
reg ls_busy_r;
reg ls_period_r;
reg [`MEM_WIDTH - 1:0] ls_op_r;

always_ff @(posedge clk) begin
    priority if (rst == `LEV_H) begin
        // output signals
        waddr_o  <= `REG_ZERO;
        raddr0_o <= `REG_ZERO;
        raddr1_o <= `REG_ZERO;
        imm_o    <= `INSTR_IMM_WIDTH'd0;
        immes_o  <= `ES_ELOS;
        wbe_o    <= `LEV_L;
        memce_o  <= `LEV_L;
        memod_o  <= `MEM_OPND_WORD;
        alusrca_o <= `ALU_SRC_R0;
        alusrcb_o <= `ALU_SRC_R1;
        alures_o  <= `ALU_RES_ADD;
        irep_o <= `LEV_L;
        bsrc_o <= `BRANCH_SRC_NOOP;
        // internal signals
        conflict_r  <= `REG_ZERO;
        ls_busy_r   <= `LEV_L;
        ls_period_r <= `LEV_L;
        ls_op_r     <= `MEM_LOAD;
    end else if (bsrc_o != `BRANCH_SRC_NOOP) begin
        case (ls_busy_r)
        `LEV_H:
        case (ls_period_r)
        `LEV_H: begin
        case (ls_op_r)
        `MEM_LOAD: begin
            // regfiles
            alusrca_o <= `ALU_SRC_MEM;
            alures_o  <= `ALU_RES_PAS;
            wbe_o   <= `LEV_H;
            waddr_o <= conflict_r;
            // internals
            ls_busy_r <= `LEV_L;
            conflict_r <= `REG_ADDR_WIDTH'd0;
        end
        `MEM_POP: begin
            // regfiles
            alusrca_o <= `ALU_SRC_MEM;
            alures_o  <= `ALU_RES_PAS;
            wbe_o   <= `LEV_H;
            waddr_o <= conflict_r;
            // internals
            ls_busy_r <= `LEV_L;
            conflict_r <= `REG_ADDR_WIDTH'd0;
        end
        default: begin
            wbe_o <= `LEV_L;
            // internals
            ls_busy_r <= `LEV_L;
            conflict_r <= `REG_ADDR_WIDTH'd0;
        end
        endcase
        end
        default: begin // period == LOW
        cache_o <= `LEV_L;
        case (ls_op_r)
        `MEM_PUSH: begin
            // regfiles
            alusrca_o <= `REG_SP;
            imm_o     <= `INSTR_IMM_WIDTH'd4;
            immes_o   <= `ES_ELOS;
            alures_o  <= `ALU_RES_SUB;
            wbe_o   <= `LEV_H;
            waddr_o <= `REG_SP;
            // internals
            ls_period_r <= `LEV_H;
        end
        `MEM_POP: begin
            // regfiles
            alusrca_o <= `REG_SP;
            imm_o     <= `INSTR_IMM_WIDTH'd4;
            immes_o   <= `ES_ELOS;
            alures_o  <= `ALU_RES_ADD;
            wbe_o   <= `LEV_H;
            waddr_o <= `REG_SP;
            // internals
            ls_period_r <= `LEV_H;
        end
        default: begin
            wbe_o <= `LEV_L;
            // internals
            ls_period_r <= `LEV_H;
        end
        endcase
        end
        endcase
        default: begin
            wbe_o <= `LEV_L;
            memce_o <= `LEV_L;
        end
        endcase
        bsrc_o <= `BRANCH_SRC_NOOP;
    end else if (ireq_i == `LEV_H) begin
        // interruption
        // if there are load/store instructions running now,
        // wait for it
        case (ls_busy_r)
        `LEV_H:
        case (ls_period_r)
        `LEV_H: begin // memory access operation is finished
            case (ls_op_r)
            `MEM_LOAD: begin
                // regfiles
                alusrca_o <= `ALU_SRC_MEM;
                alures_o  <= `ALU_RES_PAS;
                wbe_o   <= `LEV_H;
                waddr_o <= conflict_r;
                // branch
                bsrc_o <= `BRANCH_SRC_EPC; 
            end
            `MEM_POP: begin
                // regfiles
                alusrca_o <= `ALU_SRC_MEM;
                alures_o  <= `ALU_RES_PAS;
                wbe_o   <= `LEV_H;
                waddr_o <= conflict_r;
                // branch
                bsrc_o <= `BRANCH_SRC_EPC; 
            end
            default: begin
                // regfiles
                wbe_o  <= `LEV_L;
                irep_o <= `LEV_H;
                // branch
                bsrc_o <= `BRANCH_SRC_IPC;
            end
            endcase
            // internals
            ls_busy_r <= `LEV_L;
            conflict_r <= `REG_ADDR_WIDTH'd0;
        end
        default: begin // memory access operation is running
            cache_o <= `LEV_L;
            case (ls_op_r)
            `MEM_POP: begin // SP = SP + 4
                // regfiles
                raddr0_o <= `REG_SP;
                imm_o    <= `INSTR_IMM_WIDTH'd4;
                immes_o  <= `ES_ELOS;
                alusrca_o <= `ALU_SRC_R0;
                alusrcb_o <= `ALU_SRC_IMM;
                alures_o  <= `ALU_RES_ADD;
                wbe_o   <= `LEV_H;
                waddr_o <= `REG_SP;
            end
            `MEM_PUSH: begin // SP = SP - 4
                 // regfiles
                raddr0_o <= `REG_SP;
                imm_o    <= `INSTR_IMM_WIDTH'd4;
                immes_o  <= `ES_ELOS;
                alusrca_o <= `ALU_SRC_R0;
                alusrcb_o <= `ALU_SRC_IMM;
                alures_o  <= `ALU_RES_SUB;
                wbe_o   <= `LEV_H;
                waddr_o <= `REG_SP;
            end
            default: begin
                // regfiles
                wbe_o <= `LEV_L;
            end
            endcase
            // branch
            bsrc_o <= `BRANCH_SRC_EPC;
            // internals
            ls_period_r <= `LEV_H;
        end
        endcase
        default: begin // response the interruption request
            // regfiles
            wbe_o <= `LEV_L;
            irep_o <= `LEV_H;
            // branch
            bsrc_o <= `BRANCH_SRC_IPC;
            // internals
            conflict_r <= `REG_ADDR_WIDTH'd0;
        end
        endcase
    end else if (opcode_w < ALO_END) begin
        ls_period_r <= ~ls_period_r; // used when load/store is running
        case (ls_busy_r)
        `LEV_H:
        case (ls_period_r)
        `LEV_H: begin // memory access finished
            case (ls_op_r)
            `MEM_LOAD: begin // need to write back
                // regfiles
                alusrca_o <= `ALU_SRC_MEM;
                alures_o  <= `ALU_RES_PAS;
                wbe_o   <= `LEV_H;
                waddr_o <= conflict_r;
                // stall
                bsrc_o <= `BRANCH_SRC_EPC;
                // internals
                ls_busy_r <= `LEV_L;
                conflict_r <= `REG_ADDR_WIDTH'd0;
            end
            `MEM_POP: begin // need to write back
                // regfiles
                alusrca_o <= `ALU_SRC_MEM;
                alures_o  <= `ALU_RES_PAS;
                wbe_o   <= `LEV_H;
                waddr_o <= conflict_r;
                // stall
                bsrc_o <= `BRANCH_SRC_EPC;
                // internals
                ls_busy_r <= `LEV_L;
                conflict_r <= `REG_ADDR_WIDTH'd0;
            end
            default: begin // execute arithmetic or logic instruction
                // regfiles
                raddr0_o <= rb_w;
                raddr1_o <= rc_w;
                imm_o <= imm_w;
                waddr_o <= ra_w;
                case (opcode_w)
                SUB: begin
                    wbe_o <= `LEV_H;
                    alusrca_o <= `ALU_SRC_R0;
                    alusrcb_o <= `ALU_SRC_R1;
                    alures_o <= `ALU_RES_SUB;
                end
                MUL: begin
                    wbe_o <= `LEV_H;
                    alusrca_o <= `ALU_SRC_R0;
                    alusrcb_o <= `ALU_SRC_R1;
                    alures_o <= `ALU_RES_MUL;
                end
                AND: begin
                    wbe_o <= `LEV_H;
                    alusrca_o <= `ALU_SRC_R0;
                    alusrcb_o <= `ALU_SRC_R1;
                    alures_o <= `ALU_RES_AND;
                end
                OR: begin
                    wbe_o <= `LEV_H;
                    alusrca_o <= `ALU_SRC_R0;
                    alusrcb_o <= `ALU_SRC_R1;
                    alures_o <= `ALU_RES_OR;
                end
                XOR: begin
                    wbe_o <= `LEV_H;
                    alusrca_o <= `ALU_SRC_R0;
                    alusrcb_o <= `ALU_SRC_R1;
                    alures_o <= `ALU_RES_XOR;
                end
                NOT: begin
                    wbe_o <= `LEV_H;
                    alusrca_o <= `ALU_SRC_R0;
                    alusrcb_o <= `ALU_SRC_R1;
                    alures_o <= `ALU_RES_NOT;
                end
                ADDI: begin
                    wbe_o <= `LEV_H;
                    alusrca_o <= `ALU_SRC_R0;
                    alusrcb_o <= `ALU_SRC_IMM;
                    immes_o <= `ES_ELOS;
                    alures_o <= `ALU_RES_ADD;
                end
                SUBI: begin
                    wbe_o <= `LEV_H;
                    alusrca_o <= `ALU_SRC_R0;
                    alusrcb_o <= `ALU_SRC_IMM;
                    immes_o <= `ES_ELOS;
                    alures_o <= `ALU_RES_SUB;
                end
                ANDI: begin
                    wbe_o <= `LEV_H;
                    alusrca_o <= `ALU_SRC_R0;
                    alusrcb_o <= `ALU_SRC_IMM;
                    immes_o <= `ES_ELOU;
                    alures_o <= `ALU_RES_AND;
                end
                ORI: begin
                    wbe_o <= `LEV_H;
                    alusrca_o <= `ALU_SRC_R0;
                    alusrcb_o <= `ALU_SRC_IMM;
                    immes_o <= `ES_ELOU;
                    alures_o <= `ALU_RES_OR;
                end
                LUI: begin
                    wbe_o <= `LEV_H;
                    alusrca_o <= `ALU_SRC_R0;
                    alusrcb_o <= `ALU_SRC_IMM;
                    immes_o <= `ES_EHIZ;
                    alures_o <= `ALU_RES_ADD;
                end
                SLL: begin
                    wbe_o <= `LEV_H;
                    alusrca_o <= `ALU_SRC_R0;
                    alusrcb_o <= `ALU_SRC_IMM;
                    immes_o <= `ES_SHFT;
                    alures_o <= `ALU_RES_PAS;
                end
                ADD: begin
                    wbe_o <= `LEV_H;
                    alusrca_o <= `ALU_SRC_R0;
                    alusrcb_o <= `ALU_SRC_R1;
                    alures_o <= `ALU_RES_ADD;
                end
                default: begin // ADD
                    wbe_o <= `LEV_L;
                end
                endcase // build the ALU
                // branch
                bsrc_o <= `BRANCH_SRC_NOOP;
                // internals
                conflict_r <= `REG_ADDR_WIDTH'd0;
            end
            endcase
        end
        default: // memory access running
        if ((conflict_r != `REG_ZERO)
            && (ra_w == conflict_r || rb_w == conflict_r || rc_w == conflict_r)) begin
            // WAW and RAW
            wbe_o   <= `LEV_L;
            cache_o <= `LEV_L;
            // branch
            bsrc_o <= `BRANCH_SRC_EPC;
        end else begin 
            cache_o <= `LEV_L;
            case (ls_op_r)
            `MEM_POP: begin // SP = SP + 4
                // regfiles
                raddr0_o <= `REG_SP;
                imm_o    <= `INSTR_IMM_WIDTH'd4;
                immes_o  <= `ES_ELOS;
                alusrca_o <= `ALU_SRC_R0;
                alusrcb_o <= `ALU_SRC_IMM;
                alures_o  <= `ALU_RES_ADD;
                waddr_o <= `REG_SP;
                wbe_o   <= `LEV_H;
                // branch
                bsrc_o <= `BRANCH_SRC_EPC;
            end
            `MEM_PUSH: begin // SP = SP + 4
                // regfiles
                raddr0_o <= `REG_SP;
                imm_o    <= `INSTR_IMM_WIDTH'd4;
                immes_o  <= `ES_ELOS;
                alusrca_o <= `ALU_SRC_R0;
                alusrcb_o <= `ALU_SRC_IMM;
                alures_o  <= `ALU_RES_SUB;
                waddr_o <= `REG_SP;
                wbe_o   <= `LEV_H;
                // branch
                bsrc_o <= `BRANCH_SRC_EPC;
            end
            default: begin // execute arithmetic or logic instruction
                // regfiles
                raddr0_o <= rb_w;
                raddr1_o <= rc_w;
                imm_o <= imm_w;
                waddr_o <= ra_w;
                case (opcode_w)
                SUB: begin
                    wbe_o <= `LEV_H;
                    alusrca_o <= `ALU_SRC_R0;
                    alusrcb_o <= `ALU_SRC_R1;
                    alures_o <= `ALU_RES_SUB;
                end
                MUL: begin
                    wbe_o <= `LEV_H;
                    alusrca_o <= `ALU_SRC_R0;
                    alusrcb_o <= `ALU_SRC_R1;
                    alures_o <= `ALU_RES_MUL;
                end
                AND: begin
                    wbe_o <= `LEV_H;
                    alusrca_o <= `ALU_SRC_R0;
                    alusrcb_o <= `ALU_SRC_R1;
                    alures_o <= `ALU_RES_AND;
                end
                OR: begin
                    wbe_o <= `LEV_H;
                    alusrca_o <= `ALU_SRC_R0;
                    alusrcb_o <= `ALU_SRC_R1;
                    alures_o <= `ALU_RES_OR;
                end
                XOR: begin
                    wbe_o <= `LEV_H;
                    alusrca_o <= `ALU_SRC_R0;
                    alusrcb_o <= `ALU_SRC_R1;
                    alures_o <= `ALU_RES_XOR;
                end
                NOT: begin
                    wbe_o <= `LEV_H;
                    alusrca_o <= `ALU_SRC_R0;
                    alusrcb_o <= `ALU_SRC_R1;
                    alures_o <= `ALU_RES_NOT;
                end
                ADDI: begin
                    wbe_o <= `LEV_H;
                    alusrca_o <= `ALU_SRC_R0;
                    alusrcb_o <= `ALU_SRC_IMM;
                    immes_o <= `ES_ELOS;
                    alures_o <= `ALU_RES_ADD;
                end
                SUBI: begin
                    wbe_o <= `LEV_H;
                    alusrca_o <= `ALU_SRC_R0;
                    alusrcb_o <= `ALU_SRC_IMM;
                    immes_o <= `ES_ELOS;
                    alures_o <= `ALU_RES_SUB;
                end
                ANDI: begin
                    wbe_o <= `LEV_H;
                    alusrca_o <= `ALU_SRC_R0;
                    alusrcb_o <= `ALU_SRC_IMM;
                    immes_o <= `ES_ELOU;
                    alures_o <= `ALU_RES_AND;
                end
                ORI: begin
                    wbe_o <= `LEV_H;
                    alusrca_o <= `ALU_SRC_R0;
                    alusrcb_o <= `ALU_SRC_IMM;
                    immes_o <= `ES_ELOU;
                    alures_o <= `ALU_RES_OR;
                end
                LUI: begin
                    wbe_o <= `LEV_H;
                    alusrca_o <= `ALU_SRC_R0;
                    alusrcb_o <= `ALU_SRC_IMM;
                    immes_o <= `ES_EHIZ;
                    alures_o <= `ALU_RES_ADD;
                end
                SLL: begin
                    wbe_o <= `LEV_H;
                    alusrca_o <= `ALU_SRC_R0;
                    alusrcb_o <= `ALU_SRC_IMM;
                    immes_o <= `ES_SHFT;
                    alures_o <= `ALU_RES_PAS;
                end
                ADD: begin
                    wbe_o <= `LEV_H;
                    alusrca_o <= `ALU_SRC_R0;
                    alusrcb_o <= `ALU_SRC_R1;
                    alures_o <= `ALU_RES_ADD;
                end
                default: begin // NOP
                    wbe_o <= `LEV_L;
                end
                endcase // build the ALU
                // branch
                bsrc_o <= `BRANCH_SRC_NOOP;
            end
            endcase
        end
        endcase
        default: begin // no memory access operations
            // execute arithmetic or logic instruction
            // regfiles
            raddr0_o <= rb_w;
            raddr1_o <= rc_w;
            imm_o <= imm_w;
            waddr_o <= ra_w;
            case (opcode_w)
            SUB: begin
                wbe_o <= `LEV_H;
                alusrca_o <= `ALU_SRC_R0;
                alusrcb_o <= `ALU_SRC_R1;
                alures_o <= `ALU_RES_SUB;
            end
            MUL: begin
                wbe_o <= `LEV_H;
                alusrca_o <= `ALU_SRC_R0;
                alusrcb_o <= `ALU_SRC_R1;
                alures_o <= `ALU_RES_MUL;
            end
            AND: begin
                wbe_o <= `LEV_H;
                alusrca_o <= `ALU_SRC_R0;
                alusrcb_o <= `ALU_SRC_R1;
                alures_o <= `ALU_RES_AND;
            end
            OR: begin
                wbe_o <= `LEV_H;
                alusrca_o <= `ALU_SRC_R0;
                alusrcb_o <= `ALU_SRC_R1;
                alures_o <= `ALU_RES_OR;
            end
            XOR: begin
                wbe_o <= `LEV_H;
                alusrca_o <= `ALU_SRC_R0;
                alusrcb_o <= `ALU_SRC_R1;
                alures_o <= `ALU_RES_XOR;
            end
            NOT: begin
                wbe_o <= `LEV_H;
                alusrca_o <= `ALU_SRC_R0;
                alusrcb_o <= `ALU_SRC_R1;
                alures_o <= `ALU_RES_NOT;
            end
            ADDI: begin
                wbe_o <= `LEV_H;
                alusrca_o <= `ALU_SRC_R0;
                alusrcb_o <= `ALU_SRC_IMM;
                immes_o <= `ES_ELOS;
                alures_o <= `ALU_RES_ADD;
            end
            SUBI: begin
                wbe_o <= `LEV_H;
                alusrca_o <= `ALU_SRC_R0;
                alusrcb_o <= `ALU_SRC_IMM;
                immes_o <= `ES_ELOS;
                alures_o <= `ALU_RES_SUB;
            end
            ANDI: begin
                wbe_o <= `LEV_H;
                alusrca_o <= `ALU_SRC_R0;
                alusrcb_o <= `ALU_SRC_IMM;
                immes_o <= `ES_ELOU;
                alures_o <= `ALU_RES_AND;
            end
            ORI: begin
                wbe_o <= `LEV_H;
                alusrca_o <= `ALU_SRC_R0;
                alusrcb_o <= `ALU_SRC_IMM;
                immes_o <= `ES_ELOU;
                alures_o <= `ALU_RES_OR;
            end
            LUI: begin
                wbe_o <= `LEV_H;
                alusrca_o <= `ALU_SRC_R0;
                alusrcb_o <= `ALU_SRC_IMM;
                immes_o <= `ES_EHIZ;
                alures_o <= `ALU_RES_ADD;
            end
            SLL: begin
                wbe_o <= `LEV_H;
                alusrca_o <= `ALU_SRC_R0;
                alusrcb_o <= `ALU_SRC_IMM;
                immes_o <= `ES_SHFT;
                alures_o <= `ALU_RES_PAS;
            end
            ADD: begin // ADD
                wbe_o <= `LEV_H;
                alusrca_o <= `ALU_SRC_R0;
                alusrcb_o <= `ALU_SRC_R1;
                alures_o <= `ALU_RES_ADD;
            end
            default: begin // NOP
                wbe_o <= `LEV_L;
            end
            endcase // build the ALU
            // branch
            bsrc_o <= `BRANCH_SRC_NOOP;
            // internals
            conflict_r <= `REG_ADDR_WIDTH'd0;
        end
        endcase
    end else if ((opcode_w > BRO_BEGIN) && (opcode_w < BRO_END)) begin
        ls_period_r <= ~ls_period_r;
        case (ls_busy_r)
        `LEV_H:
        case (ls_period_r)
        `LEV_H: begin // memory access finished
            case (ls_op_r)
            `MEM_LOAD: begin
                // regfiles
                alusrca_o <= `ALU_SRC_MEM;
                alures_o  <= `ALU_RES_PAS;
                wbe_o   <= `LEV_H;
                waddr_o <= conflict_r;
                // branch
                bsrc_o <= `BRANCH_SRC_EPC;
            end
            `MEM_POP: begin
                // regfiles
                alusrca_o <= `ALU_SRC_MEM;
                alures_o  <= `ALU_RES_PAS;
                wbe_o   <= `LEV_H;
                waddr_o <= conflict_r;
                // branch
                bsrc_o <= `BRANCH_SRC_EPC;
            end
            default: begin // Store or Push finished
                wbe_o <= `LEV_L;
                case (opcode_w)
                RET: begin
                    // regfiles
                    raddr0_o <= `REG_RA;
                    raddr1_o <= `REG_ZERO;
                    alusrca_o <= `ALU_SRC_R0;
                    alusrcb_o <= `ALU_SRC_R1;
                    alures_o  <= `ALU_RES_ADD;
                    // branch
                    bsrc_o <= `BRANCH_SRC_JUMP;
                end
                JR: begin
                    // regfiles
                    raddr0_o <= ra_w;
                    raddr1_o <= `REG_ZERO;
                    alusrca_o <= `ALU_SRC_R0;
                    alusrcb_o <= `ALU_SRC_R1;
                    alures_o  <= `ALU_RES_ADD;
                    // branch
                    bsrc_o <= `BRANCH_SRC_JUMP;
                end
                BEQ: begin
                    // regfiles
                    raddr0_o <= ra_w;
                    raddr1_o <= rb_w;
                    imm_o    <= imm_w;
                    immes_o  <= `ES_ELOS;
                    alusrca_o <= `ALU_SRC_R0;
                    alusrcb_o <= `ALU_SRC_R1;
                    alures_o  <= `ALU_RES_SUB;
                    // branch
                    bsrc_o <= `BRANCH_SRC_BEQ;
                end
                BNE: begin
                    // regfiles
                    raddr0_o <= ra_w;
                    raddr1_o <= rb_w;
                    imm_o    <= imm_w;
                    immes_o  <= `ES_ELOS;
                    alusrca_o <= `ALU_SRC_R0;
                    alusrcb_o <= `ALU_SRC_R1;
                    alures_o  <= `ALU_RES_SUB;
                    // branch
                    bsrc_o <= `BRANCH_SRC_BNE;
                end
                BLE: begin
                    // regfiles
                    raddr0_o <= ra_w;
                    raddr1_o <= rb_w;
                    imm_o    <= imm_w;
                    immes_o  <= `ES_ELOS;
                    alusrca_o <= `ALU_SRC_R0;
                    alusrcb_o <= `ALU_SRC_R1;
                    alures_o  <= `ALU_RES_SUB;
                    // branch
                    bsrc_o <= `BRANCH_SRC_BLE;
                end
                CALL: begin
                    // regfiles
                    imm_o   <= imm_w;
                    immes_o <= `ES_ELOU;
                    alusrca_o <= `ALU_SRC_IMM;
                    alures_o  <= `ALU_RES_PAS;
                    // branch
                    bsrc_o <= `BRANCH_SRC_JUMP;
                end
                default: begin // RETI
                    // regfiles
                    raddr0_o <= `REG_RA;
                    raddr1_o <= `REG_ZERO;
                    alusrca_o <= `ALU_SRC_R0;
                    alusrcb_o <= `ALU_SRC_R1;
                    alures_o  <= `ALU_RES_ADD;
                    // branch
                    bsrc_o <= `BRANCH_SRC_RPC;
                    // interrupt
                    irep_o <= `LEV_L;
                end
                endcase
            end
            endcase
            // internals
            ls_busy_r <= `LEV_L;
        end
        default: begin // memory access running
            cache_o <= `LEV_L;
            case (ls_op_r)
            `MEM_POP: begin
                // regfiles
                raddr0_o <= `REG_SP;
                imm_o    <= `INSTR_IMM_WIDTH'd4;
                immes_o  <= `ES_ELOS;
                alusrca_o <= `ALU_SRC_R0;
                alusrcb_o <= `ALU_SRC_R1;
                alures_o  <= `ALU_RES_ADD;
                wbe_o   <= `LEV_H;
                waddr_o <= `REG_SP;
                // branch
                bsrc_o <= `BRANCH_SRC_EPC;
            end
            `MEM_PUSH: begin
                // regfiles
                raddr0_o <= `REG_SP;
                imm_o    <= `INSTR_IMM_WIDTH'd4;
                immes_o  <= `ES_ELOS;
                alusrca_o <= `ALU_SRC_R0;
                alusrcb_o <= `ALU_SRC_R1;
                alures_o  <= `ALU_RES_SUB;
                wbe_o   <= `LEV_H;
                waddr_o <= `REG_SP;
                // branch
                bsrc_o <= `BRANCH_SRC_EPC;
            end
            default: begin // execute branch operation
                wbe_o <= `LEV_L;
                case (opcode_w)
                RET: begin
                    // regfiles
                    raddr0_o <= `REG_RA;
                    raddr1_o <= `REG_ZERO;
                    alusrca_o <= `ALU_SRC_R0;
                    alusrcb_o <= `ALU_SRC_R1;
                    alures_o  <= `ALU_RES_ADD;
                    // branch
                    bsrc_o <= `BRANCH_SRC_JUMP;
                end
                JR: begin
                    // regfiles
                    raddr0_o <= ra_w;
                    raddr1_o <= `REG_ZERO;
                    alusrca_o <= `ALU_SRC_R0;
                    alusrcb_o <= `ALU_SRC_R1;
                    alures_o  <= `ALU_RES_ADD;
                    // branch
                    bsrc_o <= `BRANCH_SRC_JUMP;
                end
                BEQ: begin
                    // regfiles
                    raddr0_o <= ra_w;
                    raddr1_o <= rb_w;
                    imm_o    <= imm_w;
                    immes_o  <= `ES_ELOS;
                    alusrca_o <= `ALU_SRC_R0;
                    alusrcb_o <= `ALU_SRC_R1;
                    alures_o  <= `ALU_RES_SUB;
                    // branch
                    bsrc_o <= `BRANCH_SRC_BEQ;
                end
                BNE: begin
                    // regfiles
                    raddr0_o <= ra_w;
                    raddr1_o <= rb_w;
                    imm_o    <= imm_w;
                    immes_o  <= `ES_ELOS;
                    alusrca_o <= `ALU_SRC_R0;
                    alusrcb_o <= `ALU_SRC_R1;
                    alures_o  <= `ALU_RES_SUB;
                    // branch
                    bsrc_o <= `BRANCH_SRC_BNE;
                end
                BLE: begin
                    // regfiles
                    raddr0_o <= ra_w;
                    raddr1_o <= rb_w;
                    imm_o    <= imm_w;
                    immes_o  <= `ES_ELOS;
                    alusrca_o <= `ALU_SRC_R0;
                    alusrcb_o <= `ALU_SRC_R1;
                    alures_o  <= `ALU_RES_SUB;
                    // branch
                    bsrc_o <= `BRANCH_SRC_BLE;
                end
                CALL: begin
                    // regfiles
                    imm_o   <= imm_w;
                    immes_o <= `ES_ELOU;
                    alusrca_o <= `ALU_SRC_IMM;
                    alures_o  <= `ALU_RES_PAS;
                    // branch
                    bsrc_o <= `BRANCH_SRC_JUMP;
                end
                default: begin // RETI
                    // regfiles
                    raddr0_o <= `REG_RA;
                    raddr1_o <= `REG_ZERO;
                    alusrca_o <= `ALU_SRC_R0;
                    alusrcb_o <= `ALU_SRC_R1;
                    alures_o  <= `ALU_RES_ADD;
                    // branch
                    bsrc_o <= `BRANCH_SRC_RPC;
                    // interrupt
                    irep_o <= `LEV_L;
                end
                endcase
            end
            endcase
        end
        endcase
        default: begin // no memory access operations
            wbe_o <= `LEV_L;
            case (opcode_w)
            RET: begin
                // regfiles
                raddr0_o <= `REG_RA;
                raddr1_o <= `REG_ZERO;
                alusrca_o <= `ALU_SRC_R0;
                alusrcb_o <= `ALU_SRC_R1;
                alures_o  <= `ALU_RES_ADD;
                // branch
                bsrc_o <= `BRANCH_SRC_JUMP;
            end
            JR: begin
                // regfiles
                raddr0_o <= ra_w;
                raddr1_o <= `REG_ZERO;
                alusrca_o <= `ALU_SRC_R0;
                alusrcb_o <= `ALU_SRC_R1;
                alures_o  <= `ALU_RES_ADD;
                // branch
                bsrc_o <= `BRANCH_SRC_JUMP;
            end
            BEQ: begin
                // regfiles
                raddr0_o <= ra_w;
                raddr1_o <= rb_w;
                imm_o    <= imm_w;
                immes_o  <= `ES_ELOS;
                alusrca_o <= `ALU_SRC_R0;
                alusrcb_o <= `ALU_SRC_R1;
                alures_o  <= `ALU_RES_SUB;
                // branch
                bsrc_o <= `BRANCH_SRC_BEQ;
            end
            BNE: begin
                // regfiles
                raddr0_o <= ra_w;
                raddr1_o <= rb_w;
                imm_o    <= imm_w;
                immes_o  <= `ES_ELOS;
                alusrca_o <= `ALU_SRC_R0;
                alusrcb_o <= `ALU_SRC_R1;
                alures_o  <= `ALU_RES_SUB;
                // branch
                bsrc_o <= `BRANCH_SRC_BNE;
            end
            BLE: begin
                // regfiles
                raddr0_o <= ra_w;
                raddr1_o <= rb_w;
                imm_o    <= imm_w;
                immes_o  <= `ES_ELOS;
                alusrca_o <= `ALU_SRC_R0;
                alusrcb_o <= `ALU_SRC_R1;
                alures_o  <= `ALU_RES_SUB;
                // branch
                bsrc_o <= `BRANCH_SRC_BLE;
            end
            CALL: begin
                // regfiles
                imm_o   <= imm_w;
                immes_o <= `ES_ELOU;
                alusrca_o <= `ALU_SRC_IMM;
                alures_o  <= `ALU_RES_PAS;
                // branch
                bsrc_o <= `BRANCH_SRC_JUMP;
            end
            default: begin // RETI
                // regfiles
                raddr0_o <= `REG_RA;
                raddr1_o <= `REG_ZERO;
                alusrca_o <= `ALU_SRC_R0;
                alusrcb_o <= `ALU_SRC_R1;
                alures_o  <= `ALU_RES_ADD;
                // branch
                bsrc_o <= `BRANCH_SRC_RPC;
                // interrupt
                irep_o <= `LEV_L;
            end
            endcase
        end
        endcase
    end else if ((opcode_w > LSO_BEGIN) && (opcode_w < LSO_END)) begin
        // lw,sw
        // load operations need to write back
        // wbe_o <= (opcode_w < LSO_STORE) ? `LEV_H : `LEV_L;
        // but not the next period
        // except that the last load operation is done
        // set the data flow from regfiles
        immes_o   <= `ES_ELOS;
        alusrcb_o <= `ALU_SRC_IMM;
        case (ls_busy_r)
        `LEV_H:
        case (ls_period_r)
        `LEV_H: begin // memory access is finished
            case (ls_op_r)
            `MEM_LOAD: begin
                // regfiles
                alusrca_o <= `ALU_SRC_MEM;
                alures_o  <= `ALU_RES_PAS;
                wbe_o   <= `LEV_H;
                waddr_o <= conflict_r;
                // branch
                bsrc_o <= `BRANCH_SRC_EPC;
                // internals
                ls_busy_r <= `LEV_L;
            end
            `MEM_POP: begin
                // regfiles
                alusrca_o <= `ALU_SRC_MEM;
                alures_o  <= `ALU_RES_PAS;
                wbe_o   <= `LEV_H;
                waddr_o <= conflict_r;
                // branch
                bsrc_o <= `BRANCH_SRC_EPC;
                // internals
                ls_busy_r <= `LEV_L;
            end
            default: begin // execute memory access operations
                // regfiles
                imm_o     <= imm_w;
                alusrca_o <= `ALU_SRC_R1;
                alures_o  <= `ALU_RES_ADD;
                wbe_o <= `LEV_L;
                cache_o <= `LEV_H;
                case (opcode_w)
                LH: begin
                    raddr1_o  <= rb_w;
                    // memory
                    memce_o <= `LEV_L;
                    memod_o <= `MEM_OPND_HALF;
                    addrfix_o <= `LEV_L;
                    // internals
                    ls_op_r <= `MEM_LOAD;
                    conflict_r <= ra_w;
                end
                LHU: begin
                    raddr1_o  <= rb_w;
                    // memory
                    memce_o <= `LEV_L;
                    memod_o <= `MEM_OPND_HALFU;
                    addrfix_o <= `LEV_L;
                    // internals
                    ls_op_r <= `MEM_LOAD;
                    conflict_r <= ra_w;
                end
                LB: begin
                    raddr1_o  <= rb_w;
                    // memory
                    memce_o <= `LEV_L;
                    memod_o <= `MEM_OPND_BYTE;
                    addrfix_o <= `LEV_L;
                    // internals
                    ls_op_r <= `MEM_LOAD;
                    conflict_r <= ra_w;
                end
                LBU: begin
                    raddr1_o  <= rb_w;
                    // memory
                    memce_o <= `LEV_L;
                    memod_o <= `MEM_OPND_BYTEU;
                    addrfix_o <= `LEV_L;
                    // internals
                    ls_op_r <= `MEM_LOAD;
                    conflict_r <= ra_w;
                end
                POP: begin
                    raddr1_o  <= `REG_SP;
                    // memory
                    memce_o <= `LEV_L;
                    memod_o <= `MEM_OPND_WORD;
                    addrfix_o <= `LEV_H;
                    // internals
                    ls_op_r <= `MEM_POP;
                    conflict_r <= ra_w;
                end
                SW: begin
                    raddr0_o  <= ra_w;
                    raddr1_o  <= rb_w;
                    // memory
                    memce_o <= `LEV_H;
                    memod_o <= `MEM_OPND_WORD;
                    addrfix_o <= `LEV_L;
                    // internals
                    ls_op_r <= `MEM_STORE;
                    conflict_r <= `REG_ADDR_WIDTH'd0;
                end
                SH: begin
                    raddr0_o  <= ra_w;
                    raddr1_o  <= rb_w;
                    // memory
                    memce_o <= `LEV_H;
                    memod_o <= `MEM_OPND_HALF;
                    addrfix_o <= `LEV_L;
                    // internals
                    ls_op_r <= `MEM_STORE;
                    conflict_r <= `REG_ADDR_WIDTH'd0;
                end
                SB: begin
                    raddr0_o  <= ra_w;
                    raddr1_o  <= rb_w;
                    // memory
                    memce_o <= `LEV_H;
                    memod_o <= `MEM_OPND_BYTE;
                    addrfix_o <= `LEV_L;
                    // internals
                    ls_op_r <= `MEM_STORE;
                    conflict_r <= `REG_ADDR_WIDTH'd0;
                end
                PUSH: begin
                    raddr0_o  <= ra_w;
                    raddr1_o  <= `REG_SP;
                    // memory
                    memce_o <= `LEV_H;
                    memod_o <= `MEM_OPND_WORD;
                    addrfix_o <= `LEV_L;
                    // internals
                    ls_op_r <= `MEM_PUSH;
                    conflict_r <= `REG_ADDR_WIDTH'd0;
                end
                SET: begin
                    raddr0_o  <= ra_w;
                    raddr1_o  <= rb_w;
                    // memory
                    memce_o <= `LEV_H;
                    memod_o <= `MEM_OPND_SETIO;
                    addrfix_o <= `LEV_L;
                    // internals
                    ls_op_r <= `MEM_STORE;
                    conflict_r <= `REG_ADDR_WIDTH'd0;
                end
                default: begin // lw $ra, imm16($rb)
                    raddr1_o  <= rb_w;
                    // memory
                    memce_o <= `LEV_L;
                    memod_o <= `MEM_OPND_WORD;
                    addrfix_o <= `LEV_L;
                    // internals
                    ls_op_r <= `MEM_LOAD;
                    conflict_r <= ra_w;
                end
                endcase
                // branch
                bsrc_o <= `BRANCH_SRC_NOOP;
                // internals
                ls_busy_r <= `LEV_H;
                ls_period_r <= `LEV_L;
            end
            endcase
        end
        default: begin // memory access operation is running
            cache_o <= `LEV_L;
            case (ls_op_r)
            `MEM_POP: begin
                // regfiles
                raddr0_o  <= `REG_SP;
                imm_o     <= `INSTR_IMM_WIDTH'd4;
                alusrca_o <= `ALU_SRC_R0;
                alures_o  <= `ALU_RES_ADD;
                wbe_o   <= `LEV_H;
                waddr_o <= `REG_SP;
            end
            `MEM_PUSH: begin
                // regfiles
                raddr0_o  <= `REG_SP;
                imm_o     <= `INSTR_IMM_WIDTH'd4;
                alusrca_o <= `ALU_SRC_R0;
                alures_o  <= `ALU_RES_SUB;
                wbe_o   <= `LEV_H;
                waddr_o <= `REG_SP;
            end
            default:  begin
                // regfiles
                wbe_o <= `LEV_L;
            end
            endcase
            // branch
            bsrc_o <= `BRANCH_SRC_EPC;
            // internals
            ls_period_r <= `LEV_H;
        end
        endcase
        default: begin // execute memory access operations
            // regfiles
            imm_o     <= imm_w;
            alusrca_o <= `ALU_SRC_R1;
            alures_o  <= `ALU_RES_ADD;
            wbe_o <= `LEV_L;
            cache_o <= `LEV_H;
            case (opcode_w)
            LH: begin
                raddr1_o  <= rb_w;
                // memory
                memce_o <= `LEV_L;
                memod_o <= `MEM_OPND_HALF;
                addrfix_o <= `LEV_L;
                // internals
                ls_op_r <= `MEM_LOAD;
                conflict_r <= ra_w;
            end
            LHU: begin
                raddr1_o  <= rb_w;
                // memory
                memce_o <= `LEV_L;
                memod_o <= `MEM_OPND_HALFU;
                addrfix_o <= `LEV_L;
                // internals
                ls_op_r <= `MEM_LOAD;
                conflict_r <= ra_w;
            end
            LB: begin
                raddr1_o  <= rb_w;
                // memory
                memce_o <= `LEV_L;
                memod_o <= `MEM_OPND_BYTE;
                addrfix_o <= `LEV_L;
                // internals
                ls_op_r <= `MEM_LOAD;
                conflict_r <= ra_w;
            end
            LBU: begin
                raddr1_o  <= rb_w;
                // memory
                memce_o <= `LEV_L;
                memod_o <= `MEM_OPND_BYTEU;
                addrfix_o <= `LEV_L;
                // internals
                ls_op_r <= `MEM_LOAD;
                conflict_r <= ra_w;
            end
            POP: begin
                raddr1_o  <= `REG_SP;
                // memory
                memce_o <= `LEV_L;
                memod_o <= `MEM_OPND_WORD;
                addrfix_o <= `LEV_H;
                // internals
                ls_op_r <= `MEM_POP;
                conflict_r <= ra_w;
            end
            SW: begin
                raddr0_o <= ra_w;
                raddr1_o  <= rb_w;
                // memory
                memce_o <= `LEV_H;
                memod_o <= `MEM_OPND_WORD;
                addrfix_o <= `LEV_L;
                // internals
                ls_op_r <= `MEM_STORE;
                conflict_r <= `REG_ADDR_WIDTH'd0;
            end
            SH: begin
                raddr0_o <= ra_w;
                raddr1_o  <= rb_w;
                // memory
                memce_o <= `LEV_H;
                memod_o <= `MEM_OPND_HALF;
                addrfix_o <= `LEV_L;
                // internals
                ls_op_r <= `MEM_STORE;
                conflict_r <= `REG_ADDR_WIDTH'd0;
            end
            SB: begin
                raddr0_o <= ra_w;
                raddr1_o  <= rb_w;
                // memory
                memce_o <= `LEV_H;
                memod_o <= `MEM_OPND_BYTE;
                addrfix_o <= `LEV_L;
                // internals
                ls_op_r <= `MEM_STORE;
                conflict_r <= `REG_ADDR_WIDTH'd0;
            end
            PUSH: begin
                raddr0_o <= ra_w;
                raddr1_o  <= `REG_SP;
                // memory
                memce_o <= `LEV_H;
                memod_o <= `MEM_OPND_WORD;
                addrfix_o <= `LEV_L;
                // internals
                ls_op_r <= `MEM_PUSH;
                conflict_r <= `REG_ADDR_WIDTH'd0;
            end
            SET: begin
                raddr0_o <= ra_w;
                raddr1_o  <= rb_w;
                // memory
                memce_o <= `LEV_H;
                memod_o <= `MEM_OPND_SETIO;
                addrfix_o <= `LEV_L;
                // internals
                ls_op_r <= `MEM_STORE;
                conflict_r <= `REG_ADDR_WIDTH'd0;
            end
            default: begin // lw $ra, imm16($rb)
                raddr1_o  <= rb_w;
                // memory
                memce_o <= `LEV_L;
                memod_o <= `MEM_OPND_WORD;
                addrfix_o <= `LEV_L;
                // internals
                ls_op_r <= `MEM_LOAD;
                conflict_r <= ra_w;
            end
            endcase
            // branch
            bsrc_o <= `BRANCH_SRC_NOOP;
            // internals
            ls_busy_r <= `LEV_H;
            ls_period_r <= `LEV_L;
        end
        endcase
    end else begin
        // output signals
        waddr_o <= `REG_RA;
        raddr0_o <= `REG_ZERO;
        raddr1_o <= `REG_ZERO;
        imm_o <= `INSTR_IMM_WIDTH'd0;
        immes_o <= `ES_ELOS;
        wbe_o <= `LEV_L;
        memce_o <= `LEV_L;
        memod_o <= `MEM_OPND_WORD;
        alusrca_o <= `ALU_SRC_R0;
        alusrcb_o <= `ALU_SRC_R1;
        alures_o <= `ALU_RES_ADD;
        irep_o <= `LEV_L;
        bsrc_o <= `BRANCH_SRC_EPC;
        cache_o <= `LEV_L;
        // internal signals
        conflict_r <= `REG_ZERO;
        ls_busy_r <= `LEV_L;
        ls_period_r <= `LEV_L;
        ls_op_r <= `MEM_LOAD;
    end
end
endmodule