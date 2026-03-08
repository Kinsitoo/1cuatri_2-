# #include <iostream>
# #include <iomanip>
# int main(void) {
#     std::cout << std::fixed << std::setprecision(8);  // Ignorar en MIPS
    
#     double limite, factorial = 1.0;
#     int i = 1, contador = 0;
    
#     std::cout << "\n=== Calculadora de Factoriales ===\n";
#     std::cout << "Introduce el limite (double): ";
#     std::cin >> limite;
    
#     if (limite <= 0) {
#         std::cout << "Error: Limite debe ser positivo\n";
#     } else {
#         while (true) {
#             factorial = factorial * i;
#             contador++;
#             std::cout << i << "! = " << factorial << "\n";
            
#             if (factorial > limite) {
#                 std::cout << "*** SUPERADO ***\n";
#                 break;
#             }
#             i++;
#         }
#         std::cout << "\nFactoriales calculados: " << contador << "\n";
#     }
    
#     std::cout << "\n=== Fin ===\n";
# }

.data
strTitulo:      .asciiz "\n=== Calculadora de Factoriales ===\n"
strLimite:      .asciiz "Introduce el limite (double): "
strError:       .asciiz "Error: Limite debe ser positivo\n"
strFactorial:   .asciiz "! = "
strSuperado:    .asciiz "\n*** SUPERADO ***\n"
strTotal:       .asciiz "\nFactoriales calculados: "
strFin:         .asciiz "\n=== Fin ===\n"
strNewline:     .asciiz "\n"

# Constantes double para cálculos
const_limite_min: .double 0,0
const_uno:        .double 1,0

.text

#TABLA DE REGISTROS
#$f20 = limite
#$f22 = factorial
#$s0 = i
#$s1 = contador

main:
# int main(void) {
#     std::cout << std::fixed << std::setprecision(8);  // Ignorar en MIPS
    
#     double limite, factorial = 1.0;
#     int i = 1, contador = 0;
  l.d $f22, const_uno
  li $s0, 1
    
#     std::cout << "\n=== Calculadora de Factoriales ===\n";
  li $v0, 4
  la $a0, strTitulo
  syscall
#     std::cout << "Introduce el limite (double): ";
  li $v0, 4
  la $a0, strLimite
  syscall
#     std::cin >> limite;
  li $v0, 7
  syscall
  mov.d $f20, $f0
    
#     if (limite <= 0) {
  if:
    l.d $f0, const_limite_min
    c.lt.d $f0, $f20
    bc1t else
#         std::cout << "Error: Limite debe ser positivo\n";
    li $v0, 4
    la $a0, strError
    syscall
    b Fin
#     } else {
  else:
#         while (true) {
    while:
#             factorial = factorial * i;
      mtc1 $s0, $f2
      cvt.d.w $f2, $f2
      mul.d $f22, $f22, $f2

#             contador++;
      addi $s1, 1
#             std::cout << i << "! = " << factorial << "\n";
      li $v0, 3
      mov.d $f12, $f2
      syscall

      li $v0, 4
      la $a0, strFactorial
      syscall

      li $v0, 3
      mov.d $f12, $f22
      syscall

      li $v0, 4
      la $a0, strNewline 
      syscall
#             if (factorial > limite) {
      if_2:
        c.lt.d $f20, $f22
        bc1f if2_fin
#                 std::cout << "*** SUPERADO ***\n";
        li $v0, 4
        la $a0, strSuperado
        syscall
#                 break; 
        b while_fin
#             }
      if2_fin:
#             i++;
        addi $s0, 1
        b while
#         }
    while_fin:
#         std::cout << "\nFactoriales calculados: " << contador << "\n";
      li $v0, 4
      la $a0, strTotal
      syscall

      li $v0, 1
      move $a0, $s1
      syscall

      li $v0, 4
      la $a0, strNewline
      syscall
#     }
  if_fin:
    
#     std::cout << "\n=== Fin ===\n";
Fin:
  li $v0, 4
  la $a0, strFin
  syscall
  
  li $v0, 10
  syscall
# }