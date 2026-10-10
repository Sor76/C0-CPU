package ControlSignals_pkg;
    typedef enum logic [3:0] {
        // Arithmetic/Logic
        // MSB bit signified if the operation is the funct7/special imm variant of the funct3 operation.
        // The last three bits signified the operation.
        ADD     = 4'b0000,
        SUB     = 4'b1000,
        SLL     = 4'b0001,
        SLT     = 4'b0010,
        SLTU    = 4'b0011,
        XOR     = 4'b0100,
        SRL     = 4'b0101,
        SRA     = 4'b1101,
        OR      = 4'b0110,
        AND     = 4'b0111
    } ALUOp;
    typedef enum logic [2:0] {
        EQ  = 3'b000,
        NE  = 3'b001,
        LT  = 3'b100,
        GE  = 3'b101,
        LTU = 3'b110,
        GEU = 3'b111
    } ComOp;
    typedef enum logic [2:0] {
        // First bit or the MSB signify if the read is will be signed or unsigned extended.
        READ_OP_1_U_BYTE    = 3'b000,
        READ_OP_2_U_BYTES   = 3'b001,
        READ_OP_4_BYTES     = 3'b010,
        READ_OP_1_BYTE      = 3'b100,
        READ_OP_2_BYTES     = 3'b101,
        NO_READ_OP          = 3'b111
    } ReadOp;
    typedef enum logic [1:0] {
        WRITE_OP_1_BYTE,
        WRITE_OP_2_BYTES,
        WRITE_OP_4_BYTES,
        NO_WRITE_OP
    } WriteOp;
    typedef enum logic [1:0] {
        RDSRC_ALU_RESULT,
        RDSRC_NEXT_ADDRESS,
        RDSRC_DEVICE_READ_DATA
    } rdSrc;
    typedef enum logic {
        RD_WRITE,
        NO_RD_WRITE
    } rdWrite;

    typedef enum logic[1:0] {
        PCSRC_NEXT_ADDRESS,         // 00
        PCSRC_JUMP_ADDRESS,         // 01
        PCSRC_JUMP_JALR_ADDRESS,    // 10
        PCSRC_NULL                  // Value for resetting the CPU, so that the instruction mem grab the first one not the second.
    } PCSrc;

    typedef enum logic [1:0] {
        // Peripheral enum values must match the ID of each peripheral.
        DEVICE_DATA_SRC_DATA_MEM,
        DEVICE_DATA_SRC_LCD_CONTROLLER,
        DEVICE_DATA_SRC_BUTTON_CONTROLLER,
        DEVICE_DATA_SRC_NONE
    } DeviceDataSrc;
endpackage