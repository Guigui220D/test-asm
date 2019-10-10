
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
		
		mov $message2, %esi
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
	//%ah will be the vga color that's used (0x0B)
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
	put_char:
		cmp $'\n, %al
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
			push %eax
			push %edx
			
			mov $cur_pos_x, %eax 
			mov $0, %edx
			mov %edx, (%eax)	//Set the column to 0
			
			mov $cur_pos_y, %eax 
			mov (%eax), %edx
			inc %edx		//Increment the line
			mov %edx, (%eax)
			
			pop %edx
			pop %eax
			//jmp ptc_next
		ptc_next:
		
		push %eax
		push %edx
		
		mov $cur_pos_x, %eax 	
		mov (%eax), %edx
		cmp $VGA_WIDTH, %edx
		jne ptc_skip_x_reset
			mov $0, %edx
			mov %edx, (%eax)	//Set the x cursor pos to 0 if it's at the end of the line
		ptc_skip_x_reset:
		
		call calculate_cur_ptr
		
		cmp $VGA_BUF_END, %edx
		jne ptc_skip_xy_reset	//If the pointer reaches the end of the vga buffer
			mov $cur_pos_x, %eax
			mov $0, %edx
			mov %edx, (%eax)	//Set the x pos to 0
			mov $cur_pos_y, %eax
			mov $0, %edx
			mov %edx, (%eax)	//Set the y pos to 0
		ptc_skip_xy_reset:
			
		pop %edx
		pop %eax

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
        .string  "Hello, world\n How are you all, pals?\n"
	message2:
		.string "Im a looooooooooooooooooooooooooooong message.\na\nb\nc\nd\ne\n-\n-\n-\n-\n-\n-\n-\n-\n-\n-\n-\n-\n-\n-\n-\n-"
	//Note : .ascii doesn't add a null terminator whereas .string does
	
		
.section .data
	cur_pos_x:
		.long 0
	cur_pos_y:
		.long 0
	


