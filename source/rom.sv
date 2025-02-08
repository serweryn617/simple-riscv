module rom (
    input logic rd,

    /* verilator lint_off UNUSEDSIGNAL */
    input logic [31:0] addr,
    /* verilator lint_on UNUSEDSIGNAL */

    output wire [31:0] bus
);

    logic [31:0] rom_memory [0:15];

    initial begin
        rom_memory[0] = 32'h00802283;  // LW z0+0x8 -> r5
        rom_memory[1] = 32'h08502023;  // SW r5 -> z0+128
        rom_memory[2] = 32'h0000005A;
        rom_memory[3] = 32'h00000004;
        rom_memory[4] = 32'h00000005;
        rom_memory[5] = 32'h00000006;
        rom_memory[6] = 32'h00000007;
        rom_memory[7] = 32'h00000010;
        rom_memory[8] = 32'h00000020;
        rom_memory[9] = 32'h00000030;
        rom_memory[10] = 32'h00000040;
        rom_memory[11] = 32'h00000050;
        rom_memory[12] = 32'h00000060;
        rom_memory[13] = 32'h00000070;
        rom_memory[14] = 32'h000000AA;
        rom_memory[15] = 32'h00000055;
    end

    assign bus = (rd) ? rom_memory[addr] : 'z;

endmodule
