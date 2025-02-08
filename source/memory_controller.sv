module memory_controller (
    input logic clk,
    input logic load,
    input logic rd,
    input logic wr,
    inout wire [31:0] bus,
    output logic [7:0] leds
);

    localparam ROM_BASE_ADDR = 32'h0000_0000;
    localparam RAM_BASE_ADDR = 32'h0000_0040;
    localparam LED_BASE_ADDR = 32'h0000_0080;

    // 0x1000 = 4KiB
    localparam ROM_SIZE = 32'h0000_0040;
    localparam RAM_SIZE = 32'h0000_0040;
    localparam LED_SIZE = 32'h0000_0001;

    logic [31:0] addr;
    logic [31:0] rom_word_addr;
    logic [31:0] ram_word_addr;

    always_comb begin
        rom_word_addr = (addr - ROM_BASE_ADDR) >> 2;
        ram_word_addr = (addr - RAM_BASE_ADDR) >> 2;
    end

    logic rd_rom;
    logic rd_ram;
    logic wr_ram;
    logic rd_led;
    logic wr_led;

    rom rom_inst (
        .rd(rd_rom),
        .addr(rom_word_addr),
        .bus(bus)
    );

    memory ram_inst (
        .clk(clk),
        .rd(rd_ram),
        .wr(wr_ram),
        .addr(ram_word_addr),
        .bus(bus)
    );

    led_driver led_inst (
        .clk(clk),
        .rd(rd_led),
        .wr(wr_led),
        .bus(bus),
        .leds(leds)
    );

    always_ff @(posedge clk) begin
        if (load) begin
            addr <= bus;
        end
    end

    always_comb begin
        rd_rom = 0;
        rd_ram = 0;
        wr_ram = 0;
        rd_led = 0;
        wr_led = 0;

        if (/*addr >= ROM_BASE_ADDR &&*/ addr < (ROM_BASE_ADDR + ROM_SIZE)) begin
            rd_rom = rd;
        end else if (addr >= RAM_BASE_ADDR && addr < (RAM_BASE_ADDR + RAM_SIZE)) begin
            rd_ram = rd;
            wr_ram = wr;
        end else if (addr >= LED_BASE_ADDR && addr < (LED_BASE_ADDR + LED_SIZE)) begin
            rd_led = rd;
            wr_led = wr;
        end
        // else begin
        //     bus = (rd) ? 32'hC01D_C0FE : 32'bz;
        // end
    end

endmodule
