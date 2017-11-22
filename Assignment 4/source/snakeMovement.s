.globl		snakePrintInitial
.globl      lifeCounter
.globl      score
.globl      snakeUp
.globl      snakeDown
.globl      snakeLeft
.globl      snakeRight
.globl      pauseFlag
.globl      div
.globl      doorLocation
.globl      tracker
.globl      randomNumber
.globl      valuePack
.globl      randomLocation
.globl		appleLocation
snakePrintInitial:
	bl		InterruptEnable			//Enable CPSR

	ldr		r0, =30000000			//Set the timer.
	bl		waitingTime
	
	bl      waitEnable				//Enable after there is a time set.
	ldr		r11, =tracker
	mov		r9, #0					// Set the head pointer
	ldr		r4, =64
	ldr		r5, =640
	
	mov		r6, r4
	mov		r7, r5
	
	ldr		r8, =snakeHead
	bl		drawCell
	
	str		r4, [r11, r9]			// Store into the queue
	add		r9, #4
	str		r5, [r11, r9]			// Store into the queue
	add		r9, #4



	ldr		r4, =96
	ldr		r5, =640
	
	mov		r6, r4
	mov		r7, r5
	
	ldr		r8, =snakeHead
	bl		drawCell

	str		r4, [r11, r9]			// Store into the queue
	add		r9, #4
	str		r5, [r11, r9]			// Store into the queue
	add		r9, #4

	ldr		r4, =128
	ldr		r5, =640
	
	mov		r6, r4
	mov		r7, r5
	
	ldr		r8, =snakeHead
	bl		drawCell

	str		r4, [r11, r9]			// Store into the queue
	add		r9, #4
	str		r5, [r11, r9]			// Store into the queue
	add		r9, #4

	mov		r10, #0					// Set the tail pointer 
	
	
	bl		randomNumber
	

	
	ldr		r2, =randomLocation		// Load Random Location	
	ldr		r6, [r2]				// Load
	ldr		r7, [r2, #4]			// Store
	ldr		r2, =appleLocation		// Load Apple Location	
	str		r6, [r2]				// Store Coordinates
	str		r7, [r2, #4]
	
	mov		r2, #0
	bl		printApple
	
	
	b		snakeMovement

queueReset:						
	push	{r6, r7, lr}
	mov		r2, #0
	
resetLoop:

	cmp		r10, r9					// Compare Head To Tail
	
	ldrlt	r6, [r11, r10]			// Replace the coordinates 
	strlt	r6, [r11, r2]
	
	addlt	r10, #4
	addlt	r2, #4
	
	ldrlt	r7, [r11, r10]
	strlt	r7, [r11, r2]
	
	addlt	r10, #4
	addlt	r2, #4
	
	blt		resetLoop
	mov		r9, r2
	mov		r10, #0
	pop		{r6, r7, lr}
	bx      lr
storeQueue:
	push	{r4 - r8, lr}
	

	
	str		r4, [r11, r9]			// Store into the queue
	add		r9, #4
	str		r5, [r11, r9]			// Store into the queue
	add		r9, #4
	
	cmp		r9, #296
	blt		snakePrint


	bl		queueReset


	
snakePrint:
	
	mov		r6, r4
	mov		r7, r5
	

	mov		r0, r6
	mov		r1, r7
	
	bl		collision

	cmp		r0, #3
	beq		printGameWon

		

	cmp		r0, #-1
	ldreq	r0, =lifeCounter
	ldreq	r1, [r0]
	subeq	r1, #1
	streq	r1, [r0]
	mov		r3, r0
	beq		lives

	cmp		r0, #4
	ldr		r0, =lifeCounter
	ldr		r1, [r0]
	addeq	r1, #1
	streq	r1, [r0]
	mov		r0, r1
	bl		lifePrint



	ldr		r8, =snakeHead

	bl		drawCell
	mov		r0, r3
	bl		appleGenerator



	push	{r0,r2, lr}
	ldr     r3, =100000				// r3 = 6000
	bl      wait					// Wait for 6000 milliseconds
	pop		{r0,r2, lr}

	pop		{r4- r8, lr}
	bx		lr


appleGenerator:
	push	{lr}
	cmp		r0, #2
	beq		appleGenerate
	bne		noGenerate

appleGenerate:

	bl		randomNumber
		
	ldr		r5, =randomLocation
	ldr		r6, [r5]
	ldr		r7, [r5, #4]
	ldr		r5, =appleLocation
	str		r6, [r5]
	str		r7, [r5, #4]
	
	mov		r2, #1
	bl		printApple
	pop		{lr}
	bx 		lr

noGenerate:
	bl		tailReplace
	pop		{lr}
	bx 		lr

snakeMovement:

	bl  	Read_SNES		// branch to Read_SNES

	cmp		r0, #5			// if r0 = 5
	ldreq	r1, =pauseFlag
	streq	r0,[r1, #4]		// Save button pressed
	beq 	snakeUp			// branch to snakeUp

	cmp		r0, #6			// if r0 = 6
	ldreq	r1, =pauseFlag
	streq	r0,[r1, #4]		// Save button pressed
	beq 	snakeDown		// branch to snakeDown
	
	cmp		r0, #8			// if r0 = 8
	ldreq	r1, =pauseFlag
	streq	r0,[r1, #4]		// Save button pressed
	beq     snakeRight		// branch to snakeRight
	cmp     r0, #4			// if r0= 4

	beq		pause		// branch to pause


	b		snakeMovement	// branch if no button is pressed
	
	
snakeRight:

	add		r4, #32			// Add to the x pixel

	
	bl		storeQueue		// branch to the snakeQueue
	
	bl		Read_SNES
	


	cmp		r0, #5			// if r0 = 5
	ldreq	r1, =pauseFlag
	streq	r0,[r1, #4]		// Save button pressed
	beq 	snakeUp			// branch to snakeUp
	
	cmp		r0, #6			// if r0 = 6
	ldreq	r1, =pauseFlag
	streq	r0,[r1, #4]		// Save button pressed
	beq 	snakeDown		// branch to snakeDown
	
	cmp     r0, #4		// if r0= 4

	beq		pause		// branch to pause
	
	b       snakeRight
	

snakeLeft:

	sub		r4, #32			// subtract from the x pixel
	
	
	bl		storeQueue		// branch to the snakeQueue
	
	bl		Read_SNES


	cmp		r0, #5			// if r0 = 5
	ldreq	r1, =pauseFlag
	streq	r0,[r1, #4]		// Save button pressed
	beq 	snakeUp			// branch to snakeUp
	
	cmp		r0, #6			// if r0 = 6
	ldreq	r1, =pauseFlag
	streq	r0,[r1, #4]		// Save button pressed
	beq 	snakeDown		// branch to snakeDown

	cmp     r0, #4		// if r0= 4

	beq		pause		// branch to pause
	
	b       snakeLeft
	


snakeUp:

	sub		r5, #32			// subtract to the x pixel
	
	
	bl		storeQueue		// branch to the snakeQueue
	
	bl		Read_SNES
	

	cmp		r0, #7			// if r0 = 7
	ldreq	r1, =pauseFlag
	streq	r0,[r1, #4]		// Save button pressed
	beq 	snakeLeft		// branch to snakeLeft
	
	cmp		r0, #8			// if r0 = 8
	ldreq	r1, =pauseFlag
	streq	r0,[r1, #4]		// Save button pressed
	beq     snakeRight		// branch to snakeRight
	
	
	cmp     r0, #4		// if r0= 4

	beq		pause		// branch to pause
		
	b 		snakeUp
	
	
snakeDown:


	add		r5, #32			// add from the y pixel

	bl		storeQueue		// branch to the snakeQueue
	
	bl		Read_SNES

	cmp		r0, #7			// if r0 = 7
	ldreq	r1, =pauseFlag
	streq	r0,[r1, #4]		// Save button pressed
	beq 	snakeLeft		// branch to snakeLeft
	
	cmp		r0, #8			// if r0 = 8
	ldreq	r1, =pauseFlag
	streq	r0,[r1, #4]		// Save button pressed
	beq     snakeRight		// branch to snakeRight
	

	cmp     r0, #4			// if r0= 4

	beq		pause			// branch to pause
	b       snakeDown

pause:
	bl		disableInterrupt
	ldr		r4, =pauseFlag
	mov		r5, #1
	str		r5, [r4]
	str		r9, [r4, #8]
	str		r10, [r4, #12]
	ldr		r8, =pauseScreen
	ldr		r6, =320
	ldr		r7, =300
	ldr		r9, =359
	ldr		r10, =217
	bl		drawGame



pauseLoop:
	push	{r0,r2, lr}
	ldr     r3, =100000				// r3 = 6000
	bl      wait					// Wait for 6000 milliseconds
	pop		{r0,r2, lr}
	ldr		r0, [r4, #4]
	bl      Read_SNES
	
	cmp		r0, #4
	beq		backGround
	
	cmp		r0, #1
	moveq	r5, #0
	streq	r5, [r4]
	beq		clearScreen
	
	cmp		r0, #9
	moveq	r5, #0
	streq	r5, [r4]
	beq		main
	
	b		pauseLoop
	
tailReplace:
	push	{r6 - r8, lr}


	ldr		r6, [r11, r10]
	add		r10, #4
	ldr		r7, [r11, r10] 
	add		r10, #4
	

	ldr		r8, =gameBackground	// load address of blank
	bl      drawCell			// branch to drawCell
	
	pop		{r6 - r8, lr}	
	bx		lr

collision:
	push	{r4 - r11, lr}

	cmp		r1, #32
	ble		returnCollision
	
	cmp		r0, #992
	bge		returnCollision

	
	cmp		r0, #31
	ble		returnCollision
	
	cmp		r1, #736
	bge		returnCollision	

	ldr		r11, =brickLocation
	
collisionBlock:
	ldr		r4, [r11], #4
	cmp		r4, #0
	ldreq	r11, =tracker
	subeq	r9, #8
	beq		snakeCollision
	ldr		r5, [r11], #4
	cmp		r0, r4
	beq		checkY	
	b		collisionBlock	

checkY:
	cmp		r5, r1
	bne		collisionBlock
	beq		returnCollision


		
snakeCollision:
	cmp		r10, r9
	movge	r9, r0
	movge	r10, r1
	bge		collisionDoor
	
	ldr		r4, [r11, r10]
	add		r10, #4
	ldr		r5, [r11, r10] 
	add		r10, #4
	cmp		r0, r4
	beq		snakeCollisionY

	b       snakeCollision
snakeCollisionY:

	
	cmp		r5, r1
	beq		returnCollision
	
	b		snakeCollision

collisionDoor:
	ldr		r6, =doorLocation
	ldr		r4, [r6]
	ldr		r5, [r6, #4]
	cmp		r0, r4
	beq		doorCollisionY
	bne		collisionApple
	
doorCollisionY:	
	cmp		r5, r1
	beq		returnDoorCollision
	

collisionApple:
	ldr		r0, =appleLocation
	ldr		r1, [r0]
	ldr		r2, [r0, #4]
	cmp		r9, r1
	beq		collisionAppleY
	b		collisionPack
collisionAppleY:
	cmp		r10, r2
	beq		returnAppleCollision

collisionPack:
	ldr		r0, =valuePack
	ldr		r1, [r0]
	ldr		r2, [r0, #4]
	cmp		r9, r1
	beq		collisionPackY
	b		noCollision
collisionPackY:
	cmp		r10, r2
	beq		returnPackCollision


noCollision:
	mov		r0, #0
	pop		{r4 - r11, lr}
	bx		lr
returnCollision:
	mov		r0, #-1
	pop		{r4 - r11, lr}
	bx		lr

returnAppleCollision:
	mov		r0, #2
	pop		{r4 - r11, lr}
	bx		lr

returnDoorCollision:
	mov		r0, #3
	pop		{r4 - r11, lr}
	bx		lr

returnPackCollision:
	bl		disableInterrupt
	mov		r0, #4
	pop		{r4 - r11, lr}
	bx		lr

lives:
	cmp		r1, #0
	ble		printGameLost
	mov		r0, r1
	
	ldr		r0, =pauseFlag
	mov		r1, #0
	str		r1, [r0]
	
	bl		lifePrint
	b		backGround

printGameLost:
	bl		disableInterrupt
	ldr		r8, =loseScreen
	ldr		r6, =96
	ldr		r7, =128
	ldr		r9, =801
	ldr		r10, =480
	bl		drawGame

	ldr		r0, =pauseFlag
	mov		r1, #0
	str		r1, [r0]
	
	ldr		r0, =score
	mov		r1, #0
	str		r1, [r0]
	
gameLostLoop:
	bl 		Read_SNES
	
	cmp		r0, #9
	beq		main

	
	b		gameLostLoop


printGameWon:
	bl		disableInterrupt
	ldr		r8, =winScreen
	ldr		r6, =96
	ldr		r7, =128
	ldr		r9, =749
	ldr		r10, =468
	bl		drawGame

	ldr		r0, =pauseFlag
	mov		r1, #0
	str		r1, [r0]

	ldr		r0, =score
	mov		r1, #0
	str		r1, [r0]
	
gameWonLoop:
	bl 		Read_SNES
	
	cmp		r0, #9
	beq		main
	
	b		gameWonLoop
	
printApple:
	push	{r5 - r11, lr}
	cmp		r2, #0
	beq		printAppleExit
	ldr		r9, =score
	ldr		r10, [r9]
	add		r10, #1
	str		r10, [r9]
	
	mov		r0, r10
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
printAppleExit:

	ldr		r5, =appleLocation
	ldr		r6, [r5]
	ldr		r7, [r5, #4]
	ldr		r8, =apple
	bl		drawCell
	
	cmp		r10, #20
	blt		appleReturn
	bgt		appleReturn
	bl		drawDoor
	
appleReturn:	
	pop		{r5 - r11, lr}
	bx      lr

drawDoor:
	push	{r5- r10, lr}
	bl		randomNumber
	ldr		r5, =randomLocation
	ldr		r6, [r5]
	ldr		r7, [r5, #4]
	ldr		r5, =doorLocation
	str		r6, [r5]
	str		r7, [r5, #4]
	
		
	ldr		r8, =blank
	bl		drawCell
	pop		{r5- r10, lr}
	bx      lr

randomNumber:
	push 	{r4-r7, lr}
	
randomNumberLoop:
	ldr 	r0, =0x20003004 				// Address of CLO
	ldr 	r0, [r0] 						// x = clock value
	
	mov 	r1, #1  						// y 
	mov 	r2, #3 							// z
	mov 	r3, #9 							// w 

	mov 	r4, r0 							// t = x

	lsl 	r4, #11 						// t = t << 11
	eor 	r0, r4 							// t ^= t		

	lsr 	r4, #8 							// t = t >> 8
	eor 	r0, r4 							// t ^= t 							

	mov 	r0, r1 							// x = y
	mov 	r1, r2 							// y = z
	mov 	r2, r3 							// z = w

	lsr 	r3, #19 						// w = w >> 19
	eor		r3, r4 							// w ^= w
	
	lsl 	r4, #20
	lsr		r4, #20							// r4 >> 21
	mov		r0, r4
	mov		r1, #30
	bl		div
	
	lsl 	r1, #5
	mov 	r6, r1
	
	mov		r0, r4
	mov		r1, #21
	bl		div
	lsl 	r1, #5
	mov 	r7, r1
	
	mov 	r0, r6
	mov 	r1, r7
	
	bl		collision
	cmp		r0, #-1	
	beq		randomNumberLoop 
	ldr		r0, =randomLocation
	str		r6, [r0]
	str		r7, [r0, #4]
	pop	 	{r4-r7, lr}
	bx      lr	



div: 
	push	{lr}
    mov   r3, #0       					// Saves the quotient

div_Loop:
    cmp   r0, r1
    blt   exitDiv
    sub   r0, r1     
    add   r3, #1
    b     div_Loop
exitDiv:
    mov   r1, r0
    mov   r0, r3

	pop		{lr}
	bx      lr
tracker: 
	.rept 300
	.byte 0
	.endr

lifeCounter:
	.rept 4
	.byte 0
	.endr
randomLocation:
	.rept 8
	.byte 0
	.endr
score:
	.rept 4
	.byte 0
	.endr
pauseFlag:
	.rept 16
	.byte 0
	.endr
doorLocation:
	.rept 8
	.byte 0
	.endr
appleLocation:
	.rept 8
	.byte 0
	.endr
valuePack:
	.rept 8
	.byte 0
	.endr
	
