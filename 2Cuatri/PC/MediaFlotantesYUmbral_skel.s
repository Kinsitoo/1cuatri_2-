#Autor: Kin Daniel Fortuno Pontillas
#Fecha: 12/03/2025

# // En un bucle solicitar flotantes hasta que se meta un 0.0
# // (que no se tendrá en cuenta).
# // Al final indicar el número de números introducidos, el valor media.
# // Si la media supera 1.5 sacar mensaje indicando que se supera el umbral.

# include <iostream>
# include <iomanip>

# int main() {
#   std::cout << std::fixed << std::setprecision(8);  // Ignorar
#   std::cout << "\nMedia de flotantes y umbral\n";
#   float acumulado = 0.0;
#   int numValores = 0;
#   while(true) {
#     float valor;
#     std::cout << "Introduce valor (0.0 para terminar): ";
#     std::cin >> valor;
#     if(valor == 0.0) {
#       break;
#     }
#     acumulado += valor;
#     numValores++;
#   }
#   if (numValores > 0) {
#     float media = acumulado / numValores;
#     std::cout << "\nSe introdujeron " << numValores
#         << " valores. Su media es " << media;
#     if (media > 1.5) {
#       std::cout << "\nSe supera el umbral";
#     }
#   } else {
#     std::cout << "\nNo se introdujo ningún valor";
#   }
#   std::cout << "\n\nTerminamos\n";
# }

	.data
strTitulo:	.asciiz	"\nMedia de flotantes y umbral\n"
strIntroduce:	.asciiz	"Introduce valor (0.0 para terminar): "
strSeIntrodujo:	.asciiz	"\nSe introdujeron "
strValores:	.asciiz	" valores. Su media es "
strSupera:	.asciiz	"\nSe supera el umbral"
strNingun:	.asciiz	"\nNo se introdujo ningún valor"
strTerminamos:	.asciiz	"\n\nTerminamos\n"
float_acumulado:	 .float 0.0
int_acumulado:	.word 0

	.text

#Tabla de registros
#f20 = acumulado
#s0 = numValores
#f21 = valor
#f22 = media


main:
# int main() {
#   std::cout << std::fixed << std::setprecision(8);  // Ignorar
#   std::cout << "\nMedia de flotantes y umbral\n";
	li $v0, 4
	la $a0, strTitulo
	syscall
#   float acumulado = 0.0;
	l.s $f20, float_acumulado
#   int numValores = 0;
	li $s0, 0
#   while(true) {
	while:
#     float valor;
#     std::cout << "Introduce valor (0.0 para terminar): ";
	li $v0, 4
	la $a0, strIntroduce
	syscall
#     std::cin >> valor;
	li $v0, 6
	syscall
	mov.s $f21, $f0
#     if(valor == 0.0) {
		if:
			li.s $f0, 0.0
			c.eq.s $f21, $f0
			bc1t while_fin
#       break;
		if_fin:
#     }
#     acumulado += valor;
		add.s $f20, $f20, $f21
#     numValores++;
		addi $s0, 1
		b while
#   }
	while_fin:
#   if (numValores > 0) {
	if2:
		blez $s0, else
#     float media = acumulado / numValores;
		mtc1 $s0, $f1
		cvt.s.w $f1, $f1
		div.s $f22, $f20, $f1
#     std::cout << "\nSe introdujeron " << numValores
		li $v0, 4
		la $a0, strSeIntrodujo
		syscall

		li $v0, 1
		move $a0, $s0
		syscall

#         << " valores. Su media es " << media;
		li $v0, 4
		la $a0, strValores
		syscall

		li $v0, 2
		mov.s $f12, $f22
		syscall
#     if (media > 1.5) {
			if3:
				li.s $f0, 1.5
				c.lt.s $f0, $f22
				bc1f Fin
#       std::cout << "\nSe supera el umbral";
				li $v0, 4
				la $a0, strSupera
				syscall
				b Fin
			if_3_fin:
#     }
#   } else {
	else:
#     std::cout << "\nNo se introdujo ningún valor";
		li $v0, 4
		la $a0, strNingun
		syscall
	
	else_fin:
#   }
#   std::cout << "\n\nTerminamos\n";
	if2_fin:

Fin:
	li $v0, 4
	la $a0, strTerminamos
	syscall

	li $v0, 10
	syscall
# }
