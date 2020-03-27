`ifndef _DEFINES_H_
`define _DEFINES_H_

`define _RISC_32_
`ifdef _RISC_32_
`define DATA_WIDTH 32
`define HILO_WIDTH 64
`elsif _RISC_64_
`define DATA_WIDTH 64
`endif
`define ADDR_WIDTH 10

`define LEV_L 1'b0
`define LEV_H 1'b1

/*****************************
     Instruction Infos 
*****************************/
`define INS_WIDTH 32
`define INSTR_OPC_WIDTH 6
`define INSTR_IMM_WIDTH 16
`define INSTR_BADDR_WIDTH 26

`define ALU_SRC_WIDTH 2
`define ALU_SRC_R0 2'b00
`define ALU_SRC_R1 2'b01
`define ALU_SRC_IMM 2'b10
`define ALU_SRC_PC 2'b11

`define ALU_RES_WIDTH 3
`define ALU_RES_ADD 3'b000
`define ALU_RES_OR 3'b001

`define MEM_LOAD 1'b0
`define MEM_STORE 1'b1
`define EXT_SIGNED 1'b0
`define EXT_UNSIGNED 1'b1

// Register Files Infos
`define REG_NUM 32
`define REG_ADDR_WIDTH 5 // Power(2, 5) = 32
`define REG_ZERO `REG_ADDR_WIDTH'd0

`define MEM_OPND_WIDTH 3

`endif
