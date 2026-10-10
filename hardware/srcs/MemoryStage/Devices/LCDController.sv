`timescale 1ns/1ps

module LCDController
    import ControlSignals_pkg::*;
    import Types_pkg::*;
(
    input   logic         clk,
    input   logic         rst_n,

    input   logic        device_select,
    input   Word         write_data,
    input   WriteOp      validated_write_op,

    output  Word         data_out,

    output  logic [7:0]  lcd_write_data,
    output  logic        lcd_rs,
    output  logic        lcd_e
);
    // The most barebone form it could be.
    // The write_data contains both data, rs and e signal for the LCD.
    // MEM_WRITE_1_BYTE is only for 4-bits write mode of the LCD, while the other two are available for both 4-bits and 8-bits mode.
    // 
    // In 4-bits mode, the last 4-bits of the write_data will goes into d0 - d3 of the LCD (LSB of write_data is d0, while MSB is d3).
    // The fifth bit (write_data[4]) is for rs signal, and the sixth bit (write_data[5]) is for e signal.
    // 
    // In 8-bits mode, it is similar to 4-bits mode. The last 8-bits of write_data will goes into d0 - d7 of the LCD. It is also
    // organzie the same way as the 4-bits mode. The ninth bit of the write_data is for rs signal, and tenth bit is for e signal.
    // 
    // Note: Every signals must be managed by the programmer because it is barebone. This include manually switching e signal.
    //       When changing the write mode, the programmer must also manually send the instruction to the LCD to switch the mode.
    // 
    // Originally, I've planned this to fully controls the working of LCD, but I've a lot of fun driving the LCD without I2C
    // or any libraries. So, barebone it is.
    
    // Read operation
    assign data_out = '0;

    // Write operation / Reset
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            lcd_write_data  <= '0;
            lcd_rs          <= 0;
            lcd_e           <= 0;
        end else if (device_select && validated_write_op != NO_WRITE_OP) begin 
            case (validated_write_op)
                WRITE_OP_1_BYTE: begin
                    lcd_write_data  <= $unsigned(write_data[3:0]);
                    lcd_rs          <= write_data[4];
                    lcd_e           <= write_data[5];
                end
                WRITE_OP_2_BYTES, WRITE_OP_4_BYTES: begin
                    lcd_write_data  <= write_data[7:0];
                    lcd_rs          <= write_data[8];
                    lcd_e           <= write_data[9];
                end
                default: begin
                    lcd_write_data  <= '0;
                    lcd_rs          <= '0;
                    lcd_e           <= '0;
                end
            endcase
        end
    end
endmodule