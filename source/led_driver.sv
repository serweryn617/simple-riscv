module led_driver (
    input logic clk,
    input logic rd,
    input logic wr,
    inout wire [31:0] bus,
    output logic [7:0] leds
);

    logic [7:0] led_reg = '0;

    always_ff @(posedge clk) begin
        if (wr) begin
            led_reg <= bus[7:0];
        end
    end

    assign bus = (rd) ? {24'b0, led_reg} : 'z;
    assign leds = led_reg;

endmodule
