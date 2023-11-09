`timescale 1ns/1ps
`include "bus.v"
module Mlut_ip_tb;
    parameter period = 10;

    reg clk, rst;
    reg [`DATA_BUS] operand_1, operand_2;
    wire [`DOUBLE_DATA_BUS] result;

    initial begin
        rst = 1;
        clk = 0;
        #7 rst = 0;
    end

    always #(period/2) clk = ~clk;

    initial begin
        #(period * 10)
        operand_1 <= $random;
        operand_2 <= $random;
        #(period * 10)
        operand_1 <= $random;
        operand_2 <= $random;
        #(period * 10)
        operand_1 <= $random;
        operand_2 <= $random;
        #(period * 10)
        operand_1 <= $random;
        operand_2 <= $random;
        #(period * 10)
        operand_1 <= $random;
        operand_2 <= $random;
        #(period * 10)
        operand_1 <= $random;
        operand_2 <= $random;
    end

    mult_gen_0 u_mult_gen(
        .clk(clk),
        .A(operand_1),
        .B(operand_2),
        .P(result)
    );

endmodule //Mlut_ip_tb