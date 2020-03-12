	# sample MIPS32 assembly program
	#
	# CSCI 221 S20
	#
	# This counts up to 100, summing each of
	# those counted integers.
	#
	# It uses
	#  * load immediate
	#  * register-register addition
	#  * register-register compare & branch
	#  * no system calls
	#

	.globl main
	.text

main:
	li	$t0, 0		# sum = 0    
	li	$t1, 1		# inc = 1    
	li	$t2, 0          # count = 0  
	li 	$t3, 100        # last = 100 
loop:	
	bgt	$t3, $t2, done  # if last == count goto done

	addu	$t2, $t2, $t1   # count += inc
	addu	$t0, $t0, $t2   # sum += count
	b	loop

done:	
	li	$v0, 0		# return 0
	jr	$ra		#
	
