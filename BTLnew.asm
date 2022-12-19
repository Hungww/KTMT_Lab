#Chuong trinh: ten chuong trinh
#Data segment
	.data
#Cac dinh nghia bien	
	s1: .word 11972608
	s2: .word 9699328
	dulieu1:	.space	4
	dulieu2:	.space	4
	result: .space  4 
	tenfile:	.asciiz	"DULIEU.BIN"
	fdescr:	.word	0	
#Cac cau nhac nhap du lieu
	str_dl1:	.asciiz	"Du lieu 1 = "
	str_dl2:	.asciiz	"Du lieu 2 = "
	str_loi:	.asciiz	"Mo file bi loi."
#Code segment
	.text
	.globl	main
main:
   # mo file doc
	la	$a0,tenfile
	addi	$a1,$zero,0	#flag=0:read only
	addi	$v0,$zero,13
	syscall
	bltz	$v0,baoloi
	sw	$v0,fdescr
  # doc file
    # 4 byte so nguyen
  	lw	$a0,fdescr
  	la	$a1,dulieu1
  	addi	$a2,$zero,4
  	addi	$v0,$zero,14
  	syscall
    # 4 byte so thuc
  	la	$a1,dulieu2
  	addi	$a2,$zero,4
  	addi	$v0,$zero,14
  	syscall
  # dong file
	lw	$a0,fdescr
	addi	$v0,$zero,16
	syscall

	#s0 = result
	li $s0, 0
	
	
	#First, we have to separate each number into 3 part: 1 sign bit, 8 exponent bit,
	#and the rest is mantissa
	
	#s1 =number 1,  s2= exponent 1,    s3=mantissa 1
	#s4 =number 2,  s5= exponent 2,    s6=mantissa 2
	
	#Get 23- mantissa bit
	lw $s1, dulieu1
	lw $s4, dulieu2

	andi $s3, $s1, 0x007FFFFF
	andi $s6, $s4, 0x007FFFFF
	ori  $s3, 0x800000		#Set the 24th LS - implicit 1 bit
	ori  $s6, 0x800000		#Set the 24th LS - implicit 1 bit
	
	
	#Get 8-exponent bit
	andi $s2, $s1, 0x7f800000
	andi $s5, $s4, 0x7f800000
	srl  $s2,$s2,23
	srl  $s5,$s5,23

	#$s1 and $s4 will store the sign bit only
	andi $s1, $s1, 0x80000000
	andi $s4, $s4, 0x80000000
	
	
	
	
	#Now, we calculate the result
	
	#First, get the sign bit of result:
	xor $s0, $s1, $s4  #calculate sign bit of the result

	#Then, call a function to divide the mantissa
	move $a0, $s3, 
	move $a1, $s6
	jal DivisionAlgorithm
	
	#Finally, get the exponent
	sub $s2, $s2, $s5
	addi $s2, $s2, 127
	sub $s2, $s2, $v1
	sll $s2, $s2, 23

	#Now $v0 will store the result's mantissa, remember to remove the implicit 1 bit, 
	#then just put it in result ($s0)
	andi $v0, $v0, 0x007fffff
	or $s0, $s0, $v0
	
	
	
		

	or $s0, $s0, $s2
	
	#Store the result
	sw $s0, result
# Xuat ket qua (syscall)

  	lwc1	$f12,result
  	addi	$v0,$zero,2
  	syscall
# Ket thuc chuong trinh (syscall)
Kthuc:	addiu	$v0,$zero,10
	syscall
#-----------------------------------
baoloi:	
    la	$a0,str_loi
    addi $v0,$zero,4
    syscall
	
	
	
DivisionAlgorithm:
    addi $sp, $sp, -12      #Decrement in $sp (Stack Pointer)
    sw $s0, 0($sp)      #Pushing $s0 into Stack
    sw $ra, 4($sp)      #Pushing $ra into Stack (Function Call Exists)
    sw $s1,8($sp)       #Pushing $s1 into stack 

    move $t0, $a0       #$t0 = Mantissa of Dividend/Remainder
    move $t1, $a1       #$t1 = Mantissa of Divisor

    add $s0, $0, $0     #$s0 = Initialization
    add $v1, $0, $0     #$v1 = 0 (Displacement of Decimal Point Initialized)
    li $t8,0       #$s1 = 1 (initialize loop variable to 1)
	

loop:   
    bgtu $t8, 23, check
	#Loop for 24 time 
    addi $t8,$t8,1
    sub $t0, $t0, $t1       #Dividend = Dividend - Divisor
    sll $s0, $s0, 1     #Quotient Register Shifted Left by 1-bit
    slt $t2, $t0, $0
    bne $t2, $0, else       #If Dividend < 0, Branch to else
    addi $s0, $s0, 1        #Setting Quotient LSb to 1
    j out
else:   add $t0, $t0, $t1       #Restoring Dividend Original Value

out:    sll $t0, $t0, 1     #Dividend Register Shifted Left by 1-bit
    j loop

check:  slt $t2, $a0, $a1       #If Dividend < Divisor, Call Function 'Normalization'
    beq $t2, $0, exit       #If Dividend > Divisor, Branch to exit
    move $a0, $s0       #$a0 = Quotient

    jal Normalization       #Function Call 
    j return

exit:   move $v0, $s0       #$v0 = Calculated Mantissa
	

return: lw $ra, 4($sp)      #Restoring $ra
    lw $s0, 0($sp)      #Restoring $s0
    lw $s1, 8($sp)      #restoring $s1
    addi $sp, $sp, 8        #Increment in $sp (Stack Pointer)
    
    beqz $t0, RE
    addi $v0, $v0, 1
    #Restore the last loop
RE:   jr $ra          #Return	
	
	
	
	
Normalization:
    lui $t0, 0x0040       #$t0 = 0x40 (1 at 23rd-bit)
    addi $t2, $0, 1     #$t2 = 1 (Initialization)

loop2:  and $t1, $a0, $t0       #Extracting 23rd-bit of Mantissa 
    bne $t1, $0, else2      #If 23rd-bit = 1; Branch to else2
    addi $t2, $t2, 1        #Increment in Count of Decimal Places Moved
    sll $a0, $a0, 1     #Mantissa Shifted Left (To Extract Next Bit)
		    
    j loop2         

else2:  sll $a0, $a0, 1     #Setting 24th-bit = 1 (Implied)
    move $v0, $a0       #$v0 = Normalized Mantissa
    move $v1, $t2       #$v1 = Displacement of Decimal Point   
    jr $ra          #Return


