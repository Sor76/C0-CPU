`timescale 1ns/1ps

module DirectButtonController
    import Types_pkg::*;
#(
    parameter int BUTTON_COUNT  = 5,            // Number of buttons wired directly to pins (1 - 32).
    parameter int TARGET_MS     = 20,           // Debounce time in ms.
    parameter int CLOCK_RATE    = 50_000_000,
    parameter bit ACTIVE_LOW    = 0             // 1 = pull-up button (pressed = 0).
) (
    input   logic                       clk,
    input   logic                       rst_n,
    input   logic                       device_select,  // Read only device, so it is unused for now.
    output  Word                        data_out,
    input   logic [BUTTON_COUNT-1:0]    button_in
);
    // Button state register. Read-only.
    // Bit n of data_out is 1 while button n is held down (debounced), 0 otherwise. Upper bits are always 0.
    // Unlike the ButtonController (matrix), this one reports every button at once, so multiple buttons can be read in a single load.
    // BUTTON_COUNT must not be more than 32 or the upper buttons will be cut off.

    // Dividing the clock down to 1000Hz (1 ms per pulse)
    localparam int CLOCK_PER_MS = CLOCK_RATE / 1000;
    logic [$clog2(CLOCK_PER_MS)-1:0] clk_counter = '0;
    logic tick_1ms = 0;
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            clk_counter <= '0;
            tick_1ms    <= 1'b0;
        end else begin
            tick_1ms <= 1'b0;
            if (clk_counter == CLOCK_PER_MS - 1) begin
                clk_counter <= '0;
                tick_1ms    <= 1'b1;
            end else begin
                clk_counter <= clk_counter + 1;
            end
        end
    end

    // Debouncing each button
    logic [BUTTON_COUNT-1:0] pressed;
    for (genvar i = 0; i < BUTTON_COUNT; i = i + 1) begin : g_debouncer
        Debouncer #(
            .TARGET_MS(TARGET_MS),
            .ACTIVE_LOW(ACTIVE_LOW)
        ) debouncer (
            .clk(clk),
            .rst_n(rst_n),
            .tick_1ms(tick_1ms),

            .raw_in(button_in[i]),
            .pressed(pressed[i])
        );
    end

    // Read operation
    assign data_out = Word'(pressed);
endmodule
