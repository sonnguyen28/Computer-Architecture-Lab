#++++++++++++++++++++++++++++++Computer Architecture+++++++++++++++++++++++++++
#
#			Nguyễn Hoàng Sơn - 20184187 
#	HEDSPI, SOICT, Hanoi University of Science and Technology
#	 	   Convert Infix to Postfix and Calculate
#
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

.data
	infix: .space 256		#Chua bieu thuc infix
	postfix: .space 256	#Chua bieu thuc postfix
	stackOperator: .space 256	#Stack chua toan hang de chuiyen doi infix --> postfix 
	stackCal: .space 256		#Stack dung de tinh toan bieu thuc postfix
	Mess_Start: .asciiz "Nhap vao Infix\nNote: Chi chap nhan cac toan tu + - * / ()\nSo gioi han 0-99"
	Mess_End: .asciiz "Ban co muon tiep tuc ?"
	Mess_Bye: .asciiz "Goodbye !!!"
	Mess_Error: .asciiz "Ky tu nhap vao khong dung"
	Mess_Infix: .asciiz "Bieu thuc Infix: "
	Mess_Postfix: .asciiz "Bieu thuc Postfix: "
	Mess_Result: .asciiz "Ket qua bieu thuc: "

.text
Main:
# Nhap vao bieu thuc infix
	li $v0, 54
	la $a0, Mess_Start
	la $a1, infix
 	la $a2, 256
 	syscall
 	beq $a1,-2,End
 	beq $a1,-3,Main
# Print infix 
	li $v0, 4
	la $a0, Mess_Infix
	syscall
	li $v0, 4
	la $a0, infix
	syscall
	
# Trang thai
	li $s7,0		# Bien luu trang thai cua ky tu doc duoc
				# 0 = Chua doc duoc gi
				# 1 = Da doc duoc mot so
				# 2 = Da doc duoc mot toan tu
				# 3 = Da doc duoc '('
				# 4 = Da doc duoc ')'
	li $t0,0		# Bien dem so chu so da doc duoc
	li $t1,-1		# Size Postfix
	li $t2,-1		# Top stack operator (stack de luu toan hang dung de chuyen doi infix -> postfix)
	la $s1, infix		# Nap dia chi 
	la $s2, postfix
	la $s3, stackOperator	
	addi $s1,$s1,-1
			
# Chuyen doi Infix -> Postfix
scanInfix: 			# Doc tung ky tu cua Infix
# Check cac ky tu da doc duoc
	addi $s1,$s1,1			# Chuyen den ky tu tiep theo cua Infix
	lb $t3, ($s1)			# 
	beq $t3, ' ', scanInfix		# Neu doc duoc ' ' bo qua chuyen den ky tu tiep theo
	beq $t3, '\n', EOF		# Da doc den cuoi Infix --> Pop tat ca toan tu trong Stack vao Postfix
	beq $t0,0,digit1		# Neu trang thai t0 = 0
	beq $t0,1,digit2		# Neu trang thai t0 = 1
	beq $t0,2,digit3		# Neu trang thai t0 = 2
	continueScan:
	beq $t3, '+', addSub
	beq $t3, '-', addSub
	beq $t3, '*', mulDiv
	beq $t3, '/', mulDiv
	beq $t3, '(', openBracket
	beq $t3, ')', closeBracket
	
errorInput:	# Khi phat hien ky tu nhap vao sai
	li $v0, 55
 	la $a0, Mess_Error
 	li $a1, 2
 	syscall
 	j askContinue

finishScan:
# Print bieu thuc Postfix
	li $v0, 4
	la $a0, Mess_Postfix
	syscall
	li $t5,-1		# Bien i de duyet qua cac gia tri cua postfix
	
printPost:
	addi $t5,$t5,1		# Chuyen den vi tri tiep theo cua postfix
	add $t6,$s2,$t5		# $t6 = dia chi postfix[i]
	lbu $t7,($t6)		# $t7 = postfix[i] 
	slt $t6, $t1, $t5	#Neu t5(i) > t1(size cua postfix) -->calculate
	bnez $t6, finishPrint	#Da print xong postfix --> finishPrint --> calculate
	addi $t6, $zero, 99	# Neu t7 = postfix[i]  > 99 -->No la mot toan tu --> printOp
	slt  $t6, $t6, $t7	
	bnez $t6, printOp	
	# Neu khong thi postfix[i] la mot so
	li $v0, 1
	add $a0,$t7,$zero
	syscall
	li $v0, 11
	li $a0, ' '
	syscall
	j printPost		# Loop
	
printOp:
	li $v0, 11
	addi $t7,$t7,-100	# Decode toan tu bang cach - 100
	add $a0,$t7,$zero
	syscall
	li $v0, 11
	li $a0, ' '
	syscall
	j printPost		# Loop
	
finishPrint:
	li $v0, 11
	li $a0, '\n'
	syscall

# Tinh gia tri bieu thuc nhap vao bang bieu thuc postfix
	li $t9,-4		# Set top stackCal = -4
	la $s0,stackCal		# Nap dia chi stackCal (Stack dung dung de tinh toan bieu thuc postfix) 
	li $t5,-1		# Bien i
calPost:
	addi $t5,$t5,1		# Chuyen den vi tri tiep theo cua postfix 
	add $t6,$s2,$t5		# $t6 = dia chi postfix[i]
	lbu $t7,($t6)		# $t7 = postfix[i]
	slt $t8, $t1, $t5		#Neu t5(i) > t1(size postfix) --> Da tinh toan xong -> printResult
	bnez $t8, printResult
	addi $t8, $zero, 99	# Neu t7( postfix[i] ) > 99 --> La mot toan tu --> Pop 2 so ra khoi stack va thuc hien phep tinh
	slt $t8, $t8, $t7		
	bnez $t8, calculate 
	addi $t9,$t9,4		
	add $t4,$s0,$t9		# $t4 = Dia chi cua top stackCal
	sw $t7, ($t4)		# Nap gia tri cua t7(postfix[i]) vao top stackCal
	j calPost		# Loop
	calculate:
		# Pop 1 so
		add $t4,$s0,$t9		
		lw $a2,($t4)	#Nap so vua pop vao $a2
		# Pop so tieo theo
		addi $t9,$t9,-4
		add $t4,$s0,$t9		
		lw $a1,($t4)	#Nap so vua pop vao $a1
		# Decode toan hang
		beq $t7,143,addition		# +
		beq $t7,145,subtraction	# -
		beq $t7,142,multiply	# *
		beq $t7,147,divide	# /
		addition:
			add $a0,$a1,$a2	
			sw $a0,($t4)	# t4(Top stackCal) = a1 + a2
			j calPost
		subtraction:
			sub $a0,$a1,$a2
			sw $a0,($t4)	# t4(Top stackCal) = a1 - a2
			j calPost
		multiply:
			mul $a0,$a1,$a2
			sw $a0,($t4)	# t4(Top stackCal) = a1 * a2
			j calPost
		divide:
			div $a0,$a1,$a2
			sw $a0,($t4)	# t4(Top stackCal) = a1 / a2
			j calPost
		
printResult:	
	li $v0, 4
	la $a0, Mess_Result
	syscall
	li $v0, 1
	lw $a0,($t4)
	syscall
	li $v0, 11
	li $a0, '\n'
	syscall

askContinue: 			# Tiep tuc ?
 	li $v0, 50
 	la $a0, Mess_End
 	syscall
 	beq $a0,0,Main
 	beq $a0,2,askContinue
# Ket thuc chuong trinh
End:
 	li $v0, 55
 	la $a0, Mess_Bye
 	li $a1, 1
 	syscall
 	li $v0, 10
 	syscall
 	
 # Chuong trinh con
digit1:
	beq $t3,'0',storeDigit1
	beq $t3,'1',storeDigit1
	beq $t3,'2',storeDigit1
	beq $t3,'3',storeDigit1
	beq $t3,'4',storeDigit1
	beq $t3,'5',storeDigit1
	beq $t3,'6',storeDigit1
	beq $t3,'7',storeDigit1
	beq $t3,'8',storeDigit1
	beq $t3,'9',storeDigit1
	j continueScan	#tiep tuc doc tiep xem co chu so tiep theo khong
	
digit2: 
	beq $t3,'0',storeDigit2
	beq $t3,'1',storeDigit2
	beq $t3,'2',storeDigit2
	beq $t3,'3',storeDigit2
	beq $t3,'4',storeDigit2
	beq $t3,'5',storeDigit2
	beq $t3,'6',storeDigit2
	beq $t3,'7',storeDigit2
	beq $t3,'8',storeDigit2
	beq $t3,'9',storeDigit2
	# Neu khong doc duoc chu so the hai 
	jal numberToPost
	j continueScan
	
digit3: 
	# Neu doc duoc chu so thu ba --> error
	beq $t3,'0',errorInput
	beq $t3,'1',errorInput
	beq $t3,'2',errorInput
	beq $t3,'3',errorInput
	beq $t3,'4',errorInput
	beq $t3,'5',errorInput
	beq $t3,'6',errorInput
	beq $t3,'7',errorInput
	beq $t3,'8',errorInput
	beq $t3,'9',errorInput
	# Neu khong doc duoc chu so the ba
	jal numberToPost
	j continueScan
	
storeDigit1:
	beq $s7,4,errorInput		# Doc duoc mot so sau dau ')' --> error
	addi $v0,$t3,-48		# Chuyen mot ky tu sang mot so
	add $t0,$zero,1			# Da doc duoc 1 chu so
	li $s7,1				#Chuyen trang thai s7 thanh 1
	j scanInfix
	
storeDigit2:
	beq $s7,4,errorInput		# Doc duoc mot so sau dau ')'
	addi $s5,$t3,-48		# Chuyen mot ky tu sang mot so
	mul $v0,$v0,10		# Nhan chu so da doc duoc truoc do voi 10 
	add $v0,$v0,$s5			# so = chu so dau tien * 10 + chu so thu hai
	add $t0,$zero,2			# Da doc duoc 2 chu so
	li $s7,1				#Chuyen trang thai s7 thanh 1
	j scanInfix		#Tiep tuc scan infix
	
numberToPost:
	beq $t0,0,endnumberToPost
	addi $t1,$t1,1
	add $t4,$t1,$s2			
	sb $v0,($t4)			# Luu so vao postfix
	add $t0,$zero,$zero		# Dat t0 ve  0
	endnumberToPost:
	jr $ra
	
addSub:			# Doc duoc + || - 
	beq $s7,2,errorInput		# Doc duoc mot toan tu sau mot toan tu hoac dau '('  --> error
	beq $s7,3,errorInput
	beq $s7,0,errorInput		# Nhan duoc mot toan tu dau tien ma chua co bat ki so nao -> error
	li $s7,2			# Chuyen trang thai sang 2
	continueAddSub:
	beq $t2,-1,inputToOp		# Khong co gi trong stack --> push vao
	add $t4,$t2,$s3			# Load dia chi cua  top stack operator
	lb $t7,($t4)			# Load gia tri cua top stack operator vao t7
	beq $t7,'(',inputToOp		# Neu top la ( --> push vao stack
	beq $t7,'+',equalPrecedence	# Neu top la '+' hoac '-'    --> nhay den nhan equalPrecedence
	beq $t7,'-',equalPrecedence
	beq $t7,'*',lowerPrecedence	# Neu top la '*'  hoac '/'   ---> nhay den nhan lowerPrecedence
	beq $t7,'/',lowerPrecedence
	
mulDiv:			# Doc duoc '*'  hoac '/'
	beq $s7,2,errorInput		# Doc duoc mot toan tu sau mot toan tu hoac dau '(' -> Bao loi
	beq $s7,3,errorInput
	beq $s7,0,errorInput		# Nhan duoc mot toan tu dau tien ma chua co bat ki so nao -> Bao loi
	li $s7,2			# Chuyen trang thai sang 2
	beq $t2,-1,inputToOp		# Khong co gi trong stack --> push vao
	add $t4,$t2,$s3			# Load dia chi cua top stack operator
	lb $t7,($t4)			# Load gia tri cua top stack operator vao t7
	beq $t7,'(',inputToOp		# Neu top la ( --> push vao
	beq $t7,'+',inputToOp		# Neu top la + - --> push vao
	beq $t7,'-',inputToOp
	beq $t7,'*',equalPrecedence	# Neu top is '*' hoac  '/'  --> nhay den nhan equalPrecedence
	beq $t7,'/',equalPrecedence
	
openBracket:			# Doc duoc '('
	beq $s7,1,errorInput		# Nhan duoc dau '(' sau mot so hoac mot dau ')' -> error
	beq $s7,4,errorInput
	li $s7,3			# Chuyen trang thai sang 3
	j inputToOp
	
closeBracket:			# Doc duoc ')'
	beq $s7,2,errorInput		# Nhan duoc dau ')' sau mot toan tu hoac dau '(' -> error
	beq $s7,3,errorInput	
	li $s7,4
	add $t4,$t2,$s3			# Load dia chi cua top stack operator 
	lb $t7,($t4)			# Load gia tri cua top stack operator vao t7
	beq $t7,'(',errorInput		# Khi nhap vao () ma khong co bat ki noi dung nao o giua --> error
	continueCloseBracket:
	beq $t2,-1,errorInput		# Khong tim thay dau mo ngoac --> error
	add $t4,$t2,$s3			# Load dia chi cua top stack operator
	lb $t7,($t4)			# Load gia tri cua top stack operator vao t7
	beq $t7,'(',matchBracket	# Tim duoc dau '(' --> matchBracket
	jal opToPostfix			# Pop top cua stack operator vao postfix
	j continueCloseBracket		# Sau do lap lai cho ?en khi tim thay mot dau ngoac hoac loi phu hop	
			
equalPrecedence:	# Nhan duoc toan tu + hoac - ma trong top stack da co + hoac - ||  Nhan duoc toan tu * hoac / ma trong top stack da co * hoac /
	jal opToPostfix			# Pop top cua stack operator vao postfix
	j inputToOp			# Push mot toan tu moi vao
	
lowerPrecedence:	# Nhan duoc toan tu + hoac - ma trong top stack da co * hoac /
	jal opToPostfix			# Pop top cua stack operator vao postfix
	j continueAddSub		# Loop 

inputToOp:			# Push input vao  stack operator
	add $t2,$t2,1			# Tang top cua stack operator
	add $t4,$t2,$s3			# Load dia chi cua top stack operator 
	sb $t3,($t4)			#Luu input vao top stack operator
	j scanInfix
	
opToPostfix:			# Pop top cua stack operator vao postfix
	addi $t1,$t1,1			# Tang size cua postfix
	add $t4,$t1,$s2			# Load dia chi cua top postfix 
	addi $t7,$t7,100		# Encode toan tu bang cach + 100
	sb $t7,($t4)			# Luu toan tu pop tu stack operator vao postfix
	addi $t2,$t2,-1			# Giam top cua stack operator
	jr $ra
	
matchBracket:			# Loai bo mot cap () tuong ung
	addi $t2,$t2,-1			# Giam top cua stack operator
	j scanInfix
	
EOF:
	beq $s7,2,errorInput			# Ket thuc voi mot toan tu hoac dau '('  --> error
	beq $s7,3,errorInput
	beq $t1,-1,errorInput			# Khong co gi trong postfix --> error
	j popAll

popAll:				# Pop tat ca stack operator vao Postfix
	jal numberToPost
	beq $t2,-1,finishScan		# operator rong --> finish
	add $t4,$t2,$s3			# Load dia chi cua top stack operator 
	lb $t7,($t4)			# Load gia tri cua top stack operator vao t7
	beq $t7,'(',errorInput		# Du mot dau '(' hoac ')' --> error
	beq $t7,')',errorInput
	jal opToPostfix
	j popAll			# Loop den khi stack operator rong
