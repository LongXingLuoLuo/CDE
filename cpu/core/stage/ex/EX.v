`timescale 1ns / 1ps

`include "bus.v"
`include "funct.v"

module EX (
    // from ID stage
    input      [   `FUNCT_BUS] funct,
    input      [   `SHAMT_BUS] shamt,
    input      [    `DATA_BUS] operand_1,
    input      [    `DATA_BUS] operand_2,
    input                      mem_read_flag_in,
    input                      mem_write_flag_in,
    input                      mem_sign_ext_flag_in,
    input      [ `MEM_SEL_BUS] mem_sel_in,
    input      [    `DATA_BUS] mem_write_data_in,
    input                      reg_write_en_in,
    input      [`REG_ADDR_BUS] reg_write_addr_in,
    input      [    `ADDR_BUS] current_pc_addr_in,

    // * hilo
    input      [    `DATA_BUS] hi_in,
    input      [    `DATA_BUS] lo_in,

    // * MULTDIV
    input                           mult_div_done,
    input       [`DOUBLE_DATA_BUS]  mult_div_result,

    // to ID stage (solve data hazards)
    output                     ex_load_flag,
    // to MEM stage
    output                     mem_read_flag_out,
    output                     mem_write_flag_out,
    output                     mem_sign_ext_flag_out,
    output     [ `MEM_SEL_BUS] mem_sel_out,
    output     [    `DATA_BUS] mem_write_data_out,
    // to WB stage
    output reg [    `DATA_BUS] result,
    output                     reg_write_en_out,
    output     [`REG_ADDR_BUS] reg_write_addr_out,
    output     [    `ADDR_BUS] current_pc_addr_out,

    // * stall signle
    output  reg                stall_request,

    // * HILO control
    output  reg                 hilo_write_en,
    output  reg [`DATA_BUS]     hi_out,
    output  reg [`DATA_BUS]     lo_out
);

    // to ID stage
    assign ex_load_flag = mem_read_flag_in;
    // to MEM stage
    assign mem_read_flag_out = mem_read_flag_in;
    assign mem_write_flag_out = mem_write_flag_in;
    assign mem_sign_ext_flag_out = mem_sign_ext_flag_in;
    assign mem_sel_out = mem_sel_in;
    assign mem_write_data_out = mem_write_data_in;
    // to WB stage
    assign reg_write_en_out = reg_write_en_in && !mem_write_flag_in;
    assign reg_write_addr_out = reg_write_addr_in;
    assign current_pc_addr_out = current_pc_addr_in;

    // calculate the complement of operand_2
    wire[`DATA_BUS] operand_2_mux =
      (funct == `FUNCT_SUBU || funct == `FUNCT_SLT)
        ? (~operand_2) + 1 : operand_2;

    // sum of operand_1 & operand_2
    wire [`DATA_BUS] result_sum = operand_1 + operand_2_mux;

    // flag of operand_1 < operand_2
    wire operand_1_lt_operand_2 = funct == `FUNCT_SLT ?
    // op1 : -, op2 : +
    ((operand_1[31] && !operand_2[31]) ||
    // op1: - , op2 : -, op1 - op2 : +
    (!operand_1[31] && !operand_2[31] && result_sum[31]) ||
    // op1 : +. op2 : +, op1 - op2 : +
    (operand_1[31] && operand_2[31] && result_sum[31])) : (operand_1 < operand_2);

    // calculate result
    always @(*) begin
        case (funct)
            // jump with link & logic
            `FUNCT_JALR, `FUNCT_OR: result <= operand_1 | operand_2;
            `FUNCT_AND: result <= operand_1 & operand_2;
            `FUNCT_XOR: result <= operand_1 ^ operand_2;
            `FUNCT_NOR: result <= ~(operand_1 | operand_2);
            // comparison
            `FUNCT_SLT, `FUNCT_SLTU: result <= {31'b0, operand_1_lt_operand_2};
            // arithmetic
            `FUNCT_ADDU, `FUNCT_SUBU: result <= result_sum;
            // shift
            `FUNCT_SLL: result <= operand_2 << shamt;
            `FUNCT_SLLV: result <= operand_2 << operand_1[4:0];
            `FUNCT_SRL: result <= operand_2 >> shamt;
            `FUNCT_SRLV: result <= operand_2 >> operand_1[4:0];
            `FUNCT_SRA:
            result <= ({32{operand_2[31]}} << (6'd32 - {1'b0, shamt})) | operand_2 >> shamt;
            `FUNCT_SRAV:
            result <= ({32{operand_2[31]}} << (6'd32 - {1'b0, operand_1[4:0]})) | operand_2 >> operand_1[4:0];
            // HILO
            `FUNCT_MFHI: result <= hi_in;
            `FUNCT_MFLO: result <= lo_in;
            default: result <= 0;
        endcase
    end

    // * stall_request
    always @(*) begin
        case (funct)
            `FUNCT_MULT, `FUNCT_MULTU, 
            `FUNCT_DIV, `FUNCT_DIVU: begin
                stall_request <= !mult_div_done;
            end
            default: stall_request <= 0;
        endcase
    end

    // * hilo_write_en hi_out lo_out
    always @(*) begin
        case (funct)
            // multplication & division
            `FUNCT_MULT, `FUNCT_MULTU, 
            `FUNCT_DIV, `FUNCT_DIVU: begin
                hilo_write_en <= 1;
                hi_out <= mult_div_result[63:32];
                lo_out <= mult_div_result[31: 0];
            end
            // HILO move inst
            `FUNCT_MTHI: begin
                hilo_write_en <= 1;
                hi_out <= operand_1;
                lo_out <= lo_in;
            end
            `FUNCT_MTLO: begin
                hilo_write_en <= 1;
                hi_out <= hi_in;
                lo_out <= operand_1;
            end
            default: begin
                hilo_write_en <= 0;
                hi_out <= hi_in;
                lo_out <= lo_in;
            end
        endcase
    end

endmodule  // EX
