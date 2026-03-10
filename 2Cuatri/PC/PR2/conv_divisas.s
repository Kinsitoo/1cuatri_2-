# #include <iostream>
# #include <iomanip>
# int main() {
#     std::cout << std::fixed << std::setprecision(8);  // Ignorar en MIPS
    
#     float tasaCambio = 1.08;  // 1 euro = 1.08 dólares
#     float acumuladoEuros = 0.0;
#     float acumuladoDolares = 0.0;
#     int numConversiones = 0;
    
#     std::cout << "\nConversor de Divisas (EUR -> USD)\n";
    
#     while(true) {
#         float euros;
#         std::cout << "Introduce cantidad en euros (0.0 para terminar): ";
#         std::cin >> euros;
        
#         if (euros == 0.0) {
#             break;
#         }
        
#         float dolares = euros * tasaCambio;
#         acumuladoEuros += euros;
#         acumuladoDolares += dolares;
#         numConversiones++;
        
#         std::cout << euros << " EUR = " << dolares << " USD\n";
#     }
    
#     if (numConversiones > 0) {
#         std::cout << "\nTotal: " << acumuladoEuros << " EUR = " 
#                   << acumuladoDolares << " USD\n";
#         std::cout << "Conversiones realizadas: " << numConversiones << "\n";
        
#         if (acumuladoDolares >= 100.0) {
#             std::cout << "Se supera el umbral de 100 USD\n";
#         }
#     } else {
#         std::cout << "\nNo se realizó ninguna conversión\n";
#     }
    
#     std::cout << "\nTerminamos\n";
# }

.data
strTitulo:      .asciiz "\nConversor de Divisas (EUR -> USD)\n"
strIntro:       .asciiz "Introduce cantidad en euros (0.0 para terminar): "
strIgual:       .asciiz " EUR = "
strUSD:         .asciiz " USD\n"
strTotal:       .asciiz "\nTotal: "
strEUR:         .asciiz " EUR = "
strConversiones:.asciiz "\nConversiones realizadas: "
strSupera:      .asciiz "Se supera el umbral de 100 USD\n"
strNinguna:     .asciiz "\nNo se realizó ninguna conversión\n"
strTerminamos:  .asciiz "\nTerminamos\n"
strNewline:     .asciiz "\n"  

# Constantes float
const_tasa:     .float 1,08
const_cero:     .float 0,0
const_umbral:   .float 100,0

.text


#TABLA DE REGISTROS
#$f20 = tasaCambio
#$f21 = acumuladoEuros
#$f22 = acumuladoDolares
#$s0 = numConversiones
#$f23 = euros
#$f24 = dolares
main:
# int main() {
#     std::cout << std::fixed << std::setprecision(8);  // Ignorar en MIPS
    
#     float tasaCambio = 1.08;  // 1 euro = 1.08 dólares
  l.s $f20, const_tasa
#     float acumuladoEuros = 0.0;
  l.s $f21, const_cero
#     float acumuladoDolares = 0.0;
  l.s $f22, const_cero
#     int numConversiones = 0;
  li $s0, 0
    
#     std::cout << "\nConversor de Divisas (EUR -> USD)\n";
  li $v0, 4
  la $a0, strTitulo
  syscall
#     while(true) {
  while:
#         float euros;
#         std::cout << "Introduce cantidad en euros (0.0 para terminar): ";
    li $v0, 4
    la $a0, strIntro
    syscall
#         std::cin >> euros;
    li $v0, 6
    syscall
    mov.s $f23, $f0
#         if (euros == 0.0) {
    if:
      l.s $f0, const_cero
      c.eq.s $f23, $f0
      bc1t else

    if_fin:
#             break;
#         }
        
#         float dolares = euros * tasaCambio;
    mul.s $f24, $f23, $f20
#         acumuladoEuros += euros;
    add.s $f21, $f21, $f23
#         acumuladoDolares += dolares; 
    add.s $f22, $f22, $f24
#         numConversiones++;
    addi $s0, 1

    b while
        
#         std::cout << euros << " EUR = " << dolares << " USD\n";
    li $v0, 2
    mov.s $f12, $f23
    syscall

    li $v0, 4
    la $a0, strIgual
    syscall

    li $v0, 2
    mov.s $f12, $f24
    syscall

    li $v0, 4
    la $a0, strUSD
    syscall
#     }
  while_fin:
#     if (numConversiones > 0) {
  if_2:
    bltz $s0, else
#         std::cout << "\nTotal: " << acumuladoEuros << " EUR = " 
    li $v0, 4
    la $a0, strTotal
    syscall

    li $v0, 2
    mov.s $f12, $f21
    syscall

    li $v0, 4
    la $a0, strEUR
    syscall
#                   << acumuladoDolares << " USD\n";
    li $v0, 2
    mov.s $f12, $f22
    syscall

    li $v0, 4
    la $a0,strUSD
    syscall
#         std::cout << "Conversiones realizadas: " << numConversiones << "\n";
    li $v0, 4
    la $a0, strConversiones
    syscall

    li $v0, 1
    move $a0, $s0
    syscall

    li $v0, 4
    la $a0, strNewline
    syscall
#         if (acumuladoDolares >= 100.0) {
    if_3:
      l.s $f0, const_umbral
      c.le.s $f0, $f22
      bc1f Fin
#             std::cout << "Se supera el umbral de 100 USD\n";
      li $v0, 4
      la $a0, strSupera
      syscall
      b Fin
#         }
#     } else {
  else:
#         std::cout << "\nNo se realizó ninguna conversión\n";
    li $v0, 4
    la $a0, strNinguna
    syscall
#     }
    
#     std::cout << "\nTerminamos\n";
Fin:
  li $v0, 4
  la $a0, strTerminamos
  syscall

  li $v0, 10
  syscall
# }