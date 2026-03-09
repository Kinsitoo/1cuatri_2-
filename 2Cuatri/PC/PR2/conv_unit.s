# #include <iostream>
# #include <iomanip>
# int main() {
#     std::cout << std::setprecision(8);  // Ignorar en MIPS
    
#     std::cout << "\nConversor de Libras\n";
    
#     while(true) {
#         float libras;
#         std::cout << "\nIntroduce libras (0 o negativo para terminar): ";
#         std::cin >> libras;
        
#         if (libras <= 0.0) {
#             break;
#         }
        
#         float kilogramos = libras * 0.453592;
#         float onzas = libras * 16.0;
        
#         std::cout << libras << " libras = " << kilogramos << " kg y " 
#                   << onzas << " onzas\n";
        
#         if (kilogramos >= 10.0) {
#             std::cout << "- PESO ELEVADO\n";
#         } else {
#             std::cout << "- PESO NORMAL\n";
#         }
#     }
    
#     std::cout << "\nTermina el programa\n";
# }

.data
strTitulo:      .asciiz "\nConversor de Libras\n"
strIntro:       .asciiz "\nIntroduce libras (0 o negativo para terminar): "
strLibras:      .asciiz " libras = "
strKg:          .asciiz " kg y "
strOnzas:       .asciiz " onzas\n"
strElevado:     .asciiz "- PESO ELEVADO\n"
strNormal:      .asciiz "- PESO NORMAL\n"
strTermina:     .asciiz "\nTermina el programa\n"

# Constantes float para cálculos
const_kg:       .float  0,453592
const_onzas:    .float  16,0
const_umbral:   .float  10,0
const_cero:     .float  0,0

.text

#TABLA DE REGISTROS
#$f20 = libras
#$f21 = kg
#$f22 = onzas


main:
# int main() {
#     std::cout << std::setprecision(8);  // Ignorar en MIPS
    
#     std::cout << "\nConversor de Libras\n";
  li $v0, 4
  la $a0, strTitulo
  syscall
    
#     while(true) {
  while:
#         float libras;
#         std::cout << "\nIntroduce libras (0 o negativo para terminar): "; 
    li $v0, 4
    la $a0, strIntro
    syscall
#         std::cin >> libras;
    li $v0, 6
    syscall
    mov.s $f20, $f0
        
#         if (libras <= 0.0) {  
    if:
      l.s $f0, const_cero
      c.lt.s $f0, $f20
      bc1f Fin
#             break;
#         }
    if_fin:
        
#         float kilogramos = libras * 0.453592;
    l.s $f1, const_kg
    mul.s $f21, $f20, $f1
#         float onzas = libras * 16.0;
    l.s $f2, const_onzas
    mul.s $f22, $f20, $f2
#         std::cout << libras << " libras = " << kilogramos << " kg y " 
    li $v0, 2
    mov.s $f12, $f20
    syscall

    li $v0, 4
    la $a0, strLibras
    syscall

    li $v0, 2
    mov.s $f12, $f21
    syscall

    li $v0, 4
    la $a0, strKg
    syscall

#                   << onzas << " onzas\n";
    li $v0, 2
    mov.s $f12, $f22
    syscall

    li $v0, 4
    la $a0, strOnzas
    syscall
#         if (kilogramos >= 10.0) {
    if2:
      l.s $f3, const_umbral
      c.le.s $f3, $f21
      bc1f else
#             std::cout << "- PESO ELEVADO\n";
      li $v0, 4
      la $a0, strElevado
      syscall
      b while
#         } else {
    else:
#             std::cout << "- PESO NORMAL\n"; 
      li $v0, 4
      la $a0, strNormal
      syscall
      b while
#         }
    if2_fin:
#     }
  while_fin:
    
#     std::cout << "\nTermina el programa\n";
Fin:
  li $v0, 4
  la $a0, strTermina
  syscall

  li $v0, 10
  syscall
# }
