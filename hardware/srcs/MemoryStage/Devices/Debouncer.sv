`timescale 1ns/1ps

module Debouncer #(
    parameter int TARGET_MS     = 20,   // The input must disagree with the output for this many ms before the output follows it.
    parameter bit ACTIVE_LOW    = 1     // 1 = pull-up button (pressed = 0), 0 = pull-down button (pressed = 1).
) (
    input   logic   clk,
    input   logic   rst_n,
    input   logic   tick_1ms,           // One clock cycle pulse every 1 ms. Shared between every debouncer.

    input   logic   raw_in,             // Asynchronous input straight from the pin.
    output  logic   pressed             // Debounced output, always active high.
);
    // How it works
    // 1. raw_in is asynchronous, so it goes through 2 flip-flops first to prevent meta-stability.
    // 2. The synchronized value is compared with the current debounced output.
    //    - Same: nothing is pending, the timer stays at 0.
    //    - Different: the timer counts every ms. When it reaches TARGET_MS, the output follows the input.
    // 3. If the input bounces back before the timer finishes, both agree again and the timer is reset.
    // Pressing and releasing are handled the same way.

    logic [1:0]                         sync;
    logic                               level;      // Synchronized input, converted to active high.
    logic [$clog2(TARGET_MS+1)-1:0]     ms_timer;

    assign level = ACTIVE_LOW ? ~sync[1] : sync[1];

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            sync        <= ACTIVE_LOW ? 2'b11 : 2'b00;  // Idle level, so reset doesn't look like a press.
            ms_timer    <= '0;
            pressed     <= 1'b0;
        end else begin
            sync <= {sync[0], raw_in};

            if (level == pressed) begin
                ms_timer <= '0;
            end else if (tick_1ms) begin
                if (ms_timer == TARGET_MS - 1) begin
                    pressed     <= level;
                    ms_timer    <= '0;
                end else begin
                    ms_timer    <= ms_timer + 1;
                end
            end
        end
    end
endmodule
