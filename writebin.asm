# Chuong trinh: tao file
#-----------------------------------
# Data segment
	.data
# Cac dinh nghia bien
#dulieu1:	.float	127.03125
#dulieu2:	.float	16.9375

dulieu1:	.float	2.1592
dulieu2:	.float	3.314

#dulieu1:	.float	7.75
#dulieu2:	.float	3.25

tenfile:	.asciiz	"DULIEU.BIN"
fdescr:	.word	0	
# Cac cau nhac nhap du lieu
str_tc:	.asciiz	"Thanh cong."
str_loi:	.asciiz	"Mo file bi loi."
#-----------------------------------
# Code segment
	.text
	.globl	main
#-----------------------------------
# Chuong trinh chinh
#-----------------------------------
main:	
# Nhap (syscall)
# Xu ly
	la	$a0,tenfile
	addi	$a1,$zero,1	# open with write-only
	addi	$v0,$zero,13
	syscall
	bltz	$v0,baoloi
	sw	$v0,fdescr
  # ghi file
    # 4 byte so nguyen
  	lw	$a0,fdescr	# file descriptor
  	la	$a1,dulieu1
  	addi	$a2,$zero,4
  	addi	$v0,$zero,15
  	syscall
    # 4 byte so thuc
  	la	$a1,dulieu2
  	addi	$a2,$zero,4
  	addi	$v0,$zero,15
  	syscall
  # dong file
	lw	$a0,fdescr
	addi	$v0,$zero,16
	syscall
	la	$a0,str_tc
	addi	$v0,$zero,4
	syscall
	j	Kthuc
baoloi:	la	$a0,str_loi
	addi	$v0,$zero,4
	syscall
# Xuat ket qua (syscall)
# Ket thuc chuong trinh (syscall)
Kthuc:	addiu	$v0,$zero,10
	syscall
#-----------------------------------
