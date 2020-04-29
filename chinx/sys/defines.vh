`ifndef _DEFINES_H_
`define _DEFINES_H_

`define _RISC_32_
`ifdef _RISC_32_
`define DATA_WIDTH 32
`define HILO_WIDTH 16 // 16-bits hi or lo register
`elsif _RISC_64_
`define DATA_WIDTH 64
`endif
`define ADDR_WIDTH 8
`define LEV_L 1'b0
`define LEV_H 1'b1
// ------------------------------ //
//      Instruction Infos 
// ------------------------------ //
// ================================================ //
// | OPCODE(6) | Operands(26)                     | //
// |-----------+----------------------------------| //
// | OP(6) | RA(5) | RB(5) | RC(5) | Reserved(11) | //
// |-------+-------+-------+-------+--------------| //
// | OP(6) | RA(5) | RB(5) | Imm(16)              | //
// |-------+-------+-------+----------------------| //
// | OP(6) | Address(26)                          | //
// ================================================ //
`define INSTR_WIDTH 32 // 32-bits instruction
`define INSTR_OPC_WIDTH 6 // 6-bits operation code
`define INSTR_IMM_WIDTH 16 // 16-bits immediate number
`define INSTR_BADDR_WIDTH 26 // 26-bits address code in instruction format (not used)
// source of ALU input data ports
// from 0-port of regfiles, 1-port of regfiles, immediate number, pc value
`define ALU_SRC_WIDTH 2
`define ALU_SRC_R0 2'b00
`define ALU_SRC_R1 2'b01
`define ALU_SRC_IMM 2'b10
`define ALU_SRC_MEM 2'b11
// source of ALU output data port
// from 'add', 'sub', load data, extended 32-bits immediate number,
// 'and', 'or', 'xor', 'not' unit
`define ALU_RES_WIDTH 3
`define ALU_RES_ADD 3'b000
`define ALU_RES_SUB 3'b001
`define ALU_RES_MUL 3'b010
`define ALU_RES_PAS 3'b011
`define ALU_RES_AND 3'b100
`define ALU_RES_OR  3'b101
`define ALU_RES_XOR 3'b110
`define ALU_RES_NOT 3'b111
// source of the next pc value
`define BRANCH_SRC_WIDTH 3
`define BRANCH_SRC_NOOP 3'b000 // pc + 1
`define BRANCH_SRC_JUMP 3'b001 // from instruction
`define BRANCH_SRC_EPC 3'b010 // from the stalled pc 
`define BRANCH_SRC_IPC 3'b011 // from the interruption vector
`define BRANCH_SRC_RPC 3'b100 // from 'reti'
`define BRANCH_SRC_BEQ 3'b101
`define BRANCH_SRC_BNE 3'b110
`define BRANCH_SRC_BLE 3'b111
// caches for the address and data sent to memory module
`define STD_SRC_DATA0 1'b0
`define STD_SRC_CACHE 1'b1
`define STA_SRC_ALU 1'b0
`define STA_SRC_CACHE 1'b1
// extended immediate number
`define ES_WIDTH 2
`define ES_ELOS 2'b00
`define ES_ELOU 2'b01
`define ES_EHIZ 2'b10
`define ES_SHFT 2'b11
// ------------------------------ //
//      Register Files Infos
// ------------------------------ //
`define REG_NUM 32
`define REG_ADDR_WIDTH 5 // Power(2, 5) = 32
`define REG_ZERO `REG_ADDR_WIDTH'd0
`define REG_SP `REG_ADDR_WIDTH'd29
`define REG_RA `REG_ADDR_WIDTH'd31
// ------------------------------ //
//      Memory Infos
// ------------------------------ //
`define MEM_WIDTH 2
`define MEM_LOAD  2'b00
`define MEM_POP   2'b01
`define MEM_STORE 2'b10
`define MEM_PUSH  2'b11
`define MEM_OPND_WIDTH 3
`define MEM_OPND_WORD `MEM_OPND_WIDTH'd0
`define MEM_OPND_HALF `MEM_OPND_WIDTH'd1
`define MEM_OPND_HALFU `MEM_OPND_WIDTH'd2
`define MEM_OPND_BYTE `MEM_OPND_WIDTH'd3
`define MEM_OPND_BYTEU `MEM_OPND_WIDTH'd4
`define MEM_OPND_SETIO `MEM_OPND_WIDTH'd5
// ------------------------------ //
//      Interruption Infos
// ------------------------------ //
`define INTR_VEC_WIDTH 2
`define IO_PORT_WIDTH 8

`endif
