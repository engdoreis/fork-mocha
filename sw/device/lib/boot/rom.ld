
OUTPUT_ARCH(riscv)

INCLUDE memory.ld

MEMORY {
    rom   (RWX) : ORIGIN = ORIGIN(ROM) , LENGTH = (LENGTH(ROM))
    ram   (RWX) : ORIGIN = ORIGIN(SRAM), LENGTH = (LENGTH(SRAM))
}

_stack_len = 0x1000; /* 4 KiB */

/* Provided in init_vectors.S, immediately jumps into _start. */
ENTRY(_init_vector)

SECTIONS {
    .init_vectors ORIGIN(rom) : {
        *(.init_vectors)
    } > rom

    .text : {
        . = ALIGN(8);
        *(.text)
        *(.text.*)
        . = ALIGN(8);
    } > rom

    .rodata : {
        . = ALIGN(8);
        /* Small rodata before large rodata */
        *(.srodata)
        *(.srodata.*)
        *(.rodata)
        *(.rodata.*)
        . = ALIGN(8);
    } > rom

    /* capability relocation entries */
    /* __start___cap_relocs and __stop___cap_relocs are provided by the toolchain */
    __cap_relocs : {
        *(__cap_relocs)
        . = ALIGN(8);
    } > rom

    .data : {
        . = ALIGN(8);

        _data_start = .;
        _data_init_start = LOADADDR(.data);
        /* Small data before large data */
        *(.sdata)
        *(.sdata.*)
        *(.data)
        *(.data.*)
        . = ALIGN(8);

        _data_end = .;
        _data_init_end = LOADADDR(.data) + SIZEOF(.data);

    } > ram AT> rom

    .bss : {
        . = ALIGN(8);
        _bss_start = .;
        _sbss = .; /* Rust */
        /* Small bss before large bss */
        *(.sbss)
        *(.sbss.*)
        *(.bss)
        *(.bss.*)
        *(COMMON)
        . = ALIGN(8);
        _ebss = .; /* Rust */
        _bss_end = .;
    } > ram

    .got : {
        . = ALIGN(8);
        *(.got)
        *(.got.*)
        . = ALIGN(8);
    } > rom

    . = ALIGN(1024);
    .stack : {
        . = ALIGN(1024);
        _stack_bottom = .;
        . = . + _stack_len;
        _stack_top = .;
    } > ram
    . = ALIGN(8);
}
