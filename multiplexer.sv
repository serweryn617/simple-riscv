module multiplexer #(
    parameter int WIDTH = 32,
    parameter int NUM_INPUTS = 32
)(
    input  logic [NUM_INPUTS-1:0][WIDTH-1:0] in,
    input  logic [$clog2(NUM_INPUTS)-1:0] sel,
    output logic [WIDTH-1:0] out
);

    always_comb begin
        out = in[sel];
    end

endmodule
