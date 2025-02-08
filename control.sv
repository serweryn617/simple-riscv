module control (
    input logic clk,
    input logic rst,
    inout wire [31:0] bus,

    output logic mem_load,
    output logic mem_rd,
    output logic mem_wr,
    output logic pc_rd,
    output logic pc_wr,
    output logic pc_inc,
    output logic reg_rd,
    output logic reg_wr,
    output logic [4:0] reg_addr,
    output logic alu_wr,
    output logic alu_rd,
    output logic [3:0] alu_op
);

    logic [31:0] ir = 0;
    logic [7:0] counter = 0;

    logic [31:0] bus_out;
    logic bus_out_en;

    logic [6:0] opcode;
    logic [4:0] rd;
    logic [2:0] funct3;
    logic [4:0] rs1;
    logic [4:0] rs2;
    // logic [6:0] funct7;
    logic [4:0] imm5;
    logic [6:0] imm7;
    logic [11:0] imm12;
    // logic [19:0] imm20;

    assign opcode = ir[6:0];
    assign rd = ir[11:7];
    assign funct3 = ir[14:12];
    assign rs1 = ir[19:15];
    assign rs2 = ir[24:20];
    // assign funct7 = ir[31:25];

    assign imm5 = ir[11:7];
    assign imm7 = ir[31:25];
    assign imm12 = ir[31:20];
    // assign imm20 = ir[31:12];

    logic [31:0] imm_i;
    logic [31:0] imm_s;

    always_comb begin
        imm_i = {(imm12[11]) ? {20{1'b1}} : '0, imm12};
        imm_s = {(imm7[6]) ? {20{1'b1}} : '0, imm7, imm5};
    end

    logic ir_load;

    always_ff @(negedge clk, posedge rst) begin
        if (rst) begin
            counter <= '0;
        end else if (!clk && counter != 10) begin
            counter <= counter + 1'b1;
        end else if (!clk) begin
            counter <= '0;
        end
    end

    always_ff @(posedge clk) begin
        if (ir_load) begin
            ir <= bus;
        end
    end

    always_comb begin
        bus_out = '0;
        bus_out_en = '0;

        mem_load = '0;
        mem_rd = '0;
        mem_wr = '0;
        pc_rd = '0;
        pc_wr = '0;
        pc_inc = '0;
        reg_rd = '0;
        reg_wr = '0;
        reg_addr = 5'b0;
        alu_wr = '0;
        alu_rd = '0;
        alu_op = '0;

        ir_load = 0;

        if (counter == 1) begin
            // PC -> AR
            pc_rd = '1;
            mem_load = '1;
        end
        if (counter == 2) begin
            // MEM -> IR, PC++
            mem_rd = '1;
            pc_inc = '1;
            ir_load = '1;
        end

        // LW
        if (opcode == 7'b0000011 && funct3 == 3'b010) begin
            if (counter == 3) begin
                bus_out = imm_i;
                bus_out_en = '1;
                alu_op = '0;
                alu_wr = '1;
            end
            if (counter == 4) begin
                reg_addr = rs1;
                reg_rd = '1;
                alu_op = 4'b1000;
                alu_wr = '1;
            end
            if (counter == 5) begin
                alu_rd = '1;
                mem_load = '1;
            end
            if (counter == 6) begin
                reg_addr = rd;
                reg_wr = '1;
                mem_rd = '1;
            end
        end

        // SW
        else if (opcode == 7'b0100011 && funct3 == 3'b010) begin
            if (counter == 3) begin
                bus_out = imm_s;
                bus_out_en = '1;
                alu_op = '0;
                alu_wr = '1;
            end
            if (counter == 4) begin
                reg_addr = rs1;
                reg_rd = '1;
                alu_op = 4'b1000;
                alu_wr = '1;
            end
            if (counter == 5) begin
                alu_rd = '1;
                mem_load = '1;
            end
            if (counter == 6) begin
                reg_addr = rs2;
                reg_rd = '1;
                mem_wr = '1;
            end
        end

    end

    assign bus = (bus_out_en) ? bus_out : 'z;

endmodule
