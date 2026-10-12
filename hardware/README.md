# Generating Project
Open up Vivado. In the bottom, there should be Tcl Console opened already. In the Console, `cd` in to this directory (run `cd PATH_TO_REPO/C0-CPU/hardware`) then run `source ./C0_vivado.tcl`. The project should be generated automatically and open up for you.

By default, the generated project will use `xc7z020clg400-2` as the chip, so don't forget to change the chip to match your part. The same for the `const.xdc` file in constraints directory.

# Programming
This could be done by making a `.mem` file (there is already a `program.mem` file in programs directory), which is a hex file (big-endian) with 4 bytes per line, each byte is separate by a space. I'm currently testing whether the RISC-V GNU toolchain can compile into hex file that this CPU could understand or not. There are quite a bit of changes between my architecture and RISC-V.

Using other `.mem` file other than `program.mem` required changing `PROGRAM_NAME` localparam in Top module header file to match the `.mem` file, and have to be added to Vivado project manually.

Currently, I write assembly first (`program.s`) then compile (with my 2 hands) into binary file (`program.bin` and `program_no_space.bin`) then turn into hex file (`program_big_endian.mem`), and switch the endianess into big-endian (`program.mem`). It was very painful.

# Synthesising
If you use other chip other than `xc7z020clg400-2` with lower BRAM resource, you must change 2 localparams in Top module header, which is `INSTRUCTION_MEM_ADDRESS_WIDTH` and `DATA_MEM_ADDRESS_WIDTH`, so that the BRAM consumption wouldn't go over what your chip can provide.