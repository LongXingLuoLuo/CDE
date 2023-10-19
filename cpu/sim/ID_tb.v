//~ `New testbench
`timescale 1ns / 1ps
`include "bus.v"
`include "sim.v"

module Core_tb;

    // Core Parameters
    parameter PERIOD = 10;


    // Core Inputs
    reg                 clk;
    reg                 rst;
    reg                 stall = 0;
    wire [   `DATA_BUS] rom_read_data;
    wire [   `DATA_BUS] ram_read_data;

    // Core Outputs
    wire                rom_en;
    wire [`MEM_SEL_BUS] rom_write_en;
    wire [   `ADDR_BUS] rom_addr;
    wire [   `DATA_BUS] rom_write_data;
    wire                ram_en;
    wire [`MEM_SEL_BUS] ram_write_en;
    wire [   `ADDR_BUS] ram_addr;
    wire [   `DATA_BUS] ram_write_data;


    initial begin
        forever #(PERIOD / 2) clk = ~clk;
    end

    initial begin
        clk   = 0;
        rst   = 1;
        stall = 0;
        #7 rst = 0;
    end

    ROM rom (
        .clk           (clk),
        .rom_en        (rom_en),
        .rom_write_en  (rom_write_en),
        .rom_addr      (rom_addr),
        .rom_write_data(rom_write_data),
        .rom_read_data (rom_read_data)
    );

    RAM ram (
        .clk           (clk),
        .ram_en        (ram_en),
        .ram_write_en  (ram_write_en),
        .ram_addr      (ram_addr),
        .ram_write_data(ram_write_data),
        .ram_read_data (ram_read_data)
    );


    Core u_Core (
        .clk           (clk),
        .rst           (rst),
        .stall         (stall),
        .rom_read_data (rom_read_data),
        .ram_read_data (ram_read_data),
        .rom_en        (rom_en),
        .rom_write_en  (rom_write_en),
        .rom_addr      (rom_addr),
        .rom_write_data(rom_write_data),
        .ram_en        (ram_en),
        .ram_write_en  (ram_write_en),
        .ram_addr      (ram_addr),
        .ram_write_data(ram_write_data)
    );
endmodule
