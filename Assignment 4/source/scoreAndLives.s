.globl  scorePrint
.globl  lifePrint


scorePrint:
	push	{r6-r8, lr}
	ldr		r7, =0
	cmp		r0, #0
	ldreq	r8, =zero
	cmp		r0, #1
	ldreq	r8, =one
	cmp		r0, #2
	ldreq	r8, =two
	cmp		r0, #3
	ldreq	r8, =three
	cmp		r0, #4
	ldreq	r8, =four
	cmp		r0, #5
	ldreq	r8, =five	
	cmp		r0, #6
	ldreq	r8, =six	
	cmp		r0, #7
	ldreq	r8, =seven	
	cmp		r0, #8
	ldreq	r8, =eight	
	cmp		r0, #9
	ldreq	r8, =nine	
	bl      drawCell
	pop		{r6-r8, lr}
	bx		lr
lifePrint:
	push	{r6-r8, lr}
	ldr		r6, =768
	ldr		r7, =0
	cmp		r0, #0
	ldreq	r8, =zero
	cmp		r0, #1
	ldreq	r8, =one
	cmp		r0, #2
	ldreq	r8, =two
	cmp		r0, #3
	ldreq	r8, =three
	cmp		r0, #4
	ldreq	r8, =four
	cmp		r0, #5
	ldreq	r8, =five	
	cmp		r0, #6
	ldreq	r8, =six	
	cmp		r0, #7
	ldreq	r8, =seven	
	cmp		r0, #8
	ldreq	r8, =eight	
	cmp		r0, #9
	ldreq	r8, =nine	
	bl      drawCell
	pop		{r6-r8, lr}
	bx      lr
