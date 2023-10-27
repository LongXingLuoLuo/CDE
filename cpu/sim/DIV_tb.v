`timescale 1ns/1ps
module DIV_tb;
    // TODO
    //! 仿真结果不正确问题
    //! m_axis_dout_tvalid 无结果问题
    reg clk;
    reg [32-1:0] s_axis_dividend_tdata;
    reg s_axis_dividend_tvalid;
    wire s_axis_dividend_tready;
    reg [32-1:0] s_axis_divisor_tdata;
    reg s_axis_divisor_tvalid;
    wire s_axis_divisor_tready;
    wire [63:0] m_axis_dout_tdata;
    wire m_axis_dout_tvalid;

    initial begin
        clk = 0;
        s_axis_dividend_tdata = 32'd0;
        s_axis_divisor_tdata = 32'd0;
        s_axis_dividend_tvalid = 0;
        s_axis_divisor_tvalid = 0;
    end

    always begin
        #5 clk = !clk;
    end

    initial begin
        forever begin
            #400
            s_axis_dividend_tdata <= $random % (2**10);
            s_axis_divisor_tdata <= $random % (2**4);
            s_axis_dividend_tvalid <= 1;
            s_axis_divisor_tvalid <= 1;
        end
    end

    always @(posedge s_axis_dividend_tready) begin
        s_axis_dividend_tvalid <= 0;
    end

    always @(posedge s_axis_divisor_tready) begin
        s_axis_divisor_tvalid <= 0;
    end

    //例化待测设计
    div_gen_0 u_div_gen_0 (
        .aclk(clk),
        .s_axis_dividend_tdata(s_axis_dividend_tdata),
        .s_axis_dividend_tvalid(s_axis_dividend_tvalid),
        .s_axis_dividend_tready(s_axis_dividend_tready),
        .s_axis_divisor_tdata(s_axis_divisor_tdata),
        .s_axis_divisor_tvalid(s_axis_divisor_tvalid),
        .s_axis_divisor_tready(s_axis_divisor_tready),
        .m_axis_dout_tdata(m_axis_dout_tdata),
        .m_axis_dout_tvalid(m_axis_dout_tvalid)
    );

endmodule //DIV_tb