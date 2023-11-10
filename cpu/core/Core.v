`timescale 1ns / 1ps

`include "bus.v"

module Core (
    input                  clk,
    input                  rst,
    input                  stall,
    // ROM control
    output                 rom_en,
    output [ `MEM_SEL_BUS] rom_write_en,
    output [    `ADDR_BUS] rom_addr,
    input  [    `DATA_BUS] rom_read_data,
    output [    `DATA_BUS] rom_write_data,
    // RAM control
    output                 ram_en,
    output [ `MEM_SEL_BUS] ram_write_en,
    output [    `ADDR_BUS] ram_addr,
    input  [    `DATA_BUS] ram_read_data,
    output [    `DATA_BUS] ram_write_data,
    // debug signals
    output                 debug_reg_write_en,
    output [`REG_ADDR_BUS] debug_reg_write_addr,
    output [    `DATA_BUS] debug_reg_write_data,
    output [    `ADDR_BUS] debug_pc_addr
);


    // stall signals
    wire stall_pc_conn, stall_if_conn, stall_id_conn, stall_ex_conn, stall_mem_conn, stall_wb_conn;


    // PC stage
    wire pc_branch_flag;
    wire [`ADDR_BUS] pc_branch_addr, pc_pc, ifid_addr;
    wire [`INST_BUS] ifid_inst;

    PC pc_stage (
        .clk(clk),
        .rst(rst),

        .stall_pc   (stall_pc_conn),
        .branch_flag(pc_branch_flag),
        .branch_addr(pc_branch_addr),
        .pc         (pc_pc),

        .rom_en        (rom_en),
        .rom_write_en  (rom_write_en),
        .rom_addr      (rom_addr),
        .rom_write_data(rom_write_data)
    );

    IFID ifid (
        .clk                (clk),
        .rst                (rst),
        .stall_current_stage(stall_if_conn),
        .stall_next_stage   (stall_id_conn),

        .addr_in(pc_pc),
        .inst_in(rom_read_data),

        .addr_out(ifid_addr),
        .inst_out(ifid_inst)
    );


    // ID stage
    wire id_load_related_1, id_load_related_2;
    wire id_reg_read_en_1, id_reg_read_en_2;
    wire [`REG_ADDR_BUS] id_reg_addr_1, id_reg_addr_2;
    wire [`DATA_BUS] id_reg_data_1, id_reg_data_2;
    wire id_stall_request;
    wire [`FUNCT_BUS] id_funct, idex_funct;
    wire [`SHAMT_BUS] id_shamt, idex_shamt;
    wire [`DATA_BUS] id_operand_1, id_operand_2;
    wire [`DATA_BUS] idex_operand_1, idex_operand_2;
    wire id_mem_read_flag, id_mem_write_flag, id_mem_sign_ext_flag;
    wire idex_mem_read_flag, idex_mem_write_flag, idex_mem_sign_ext_flag;
    wire [`MEM_SEL_BUS] id_mem_sel, idex_mem_sel;
    wire [`DATA_BUS] id_mem_write_data, idex_mem_write_data;
    wire id_reg_write_en, idex_reg_write_en;
    wire [`REG_ADDR_BUS] id_reg_write_addr, idex_reg_write_addr;
    wire [`ADDR_BUS] id_current_pc_addr, idex_current_pc_addr;


    wire id_cp0_write_en, id_cp0_read_en;
    wire [`DATA_BUS] id_cp0_write_data;
    wire [`CP0_ADDR_BUS] id_cp0_addr;
    // wire  id_delayslot_flag_in, id_delayslot_flag_out, id_next_inst_delayslot_flag, id_eret_flag, id_syscall_flag, id_break_flag;
    // wire [`EXC_TYPE_BUS] id_exception_type;


    wire  idex_cp0_write_en, idex_cp0_read_en;
    wire [`DATA_BUS] idex_cp0_write_data, idex_cp0_read_data;
    wire [`CP0_ADDR_BUS] idex_cp0_addr;
    // wire idex_eret_flag, idex_syscall_flag, idex_break_flag, idex_delayslot_flag;

    wire [`DATA_BUS] cp0_rp_data;
    // wire [`DATA_BUS] cp0_rp_status, cp0_rp_cause, cp0_rp_epc;
    // wire [`EXC_TYPE_BUS] idex_exception_type;

    ID id_stage (
        .addr(ifid_addr),
        .inst(ifid_inst),

        .load_related_1(id_load_related_1),
        .load_related_2(id_load_related_2),

        // .delayslot_flag_in        (id_delayslot_flag_in),

        .reg_read_en_1(id_reg_read_en_1),
        .reg_addr_1   (id_reg_addr_1),
        .reg_data_1   (id_reg_data_1),
        .reg_read_en_2(id_reg_read_en_2),
        .reg_addr_2   (id_reg_addr_2),
        .reg_data_2   (id_reg_data_2),

        .stall_request(id_stall_request),

        .branch_flag(pc_branch_flag),
        .branch_addr(pc_branch_addr),

        .funct    (id_funct),
        .shamt    (id_shamt),
        .operand_1(id_operand_1),
        .operand_2(id_operand_2),

        .mem_read_flag    (id_mem_read_flag),
        .mem_write_flag   (id_mem_write_flag),
        .mem_sign_ext_flag(id_mem_sign_ext_flag),
        .mem_sel          (id_mem_sel),
        .mem_write_data   (id_mem_write_data),

        .reg_write_en  (id_reg_write_en),
        .reg_write_addr(id_reg_write_addr),

        //* cp0
        .cp0_write_en             (id_cp0_write_en),
        .cp0_read_en              (id_cp0_read_en),
        .cp0_addr                 (id_cp0_addr),
        .cp0_write_data           (id_cp0_write_data),

        // .delayslot_flag_out       (id_delayslot_flag_out),
        // .next_inst_delayslot_flag (id_next_inst_delayslot_flag),
        // .exception_type           ( id_exception_type   ),
        // .eret_flag                (id_eret_flag),
        // .syscall_flag             (id_syscall_flag),
        // .break_flag               (id_break_flag), 

        .current_pc_addr(id_current_pc_addr)
    );

    IDEX idex (
        .clk                (clk),
        .rst                (rst),
        .stall_current_stage(stall_id_conn),
        .stall_next_stage   (stall_ex_conn),

        .funct_in            (id_funct),
        .shamt_in            (id_shamt),
        .operand_1_in        (id_operand_1),
        .operand_2_in        (id_operand_2),
        .mem_read_flag_in    (id_mem_read_flag),
        .mem_write_flag_in   (id_mem_write_flag),
        .mem_sign_ext_flag_in(id_mem_sign_ext_flag),
        .mem_sel_in          (id_mem_sel),
        .mem_write_data_in   (id_mem_write_data),
        .reg_write_en_in     (id_reg_write_en),
        .reg_write_addr_in   (id_reg_write_addr),

        //* cp0
        .cp0_write_en_in      (id_cp0_write_en),
        .cp0_read_en_in       (id_cp0_read_en),
        .cp0_addr_in          (id_cp0_addr),
        .cp0_write_data_in    (id_cp0_write_data),
        .cp0_read_data_in     (cp0_rp_data),
        // .exception_type_in            (id_exception_type),
        // .eret_flag_in                 (id_eret_flag),
        // .syscall_flag_in              (id_syscall_flag),
        // .break_flag_in                (id_break_flag),
        // .delayslot_flag_in            (id_delayslot_flag_out),
        // .next_inst_delayslot_flag_in  (id_next_inst_delayslot_flag),

        .current_pc_addr_in  (id_current_pc_addr),

        .funct_out            (idex_funct),
        .shamt_out            (idex_shamt),
        .operand_1_out        (idex_operand_1),
        .operand_2_out        (idex_operand_2),
        .mem_read_flag_out    (idex_mem_read_flag),
        .mem_write_flag_out   (idex_mem_write_flag),
        .mem_sign_ext_flag_out(idex_mem_sign_ext_flag),
        .mem_sel_out          (idex_mem_sel),
        .mem_write_data_out   (idex_mem_write_data),
        .reg_write_en_out     (idex_reg_write_en),
        .reg_write_addr_out   (idex_reg_write_addr),

        //* cp0
        .cp0_write_en_out     (idex_cp0_write_en),
        .cp0_read_en_out      (idex_cp0_read_en),
        .cp0_addr_out         (idex_cp0_addr),
        .cp0_write_data_out   (idex_cp0_write_data),
        .cp0_read_data_out    (idex_cp0_read_data),

        // .exception_type_out           (idex_exception_type),
        // .eret_flag_out                (idex_eret_flag),
        // .syscall_flag_out             (idex_syscall_flag),
        // .break_flag_out               (idex_break_flag),
        // .delayslot_flag_out           (idex_delayslot_flag),
        // .next_inst_delayslot_flag_out (id_delayslot_flag_in),

        .current_pc_addr_out  (idex_current_pc_addr)
    );

    // * from HILO
    wire [`DATA_BUS] idex_hi, idex_lo;

    // * mult div
    wire [`DOUBLE_DATA_BUS] mult_div_result;
    wire mult_div_done;

    MultDiv u_MultDiv (
        .clk                 (clk),
        .rst                 (rst),
        .stall_all           (stall),
        .funct               (idex_funct),
        .operand_1           (idex_operand_1),
        .operand_2           (idex_operand_2),
        .hi                  (idex_hi),
        .lo                  (idex_lo),
        .done                (mult_div_done),
        .result              (mult_div_result)
    );


    // EX stage
    wire ex_ex_load_flag;
    wire ex_mem_read_flag, ex_mem_write_flag, ex_mem_sign_ext_flag;
    wire exmem_mem_read_flag, exmem_mem_write_flag, exmem_mem_sign_ext_flag;
    wire [`MEM_SEL_BUS] ex_mem_sel, exmem_mem_sel;
    wire [`DATA_BUS] ex_mem_write_data, ex_result;
    wire [`DATA_BUS] exmem_mem_write_data, exmem_result;
    wire ex_reg_write_en, exmem_reg_write_en;
    wire [`REG_ADDR_BUS] ex_reg_write_addr, exmem_reg_write_addr;
    wire [`ADDR_BUS] ex_current_pc_addr, exmem_current_pc_addr;

    wire [`DATA_BUS] ex_hi, ex_lo, exmem_hi, exmem_lo;
    wire ex_hilo_write_en, exmem_hilo_write_en;

    // * stall_request
    wire ex_stall_request;

    //* cp0
    wire ex_cp0_write_en;
    wire [`ADDR_BUS] ex_cp0_write_data;
    wire [`CP0_ADDR_BUS] ex_cp0_addr;
    // wire ex_eret_flag, ex_syscall_flag, ex_break_flag, ex_delayslot_flag;
    // wire [`EXC_TYPE_BUS] ex_exception_type;

    wire exmem_cp0_write_en;
    wire [`ADDR_BUS] exmem_cp0_write_data;
    wire [`CP0_ADDR_BUS] exmem_cp0_addr;
    // wire exmem_eret_flag, exmem_syscall_flag, exmem_break_flag, exmem_delayslot_flag;
    // wire [`EXC_TYPE_BUS] exmem_exception_type;

    EX ex_stage (
        .funct               (idex_funct),
        .shamt               (idex_shamt),
        .operand_1           (idex_operand_1),
        .operand_2           (idex_operand_2),
        .mem_read_flag_in    (idex_mem_read_flag),
        .mem_write_flag_in   (idex_mem_write_flag),
        .mem_sign_ext_flag_in(idex_mem_sign_ext_flag),
        .mem_sel_in          (idex_mem_sel),
        .mem_write_data_in   (idex_mem_write_data),
        .reg_write_en_in     (idex_reg_write_en),
        .reg_write_addr_in   (idex_reg_write_addr),
        .current_pc_addr_in  (idex_current_pc_addr),

        // * hilo
        .hi_in               (idex_hi),
        .lo_in               (idex_lo),

        // * mult div
        .mult_div_done       (mult_div_done),
        .mult_div_result     (mult_div_result),

        //* cp0
        .cp0_write_en_in      (idex_cp0_write_en),
        .cp0_read_en_in       (idex_cp0_read_en),
        .cp0_addr_in          (idex_cp0_addr),
        .cp0_write_data_in    (idex_cp0_write_data),
        .cp0_read_data_in     (idex_cp0_read_data),
        // .exception_type_in    (idex_exception_type),
        // .eret_flag_in         (idex_eret_flag),
        // .syscall_flag_in      (idex_syscall_flag),
        // .break_flag_in        (idex_break_flag),
        // .delayslot_flag_in    (idex_delayslot_flag),


        .ex_load_flag(ex_ex_load_flag),

        .mem_read_flag_out    (ex_mem_read_flag),
        .mem_write_flag_out   (ex_mem_write_flag),
        .mem_sign_ext_flag_out(ex_mem_sign_ext_flag),
        .mem_sel_out          (ex_mem_sel),
        .mem_write_data_out   (ex_mem_write_data),

        .hilo_write_en        (ex_hilo_write_en),
        .hi_out               (ex_hi),
        .lo_out               (ex_lo),

        // * stall_request
        .stall_request(ex_stall_request),

        //* cp0
        .cp0_write_en_out     (ex_cp0_write_en),
        .cp0_write_data_out   (ex_cp0_write_data),
        .cp0_addr_out         (ex_cp0_addr),
        // .exception_type_out   (ex_exception_type),
        // .eret_flag_out        (ex_eret_flag),
        // .syscall_flag_out     (ex_syscall_flag),
        // .break_flag_out       (ex_break_flag),
        // .delayslot_flag_out   (ex_delayslot_flag),

        .result             (ex_result),
        .reg_write_en_out   (ex_reg_write_en),
        .reg_write_addr_out (ex_reg_write_addr),
        .current_pc_addr_out(ex_current_pc_addr)
    );

    EXMEM exmem (
        .clk                (clk),
        .rst                (rst),
        .stall_current_stage(stall_ex_conn),
        .stall_next_stage   (stall_mem_conn),

        .mem_read_flag_in    (ex_mem_read_flag),
        .mem_write_flag_in   (ex_mem_write_flag),
        .mem_sign_ext_flag_in(ex_mem_sign_ext_flag),
        .mem_sel_in          (ex_mem_sel),
        .mem_write_data_in   (ex_mem_write_data),
        .result_in           (ex_result),
        .reg_write_en_in     (ex_reg_write_en),
        .reg_write_addr_in   (ex_reg_write_addr),
        .current_pc_addr_in  (ex_current_pc_addr),

        // hilo
        .hilo_write_en_in     (ex_hilo_write_en),
        .hi_in                (ex_hi),
        .lo_in                (ex_lo),

        //* cp0
        .cp0_write_en_in        (ex_cp0_write_en),
        .cp0_write_data_in      (ex_cp0_write_data),
        .cp0_addr_in            (ex_cp0_addr),
        // .exception_type_in      (ex_exception_type),
        // .eret_flag_in           (ex_eret_flag),
        // .syscall_flag_in        (ex_syscall_flag),
        // .break_flag_in          (ex_break_flag),
        // .delayslot_flag_in      (ex_delayslot_flag),

        .mem_read_flag_out    (exmem_mem_read_flag),
        .mem_write_flag_out   (exmem_mem_write_flag),
        .mem_sign_ext_flag_out(exmem_mem_sign_ext_flag),
        .mem_sel_out          (exmem_mem_sel),
        .mem_write_data_out   (exmem_mem_write_data),

        // hilo
        .hilo_write_en_out      (exmem_hilo_write_en),
        .hi_out                 (exmem_hi),
        .lo_out                 (exmem_lo),

        //* cp0
        .cp0_write_en_out     (exmem_cp0_write_en),
        .cp0_write_data_out   (exmem_cp0_write_data),
        .cp0_addr_out         (exmem_cp0_addr),
        // .exception_type_out   (exmem_exception_type),
        // .eret_flag_out        (exmem_eret_flag),
        // .syscall_flag_out     (exmem_syscall_flag),
        // .break_flag_out       (exmem_break_flag),
        // .delayslot_flag_out   (exmem_delayslot_flag),

        .result_out           (exmem_result),
        .reg_write_en_out     (exmem_reg_write_en),
        .reg_write_addr_out   (exmem_reg_write_addr),
        .current_pc_addr_out  (exmem_current_pc_addr)
    );


    // MEM stage
    wire mem_mem_load_flag;
    wire mem_mem_read_flag, mem_mem_write_flag, mem_mem_sign_ext_flag;
    wire memwb_mem_read_flag, memwb_mem_write_flag, memwb_mem_sign_ext_flag;
    wire [`MEM_SEL_BUS] mem_mem_sel, memwb_mem_sel;
    wire [`DATA_BUS] mem_result, memwb_result, memwb_ram_read_data;
    wire mem_reg_write_en, memwb_reg_write_en;
    wire [`REG_ADDR_BUS] mem_reg_write_addr, memwb_reg_write_addr;
    wire [`ADDR_BUS] mem_current_pc_addr, memwb_current_pc_addr;


    wire [`DATA_BUS] mem_hi, mem_lo, memwb_hi, memwb_lo;
    wire mem_hilo_write_en, memwb_hilo_write_en;

    // cp0 exception

    wire mem_cp0_write_en;
    wire [`DATA_BUS] mem_cp0_write_data;
    wire [`CP0_ADDR_BUS] mem_cp0_addr;
    // wire [`EXC_TYPE_BUS] cp0_exception_type;
    // wire cp0_delayslot_flag;
    // wire [`ADDR_BUS] cp0_badvaddr_write_data;
    // // to pipelineControl
    // wire [`ADDR_BUS] ctrl_cp0_epc;
    // wire [`DATA_BUS] exmem_cp0_status, exmem_cp0_cause, exmem_cp0_epc;
    // wire mem_eret_flag, mem_syscall_flag, mem_break_flag;

    wire memwb_cp0_write_en;
    wire [`DATA_BUS] memwb_cp0_write_data;
    wire [`CP0_ADDR_BUS] memwb_cp0_addr;

    MEM mem_stage (
        .mem_read_flag_in    (exmem_mem_read_flag),
        .mem_write_flag_in   (exmem_mem_write_flag),
        .mem_sign_ext_flag_in(exmem_mem_sign_ext_flag),
        .mem_sel_in          (exmem_mem_sel),
        .mem_write_data      (exmem_mem_write_data),

        .result_in         (exmem_result),
        .reg_write_en_in   (exmem_reg_write_en),
        .reg_write_addr_in (exmem_reg_write_addr),
        .current_pc_addr_in(exmem_current_pc_addr),

        .hilo_write_en_in  (exmem_hilo_write_en),
        .hi_in             (exmem_hi),
        .lo_in             (exmem_lo),

        //* cp0
        .cp0_write_en_in   (exmem_cp0_write_en),
        .cp0_write_data_in (exmem_cp0_write_data),
        .cp0_addr_in       (exmem_cp0_addr),
        // .cp0_status_in     (exmem_cp0_status),
        // .cp0_cause_in      (exmem_cp0_cause),
        // .cp0_epc_in        (exmem_cp0_epc),
        // .eret_flag_in      (exmem_eret_flag),
        // .syscall_flag_in   (exmem_syscall_flag),
        // .break_flag_in     (exmem_break_flag),
        // .exception_type_in (exmem_exception_type),

        .ram_en        (ram_en),
        .ram_write_en  (ram_write_en),
        .ram_addr      (ram_addr),
        .ram_write_data(ram_write_data),

        .mem_load_flag(mem_mem_load_flag),

        .mem_read_flag_out    (mem_mem_read_flag),
        .mem_write_flag_out   (mem_mem_write_flag),
        .mem_sign_ext_flag_out(mem_mem_sign_ext_flag),
        .mem_sel_out          (mem_mem_sel),
        .result_out           (mem_result),
        .reg_write_en_out     (mem_reg_write_en),
        .reg_write_addr_out   (mem_reg_write_addr),
        .current_pc_addr_out  (mem_current_pc_addr),

        // * hilo
        .hilo_write_en_out      (mem_hilo_write_en),
        .hi_out                 (mem_hi),
        .lo_out                 (mem_lo),

        //* cp0
        .cp0_write_en_out       (mem_cp0_write_en),
        .cp0_write_data_out     (mem_cp0_write_data),
        .cp0_addr_out           (mem_cp0_addr)
        // .eret_flag_out          (mem_eret_flag),
        // .syscall_flag_out       (mem_syscall_flag),
        // .break_flag_out         (mem_break_flag),
        // .exception_type_out     (cp0_exception_type),
        // .delayslot_flag_out     (cp0_delayslot_flag),
        // .cp0_epc_out            (cp0_rp_epc),
        // .cp0_badvaddr_write_data_out      (cp0_badvaddr_write_data)
    );

    MEMWB memwb (
        .clk                (clk),
        .rst                (rst),
        .stall_current_stage(stall_mem_conn),
        .stall_next_stage   (stall_wb_conn),

        .ram_read_data_in(ram_read_data),

        .mem_read_flag_in    (mem_mem_read_flag),
        .mem_write_flag_in   (mem_mem_write_flag),
        .mem_sign_ext_flag_in(mem_mem_sign_ext_flag),
        .mem_sel_in          (mem_mem_sel),
        .result_in           (mem_result),
        .reg_write_en_in     (mem_reg_write_en),
        .reg_write_addr_in   (mem_reg_write_addr),
        .current_pc_addr_in  (mem_current_pc_addr),

        // * hilo
        .hilo_write_en_in    (mem_hilo_write_en),
        .hi_in               (mem_hi),
        .lo_in               (mem_lo),

        //* cp0
        .cp0_write_en_in     (mem_cp0_write_en),
        .cp0_write_data_in   (mem_cp0_write_data),
        .cp0_addr_in         (mem_cp0_addr),

        .ram_read_data_out(memwb_ram_read_data),

        .mem_read_flag_out    (memwb_mem_read_flag),
        .mem_write_flag_out   (memwb_mem_write_flag),
        .mem_sign_ext_flag_out(memwb_mem_sign_ext_flag),
        .mem_sel_out          (memwb_mem_sel),
        .result_out           (memwb_result),
        .reg_write_en_out     (memwb_reg_write_en),
        .reg_write_addr_out   (memwb_reg_write_addr),
        .current_pc_addr_out  (memwb_current_pc_addr),

        // * hilo
        .hilo_write_en_out    (memwb_hilo_write_en),
        .hi_out               (memwb_hi),
        .lo_out               (memwb_lo),

        //* cp0
        .cp0_write_en_out     (memwb_cp0_write_en),
        .cp0_write_data_out   (memwb_cp0_write_data),
        .cp0_addr_out         (memwb_cp0_addr)
    );


    // WB stage
    wire [    `DATA_BUS] wb_result, wb_hilo_hi, wb_hilo_lo;
    wire                 wb_reg_write_en, wb_hilo_write_en;
    wire [`REG_ADDR_BUS] wb_reg_write_addr;

    assign debug_reg_write_addr = wb_reg_write_addr;
    assign debug_reg_write_data = wb_result;

    wire cp0_write_en;
    wire [`DATA_BUS] cp0_write_data;
    wire [`CP0_ADDR_BUS] cp0_addr;

    WB wb_stage (
        .ram_read_data(memwb_ram_read_data),

        .mem_read_flag    (memwb_mem_read_flag),
        .mem_write_flag   (memwb_mem_write_flag),
        .mem_sign_ext_flag(memwb_mem_sign_ext_flag),
        .mem_sel          (memwb_mem_sel),

        .result_in         (memwb_result),
        .reg_write_en_in   (memwb_reg_write_en),
        .reg_write_addr_in (memwb_reg_write_addr),
        .current_pc_addr_in(memwb_current_pc_addr),

        .hilo_write_en_in   ( memwb_hilo_write_en),
        .hi_in              ( memwb_hi),
        .lo_in              ( memwb_lo),

        //* cp0 in
        .cp0_write_en_in   (memwb_cp0_write_en),
        .cp0_write_data_in (memwb_cp0_write_data),
        .cp0_addr_in       (memwb_cp0_addr), 

        .result_out        (wb_result),
        .reg_write_en_out  (wb_reg_write_en),
        .reg_write_addr_out(wb_reg_write_addr),


        .hilo_write_en_out (wb_hilo_write_en),
        .hi_out(wb_hilo_hi),
        .lo_out(wb_hilo_lo),

        //* cp0 out
        .cp0_write_en_out  (cp0_write_en),
        .cp0_write_data_out(cp0_write_data),
        .cp0_addr_out      (cp0_addr),

        .debug_reg_write_en(debug_reg_write_en),
        .debug_pc_addr_out (debug_pc_addr)
    );


    // register file
    wire [`DATA_BUS] regfile_read_data_1, regfile_read_data_2;

    RegFile regfile (
        .clk(clk),
        .rst(rst),

        .read_en_1  (id_reg_read_en_1),
        .read_addr_1(id_reg_addr_1),
        .read_data_1(regfile_read_data_1),

        .read_en_2  (id_reg_read_en_2),
        .read_addr_2(id_reg_addr_2),
        .read_data_2(regfile_read_data_2),

        .write_en  (wb_reg_write_en),
        .write_addr(wb_reg_write_addr),
        .write_data(wb_result)
    );

    RegReadProxy reg_read_proxy (
        .read_en_1  (id_reg_read_en_1),
        .read_en_2  (id_reg_read_en_2),
        .read_addr_1(id_reg_addr_1),
        .read_addr_2(id_reg_addr_2),

        .data_1_from_reg(regfile_read_data_1),
        .data_2_from_reg(regfile_read_data_2),

        .ex_load_flag          (ex_ex_load_flag),
        .reg_write_en_from_ex  (ex_reg_write_en),
        .reg_write_addr_from_ex(ex_reg_write_addr),
        .data_from_ex          (ex_result),

        .mem_load_flag          (mem_mem_load_flag),
        .reg_write_en_from_mem  (mem_reg_write_en),
        .reg_write_addr_from_mem(mem_reg_write_addr),
        .data_from_mem          (mem_result),

        .load_related_1(id_load_related_1),
        .load_related_2(id_load_related_2),

        .read_data_1(id_reg_data_1),
        .read_data_2(id_reg_data_2)
    );

    // HILO
    wire [`DATA_BUS] hilo_rp_hi, hilo_rp_lo;

    HILO_RegFile hilo(
        .clk    (clk),
        .rst    (rst),
        .write_en(wb_hilo_write_en),
        .hi_i   (wb_hilo_hi),
        .lo_i   (wb_hilo_lo),
        .hi_o   (hilo_rp_hi),
        .lo_o   (hilo_rp_lo)
    );

    HILO_RegReadProxy hilo_regreadproxy(
        .hi_i   (hilo_rp_hi),
        .lo_i   (hilo_rp_lo),
        .mem_hilo_write_en(mem_hilo_write_en),
        .mem_hi_i(mem_hi),
        .mem_lo_i(mem_lo),
        .wb_hilo_write_en(wb_hilo_write_en),
        .wb_hi_i(wb_hilo_hi),
        .wb_lo_i(wb_hilo_lo),
        .hi_o(idex_hi),
        .lo_o(idex_lo)
    );

    wire [`DATA_BUS] cp0_data;
    // wire [`DATA_BUS] cp0_status, cp0_cause, cp0_epc, cp0_count, cp0_config;
	// wire [`ADDR_BUS] cp0_current_pc_addr = mem_current_pc_addr;
    // wire [`DATA_BUS] cp0_config0;

    CP0  cp0 (
        .clk                (clk),
        .rst                (rst),
        .cp0_write_en       (cp0_write_en),
        .cp0_read_addr      (ex_cp0_addr),
        .cp0_write_addr     (cp0_addr),
        .cp0_write_data     (cp0_write_data),
        // .cp0_badvaddr_write_data  (cp0_badvaddr_write_data),
        // .interrupt_i        (interrupt),
        // .exception_type     (cp0_exception_type),
        // .eret_flag          (mem_eret_flag),
        // .syscall_flag       (mem_syscall_flag),
        // .break_flag         (mem_break_flag),
        // .delayslot_flag     (cp0_delayslot_flag),
        // .current_pc_addr    (cp0_current_pc_addr),

        .data_o             (cp0_data)
        // .status_o           (cp0_status),
        // .cause_o            (cp0_cause),
        // .epc_o              (cp0_epc),
        // .count_o            (cp0_count),
        // .config0_o          (cp0_config)
    );

    CP0ReadProxy  cp0ReadProxy(
        .cp0_read_addr      (id_cp0_addr),
        .cp0_read_data_i    (cp0_data),
        // .cp0_status_i       (cp0_status),
        // .cp0_cause_i        (cp0_cause),
        // .cp0_epc_i          (cp0_epc),
        // .cp0_count_i        (cp0_count),
        // .cp0_config0_i      (cp0_config),

        .mem_cp0_write_en   (mem_cp0_write_en),
        .mem_cp0_write_addr (mem_cp0_addr),
        .mem_cp0_write_data (mem_cp0_write_data),
        .wb_cp0_write_en    (memwb_cp0_write_en),
        .wb_cp0_write_addr  (memwb_cp0_addr),
        .wb_cp0_write_data  (memwb_cp0_write_data),

        .cp0_read_data_o    (idex_cp0_read_data)
        // .cp0_status_o       (exmem_cp0_status),
        // .cp0_cause_o        (exmem_cp0_cause),
        // .cp0_epc_o          (exmem_cp0_epc),
        // .cp0_count_o        (           ),
        // .cp0_config0_o      (cp0_config0)
    );



    // pipeline control
    PipelineController pipeline_controller (
        .request_from_id(id_stall_request),
        .request_from_ex(ex_stall_request),
        .stall_all      (stall),
        .stall_pc       (stall_pc_conn),
        .stall_if       (stall_if_conn),
        .stall_id       (stall_id_conn),
        .stall_ex       (stall_ex_conn),
        .stall_mem      (stall_mem_conn),
        .stall_wb       (stall_wb_conn)
    );


endmodule  // Core
