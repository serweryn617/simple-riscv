module cpu (
    input logic clk,
    output logic [7:0] leds
);

    logic rst = 0;

    // Data bus
    wire [31:0] bus;

    // Control signals
    logic mem_load;
    logic mem_rd;
    logic mem_wr;
    logic pc_rd;
    logic pc_wr;
    logic pc_inc;
    logic reg_rd;
    logic reg_wr;
    logic [4:0] reg_addr;
    logic alu_wr;
    logic alu_rd;
    logic [3:0] alu_op;

    memory_controller mem_inst (
        .clk(clk),
        .load(mem_load),
        .rd(mem_rd),
        .wr(mem_wr),
        .bus(bus),
        .leds(leds)
    );

    register_pc pc_inst (
        .clk(clk),
        .rst(rst),
        .rd(pc_rd),
        .wr(pc_wr),
        .inc(pc_inc),
        .bus(bus)
    );

    register_file reg_file_inst (
        .clk(clk),
        .rd(reg_rd),
        .wr(reg_wr),
        .addr(reg_addr),
        .bus(bus)
    );

    alu alu_inst (
        .clk(clk),
        .wr(alu_wr),
        .rd(alu_rd),
        .op(alu_op),
        .bus(bus)
    );

    control ctrl_inst (
        .clk(clk),
        .rst(rst),
        .mem_load(mem_load),
        .mem_rd(mem_rd),
        .mem_wr(mem_wr),
        .pc_rd(pc_rd),
        .pc_wr(pc_wr),
        .pc_inc(pc_inc),
        .reg_rd(reg_rd),
        .reg_wr(reg_wr),
        .reg_addr(reg_addr),
        .alu_wr(alu_wr),
        .alu_rd(alu_rd),
        .alu_op(alu_op),
        .bus(bus)
    );

endmodule
