`timescale 1ns/1ps

module IFIDReg
    import Types_pkg::*;
(
    input   Word instruction,
    input   Word address,

    output  Word instruction_register,
    output  Word address_register
);
    assign instruction_register = instruction;
    assign address_register = address;
endmodule