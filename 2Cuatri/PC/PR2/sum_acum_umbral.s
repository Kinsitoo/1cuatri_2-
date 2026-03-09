# #include <iostream>
# #include <iomanip>
# int main() {
#     std::cout << std::fixed << std::setprecision(8);  // Ignorar en MIPS
    
#     std::cout << "\nSuma Acumulada y Umbral\n";
    
#     float acumulado = 0.0;
#     int numValores = 0;
    
#     while(true) {
#         float valor;
#         std::cout << "Introduce valor (0.0 para terminar): ";
#         std::cin >> valor;
        
#         if (valor == 0.0) {
#             break;
#         }
        
#         acumulado += valor;
#         numValores++;
#     }
    
#     if (numValores > 0) {
#         std::cout << "\nSe introdujeron " << numValores 
#                   << " valores. Suma total: " << acumulado;
        
#         if (acumulado >= 100.0) {
#             std::cout << "\nSe supera el umbral de 100";
#         } else {
#             std::cout << "\nNo supera el umbral de 100";
#         }
#     } else {
#         std::cout << "\nNo se introdujo ningún valor";
#     }
    
#     std::cout << "\n\nTerminamos\n";
# }

.data
strTitulo:      .asciiz "\nSuma Acumulada y Umbral\n"
strIntroduce:   .asciiz "Introduce valor (0.0 para terminar): "
strSeIntrodujo: .asciiz "\nSe introdujeron "
strValores:     .asciiz " valores. Suma total: "
strSupera:      .asciiz "\nSe supera el umbral de 100"
strNoSupera:    .asciiz "\nNo supera el umbral de 100"
strNingun:      .asciiz "\nNo se introdujo ningún valor"
strTerminamos:  .asciiz "\n\nTerminamos\n"

# Constantes float
float_cero:     .float  0,0
float_umbral:   .float  100,0

.text

#TABLA DE REGISTROS
#$f20 = acumulado
#$s0, = numValores
#$f21 = valor

main:
# int main() {
#     std::cout << std::fixed << std::setprecision(8);  // Ignorar en MIPS
    
#     std::cout << "\nSuma Acumulada y Umbral\n";
  li $v0, 4
  la $a0, strTitulo
  syscall
    
#     float acumulado = 0.0;
  l.s $f20, float_cero
#     int numValores = 0;
  li $s0, 0
    
#     while(true) {
  while:
#         float valor;
#         std::cout << "Introduce valor (0.0 para terminar): ";
    li $v0, 4
    la $a0, strIntroduce
    syscall
#         std::cin >> valor;
    li $v0, 6
    syscall
    mov.s $f21, $f0
        
#         if (valor == 0.0) {
    if:
      l.s $f0, float_cero
      c.eq.s $f21, $f0
      bc1t while_fin
#             break;
#         }
    if_fin:
        
#         acumulado += valor;
    add.s $f20, $f20, $f21
#         numValores++;
    addi $s0, 1
#     }
    b while
  while_fin:
    
#     if (numValores > 0) {
  if2:
    li $t0, 0
    ble $s0, $t0, else
#         std::cout << "\nSe introdujeron " << numValores 
    li $v0, 4
    la $a0, strSeIntrodujo
    syscall
#                   << " valores. Suma total: " << acumulado;
    li $v0, 1
    move $a0, $s0
    syscall

    li $v0, 4
    la $a0, strValores
    syscall

    li $v0, 2 
    mov.s $f12, $f20
    syscall
        
#         if (acumulado >= 100.0) { 
      if3:
        l.s $f1, float_umbral
        c.le.s $f1, $f20
        bc1f else_2
#             std::cout << "\nSe supera el umbral de 100"; 
        li $v0, 4
        la $a0, strSupera
        syscall
        b Fin
#         } else {
      else_2:
#             std::cout << "\nNo supera el umbral de 100";
        li $v0, 4
        la $a0, strNoSupera
        syscall
        b Fin
#         }
#     } else {
  else:
#         std::cout << "\nNo se introdujo ningún valor"; 
    li $v0, 4
    la $a0, strNingun
    syscall
#     }
    
#     std::cout << "\n\nTerminamos\n";

Fin:
  li $v0, 4
  la $a0, strTerminamos
  syscall

  li $v0, 10
  syscall
# }
