`timescale 1ns / 1ps

`include "bus.v"
`include "funct.v"


module MultDiv(
    input                     clk,
    input                     rst,
    input                     stall_all,
    input     [`FUNCT_BUS]    funct,
    input     [`DATA_BUS]     operand_1,
    input     [`DATA_BUS]     operand_2,
    input     [`DATA_BUS]     hi,
    input     [`DATA_BUS]     lo,
    output                    done,
    output reg[`DOUBLE_DATA_BUS]  result
);

    // * 运算周期
    parameter kDivCycle = 40, kMultCycle = 1;

    reg[kDivCycle - 1:0] cycle_counter;
    reg[`FUNCT_BUS] last_funct;
    wire [`DOUBLE_DATA_BUS] mult_result;
    reg done_flag;

    wire signed_flag, result_neg_flag, remainder_neg_flag;
    wire[`DATA_BUS] op_1, op_2;
    wire[`DATA_BUS] quotient, remainder;

    assign signed_flag = funct == `FUNCT_MULT || funct == `FUNCT_DIV;           // 是否为有符号运算
    assign result_neg_flag = signed_flag && (operand_1[31] ^ operand_2[31]);    // 最终结果是否取负
    assign remainder_neg_flag = signed_flag && (operand_1[31] ^ remainder[31]); // 商运算结果shi
    assign op_1 = (signed_flag && operand_1[31]) ? (-operand_1) : operand_1;    // 运算数是否取负
    assign op_2 = (signed_flag && operand_2[31]) ? (-operand_2) : operand_2;    // 运算数是否取负
    assign done = cycle_counter[0] | done_flag;

    // // divider
    // Divider16t divider(
    //     clk, rst, funct == `FUNCT_DIV || funct == `FUNCT_DIVU,
    //     op_1, op_2, quotient, remainder,
    //     div_div0, div_done
    // );
    mult_gen_0 u_mult_gen(
        .clk(clk),
        .A(op_1),
        .B(op_2),
        .P(mult_result)
    );

    div_gen_0 u_div(
        .aclk(clk),
        .s_axis_dividend_tdata(op_1),
        .s_axis_divisor_tdata(op_2),
        .m_axis_dout_tdata({quotient, remainder})
    );

    always @(*) begin
        case (funct)
            `FUNCT_MULT, `FUNCT_MULTU: begin
                if (result_neg_flag) begin
                    result <= (-mult_result);
                end else begin
                    result <= mult_result;
                end
            end
            `FUNCT_DIV, `FUNCT_DIVU: begin
                result <= {
                    remainder_neg_flag ? -remainder : remainder,
                    result_neg_flag ? -quotient : quotient
                };
            end
            default: result <= 0;
        endcase
    end

    always @(posedge clk) begin
        if (rst) begin
            cycle_counter <= 0;
        end
        else if (stall_all) begin
            if (cycle_counter == 1) begin
                cycle_counter <= cycle_counter;
            end else if (cycle_counter)  begin
                cycle_counter <= cycle_counter >> 1;
            end
            else begin
                cycle_counter <= cycle_counter;
            end
        end
        else if (cycle_counter) begin
            cycle_counter <= cycle_counter >> 1;
        end
        else begin
            case (funct)
                `FUNCT_MULT, `FUNCT_MULTU: begin
                    cycle_counter <= 1'b1 << (kMultCycle - 1);
                end
                `FUNCT_DIV, `FUNCT_DIVU: begin
                    cycle_counter <= 1'b1 << (kDivCycle - 1);
                end
                default: begin
                    cycle_counter <= 0;
                end
            endcase
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            last_funct <= 0;
        end
        else begin
            last_funct <= funct;
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            done_flag <= 0;
        end
        else if (last_funct != funct) begin
            done_flag <= 0;
        end
        else if (cycle_counter) begin
            done_flag <= cycle_counter[0];
        end
    end

endmodule // MultDiv