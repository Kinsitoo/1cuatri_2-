# #include <iostream>
# #include <iomanip>
# int main(void) {
#     std::cout << std::fixed << std::setprecision(8);  // Ignorar en MIPS
    
#     double celsius_ini, celsius_fin, celsius, fahrenheit, kelvin;
#     int incremento, contador = 0;
    
#     std::cout << "\n=== Conversor de Temperaturas ===\n";
    
#     do {
#         std::cout << "Temperatura inicial (C): ";
#         std::cin >> celsius_ini;
#         std::cout << "Temperatura final (C): ";
#         std::cin >> celsius_fin;
#         if (celsius_ini > celsius_fin) {
#             std::cout << "Error: Inicial no puede ser mayor que final\n";
#         }
#     } while (celsius_ini > celsius_fin);
    
#     std::cout << "Incremento (entero): ";
#     std::cin >> incremento;
    
#     for (celsius = celsius_ini; celsius <= celsius_fin; celsius += incremento) {
#         fahrenheit = celsius * 1.8 + 32.0;
#         kelvin = celsius + 273.15;
#         contador++;
        
#         if (celsius >= 0.0) {
#             std::cout << "C: " << celsius << " F: " << fahrenheit 
#                       << " K: " << kelvin << " [VALIDA]\n";
#         } else {
#             std::cout << "C: " << celsius << " F: " << fahrenheit 
#                       << " K: " << kelvin << " [BAJO CERO]\n";
#         }
#     }
    
#     std::cout << "\nTotal iteraciones: " << contador << "\n";
#     std::cout << "\n=== Fin del Programa ===\n";
# }

.data
strTitulo:      .asciiz "\n=== Conversor de Temperaturas ===\n"
strIni:         .asciiz "Temperatura inicial (C): "
strFin:         .asciiz "Temperatura final (C): "
strError:       .asciiz "Error: Inicial no puede ser mayor que final\n"
strInc:         .asciiz "Incremento (entero): "
strValida:      .asciiz " [VALIDA]\n"
strBajoCero:    .asciiz " [BAJO CERO]\n"
strTotal:       .asciiz "\nTotal iteraciones: "
strFinProg:     .asciiz "\n=== Fin del Programa ===\n"
strNewline:     .asciiz "\n"
strC:           .asciiz "C: "
strF:           .asciiz "  F: "
strK:           .asciiz "  K: "

# Constantes double para cálculos
const_1_8:      .double 1,8
const_32:       .double 32,0
const_273_15:   .double 273,15
const_cero:     .double 0,0

.text

#TABLA DE REGISTROS
#$f20 = celsius_ini
#$f22 = celsius_fin
#$s0 = incremento
#$f24 = fahrenheit
#$f26 = kelvin

main:
# int main(void) {
#     std::cout << std::fixed << std::setprecision(8);  // Ignorar en MIPS
    
#     double celsius_ini, celsius_fin, celsius, fahrenheit, kelvin;
#     int incremento, contador = 0;
    
#     std::cout << "\n=== Conversor de Temperaturas ===\n";
  li $v0, 4
  la $a0, strTitulo
  syscall
    
#     do {
  do_while:
#         std::cout << "Temperatura inicial (C): ";
    li $v0, 4
    la $a0, strIni
    syscall
#         std::cin >> celsius_ini;
    li $v0, 7
    syscall
    mov.d $f20, $f0
#         std::cout << "Temperatura final (C): ";
    li $v0, 4
    la $a0, strFin
    syscall
#         std::cin >> celsius_fin;
    li $v0, 7
    syscall
    mov.d $f22, $f0
#         if (celsius_ini > celsius_fin) {
      if:
        c.lt.d $f22, $f20
        bc1f do_while_fin
#             std::cout << "Error: Inicial no puede ser mayor que final\n";
        li $v0, 4
        la $a0, strError
        syscall
        b do_while
#         }
      if_fin:
#     } while (celsius_ini > celsius_fin);
    
  do_while_fin:
    
#     std::cout << "Incremento (entero): ";
  li $v0, 4
  la $a0, strInc
  syscall
#     std::cin >> incremento;
  li $v0, 5
  syscall
  move $s0, $v0

#     for (celsius = celsius_ini; celsius <= celsius_fin; celsius += incremento) {
  for:
    c.lt.d $f22, $f20
    bc1t for_fin
#         fahrenheit = celsius * 1.8 + 32.0;
      l.d $f0, const_1_8
      l.d $f2, const_32
      mul.d $f24, $f20, $f0
      add.d $f24, $f24, $f2
#         kelvin = celsius + 273.15;
      l.d $f4, const_273_15
      add.d $f26, $f20, $f4
#         contador++;
      addi $s1, 1
#         if (celsius >= 0.0) {
        if2:
          l.d $f6, const_cero
          c.le.d $f6, $f20
          bc1f else
#             std::cout << "C: " << celsius << " F: " << fahrenheit 
          li $v0, 4
          la $a0, strC
          syscall

          li $v0, 3
          mov.d $f12, $f20
          syscall

          li $v0, 4
          la $a0, strF
          syscall

          li $v0, 3
          mov.d $f12, $f24
          syscall
#                       << " K: " << kelvin << " [VALIDA]\n";
          li $v0, 4
          la $a0, strK
          syscall

          li $v0, 3
          mov.d $f12, $f26
          syscall

          li $v0, 4
          la $a0, strValida
          syscall

          mtc1 $s0, $f8
          cvt.d.w $f8, $f8
          add.d $f20, $f20, $f8
          b for
#         } else {
        else:
#             std::cout << "C: " << celsius << " F: " << fahrenheit 
          li $v0, 4
          la $a0, strC
          syscall

          li $v0, 3
          mov.d $f12, $f20
          syscall

          li $v0, 4
          la $a0, strF
          syscall

          li $v0, 3
          mov.d $f12, $f24
          syscall
#                       << " K: " << kelvin << " [BAJO CERO]\n";
          li $v0, 4
          la $a0, strK
          syscall

          li $v0, 3
          mov.d $f12, $f26
          syscall

          li $v0, 4
          la $a0, strBajoCero
          syscall

          mtc1 $s0, $f8
          cvt.d.w $f8, $f8
          add.d $f20, $f20, $f8
          b for
#         }
        if2_fin:

#     }
  for_fin:
    
#     std::cout << "\nTotal iteraciones: " << contador << "\n";
  li $v0, 4
  la $a0, strTotal
  syscall

  li $v0, 1
  move $a0, $s1
  syscall
#     std::cout << "\n=== Fin del Programa ===\n";
Fin:
  li $v0, 4
  la $a0, strFinProg
  syscall

  li $v0, 10
  syscall
# }
