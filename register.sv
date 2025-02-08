module register #(
    parameter WIDTH = 8
) (
    input clk,
    input rst,
    input load,
    input [WIDTH-1:0] in,
    output logic [WIDTH-1:0] out
);

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        out <= '0;
    end
    else if (load) begin
        out <= in;
    end
end

endmodule
