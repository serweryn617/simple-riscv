module alu (
    input logic clk,
    input logic wr,
    input logic rd,
    input logic [4:0] op,

    inout wire [31:0] bus
);

    logic [31:0] acc;
    logic [31:0] result;

    always_comb begin
        case (op)
            5'b00000: result = bus;

            5'b10000: result = bus + acc;
            5'b11000: result = bus - acc;
            5'b10001: result = bus << acc[4:0];
            5'b10010: result = (bus < acc) ? 1 : 0;
            5'b10011: result = ((unsigned'(bus) < unsigned'(acc)) ? 1 : 0);
            5'b10100: result = bus ^ acc;
            5'b10101: result = bus >> acc[4:0];
            5'b11101: result = bus >>> acc[4:0];
            5'b10110: result = bus | acc;
            5'b10111: result = bus & acc;

            5'b01000: result = {31'b0, bus == acc};
            5'b01001: result = {31'b0, bus != acc};
            5'b01100: result = {31'b0, bus < acc};
            5'b01101: result = {31'b0, bus >= acc};
            5'b01110: result = {31'b0, unsigned'(bus) < unsigned'(acc)};
            5'b01111: result = {31'b0, unsigned'(bus) >= unsigned'(acc)};

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
