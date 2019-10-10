# asm-test

This is a personal project on which I try to learn x86 assembly
I'm using AT&T syntax

I used this tutorial/this site to get started : https://wiki.osdev.org/User:Zesterer/Bare_Bones

### Compiling/Assembling
`i686-elf-gcc -std=gnu99 -ffreestanding -g -c start.s -o obj/start.o`
`i686-elf-gcc -ffreestanding -nostdlib -g -T linker.ld obj/start.o -o bin/kernel.elf -lgcc`

### Running
`qemu-system-i386 -kernel kernel.elf`