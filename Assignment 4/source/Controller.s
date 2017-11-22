.globl 		Read_SNES
.globl 		buttons
.globl 		wait
.globl      Init_GPIO    
.section 	.text

main:
    mov    	sp, #0x8000 // Initializing the stack pointer
	bl		EnableJTAG // Enable JTAG
	bl		InitUART    // Initialize the UART

Init_GPIO:
	push	{lr}
	bl    	dataInit
	bl    	latchInit
	bl		clockInit
	pop		{lr}
	bx      lr
dataInit:
	ldr r0, =0x20200004			// load address into r0
	ldr r2, [r0]				// load value of r0 into r2	
	mov r3, #7				// move 7 into r3
	bic r2, r3
	str r2, [r0]				
	bx		lr
	
latchInit:
	ldr r0, =0x20200000			// load address into r0
	ldr r2, [r0]				// load value of r0 into r2
	mov r3, #7				// move 7 into r3
	lsl r3, #27				
	bic r2, r3
	mov r4, #1				//move 1 into r4
	lsl r4, #27
	orr r2, r4
	str r2, [r0]
	bx		lr
clockInit:
	ldr 	r0, =0x20200004			// load address into r0
	ldr		 r2, [r0]				// load value of r0 into r2
	mov 	r3, #7				// move 7 into r3
	lsl 	r3, #3				
	bic 	r2, r3
	mov 	r4, #1				//move 1 into r4
	lsl 	r4, #3
	orr 	r2, r4
	str		 r2, [r0]
	bx		lr
	

Write_Clock:

    mov     r0, #11					// pin number
	ldr		r2, =0x20200000 		// base GPIO reg
	mov 	r3, #1					// r3 = 1
	lsl 	r3, r0 					// align bit for pin#9
	teq 	r1, #0
	streq  	r3, [r2, #40] 			// GPCLR0
	strne 	r3, [r2, #28] 			// GPSET0  

	bx      lr						// return
Write_Latch:

    mov     r0, #9					// pin number
	ldr		r2, =0x20200000 		// base GPIO reg
	mov 	r3, #1					// r3 = 1
	lsl 	r3, r0 					// align bit for pin#9
	teq 	r1, #0
	streq  	r3, [r2, #40] 			// GPCLR0
	strne 	r3, [r2, #28] 			// GPSET0    
	bx      lr

Read_Data:

	mov     r0, #10					// pin number
    ldr 	r2, =0x20200000 		// base GPIO reg
    ldr 	r1, [r2, #52] 			// GPLEV0
    mov 	r3, #1
    lsl 	r3, r0 					// align pin10 bit
    and 	r1, r3 					// mask everything else
    teq 	r1, #0
    moveq 	r0, #0 					// return 0
    movne 	r0, #1 					// return 1
	bx      lr
	
wait:
	
    ldr 	r0, =0x20003004 		// address of CLO
    ldr 	r1, [r0] 				// read CLO
    add 	r1, r3 					// add 12 micros
waitLoop:
    ldr 	r2, [r0]
    cmp 	r1, r2 					// stop when CLO = r1

    bhi 	waitLoop	
	bx      lr



Read_SNES:
	push 	{r4 - r11, lr}
	
	ldr		r5, =buttons			// Load buffer
	
	push	{lr}					// Push onto stack
	mov     r1, #1                  // r1 = 1
	bl      Write_Clock             // Write clock
	pop		{lr}					// Pop onto stack
	
	push	{lr}					// Push onto stack
	mov     r1, #1                  // r1 = 1
	bl      Write_Latch             // Write latch
	pop		{lr}					// Pop onto stack
	
	push	{lr}					// Push onto stack
	mov     r3, #12					// Wait Time
	bl      wait					// Wait
	pop		{lr}					// Pop onto stack
	
	push	{lr}					// Push onto stack
	mov     r1, #0                  // r1 = 1
	bl      Write_Latch             // Write latch
	pop		{lr}					// Pop onto stack
	
	mov     r4, #0					// r4 = 0

pulseLoop:

	push	{lr}
	mov     r3, #6					// r3 = 6
	bl      wait					// Wait
	pop		{lr}
	
	push	{lr}					// Push onto stack
	mov     r1, #0                  // r1 = 0
	bl      Write_Clock             // Write clock
	pop		{lr}					// Pop onto stack
	
	push	{lr}					// Push onto stack	
	mov     r3, #6					// r3 = 6
	bl      wait					// Wait
	pop		{lr}					// Pop onto stack
	
	push	{lr}
	bl      Read_Data               // Read Data, get 0 or 1 in r0
	pop		{lr}
	strb    r0, [r5], #1  			// buttons[i] = r0 
	
	push 	{lr}
	mov     r1, #1                  // r1 = 1
	bl      Write_Clock             // Write clock	
	pop 	{lr}
	
	add     r4, #1					// r4 + 1
	cmp     r4, #16					// Loop
	
	blt     pulseLoop				// To pulse loop 
	ldr 	r5, =buttons
	mov		r1, #0
	mov     r0, #1					// Counter for the button pressed
	

check:
	ldrb	r1, [r5], #1			// Load a byte from the buffer
	cmp 	r1, #0					// See if a button was pressed 
	beq 	returnButton			// return
	add 	r0, #1					// r0 + 1
	cmp 	r0, #16					// loop this function
	bne 	check				
	
returnButton:
	pop		{r4 - r11, lr}
	bx      lr


haltLoop$:							// haltloop to end program
	b	haltLoop$


.section 			.data

buttons:
	.rept 16
	.byte 0
	.endr
	

