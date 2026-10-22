This note is for making the next CPU, it could be optimization or any idea.
1. ALU Optimization
    - The ALUOp Control Signal could cut all branch operation to instead use pure math operation. There would have to be a change to JmpHandler for interpreter the ALU's result, maybe adding additional bit to JmpOp Control Signal for signifying the branch operation condition could be one of the way.
2. Memory
    - Use Byte addressable instead of Word addressable. (Modern standard and more efficient in variable data size access)
    - Could do the streaming operator in the same module as the controller now, and move the mux and bit extender back to the WB stage. Thanks to the limitation of BRAM for bringing this idea.
    - Add another port to the instruction memory, so that the `.rodata` and `.data` section could store data into the instruction memory and load it.