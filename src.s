


.global _start
_start:
	

_read:
	mov R7, #3 	@ sets up Syscall to read from the screen
	mov R0, #0 	@ keyboard input
	mov R2, #10 	@ reads first 4 characters
	ldr R1,=stringIn @ input placed into stringIn
	swi #0     	@ executes Syscall
	
	mov R9, #10
	mov R4, #0 	@ R4 Used as running int total of user input
	mov R6, #0 	@ zero out R6, 
		   	@ R6 used as counter of characters input
	

_countChar:


	ldrb R2, [R1, R6]	@Load CHAR @ R1 offset R6 (Not 32-bits...) into R2
	
	cmp R2, #10		@If Char in R2 is LineFeed, jump to _toInt
	beq _toInt
	add R6, R6, #1		@Increment offset to next char
	bal _countChar		@loop back

_toInt:
	@Now R6 has the number of characters
	sub R6, R6, #1		@decrement counter
	mov R3, #1 		@R3 holds TensMultiplier; aka the weight of a given character
				@ie 140 "4" has a weight of 4 * 10	

	
_loopMe:

	ldrb R2, [R1, R6]	@Load CHAR @ R1 offset R6 (Not 32-bits...) into R2
	
	sub R2, R2, #48		@Do ascii math to convert char '1' (value 49) to int (value 1)
	mul R7, R2, R3 		@Multiply by the "weight" of the digit
	mov R2, R7		@^^^
	add R4, R4, R2 		@Update Sum
	sub R6, R6, #1		@dec counter

	mul R7, R3, R9		@Update TensMultiplier to have weight 10x higher than last digit
	mov R3, R7
	cmp R6, #0		

	bpl _loopMe		@jump if R6 is positive, aka we still have more digits to process

_letsPrint:

	

	mov R2, #1		@setup our mask. R3 masks a single bit at a time.
	mov R3, R2, LSL #31	@Slide it all the way left to the most significant bit
	ldr R1, =stringOut	@R1 now has pointer to first char of Output String

_bitHandling:
	
	tst R4, R3		@bitwise AND comparison between mask and int sum
	bne _noMoreLeadingZeros1	@if we find a 1, we've found our first relevant bit (ie drop leading zeros)
	mov R2, R3, LSR #1	@Shift our mask 1 bit to the right
	mov R3, R2		@^^^^
	bal _bitHandling	@loopback, keep doing this until we find our first 1 bit
	
	
_noMoreLeadingZeros1:
	mov R6, #0 @Zero out counter

_testBits:
	
	tst R4, R3		@bitwise AND comparison between mask and int sum
	beq _zeroBit

_oneBit: 		@We found a one bit
	mov R2, #49		@Move ascii '1' into R2
	bal _putItInTheString	

_zeroBit: 		@We found a zero bit
	mov R2, #48		@Move ascii '0' into R2
	bal _putItInTheString

_printToConsole:
	mov R7, #4		@Setup syscall to print to console	
	mov R0, #1		@^^
	mov R2, R6		@Number of ascii characters we want to print
	swi #0			@Execute syscall

_exit:
	mov R7, #1 		@sets up syscall to exit program
	swi #0 			@execute syscall

_putItInTheString:

	strb R2, [R1, R6]	@Store a single byte at the memory location R1 with R6 offset

	add R6, R6, #1		@increment our offset to move to next char position
	mov R2, R3, LSR #1	@shift our mask right 1 bit.
	mov R3, R2		@^^^
	cmp R3, #0		@If our mask is empty... we've processed all bits
	beq _printToConsole	@^^^^ Let's Print this
	bal _testBits		@Otherwise, loopback and process more bits


.data
stringOut:
.ascii ""
stringIn:
.asciz ""