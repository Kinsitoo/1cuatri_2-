# #include <iostream>
# #include <iomanip>
# int main(void) {
#     std::cout << std::fixed << std::setprecision(8);  // Ignorar en MIPS
    
#     double r, umbral, termino = 1.0, suma = 0.0;
#     int iteraciones = 0;
    
#     std::cout << "\n=== Serie Geometrica ===\n";
#     std::cout << "Introduce razon r (0 < r < 1): ";
#     std::cin >> r;
#     std::cout << "Introduce umbral de precision: ";
#     std::cin >> umbral;
    
#     if (r <= 0 || r >= 1) {
#         std::cout << "Error: r debe estar entre 0 y 1\n";
#     } else {
#         while (termino >= umbral) {
#             suma += termino;
#             termino *= r;
#             iteraciones++;
#         }
        
#         std::cout << "\nSuma final: " << suma << "\n";
#         std::cout << "Iteraciones: " << iteraciones << "\n";
#         std::cout << "Valor teorico: " << 1.0/(1.0-r) << "\n";
#     }
    
#     std::cout << "\n=== Fin ===\n";
# }

.data
strTitulo:      .asciiz "\n=== Serie Geometrica ===\n"
strR:           .asciiz "Introduce razon r (0 < r < 1): "
strUmbral:      .asciiz "Introduce umbral de precision: "
strError:       .asciiz "Error: r debe estar entre 0 y 1\n"
strSuma:        .asciiz "\nSuma final: "
strIter:        .asciiz "\nIteraciones: "
strTeorico:     .asciiz "\nValor teorico: "
strFin:         .asciiz "\n=== Fin ===\n"
strNewline:     .asciiz "\n"

# Constantes double para cálculos
const_uno:      .double 1,0
const_cero:     .double 0,0

.text

#TABLA DE REGISTROS
#$f20 = r
#$f22 = umbral
#$f24 = termino
#$f26 = suma
#$s0 = iteraciones

main:
# int main(void) {
#     std::cout << std::fixed << std::setprecision(8);  // Ignorar en MIPS
    
#     double r, umbral, termino = 1.0, suma = 0.0;
#     int iteraciones = 0;
  l.d $f24, const_uno
  l.d $f26, const_cero
    
#     std::cout << "\n=== Serie Geometrica ===\n";
  li $v0, 4
  la $a0, strTitulo
  syscall
#     std::cout << "Introduce razon r (0 < r < 1): ";
  li $v0, 4
  la $a0, strR
  syscall
#     std::cin >> r;
  li $v0, 7
  syscall
  mov.d $f20, $f0
#     std::cout << "Introduce umbral de precision: ";
  li $v0, 4
  la $a0, strUmbral
  syscall
#     std::cin >> umbral; 
  li $v0, 7
  syscall
  mov.d $f22, $f0
    
#     if (r <= 0 || r >= 1) {
  if:
    l.d $f0, const_cero
    l.d $f2, const_uno
    c.le.d $f0, $f20
    bc1f then
    c.le.d $f2, $f20
    bc1t then
    b else
#         std::cout << "Error: r debe estar entre 0 y 1\n";
  then:
    li $v0, 4
    la $a0, strError
    syscall
    b Fin
#     } else {
  else:
#         while (termino >= umbral) {
    while:
      c.lt.d $f22, $f24
      bc1f while_fin
#             suma += termino;
      add.d $f26, $f26, $f24
#             termino *= r;
      mul.d $f24, $f24, $f20
#             iteraciones++;
      addi $s0, 1
      b while
#         }
    while_fin:
#         std::cout << "\nSuma final: " << suma << "\n";
  li $v0, 4
  la $a0, strSuma
  syscall

  li $v0, 3
  mov.d $f12, $f26
  syscall

  li $v0, 4
  la $a0, strNewline
  syscall
#         std::cout << "Iteraciones: " << iteraciones << "\n";  
  li $v0, 4
  la $a0, strIter
  syscall

  li $v0, 1
  move $a0, $s0
  syscall

  li $v0, 4
  la $a0, strNewline
  syscall
#         std::cout << "Valor teorico: " << 1.0/(1.0-r) << "\n";  
  li $v0, 4
  la $a0, strTeorico
  syscall

  l.d $f0, const_uno
  sub.d $f2, $f0, $f20
  div.d $f4, $f0, $f2

  li $v0, 3
  mov.d $f12, $f4
  syscall

  li $v0, 4
  la $a0, strNewline
  syscall
#     }
    
#     std::cout << "\n=== Fin ===\n";
Fin:
  li $v0, 4
  la $a0, strFin
  syscall

  li $v0, 10
  syscall
# }
