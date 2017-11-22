.section    .init
.globl     	_start
.globl		drawGame
.globl		drawCell
.globl 		haltLoop$ 
 
_start:
    b       main
    
.section .text

main:
    mov     sp, #0x8000
	
	bl		EnableJTAG

	bl		InitFrameBuffer

	
	mov	 	r1, #9					// latch line
	bl 		Init_GPIO				// Branch Init-GPIO
							
	mov		r1, #10					// data line
	bl 		Init_GPIO				// Branch Init-GPIO
	
	mov 	r1, #11					// Clock line
	bl		Init_GPIO               // Branch Init-GPIO

	ldr		r0, =doorLocation
	mov		r1, #0
	str		r1, [r0]
	str		r1, [r0, #4]


	ldr		r0, =pauseFlag
	mov		r1, #0
	str		r1, [r0]
	
	ldr		r0, =lifeCounter
	mov		r1, #5
	str		r1, [r0]

	
	
	ldr		r1, =score
	mov		r0, #0
	str		r0, [r1]

	ldr		r6, =256
	bl		scorePrint
	

	ldr		r6, =224
	bl		scorePrint

	b   	backGround				// Temp
	
	px		.req	r6				// px represents r6
	py		.req	r7				// py represents r7
	addr	.req	r8				// addr represents r8
	xSize   .req	r9				// xSize represents r9
	ySize	.req	r10				// ySize represents r10
	
//	ldr		addr, =startScreen		// load address for startScreen
	mov		px, #0					// set x coordinate
	mov		py, #0					// set y coordinate
	ldr     r9, =1023				// set x size
	ldr     r10, =767				// set y size
	
//	bl		drawGame				// branch to drawGame

	ldr		addr, =arrow			// load the addres of arrow
	ldr		px, =430				// px = 430
	ldr		py, =616				// py = 616
	ldr     r9, =31					// r9 = 31
	ldr     r10, =31				// r10 = 31
	
	bl		drawGame				// branch drawGame
		
	b 		arrowInit				// branch always to arrowInit
    
haltLoop$:
	b		haltLoop$


drawGame:
	push		{r3-r11, lr}
	px			.req	r6				// px represents r6
	py			.req	r7				// py represents r7
	addr		.req	r8				// addr represents r8
	xSize   	.req	r9				// xSize represents r9
	ySize		.req	r10				// ySize represents r10
	img			.req	r2				// img	represents r2
	counterX	.req	r5				// counterX represents r5
	counterY	.req	r11				// counterY represents r11
	
	mov		r4, px						// r4 = px
	
	mov		counterX, #0				// initialize counters
	mov		counterY, #0
drawGameLoop: 

	ldrh	img, [addr], #2				// load 2 bytes from addr
	

	mov		r0 ,px						// r0 = px
	mov		r1, py						// r1 = py

	bl      DrawPixel					// branch to DrawPixel
	
	cmp     counterX, xSize				// if counterX = xSize
	add		counterX, #1     			// counterX +=1
	add		px, #1						// px +=1
	blt		drawGameLoop				// branch to drawGameLoop
	
	mov     px, r4						// px = r4
	mov     counterX, #0				// counterX = 0

	
	cmp     counterY, ySize				// if counterX = xSize
	add     py, #1						// py += 1
	add     counterY, #1				// counterY += 1
	blt     drawGameLoop				// drawGameLoop
	pop		{r3-r11, lr}
	bx      lr


drawCell:
	push		{r3-r11, lr}
	px			.req	r6				// px represents r6
	py			.req	r7				// py represents r7
	addr		.req	r8				// addr represents r8
	
	img			.req	r2				// img	represents r2
	counterX	.req	r5				// counterX represents r5
	counterY	.req	r11				// counterY represents r11
	
	mov		r4, px						// r4 = px
	
	mov		counterX, #0				// initialize counters
	mov		counterY, #0
drawCellLoop: 

	ldrh	img, [addr], #2				// load 2 bytes from addr
	

	mov		r0 ,px						// r0 = px
	mov		r1, py						// r1 = py

	bl      DrawPixel					// branch to DrawPixel
	
	cmp     counterX, #31				// if counterX = xSize
	add		counterX, #1     			// counterX +=1
	add		px, #1						// px +=1
	blt		drawCellLoop				// branch to drawGameLoop
	
	mov     px, r4						// px = r4
	mov     counterX, #0				// counterX = 0

	
	cmp     counterY, #31				// if counterX = xSize
	add     py, #1						// py += 1
	add     counterY, #1				// counterY += 1
	blt     drawCellLoop				// drawGameLoop
	pop		{r3-r11, lr}
	bx      lr





arrowInit:	
	px		.req	r6				// px represents r6
	py		.req	r7				// py represents r7
	addr	.req	r8				// addr represents r8
	xSize   .req	r9				// xSize represents r9
	ySize	.req	r10				// ySize represents r10
	moveq	r5, #0					// set the counter

arrowControl:
	mov		r0, #0					// make r0 = 0
	bl   	Read_SNES				// Call Read_SNES
	
	mov     r4, r0					// copy r0 into r4
arrowControlLoop:	
	cmp		r0, #16					// if r0 = 16
	beq		arrowControl			// branch if it is	
		
	cmp		r4, #9					// if r4 = 9 					
	beq		aPressed				// branch if it is
	
	cmp     r4, #5					// if r4 = 5
	ldreq	px, =430				// px = 430 if it is
	ldreq	py, =616				// py = 616 if it is
	moveq	r5, #1					// r5 = 1 if it is
	beq		draw					// branch to draw if it is
	
	
	
	cmp		r4, #6					// if r4 = 6
	ldreq	px, =430				// px = 430 if it is
	ldreq	py, =661				// py = 661	if it is
	moveq	r5, #2					// r5 = 2 if it is
	beq		draw					// branch to draw if it is
	

	b       arrowControl			// branch always arrowControl
draw:
	
	mov		xSize, #31				// xSize = 31
	mov		ySize, #31				// ySize = 31
	ldr		addr, =arrow			// load the address of arrow
	bl      drawGame				// branch drawGame
	
replace:
	cmp		r5, #1					// if r5 = 1
	ldreq	px, =430				// px = 430
	ldreq	py, =661				// py = 661
	
	cmp		r5, #2					// if r5 = 2
	ldreq	px, =430				// px = 430
	ldreq	py, =616				// py = 616
	cmp		r5, #0					// if r5 = 0
	beq		arrowControl			// branch if equal
	
	mov		xSize, #31				// xSize = 31
	mov		ySize, #31				// ySize = 31
	ldr		addr, =blank			// load address of blank
	bl      drawGame				// branch to drawGame
	b		arrowControl			// branch always to arrowControl
	
	mov		r11, r5
	
aPressed:
	cmp		r5, #0					// 
	beq		backGround	 			// 
	cmp     r5, #1
	beq		backGround				// temp
	cmp		r5, #2
	beq		arrowControl
	
