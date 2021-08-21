.data
strtmp: .space 32 # strtmp - Chuoi chua tung 8 ki tu de chuyen 8 ky tu co dang chuoi nhi phan sang mot so thap phan tuong duong
strprint: .space 64 # strprint - Chuoi da duoc giai ma
str: .space 160	# str - Chuoi bi ma hoa
init_val: .word 0 # Bien de luu gia tri cua strtmp sau khi chuyen sang mot so thap phan tuong duong
ascii_zero: .word 48 # So 0 trong bang ma ascii co gia tri trong he thap phan = 48
Message1: .asciiz "Nhap vao chuoi bi ma hoa: "
Message2: .asciiz "Chuoi bi ma hoa la: \n"

.text
input:	# Nhap vao chuoi bi ma hoa
	li 	$v0, 54
	la 	$a0, Message1
	la	$a1, str
	la	$a2, 159
	syscall
	
runner:	# Gan dia chi cua chuoi cho cac thanh ghi
	la 	$s0, str	# $s0 = Dia chi cua str 
	la 	$s1, strtmp	# $s1 = Dia chi cua strtmp
	la 	$s2, strprint	# $s2 = Dia chi cua strprint

check:	
	lb	$t0, 0($s0)	# t0 = s0[0]
	li	$t1, 10		# t1 = '\n'
	beq 	$t0, $t1, exit	# Neu s0[0] = '\n' thi chuyen den nhan exit
	li	$t5, 0		# t5 = i = 0
	
strcopy_loop:	#Copy 8 ki tu cua $s0 vao $s1(strtmp)
	slti	$t1, $t5, 8 	# i < 8 ?
	beq	$t1, $zero, strcopy_done # neu dung => Da copy xong 8 ky tu
	add	$t2, $t5, $s0 	# $t2 = Dia chi cua s0[i]
	lb	$t3, 0($t2)	# t3 = s0[i]
	add	$t4, $t5, $s1 	# $t4 = Dia chi cua strtmp[i]
	sb	$t3, 0($t4) 	# strtmp[i] = s[i]
	addi	$t5, $t5, 1	# i = i + 1
	j strcopy_loop
	nop
	
strcopy_done: 	#Da copy xong 8 ky tu vao chuoi strtmp 
		# Gan ki tu '\0' (Ke thuc chuoi) vao cuoi chuoi strtmp
	li	$t0, 0 		# t0 = '\0'
	sb	$t0, 8($s1) 	# strtmp[8] = '\0'
	addi	$s0, $s0, 8	# Di chuyen $s0 len phia truoc 8 byte
	addu	$a0, $zero, $s1	# $a0 = Dia chi cua $s1(strtmp)

#Chuyen doi chuoi strtmp thanh so thap phan tuong duong VD: "01001000" -> 01001000 (72)
binary_convert: 
	lw 	$t9, ascii_zero
	lw 	$v0, init_val	#Gia tri cua chuoi sau khi chuyen doi (Khoi tao ban dau = 0)
	
binary_convert_loop: 
	lb	$t0, 0($a0)	# t0 = byte dau tien cua $a0
	beqz	$t0, binary_convert_done # Chuyen doi hoan thanh neu t0 = '\0' 
	sub	$t0, $t0, $t9	# t0 = t0 - 48 de chuyen '0' -> 0 , '1' -> 1 
	sll	$v0, $v0, 1	# Dich chuyen gia tri tra ve hien tai sang trai 1 bit 
	add	$v0, $v0, $t0	# Them t0 vao gia tri tra ve hien tai
	addi 	$a0, $a0, 1	# Di chuyen dia chi chuoi dau vao ($a0) len 1 byte
	j	binary_convert_loop

binary_convert_done: 
	sb	$v0, 0($s2)	# Them v0 vao chuoi strprint
	addi	$s2, $s2, 1	# Di chuyen $s2 len 1 byte
	j	check

exit:	#In chuoi da duoc giai ma
	li	$v0, 59
	la	$a0, Message2
	la	$a1, strprint
	syscall
