module memory #(
    parameter MEM_SIZE = 64  // bytes
) (
    input logic clk,
    input logic rd,
    input logic wr,

    /* verilator lint_off UNUSEDSIGNAL */
    input logic [31:0] addr,
    /* verilator lint_on UNUSEDSIGNAL */

    inout wire [31:0] bus
);
    localparam int WORD_COUNT = MEM_SIZE / 4;

    logic [31:0] mem [0:WORD_COUNT-1];

     always_ff @(posedge clk) begin
        if (wr) begin
            mem[addr] <= bus;
        end
    end

    assign bus = (rd) ? mem[addr] : 'z;

endmodule
