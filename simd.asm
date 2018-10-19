# Author: Boyan Hristov
# Date: 10/19/2018
# This program tries to simulate a SIMD addition instruction using a single 32 bit register
# by utilizing bitshifts and masks
.data
arr1:	.word	3, 4, 5, 6, 7, 8
arrSize: .word	6
arr2:	.word	2, 3, 4, 5, 6, 7
shiftMask: .word 0x3E000000

msg_sum_is:	.asciiz	"The sum of the two arrays is: "

.text
main:
	# attemp to simulate a SIMD instruction
	# the single zeros are going to be the carryover values
	# this instruction will only work with nums that can be represented with 4 bits
	# 00 0 0000 0 0000 0 0000 0 0000 0 0000 0 0000
	# this will be the way the bits on an register will be grouped
	# the leftmost one will store the first num
	# the way to get this value will be to and it with a hex number 0xFE000000
	# and then shift it by 25 to the right
	
	# the addresses of the arrays will be loaded into $a0 and $a1
	

	la	$a0, arr1
	la	$a1, arr2
	lw	$a2, arrSize
	lw	$a3, shiftMask
	j	SIMD_add
	
term:
	move	$a1, $v0
	
	ori	$v0, $0, 4 # prints a string
	la	$a0, msg_sum_is
	syscall
	
	move	$a0, $a1
	ori	$v0, $0, 1 # prints the sum
	syscall
	
	ori	$v0, $0, 10
	syscall
	

# $a0 address of arr1
# $a1 address of arr2
# $a2 array size
# $a3, shiftMask, this will help extract the numbers
# $t0 stores temp arr1 vals
# $t1 stores temp arr2 vals
# $t6 will be filled with 5 words from arr1
# $t7 will be filled with 5 words from arr2
# $t4 stores the shift amount
# $t3 is the loop counter
# the resulting sum will be stored in $t5
# after this it will be accumulated and returned in $v0
SIMD_add:
	xor	$t3, $t3, $t3
	xor	$t4, $t4, $t4
	xor	$t6, $t6, $t6
	xor	$t7, $t7, $t7
	xor	$v0, $v0, $v0
SIMD_store_loop:
	
	beq	$t3, $a2, End
	
	lw	$t0, ($a0) # loads num
	addi	$a0, $a0, 4 # advances to next num
	
	sllv	$t0, $t0, $t4
	or	$t6, $t6, $t0 # stores the num in $t6
	
	lw	$t0, ($a1)
	addi	$a1, $a1, 4
	
	sllv	$t0, $t0, $t4
	or	$t7, $t7, $t0
	
	addi	$t4, $t4, 5
	addi	$t3, $t3, 1
	
	b	SIMD_store_loop
	
End:
	add	$t5, $t6, $t7
	addi	$t4, $t4, -5	# should have 25
sum_loop:
	beq	$t3, 0, term
	
	and	$t0, $t5, $a3
	srlv	$t0, $t0, $t4
	
	srl	$a3, $a3, 5 # shift the mask to get the next val
	addi	$t4, $t4, -5 # reduce shift amount
	
	add	$v0, $v0, $t0
	addi	$t3, $t3, -1

	b	sum_loop