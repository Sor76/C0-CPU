ENTRY(_start)

MEMORY
{
    ROM     (rx)    : ORIGIN = 0x00000000, LENGTH = 256K
    RAM     (rw)    : ORIGIN = 0x40000000, LENGTH = 256K
    LCD     (w)     : ORIGIN = 0x80000000, LENGTH = 4
    BUTTON  (r)     : ORIGIN = 0xC0000000, LENGTH = 4
}

SECTIONS
{
    PROVIDE(_rom_origin = ORIGIN(ROM));
    PROVIDE(_ram_origin = ORIGIN(RAM));
    PROVIDE(_lcd_origin = ORIGIN(LCD));
    PROVIDE(_button_origin = ORIGIN(BUTTON));

    .text :
    {
        . = ALIGN(4);
        *(.text)
        *(.text*)
        *(.rodata)
        *(.rodata*)
        . = ALIGN(4);

        _etext = .;
    } > ROM

    .data :
    {
        . = ALIGN(1);
        _sdata = .;
        *(.data)
        *(.data*)
        . = ALIGN(1);

        _edata = .;
    } > RAM AT > ROM

    .bss :
    {
        . = ALIGN(1);
        *(.bss)
        *(.bss*)
        . = ALIGN(1);
    } > RAM

    .stack :
    {
        . = ALIGN(16);
        _stack_bottom = .;
        . += 0x1000;
        _stack_top = .;
    }
}