#LC_NUMERIC=en_US.UTF-8 qtspim


# // Principio de Computadores.
# // Operaciones con funciones y direccionamiento indirecto
# // Autores: Carlos Martín Galán y Alberto Hamilton Castro
# // Fecha última modificación: 2025-04-11
# #include <iostream>

# const int n1 = 10;
# double v1[n1] = {10.5, 9.5, 7.25, 6.25, 5.75, 4.5, 4.25, 3.5, -1.5, -2.0};
# const int n2 = 5;
# double v2[n2] = {5.5, 4.5, 4.25, 2.5, 2.5 };
# const int n3 = 4;
# double v3[n3] = {7.0, 5.0, 2.0, 1.0};


# void printvec(double* v, const int n) {
#     std::cout << "\nVector con dimension " << n << '\n';
#     for (int i = 0; i < n; i++)
#         std::cout << v[i] << " ";

#     std::cout << "\n";
#     return;
# }

# int ordenado(double* v, const int n) {
#     int resultado = 1;
#     int i = 0;
#     while (i < n-1) {
#         if (v[i+1] >= v[i]) {
#             resultado = 0;
#             break;
#         }
#         i++;
#     }
#     return resultado;
# }

# void merge(double* v1, const int n1,double* v2, const int n2) {

#     int  o1 = ordenado(v1,n1);
#     if (o1 == 0) {
#       std::cout << "Primer vector no ordenado. NO se puede mezclar\n";
#       return;
#     }
#     int o2 = ordenado(v2,n2);
#     if (o2 == 0) {
#       std::cout << "Segundo vector no ordenado. NO se puede mezclar\n";
#       return;
#     }
#     int i = 0; // índice para recorrer el v1
#     int j = 0; // índice para recorrer el v2
#     while ( ( i < n1) && (j < n2) ) {
#         if (v1[i] >= v2[j]) {
#             std::cout << v1[i] << ' ';
#             i++;
#         }
#         else {
#             std::cout << v2[j] << ' ';
#             j++;
#         }
#     }
#     while ( i < n1) {
#         std::cout << v1[i] << ' ';
#         i++;
#     }
#     while ( j < n2) {
#         std::cout << v2[j] << ' ';
#         j++;
#     }
#     std::cout << '\n';
#     return;
# }

# int main(void) {
#   std::cout << "\nPrograma de mezcla de vectores\n";

#   printvec(v1,n1);
#   printvec(v2,n2);
#   printvec(v3,n3);

#   std::cout << "\nIntentando mezcla con dos vectores ...\n";
#   merge(v1,n1,v2,n2);

#   std::cout << "\nIntentando mezcla con dos vectores ...\n";
#   merge(v1,n1,v3,n3);

#   std::cout << "\nIntentando mezcla con dos vectores ...\n";
#   merge(v2,n2,v3,n3);

#   std::cout << "\nFIN DEL PROGRAMA\n";
#   return 0;
# }

sizeD = 8

    .data
n1:     .word 10
v1:     .double 10.5, 9.5, 7.25, 6.25, 5.75, 4.5, 4.25, 3.5, -1.5, -2.0
n2:     .word 5
v2:     .double 5.5, 4.5, 4.25, 2.5, 2.5
n3:     .word 4
v3:     .double 7.0, 5.0, 2.0, 1.0

cad0:	.asciiz	"\nPrograma de mezcla de vectores\n"
cad1:   .asciiz "\nVector con dimension "
cad51:	.asciiz	"Primer vector no ordenado. NO se puede mezclar\n"
cad52:	.asciiz	"Segundo vector no ordenado. NO se puede mezclar\n"
cad2:   .asciiz "\nIntentando mezcla con dos vectores ...\n"
cad3:   .asciiz "\nFIN DEL PROGRAMA\n"

	.text

# Párametros de entrada:
# v = $a0
# n = #a1

#Paŕametros de salida: Ninguno

#Funcion que no llama a otra, pero hay syscall: SE USA LA PILA

#TABLA DE REGISTROS:
#$s0 = v
#$s1 = n
#s2 = i

	# void printvec(double* v, const int n) {
printvec:

	#PUSH: $ra, $s0, $s1, $s2
	add $sp, $sp, -16
	sw $ra, 12($sp)
	sw $s0, 8($sp)
	sw $s1, 4($sp)
	sw $s2, 0($sp)

	move $s0 $a0
	move $s1, $a1
	#     std::cout << "\nVector con dimension " << n << '\n';
	li $v0, 4
	la $a0, cad1
	syscall

	li $v0, 1
	move $a0, $s1
	syscall 

	li $v0, 11
	la $a0, '\n'
	syscall

	li $s2, 0 
	#    for (int i = 0; i < n; i++)
	for_print_vec:
		bge $s2, $s1, for_print_vec_fin
	#         std::cout << v[i] << " ";
	mul $t0, $s2, sizeD
	add $t0, $t0, $s0
	l.d $f12, 0($t0)

	li $v0, 3
	syscall

	li $v0, 11
	la $a0, ' '
	syscall


	addi $s2, 1
	b for_print_vec
	# }
	for_print_vec_fin:
	#     std::cout << "\n";
		li $v0, 11
		la $a0, '\n'
		syscall
		#     return;
		#POP: #ra, $s0, $s1, $s2
		lw $s2, 0($sp)
		lw $s1, 4($sp)
		lw $s0, 8($sp)
		lw $ra, 12($sp)
		add $sp, $sp, 16

		jr $ra
printvec__MARCAFIN:

#Parametros de entrada: 
#v = $a0
#n = $a1

#Parametros de salida: int
#$v0

#Funcion que no tiene syscall ni llama a otra funcion: NO ES NECESARIO USAR PILA

	# int ordenado(double* v, const int n) {
ordenado:

	li $t0, 1                    # resultado = 1
	li $t1, 0                    # i = 0
	addi $t5, $a1, -1            # t5 = n - 1 (guardamos el límite)
	
	while_ordenado:
		bge $t1, $t5, while_ordenado_fin  # if (i >= n-1) break
		
		if_ordenado:
			addi $t2, $t1, 1
			mul $t3, $t2, sizeD
			add $t3, $t3, $a0

			mul $t4, $t1, sizeD
			add $t4, $t4, $a0

			l.d $f0, 0($t3)            # f0 = v[i+1]
			l.d $f2, 0($t4)            # f2 = v[i]
			c.lt.d $f0, $f2            # ¿v[i+1] < v[i]?
			bc1f no_ordenado           # Si v[i+1] < v[i], NO está ordenado
			j if_ordenado_fin          # Si v[i+1] >= v[i], continúa
			
		no_ordenado:
			li $t0, 0
			b while_ordenado_fin
			
		if_ordenado_fin:
			addi $t1, $t1, 1       # i++
			blt $t1, $t5, while_ordenado  # if (i < n-1) continue
			
	while_ordenado_fin:
		move $v0, $t0
		jr $ra
ordenado__MARCAFIN:


	# void merge(double* v1, const int n1,double* v2, const int n2) {
	#Parametros de entrada: 	
	#v1 = $a0
	#n1 = $a1
	#v2 = $a2
	#n2 = $a3

	#Parametros de salida: Ninguna

	#FUNCION QUE LLAMA A OTRA: NECESITA EL USO DE PILA

merge:
	#PUSH: $ra, $s0, $s1, $s2, $s3, $s4, $s5, $f20, $f22 28 + 16
	addi $sp, $sp, -44
	sw $ra, 40($sp)
	sw $s0, 36($sp)
	sw $s1, 32($sp)
	sw $s2, 28($sp)
	sw $s3, 24($sp)
	sw $s4, 20($sp)
	sw $s5, 16($sp)
	s.d $f20, 8($sp)
	s.d $f22, 0($sp)

	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	#     int  o1 = ordenado(v1,n1);
	move $a0, $s0
	move $a1, $s1
	jal ordenado
	move $t0, $v0
	#     if (o1 == 0) {
	if_merge1:
		bnez $t0, if_merge1_fin
	#       std::cout << "Primer vector no ordenado. NO se puede mezclar\n";
		li $v0, 4
		la $a0, cad51
		syscall
	#       return;
		l.d $f22, 0($sp)
		l.d $f20, 8($sp)
		lw $s5, 16($sp)
		lw $s4, 20($sp)
		lw $s3, 24($sp)
		lw $s2, 28($sp)
		lw $s1, 32($sp)
		lw $s0, 36($sp)
		lw $ra, 40($sp)
		addi $sp, $sp, 44
		jr $ra
	#     }
	if_merge1_fin:
	#     int o2 = ordenado(v2,n2);
		move $a0, $s2
		move $a1, $s3
		jal ordenado
		move $t1, $v0 
	#     if (o2 == 0) {
	if_merge2:
		bnez $t1, if_merge2_fin
	#       std::cout << "Segundo vector no ordenado. NO se puede mezclar\n";
		li $v0, 4
		la $a0, cad52
		syscall
	#       return;
		l.d $f22, 0($sp)
		l.d $f20, 8($sp)
		lw $s5, 16($sp)
		lw $s4, 20($sp)
		lw $s3, 24($sp)
		lw $s2, 28($sp)
		lw $s1, 32($sp)
		lw $s0, 36($sp)
		lw $ra, 40($sp)
		addi $sp, $sp, 44
		jr $ra
	#     }
	if_merge2_fin:
	#     int i = 0; // índice para recorrer el v1
	li $s4, 0
	#     int j = 0; // índice para recorrer el v2
	li $s5, 0
	#     while ( ( i < n1) && (j < n2) ) {
	while_merge:
		bge $s4, $s1, while_merge_fin
		bge $s5, $s3, while_merge_fin
	#         if (v1[i] >= v2[j]) {
		if_merge3:
			mul $t2, $s4, sizeD
			add $t2, $t2, $s0

			mul $t3, $s5, sizeD
			add $t3, $t3, $s2

			l.d $f20, 0($t2)
			l.d $f22, 0($t3)
			c.le.d $f22, $f20
			bc1f if_merge3_else
	#             std::cout << v1[i] << ' ';
			li $v0, 3
			mov.d $f12, $f20
			syscall

			li $v0, 11
			la $a0, ' '
			syscall
	#             i++;
			addi $s4, 1
			b while_merge
	#         }
	#         else {
		if_merge3_else:
	#             std::cout << v2[j] << ' ';
		li $v0, 3
		mov.d $f12, $f22
		syscall

		li $v0, 11
		la $a0, ' '
		syscall
	#             j++;
		addi $s5, 1
		b while_merge
	#         }
	#     }
	while_merge_fin:

	#     while ( i < n1) {
	while_merge2:
		bge $s4, $s1, while_merge2_fin
	#         std::cout << v1[i] << ' ';
		mul $t4, $s4, sizeD
		add $t4, $t4, $s0
		l.d $f12, 0($t4)

		li $v0, 3
		syscall

		li $v0, 11
		la $a0, ' ' 
		syscall
	#         i++;
		addi $s4, 1
		b while_merge2
	#     }
	while_merge2_fin:
	#     while ( j < n2) {
	while_merge3:
		bge $s5, $s3, while_merge3_fin
	#         std::cout << v2[j] << ' ';
		mul $t5, $s5, sizeD
		add $t5, $t5, $s2
		l.d $f12, 0($t5)

		li $v0, 3
		syscall

		li $v0, 11
		la $a0, ' '
		syscall
	#         j++;
		addi $s5, 1
		b while_merge3
	#     }
	while_merge3_fin:
	#     std::cout << '\n';
		li $v0, 11
		la $a0, '\n'
		syscall
	#     return;
	#POP: $ra, $s0, $s1, $s2, $s3, $s4, $s5, $f20, $f22
		l.d $f22, 0($sp)
		l.d $f20, 8($sp)
		lw $s5, 16($sp)
		lw $s4, 20($sp)
		lw $s3, 24($sp)
		lw $s2, 28($sp)
		lw $s1, 32($sp)
		lw $s0, 36($sp)
		lw $ra, 40($sp)
		addi $sp, $sp, 44
		jr $ra
	# }
merge__MARCAFIN:

	# int main(void) {
main:
	#   std::cout << "\nPrograma de mezcla de vectores\n";
	li $v0, 4
	la $a0, cad0
	syscall

	#   printvec(v1,n1);
	la $a0, v1
	lw $a1, n1
	jal printvec

	#   printvec(v2,n2);
	la $a0, v2
	lw $a1, n2
	jal printvec
	#   printvec(v3,n3);
	la $a0, v3
	lw $a1, n3
	jal printvec


	#   std::cout << "\nIntentando mezcla con dos vectores ...\n";
	li $v0, 4
	la $a0, cad2
	syscall
	#   merge(v1,n1,v2,n2);
	la $a0, v1
	lw $a1, n1
	la $a2, v2
	lw $a3, n2
	jal merge

	#   std::cout << "\nIntentando mezcla con dos vectores ...\n";
	li $v0, 4
	la $a0, cad2
	syscall
	#   merge(v1,n1,v3,n3);
	la $a0, v1
	lw $a1, n1
	la $a2, v3
	lw $a3, n3
	jal merge

	#   std::cout << "\nIntentando mezcla con dos vectores ...\n";
	li $v0, 4
	la $a0, cad2
	syscall
	#   merge(v2,n2,v3,n3);
	la $a0, v2
	lw $a1, n2
	la $a2, v3
	lw $a3, n3
	jal merge

	#   std::cout << "\nFIN DEL PROGRAMA\n";
Fin:
	li $v0, 4
	la $a0, cad3	
	syscall

	li $v0, 10
	syscall
	#   return 0;
	# }