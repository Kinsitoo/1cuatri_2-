#Autor: Kin Daniel Fortuno Pontillas
#Fecha : 4 de Marzo de 2026

#// Programa para evaluar polinomio tercer grado
#//Realiza un programa en ensamblador MIPS que evalúe un polinomio de tercer 
#//grado de la forma 
#//f(x) = a x^3 + b x^2 + c x + d
#//en un rango de valores enteros [r,s] y devuelva aquellos valores que 
#//son mayores de 2.5
#//El programa debe pedir por consola:
#//- cuatro números flotantes en simple precisión: a, b, c y d
#//- dos números enteros r y s comprobando que r <= s 

# Testear en
# https://codetest.iaas.ull.es/testeaPrinComp/testea/bbad44792ef4f0305d176

# #include <iostream>
# #include <iomanip>

# int main(void) {
#   std::cout << std::fixed << std::setprecision(8);  // Ignorar
#   float a,b,c,d;
#   std::cout << "\nEvaluacion polinomio f(x) = a x^3 + b x^2 + c x + d"
#             << " en un intervalo [r,s]\n";
#   std::cout << "\nIntroduzca coeficiente a: ";
#   std::cin >> a;
#   std::cout << "Introduzca coeficiente b: ";
#   std::cin >> b;
#   std::cout << "Introduzca coeficiente c: ";
#   std::cin >> c;
#   std::cout << "Introduzca coeficiente d: ";
#   std::cin >> d;
#   int r,s;
#   do {
#     std::cout << "\nLímite inferior r: ";
#     std::cin >> r;
#     std::cout << "Límite superior s: ";
#     std::cin >> s;
#   } while (r > s);

#   for (int x = r ; x <= s ; x++) {
#     // float f = x*x*x*a + x*x*b + x*c + d;
#     float f = d;
#     f += x*c;
#     f += x*x*b;
#     f += x*x*x*a;
#    if (f >= 2.5) {
#      std::cout << "f(" << x << ") = " << f;
#    } else {
#      std::cout << x << " no supera";
#    }
#    std::cout << '\n';
#   }
#   std::cout << "\n\nTermina el programa\n";
# }

	.data
strTitulo:	.ascii	"\nEvaluacion polinomio f(x) = a x^3 + b x^2 + c x + d"
		.asciiz	" en un intervalo [r,s]\n"
strIntroA:	.asciiz	"\nIntroduzca coeficiente a: "
strIntroB:	.asciiz	"Introduzca coeficiente b: "
strIntroC:	.asciiz	"Introduzca coeficiente c: "
strIntroD:	.asciiz	"Introduzca coeficiente d: "

strIntroR:	.asciiz	"\nLímite inferior r: "
strIntroS:	.asciiz	"Límite superior s: "

strF:		.asciiz	"f("
strIgual:	.asciiz	") = "
strNoSupera:	.asciiz	" no supera"
strTermina:	.asciiz	"\n\nTermina el programa\n"
strNewline: .asciiz "\n"

.text


#$Tabla de registros 
#$f20 = a
#$f21 = b
#$f22 = c
#$f23 = d
#$s0 = r
#$s1 = s 
#$f24 = f

main:

# int main(void) {
#   std::cout << std::fixed << std::setprecision(8);  // Ignorar
#   float a,b,c,d;
#   std::cout << "\nEvaluacion polinomio f(x) = a x^3 + b x^2 + c x + d"
#             << " en un intervalo [r,s]\n";
  li $v0, 4
  la $a0, strTitulo
  syscall
#   std::cout << "\nIntroduzca coeficiente a: ";
  li $v0, 4
  la $a0, strIntroA
  syscall
#   std::cin >> a;
  li $v0, 6
  syscall
  mov.s $f20, $f0
#   std::cout << "Introduzca coeficiente b: ";\
  li $v0, 4
  la $a0, strIntroB
  syscall
#   std::cin >> b;
  li $v0, 6
  syscall
  mov.s $f21, $f0
#   std::cout << "Introduzca coeficiente c: ";
  li $v0, 4
  la $a0, strIntroC
  syscall
#   std::cin >> c;
  li $v0, 6
  syscall
  mov.s $f22, $f0
#   std::cout << "Introduzca coeficiente d: ";
  li $v0, 4
  la $a0, strIntroD
  syscall
#   std::cin >> d;
  li $v0, 6
  syscall
  mov.s $f23, $f0
#   int r,s;
#   do {
  do_while:
#     std::cout << "\nLímite inferior r: ";
    li $v0, 4
    la $a0, strIntroR
    syscall
#     std::cin >> r;
    li $v0, 5
    syscall
    move $s0, $v0
#     std::cout << "Límite superior s: ";
    li $v0, 4
    la $a0, strIntroS
    syscall
#     std::cin >> s;
    li $v0, 5
    syscall
    move $s1, $v0
#   } while (r > s);
    bgt $s0, $s1, do_while
  
  do_while_fin:

#   for (int x = r ; x <= s ; x++) {
    for: 
      bgt $s0, $s1, for_fin
#     // float f = x*x*x*a + x*x*b + x*c + d;
#     float f = d;
      mov.s $f24, $f23
#     f += x*c;
      mtc1 $s0, $f0
      cvt.s.w $f0, $f0
      mul.s $f1, $f0, $f22
      add.s $f24, $f24, $f1
#     f += x*x*b;
      mul.s $f2, $f0, $f0
      mul.s $f2, $f2, $f21
      add.s $f24, $f24, $f2
#     f += x*x*x*a;
      mul.s $f3, $f0, $f0
      mul.s $f3, $f3, $f0
      mul.s $f3, $f3, $f20
      add.s $f24, $f24, $f3

    
#    if (f >= 2.5) {
    if:
      li.s $f4, 2.5
      c.le.s $f4, $f24
      bc1f else
#      std::cout << "f(" << x << ") = " << f;
      li $v0, 4
      la $a0, strF
      syscall

      li $v0, 1
      move $a0, $s0
      syscall

      li $v0, 4
      la $a0, strIgual
      syscall

      li $v0, 2
      mov.s $f12, $f24
      syscall

      addi $s0, 1

      li $v0, 4
      la $a0, strNewline
      syscall

      b for
#    } else {
    else:
#      std::cout << x << " no supera";
      li $v0, 1
      move $a0, $s0
      syscall

      li $v0, 4
      la $a0, strNoSupera
      syscall

      li $v0, 4
      la $a0, strNewline 
      syscall

      addi $s0, 1
      b for

    for_fin:
#    }
#   }
#   std::cout << "\n\nTermina el programa\n";
Fin:
  li $v0, 4
  la $a0, strTermina
  syscall

  li $v0, 10
  syscall
# }
