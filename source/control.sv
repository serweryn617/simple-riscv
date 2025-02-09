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
    output logic [4:0] alu_op,
    output logic ext_wr,
    output logic ext_rd,
    output logic [2:0] ext_op
);

    logic [31:0] ir = 0;
    logic cmp = 0;
    logic [7:0] counter = 0;

    logic [31:0] bus_out;
    logic bus_out_en;

    /* verilator lint_off UNUSEDSIGNAL */

    logic [6:0] opcode;
    logic [4:0] rd;
    logic [2:0] funct3;
    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [6:0] funct7;
    logic [4:0] imm5;
    logic [6:0] imm7;
    logic [11:0] imm12;
    logic [19:0] imm20;

    assign opcode = ir[6:0];
    assign rd = ir[11:7];
    assign funct3 = ir[14:12];
    assign rs1 = ir[19:15];
    assign rs2 = ir[24:20];
    assign funct7 = ir[31:25];

    assign imm5 = ir[11:7];
    assign imm7 = ir[31:25];
    assign imm12 = ir[31:20];
    assign imm20 = ir[31:12];

    logic [31:0] imm_i;
    logic [31:0] imm_s;
    logic [31:0] imm_b;
    logic [31:0] imm_u;
    logic [31:0] imm_j;

    assign imm_i = {{20{imm12[11]}}, imm12};
    assign imm_s = {{20{imm7[6]}}, imm7, imm5};
    assign imm_b = {{20{imm7[6]}}, imm5[0], imm7[5:0], imm5[4:1], 1'b0};
    assign imm_u = {imm20, 12'b0};
    assign imm_j = {{12{imm20[19]}}, imm20[7:0], imm20[8], imm20[18:9], 1'b0};

    /* verilator lint_on UNUSEDSIGNAL */

    logic ir_load;
    logic cmp_load;

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
        if (cmp_load) begin
            cmp <= bus[0];
        end
    end

    always_comb begin
        ir_load = 0;
        cmp_load = 0;
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
        ext_wr = '0;
        ext_rd = '0;
        ext_op = '0;

        if (counter == 1) begin
            pc_rd = '1;
            mem_load = '1;
        end
        if (counter == 2) begin
            mem_rd = '1;
            ir_load = '1;
        end

        // ADDI, SLTI, SLTIU, ANDI, ORI, XORI, SLLI, SRLI, SRAI
        if (opcode == 7'b0010011) begin
            if (counter == 3) begin
                bus_out = imm_i;
                bus_out_en = '1;
                alu_op = '0;
                alu_wr = '1;
            end
            if (counter == 4) begin
                reg_addr = rs1;
                reg_rd = '1;
                alu_op = {1'b1, (funct3[1:0] == 2'b01) ? funct7[5] : 1'b0, funct3};
                alu_wr = '1;
            end
            if (counter == 5) begin
                alu_rd = '1;
                reg_addr = rd;
                reg_wr = '1;
                pc_inc = '1;
            end
        end

        // LUI
        if (opcode == 7'b0110111) begin
            if (counter == 3) begin
                bus_out = imm_u;
                bus_out_en = '1;
                reg_addr = rd;
                reg_wr = '1;
                pc_inc = '1;
            end
        end

        // AUIPC
        if (opcode == 7'b0110111) begin
            if (counter == 3) begin
                bus_out = imm_u;
                bus_out_en = '1;
                alu_op = '0;
                alu_wr = '1;
            end
            if (counter == 4) begin
                pc_rd = '1;
                alu_op = 5'b10000;
                alu_wr = '1;
            end
            if (counter == 5) begin
                alu_rd = '1;
                reg_addr = rd;
                reg_wr = '1;
                pc_inc = '1;
            end
        end

        // ADD, SLT, SLTU, AND, OR, XOR, SLL, SRL, SUB, SRA
        if (opcode == 7'b0010011) begin
            if (counter == 3) begin
                reg_addr = rs2;
                reg_rd = '1;
                alu_op = '0;
                alu_wr = '1;
            end
            if (counter == 4) begin
                reg_addr = rs1;
                reg_rd = '1;
                alu_op = {1'b1, funct7[5], funct3};
                alu_wr = '1;
            end
            if (counter == 5) begin
                alu_rd = '1;
                reg_addr = rd;
                reg_wr = '1;
                pc_inc = '1;
            end
        end

        // JAL
        if (opcode == 7'b1101111) begin
            if (counter == 3) begin
                pc_rd = '1;
                alu_op = '0;
                alu_wr = '1;
            end
            if (counter == 4) begin
                bus_out = imm_j;
                bus_out_en = '1;
                alu_op = 5'b10000;
                alu_wr = '1;
                pc_inc = '1;
            end
            if (counter == 5) begin
                pc_rd = '1;
                reg_addr = rd;
                reg_wr = '1;
            end
            if (counter == 6) begin
                alu_rd = '1;
                pc_wr = '1;
            end
        end

        // JALR
        if (opcode == 7'b1100111) begin
            if (counter == 3) begin
                reg_addr = rs1;
                reg_rd = '1;
                alu_op = '0;
                alu_wr = '1;
            end
            if (counter == 4) begin
                bus_out = imm_i;
                bus_out_en = '1;
                alu_op = 5'b10000;
                alu_wr = '1;
                pc_inc = '1;
            end
            if (counter == 5) begin
                pc_rd = '1;
                reg_addr = rd;
                reg_wr = '1;
            end
            if (counter == 6) begin
                bus_out = 32'hFFFFFFFE;
                bus_out_en = '1;
                alu_op = 5'b10111;  // AND
                alu_wr = '1;
            end
            if (counter == 7) begin
                alu_rd = '1;
                pc_wr = '1;
            end
        end

        // BEQ, BNE, BLT, BGE, BLTU, BGEU
        if (opcode == 7'b1100011) begin
            if (counter == 3) begin
                reg_addr = rs2;
                reg_rd = '1;
                alu_op = '0;
                alu_wr = '1;
            end
            if (counter == 4) begin
                reg_addr = rs1;
                reg_rd = '1;
                alu_op = {2'b01, funct3};
                alu_wr = '1;
            end
            if (counter == 5) begin
                alu_rd = '1;
                cmp_load = '1;
            end
            if (counter == 6) begin
                pc_rd = '1;
                alu_op = '0;
                alu_wr = '1;
            end
            if (counter == 7) begin
                bus_out = imm_b;
                bus_out_en = '1;
                alu_op = 5'b10000;
                alu_wr = '1;
            end
            if (counter == 8) begin
                if (cmp) begin
                    alu_rd = '1;
                    pc_wr = '1;
                end else begin
                    pc_inc = '1;
                end
            end
        end

        // LW, LH, LB, LHU, LBU
        if (opcode == 7'b0000011) begin
            if (counter == 3) begin
                bus_out = imm_i;
                bus_out_en = '1;
                alu_op = '0;
                alu_wr = '1;
            end
            if (counter == 4) begin
                reg_addr = rs1;
                reg_rd = '1;
                alu_op = 5'b10000;
                alu_wr = '1;
            end
            if (counter == 5) begin
                alu_rd = '1;
                mem_load = '1;
            end
            if (counter == 6) begin
                mem_rd = '1;
                ext_wr = '1;
            end
            if (counter == 7) begin
                ext_rd = '1;
                ext_op = funct3;
                reg_addr = rd;
                reg_wr = '1;
                pc_inc = '1;
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
                alu_op = 5'b10000;
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
                pc_inc = '1;
            end
        end

    end

    assign bus = (bus_out_en) ? bus_out : 'z;

endmodule
