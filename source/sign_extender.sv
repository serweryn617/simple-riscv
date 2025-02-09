module sign_extender (
    input logic clk,
    input logic wr,
    input logic rd,
    input logic [2:0] op,

    inout wire [31:0] bus
);

    logic [31:0] acc;
    logic [31:0] result;

    always_comb begin
        case (op)
            3'b000: result = {{24{acc[7]}}, acc[7:0]};
            3'b001: result = {{16{acc[15]}}, acc[15:0]};
            3'b010: result = acc;
            3'b100: result = {{24{1'b0}}, acc[7:0]};
            3'b101: result = {{16{1'b0}}, acc[15:0]};
            default: result = acc;
        endcase
    end

    always_ff @(posedge clk) begin
        if (wr) begin
            acc <= bus;
        end
    end

    assign bus = (rd) ? result : 'z;

endmodule
