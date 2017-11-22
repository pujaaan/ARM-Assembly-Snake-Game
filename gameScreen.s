.globl 	backGround
.globl	brickLocation

backGround:

	px		.req	r6
	py		.req	r7
	addr	.req	r8
	ldr		addr, =gameBackground
	mov		px, #0
	mov		py, #0
	ldr     r9, =1023
	ldr		r10, =767
	
backGroundLoop:
	bl		drawCell
	add		px, #31	
	cmp		px, r9
	blt		backGroundLoop
	
	mov		px, #0
	
	cmp		py, r10
	add		py, #31
	
	blt		backGroundLoop		
	

gameScreen:

	mov		r4, #0
	
	mov		px, #32
	mov		py, #32

	ldr		addr, =brick
gameScreenLoopX1:	
	bl      drawCell
	add		px, #31
	cmp		r4, #31
	add		r4, #1
	ble		gameScreenLoopX1
	ldr		py, =736
	mov		px, #0	
	mov		r4, #0

	
gameScreenLoopX2:
	bl      drawCell
	add		px, #31
	cmp		r4, #31
	add		r4, #1
	ble		gameScreenLoopX2	
	mov		px, #0
	mov		py, #32
	mov     r4, #0
gameScreenLoopY1:
	bl      drawCell
	add		py, #31
	cmp		r4, #21
	add		r4, #1
	ble		gameScreenLoopY1	
	ldr		px, =992
	mov		py, #32
	mov     r4, #0
	
gameScreenLoopY2:
	bl      drawCell
	add		py, #31
	cmp		r4, #21
	add		r4, #1
	ble		gameScreenLoopY2	


drawBlock:
	ldr		r11, =brickLocation
drawBlockLoop:
	ldr		px, [r11], #4
	cmp		px, #0
	popeq	{r4 - r11}
	beq		printLives
	ldr		py, [r11], #4
	bl		drawCell
	
	b		drawBlockLoop

printLives:
	ldr		r8, =livesImage
	ldr		px, =608
	mov		py, #0
	ldr		r9, =159
	ldr		r10, =31
	bl		drawGame
	ldr		r1, =lifeCounter
	ldr		r0, [r1]
	mov		r6, r0
	bl      lifePrint

	cmp		r6, #5
	bge		printScore	
	blt		door
door:
	ldr		r5, =doorLocation
	ldr		r6, [r5]
	ldr		r7, [r5, #4]
	ldr		r8, =blank
	bl		drawCell

	
printScore:
	ldr		r8, =scoreImage
	ldr		px, =96
	mov		py, #0
	ldr		r9, =159
	ldr		r10, =31
	bl		drawGame
	
	ldr		r1, =score
	ldr		r0, [r1]

	mov		r1, #10
	bl		div
	mov		r5, r0
	
	mov		r0, r1
	ldr		r6, =256
	bl		scorePrint
	
	mov		r0, r5
	mov		r1, #10
	
	bl		div	
	mov		r0, r1
	ldr		r6, =224
	
	bl		scorePrint

	ldr		r0, =pauseFlag
	ldr		r1, [r0]
	cmp		r1, #1
	beq		paused
	
	b		snakePrintInitial
paused:
	ldr		r11, =tracker
	ldr		r9, [r0, #8]
	ldr		r10, [r0, #12]

pausedPrintSnake:
	ldr		r6, [r11, r10]
	add		r10, #4
	ldr		r7, [r11, r10] 
	add		r10, #4
	ldr		r8, =snakeHead
	bl		drawCell
	
	cmp		r10, r9
	blt		pausedPrintSnake
	

returnFromPaused:
	sub		r9, #4
	ldr		r5, [r11]
	sub		r9, #9
	ldr		r4, [r11]
	ldr		r0, =pauseFlag
	ldr		r1, [r0, #4]
	ldr		r9, [r0, #8]
	ldr		r10, [r0, #12]



	cmp		r1, #5			// if r1 = 5
	beq 	snakeUp			// branch to snakeUp

	cmp		r1, #6			// if r1 = 6
	beq 	snakeDown		// branch to snakeDown
	
	cmp		r1, #7			// if r1 = 7
	beq 	snakeLeft		// branch to snakeLeft	
	
	cmp		r1, #8			// if r0 = 8
	beq     snakeRight		// branch to snakeRight
	





.section	.data
brickLocation:
	.word	192, 256, 224, 288
	.word    800, 256, 768, 288
	.word	 224, 480, 192, 512
	.word	768, 480,  800, 512
	.word	0



