.globl		InterruptEnable
.globl      disableInterrupt
.globl		Timer
.globl		waitingTime
.globl		IntTable
.globl      InstallIntTable
.globl      waitEnable
		// enable interrupt
		InterruptEnable:	
					push {lr}
					// enable IRQ
					MRS r0, cpsr
					bic r0, #0x80
					MSR cpsr_c, r0
					pop {pc}
					
			// enable timer interrupt		
		disableInterrupt:	
					push 	{lr}

					ldr 	r0, =0x2000b21C 			// Disable IRQ register 1
					mov 	r1, #2  					// bit #1
					str 	r1, [r0] 						//Actually disables C1
				
				
				
					ldr 	r0, =0x20003004 				// Timer
					ldr 	r0, [r0]  

				//	sub 	r0, #1				//Wtf does this do and why?
				
					ldr 	r1, =0x20003010 		//C1
					str 	r0, [r1]				//Store the wtf  into this, triggering an interrupt right now?
													// Furthermore, you never actually disabled the interrupt. you just triggered it.
					//To disable
					
					pop 	{pc}
					
		waitEnable:
		ldr     r0, =0x2000B210          					//IRQ ENABLE 1 (?)   
		mov     r1, #0x2                    //2
		str     r1, [r0]                   //Enables IRQ.
		bx		lr                     		
		
		
		// how long it waits before interrupt
		waitingTime:
				push 	{lr}
				
				ldr 	r1, =0x20003004 		//Sys low(?)
				ldr 	r1, [r1]  						

				add 	r0, r1 							//Adds to delay

				ldr 	r1, =0x20003010 		//C1
				str 	r0, [r1]				//Set timer delay.
				pop 	{lr}				
				bx		lr

				
		//the IRQ part
		IRQ:
			push 	{r4-r11,lr}
			
			//May want to disable IRQ's?
			
			ldr		r0, =0x20003000			//CS1
			ldr		r1, [r0]			
			cmp		r1, #0					
			beq		irqEnd
					
		generateValuePack:
			bl 		randomNumber
			ldr		r2, =randomLocation
			ldr		r6, [r2]
			ldr		r7, [r2, #4]
			ldr		r2, =valuePack
			str		r6, [r2]
			str		r7, [r2, #4]	
			ldr		r8, =heart
			bl		drawCell
			
			ldr 	r0, =0x20003000	 // clear bit of c1 ((not neccissarly the detected bit))
			mov	 	r1, #2 	
			str 	r1, [r0]			
			
			ldr		r1,	[r0]			//A test, clears all system timer detected bits.
			str		r1,	[r0]

        irqEnd:
        
				
				
					pop {r4-r11, lr}

					subs pc, lr, #4



			
		InstallIntTable:
					ldr  r0, =IntTable
					mov r1, #0x00000000
					
					// load the first 8 words and store at the 0 address
					ldmia	r0!, {r2-r9}
					stmia	r1!, {r2-r9}

					// load the second 8 words and store at the next address
					ldmia	r0!, {r2-r9}
					stmia	r1!, {r2-r9}
					
					// switch to IRQ mode and set stack pointer
					mov		r0, #0xD2
					msr		cpsr_c, r0
					mov		sp, #0x8000

					// switch back to Supervisor mode, set the stack pointer
					mov		r0, #0xD3
					msr		cpsr_c, r0
					mov		sp, #0x8000000

					bx		lr


        hang:
					b   hang
					
			.section .data
		.align	4
		IntTable:
					// Interrupt Vector Table (8 words)
					ldr		pc, reset_handler
					ldr		pc, undefined_handler
					ldr		pc, swi_handler
					ldr		pc, prefetch_handler
					ldr		pc, data_handler
					ldr		pc, unused_handler
					ldr		pc, irq_handler
					ldr		pc, fiq_handler

			//Jump Locations (8 words)
		reset_handler:		.word hang
		undefined_handler:	.word hang
		swi_handler:		.word hang
		prefetch_handler:	.word hang
		data_handler:		.word hang
		unused_handler:		.word hang
		irq_handler:		.word IRQ
		fiq_handler:		.word hang

