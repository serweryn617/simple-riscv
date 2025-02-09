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
            4'b1001: result = bus << acc[4:0];
            4'b1010: result = (bus < acc) ? 1 : 0;
            4'b1011: result = ((unsigned'(bus) < unsigned'(acc)) ? 1 : 0);
            4'b1101: begin
                if (acc[10]) begin
                    result = bus >>> acc[4:0];
                end else begin
                    result = bus >> acc[4:0];
                end
            end
            4'b1100: result = bus ^ acc;
            4'b1110: result = bus | acc;
            4'b1111: result = bus & acc;

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
