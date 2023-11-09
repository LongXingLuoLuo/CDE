`include "bus.v"
module Div_ip_tb;
    parameter period = 10;

    reg clk, rst;
    // s_axis_dividend_tdata 被除数
    // s_axis_divisor_tdata 除数
    reg [`DATA_BUS] s_axis_dividend_tdata = 32'h00000000, s_axis_divisor_tdata = 32'h00000000;
    // reg s_axis_dividend_tvalid  = 0;
    // wire s_axis_dividend_tready;
    // reg s_axis_divisor_tvalid   = 0;
    // wire s_axis_divisor_tready;


    // wire [`DOUBLE_DATA_BUS] m_axis_dout_tdata;
    // wire m_axis_dout_tvalid;

    wire [`DATA_BUS] quoeitnt;  // 商数
    wire [`DATA_BUS] remainder;    // 余数
    // assign quoeitnt = m_axis_dout_tdata[63:32];
    // assign remainder = m_axis_dout_tdata[31:0];

    initial begin
        rst = 1;
        clk = 0;
        #7 rst = 0;
    end

    always #(period/2) clk = ~clk;

    initial begin
        // #(period * 100)
        // operand_1 <= $random;
        // operand_2 <= $random;
        // s_axis_dividend_tvalid = 1;
        // s_axis_divisor_tvalid = 1;
        #(period * 20)
        s_axis_dividend_tdata = 32'd142;
        s_axis_divisor_tdata = 32'd12;
        #(period * 50);
        s_axis_dividend_tdata = 32'h80000012;
        s_axis_divisor_tdata = 32'h00000012;
    end

    // always @(posedge s_axis_dividend_tready) begin
    //     s_axis_dividend_tvalid <= 0;
    // end

    // always @(posedge s_axis_divisor_tready) begin
    //     s_axis_divisor_tvalid <= 0;
    // end

    div_gen_0 u_div(
        .aclk(clk),
        .s_axis_divisor_tdata(s_axis_divisor_tdata),
        .s_axis_dividend_tdata(s_axis_dividend_tdata),
        .m_axis_dout_tdata({quoeitnt, remainder})
    );

endmodule //Div_ip_tb