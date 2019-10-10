
.global start

.set VGA_BUF, 0xB8000
.set VGA_BUF_END, 0xB8FA0
.set VGA_HEIGHT, 25
.set VGA_WIDTH, 80

.set MB_MAGIC, 0x1BADB002          
.set MB_FLAGS, (1 << 0) | (1 << 1) 
.set MB_CHECKSUM, (0 - (MB_MAGIC + MB_FLAGS))
 
.section .multiboot
	.align 4
	.long MB_MAGIC
	.long MB_FLAGS
	.long MB_CHECKSUM
 
.section .bss
	.align 16
	stack_bottom:
		.skip 4096 // Reserve a 4096-byte (4K) stack
	stack_top:
	
	
 
// This section contains our actual assembly code to be run when our kernel loads
.section .text

	start:
		call init_vga
		mov $message, %esi
		call print
		
		hang:
			cli      // Disable CPU interrupts
			hlt      // Halt the CPU
			jmp hang // If that didn't work, loop around and try again.
	
	init_vga:
		call clear_screen
		
		ret
	
	//Input :
	//%esi : the pointer to the string
	//Output :
	//%esi will be changed
	//%al will be 0
	//%ah will be the vga color that's used (0xB0)
	print:
		mov $0x0B, %ah		//VGA Color
		print_loop:
			mov (%esi), %al	//Get the char at the index
			test %al, %al	
			je end_print	//Exit if character is 0
			call put_char	//Write the char
			inc %esi		//Increment the string pointer
			jmp print_loop
		end_print:
		ret
		
	//Input :
	//%al is the character to print
	//%ah is the vga color to be used
	//Output :
	//%
	put_char:
		cmp %al, '\n
		je ptc_return 
		ptc_char:
		//If it is any character except carret return
		call calculate_cur_ptr
		mov %ax, (%edx)	//Write the char
		
		push %eax
		push %edx
		
		mov $cur_pos_x, %eax 
		mov (%eax), %edx
		inc %edx		//Increment the column
		mov %edx, (%eax)
		
		pop %edx
		pop %eax
		
		jmp ptc_next
		ptc_return:
		//If it is a \n
		mov $cur_pos_x, %eax 
		mov $0, %edx
		mov %edx, (%eax)	//Set the column to 0
		
		mov $cur_pos_y, %eax 
		mov (%eax), %edx
		inc %edx		//Increment the line
		mov %edx, (%eax)
		//jmp ptc_next
		ptc_next:
		
		

		ret
	
	//Output :
	//%edx : the pointer
	calculate_cur_ptr:
		push %eax
		
		mov $cur_pos_x, %eax
		push %eax
		mov $cur_pos_y, %eax
		mov (%eax), %eax
		mov $VGA_WIDTH, %edx
		mul %edx
		
		mov %eax, %edx
		pop %eax
		mov (%eax), %eax
		add %eax, %edx 
		
		shl $1, %edx
		
		mov $VGA_BUF, %eax
		add %eax, %edx
		
		pop %eax
		ret
	
	clear_screen:
		mov $VGA_BUF, %edx
		mov $0x0B00, %ax
		clear_loop:
			cmp $VGA_BUF_END, %edx
			je end_clear
			mov %ax, (%edx)
			add $2, %edx
			jmp clear_loop
		end_clear:
		ret
	
			
.section .rodata
	message:
        .ascii  "Hello, world\n How are you all, pals?"
		
	
		
.section .data
	cur_pos_x:
		.long 0
	cur_pos_y:
		.long 0
	


