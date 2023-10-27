`timescale 1ns/1ps
module MULTI_tb;
    reg clk;
    reg [32-1:0] operand_1;
    reg [32-1:0] operand_2;
    wire [63:0] result;

    initial begin
        clk = 0;
        operand_1 = 32'd0;
        operand_2 = 32'd0;
    end

    always begin
        #5 clk = !clk;
    end

    initial begin
        forever begin
            #100
            operand_1 = operand_1 + 1;
            operand_2 = operand_2 + 1;
        end
    end

    //例化待测设计
    mult_gen_0 u_mult_gen_0 (
        .CLK(clk),  // input wire CLK
        .A(operand_1),      // input wire [15 : 0] A
        .B(operand_2),      // input wire [15 : 0] B
        .P(result)      // output wire [31 : 0] P
    );

endmodule //MULTI_tb