module alu (
    input logic clk,
    input logic wr,
    input logic rd,
    input logic [3:0] op,
    inout wire [31:0] bus
);

    logic [31:0] acc;
    logic [31:0] result;

    always_comb begin
        case (op)
            4'b0000: result = bus;
            4'b1000: result = bus + acc;
            default: result = bus;
        endcase
    end

    always_ff @(posedge clk) begin
        if (wr) begin
            acc <= result;
        end
    end

    assign bus = (rd) ? acc : 'z;

endmodule
