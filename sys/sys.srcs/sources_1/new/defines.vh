`ifndef _DEFINES_H_
`define _DEFINES_H_
`endif

`define _RISC_32_

`ifdef _RISC_32_
`define BUS_WIDTH 32
`elsif _RISC_64_
`define BUS_WIDTH 64
`endif

`define LEV_L 1'b0
`define LEV_H 1'b1

/*****************************
     Instruction Infos 
*****************************/
`define INS_WIDTH 32
`define INS_OP_LEN 6
`define INS_REG_LEN 5
`define INS_SA_LEN 5
`define INS_FUNC_LEN 6
`define INS_IMM_LEN 16
`define INS_ADDR_LEN 26

`define OP_ADDU
`define OP_CLO
`define OP_CLZ
`define OP_LA
`define OP_LUI
`define OP_MOVE
`define OP_SUBU
`define OP_SLL
`define OP_SLLV
`define OP_SRL
`define OP_SRLV
`define OP_AND
`define OP_ANDI
`define OP_NOP
`define OP_NOR
`define OP_NOT
`define OP_OR
`define OP_ORI
`define OP_XOR
`define OP_XORI
`define OP_SLTIU
`define OP_SLTIU
`define OP_DIVU
`define OP_MULTU
`define OP_MFHI
`define OP_MFLO
`define OP_MTHI
`define OP_MTLO
`define OP_B
`define OP_BAL
`define OP_BEQ
`define OP_BEQZ
`define OP_BNE
`define OP_BNEZ
`define OP_J
`define OP_JAL
`define OP_JALR
`define OP_JR
`define OP_LBU
`define OP_LHU
`define OP_LW
`define OP_SB
`define OP_SH
`define OP_SW
`define OP_PUSH
`define OP_POP
`define OP_RETI
`define OP_CALLI

`define WORD_LEN 32

// Register Files Infos
`define REG_SIZE 32
`define REG_WIDTH 5 // Power(2, 5) = 32
