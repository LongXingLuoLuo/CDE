// coprocessor instructions
`define CP0_MFC0                 5'b00000
`define CP0_MTC0                 5'b00100
`define CP0_ERET                 5'b10000
`define CP0_ERET_FULL            32'h42000018

// coprocessor 0 register address definitions
`define CP0_REG_BADVADDR         8'b01000000
`define CP0_REG_COUNT            8'b01001000
`define CP0_REG_COMPARE          8'b01011000
`define CP0_REG_STATUS           8'b01100000
`define CP0_REG_CAUSE            8'b01101000
`define CP0_REG_EPC              8'b01110000
`define CP0_REG_PRID             8'b01111000
`define CP0_REG_EBASE            8'b01111001
`define CP0_REG_CONFIG0          8'b10000000
`define CP0_REG_CONFIG1          8'b10000001

// coprocessor 0 register value & write mask
`define CP0_REG_BADVADDR_VALUE   32'h00000000
`define CP0_REG_BADVADDR_MASK    32'h00000000
`define CP0_REG_STATUS_VALUE     32'h0040ff00
`define CP0_REG_STATUS_MASK      32'h0040ff03
`define CP0_REG_CAUSE_VALUE      32'h00000000
`define CP0_REG_CAUSE_MASK       32'h00000300
`define CP0_REG_EPC_VALUE        32'h00000000
`define CP0_REG_EPC_MASK         32'hffffffff
// NOTE: 0x55 -> U -> USTB, 0x0000 -> Uranus Zero
`define CP0_REG_PRID_VALUE       32'h00550000
`define CP0_REG_PRID_MASK        32'h00000000
`define CP0_REG_EBASE_VALUE      32'h80000000
`define CP0_REG_EBASE_MASK       32'h3ffff000
`define CP0_REG_CONFIG0_VALUE    32'h36000183
`define CP0_REG_CONFIG0_MASK     32'h00000000

// coprocessor 0 segment definitions of STATUS & CAUSE
`define CP0_SEG_BEV              22      // STATUS
`define CP0_SEG_IM               15:8    // STATUS
`define CP0_SEG_EXL              1       // STATUS
`define CP0_SEG_IE               0       // STATUS
`define CP0_SEG_BD               31      // CAUSE
`define CP0_SEG_HWI              15:10   // CAUSE
`define CP0_SEG_SWI              9:8     // CAUSE
`define CP0_SEG_INT              15:8    // CAUSE
`define CP0_SEG_EXCCODE          6:2     // CAUSE

// ExcCode definitions
`define CP0_EXCCODE_INT          8'h00
`define CP0_EXCCODE_ADEL         8'h04
`define CP0_EXCCODE_ADES         8'h05
`define CP0_EXCCODE_SYS          8'h08
`define CP0_EXCCODE_BP           8'h09
`define CP0_EXCCODE_RI           8'h0a
`define CP0_EXCCODE_OV           8'h0c


// // exception entrance
// `define INIT_PC             32'hbfc00000
// `define EXC_BASE            32'hbfc00200
// `define EXC_OFFSET          32'h00000180

// // exception type segment position
// `define EXC_TYPE_POS_INT    7:0
// `define EXC_TYPE_POS_IF     0
// `define EXC_TYPE_POS_RI     1   // no inst
// `define EXC_TYPE_POS_OV     2   // overflow
// `define EXC_TYPE_POS_TP     3
// `define EXC_TYPE_POS_BP     4   // break inst
// `define EXC_TYPE_POS_SYS    5   // system inst
// `define EXC_TYPE_POS_ADE    6   // NOTE: can be removed
// `define EXC_TYPE_POS_ERET   7   // eret inst

// // exception type definitions
// `define EXC_TYPE_NULL       8'h0
// `define EXC_TYPE_INT        8'h1
// `define EXC_TYPE_IF         8'h2
// `define EXC_TYPE_RI         8'h3
// `define EXC_TYPE_OV         8'h4
// `define EXC_TYPE_TP         8'h5
// `define EXC_TYPE_BP         8'h6
// `define EXC_TYPE_SYS        8'h7
// `define EXC_TYPE_ADEL       8'h8
// `define EXC_TYPE_ADES       8'h9
// `define EXC_TYPE_ERET       8'ha