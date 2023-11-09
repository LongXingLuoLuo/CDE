//~ `New testbench
`timescale  1ns / 1ps
`include "bus.v"
`include "funct.v"

module MultDiv_tb;

    // CLK Parameters
    parameter PERIOD     = 10;

    // MultDiv Inputs
    reg                         clk         = 0 ;
    reg                         rst         = 1 ;
    reg                         stall_all   = 0 ;
    reg     [`FUNCT_BUS]        funct       = 6'b000000;  
    reg     [`DATA_BUS]         operand_1   = 32'h00000000;
    reg     [`DATA_BUS]         operand_2   = 32'h00000000;
    reg     [`DATA_BUS]         hi          = 32'h00000000;
    reg     [`DATA_BUS]         lo          = 32'h00000000;
    wire                        done;
    wire    [`DOUBLE_DATA_BUS]  result;

    // MultDiv Instance
    MultDiv u_multdiv(
        .clk(clk),
        .rst(rst),
        .stall_all(stall_all),
        .funct(funct),
        .operand_1(operand_1),
        .operand_2(operand_2),
        .hi(hi),
        .lo(lo),
        .done(done),
        .result(result)
    );

    // Clock Generation
    always #(PERIOD/2) clk = ~clk;

    // initial rst
    initial begin
        rst = 1;
        #7 rst = 0;
    end

    // operand_1 <= $random;
    initial begin
        // #100
        // operand_1 <= 32'd12;
        // operand_2 <= 32'd12;
        // funct = `FUNCT_MULTU;
        // #100
        // operand_1 <= 32'h80000012;
        // operand_2 <= 32'h80000012;
        // funct = `FUNCT_MULT;
        #(PERIOD * 100)
        operand_1 <= 32'd142;
        operand_2 <= 32'd12;
        funct = `FUNCT_DIVU;
        #(PERIOD * 100)
        operand_1 <= 32'h80000012;
        operand_2 <= 32'h00000012;
        funct = `FUNCT_DIV;
    end

endmodule