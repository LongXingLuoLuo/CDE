`timescale 1ns / 1ps

`include "bus.v"

module HILO_RegFile(
    input                       clk,
    input                       rst,
    // read channel hi
    output      [`DATA_BUS]     hi_o,
    // read channel #2
    output      [`DATA_BUS]     lo_o,
    // write channel
    input                       write_en,
    input       [`DATA_BUS]     hi_i,
    input       [`DATA_BUS]     lo_i
);

  reg[`DATA_BUS] hi, lo;
  assign hi_o = hi;
  assign lo_o = lo;

  // writing
  always @(posedge clk) begin
    if (rst) begin
        hi <= 0;
        lo <= 0;
    end
    else if (write_en) begin
        hi <= hi_i;
        lo <= lo_i;
    end
  end

endmodule // HILO_RegFile
