module register_pc (
    input logic clk,
    input logic rst,
    input logic rd,
    input logic wr,
    input logic inc,
    inout wire [31:0] bus
);

    logic [31:0] pc = 0;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            pc <= '0;
        end else if (inc) begin
            pc <= pc + 4;
        end else if (wr) begin
            pc <= bus;
        end
    end

    assign bus = (rd) ? pc : 'z;

endmodule
