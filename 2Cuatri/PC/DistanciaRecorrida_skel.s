#Autor: Kin Daniel Fortuno Pontillas
#Fecha: 4 de marzo de 2026

# // Calcular la distancia en metros recorrida por un vehículo. Para ello,
# // se solicitarán dos números enteros por consola: la velocidad expresada
# // en Km/h y tiempo que ha circulado a esa velocidad
# // (expresada en segundos).
# // El programa mostrará por consola un número flotante de doble precisión
# // que representa los metros recorridos por el vehículo. Si la distancia
# // recorrida es mayor de 250.0 metros debe sacar mensaje indicando
# // que "LLEGA", caso contrario que "NO Llega".
# // El programa funcionará de forma cíclica (volviendo a solicitar
# // los valores de entrada) hasta que uno de los datos
# // introducidos sea un cero.

# #include <iostream>
# #include <iomanip>
# int main() {
#   std::cout << "\nDistancia Recorrida\n";
#
#   while(true) {
#     std::cout << std::setprecision(18); // Ignorar
#     int velocidad;
#     std::cout << "\nIntroduce la velocidad en Km/h (entero): ";
#     std::cin >> velocidad;
#
#     int segundos;
#     std::cout << "Introduce los segundos (entero): ";
#     std::cin >> segundos;
#
#     if ((velocidad == 0) || (segundos == 0)) {
#       break;
#     }
#     double distancia = 1000.0 / 3600.0 * velocidad * segundos;
#     std::cout << "Yendo a " << velocidad << "Km/h durante " << segundos
#       << " sg se recorre " << distancia << " metros.";
#     if (distancia > 250.0) {
#       std::cout << "\n- LLEGA\n";
#     } else {
#       std::cout << "\n- No Llega\n";
#     }
#   }
#   std::cout << "\nTermina el programa\n";
# }

	.data
strTitulo:	.asciiz	"\nDistancia Recorrida\n"
strIntroVel:	.asciiz	"\nIntroduce la velocidad en Km/h (entero): "
strIntroSg:	.asciiz	"Introduce los segundos (entero): "
strYendo:	.asciiz	"Yendo a "
strDurante:	.asciiz	"Km/h durante "
strRecorre:	.asciiz	" sg se recorre "
strMetros:	.asciiz	" metros."
strLlega:	.asciiz	"\n- LLEGA\n"
strNoLlega:	.asciiz	"\n- No Llega\n"
strTermina:	.asciiz	"\nTermina el programa\n"

.text

#Tabla de registros
#$s0 = velocidad
#$s1 = segundos
#f0 = velocidad en double
#$f2 = segundos en double
#f4 = 1000.0
#f6 = 3600.0
#$f20 = distancia

main:

# int main() {
#   std::cout << "\nDistancia Recorrida\n";
	li $v0, 4
	la $a0, strTitulo
	syscall
#
#   while(true) {
	while:
#     std::cout << std::setprecision(18); // Ignorar
#     int velocidad;
#     std::cout << "\nIntroduce la velocidad en Km/h (entero): ";
		li $v0, 4
		la $a0, strIntroVel
		syscall
#     std::cin >> velocidad;
		li $v0, 5
		syscall
		move $s0, $v0
#
#     int segundos;
#     std::cout << "Introduce los segundos (entero): ";
		li $v0, 4
		la $a0, strIntroSg
		syscall
#     std::cin >> segundos;
		li $v0, 5
		syscall
		move $s1, $v0
#
#     if ((velocidad == 0) || (segundos == 0)) {
		if:
			bnez $s0, while
			b while_fin
			bnez $s1, while
			b while_fin
#       break;
#     }
	while_fin:
#     double distancia = 1000.0 / 3600.0 * velocidad * segundos;
	mtc1 $s0, $f0
	cvt.d.w $f0, $f0
	mtc1 $s1, $f2
	cvt.d.w $f2, $f2
	li.d $f4, 1000.0
	li.d $f6, 3600.0
	mul.d $f8, $f0, $f2
	div.d $f10, $f4, $f6
	mul.d $f20, $f8, $f10

#     std::cout << "Yendo a " << velocidad << "Km/h durante " << segundos
	li $v0, 4
	la $a0, strYendo
	syscall

	li $v0, 1
	move $a0, $s0
	syscall

	li $v0, 4
	la $a0, strDurante
	syscall

	li $v0, 1
	move $a0, $s1
	syscall
#       << " sg se recorre " << distancia << " metros.";
	li $v0, 4
	la $a0, strRecorre
	syscall

	li $v0, 3
	mov.d $f12, $f20
	syscall

	li $v0, 4
	la $a0, strMetros
	syscall
#     if (distancia > 250.0) {
		if2:
			li.d $f0, 250.0
			c.le.d $f0, $f20
			bc1f else
#       std::cout << "\n- LLEGA\n";
			li $v0, 4
			la $a0, strLlega
			syscall
			b Fin
#     } else {
		else:
#       std::cout << "\n- No Llega\n";
			li $v0, 4
			la $a0, strNoLlega
			syscall
#     }
		if2_fin:
#   }
#   std::cout << "\nTermina el programa\n";
Fin:
	li $v0, 4
	la $a0, strTermina
	syscall

	li $v0, 10
	syscall
# }
