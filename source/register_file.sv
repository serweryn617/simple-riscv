module register_file (
    input logic clk,
    input logic rd,
    input logic wr,
    input logic [4:0] addr,
    inout wire [31:0] bus
);

    logic [31:0] regs [0:31];

     initial begin
        regs[0] = 32'h0;
        regs[1] = 32'h0;
        regs[2] = 32'h0;
        regs[3] = 32'h0;
        regs[4] = 32'h0;
        regs[5] = 32'h0;
        regs[6] = 32'h0;
    end
     
    always_ff @(posedge clk) begin
        if (wr && addr != 0) begin
            regs[addr] <= bus;
        end
    end

    assign bus = (rd) ? regs[addr] : 'z;

endmodule
