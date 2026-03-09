# #include <iostream>
# #include <iomanip>
# int main() {
#     std::cout << std::fixed << std::setprecision(8);  // Ignorar en MIPS
    
#     float pi = 3.141592;
#     int r, s;
    
#     std::cout << "\nCalculo de Areas de Circulos\n";
#     std::cout << "para radios en rango [r, s]\n";
    
#     do {
#         std::cout << "\nLímite inferior r: ";
#         std::cin >> r;
#         std::cout << "Límite superior s: ";
#         std::cin >> s;
#     } while (r > s || r <= 0);
    
#     for (int radio = r; radio <= s; radio++) {
#         float area = pi * radio * radio;
        
#         std::cout << "Radio " << radio << ": Area = " << area;
        
#         if (area >= 50.0) {
#             std::cout << " [GRANDE]";
#         } else {
#             std::cout << " [PEQUEÑO]";
#         }
#         std::cout << '\n';
#     }
    
#     std::cout << "\nTermina el programa\n";
# }

.data
strTitulo:      .asciiz "\nCalculo de Areas de Circulos\n"
strRango:       .asciiz "para radios en rango [r, s]\n"
strIntroR:      .asciiz "\nLímite inferior r: "
strIntroS:      .asciiz "Límite superior s: "
strRadio:       .asciiz "Radio "
strArea:        .asciiz ": Area = "
strGrande:      .asciiz " [GRANDE]"
strPequeno:     .asciiz " [PEQUEÑO]"
strNewline:     .asciiz "\n"
strTermina:     .asciiz "\nTermina el programa\n"

# Constantes float
const_pi:       .float  3,141592
const_umbral:   .float  50,0

.text


#TABLA DE REGISTROS
#$f20 = pi
#$s0 = r
#$s1 = s
#$f21 = area
main:
# int main() {
#     std::cout << std::fixed << std::setprecision(8);  // Ignorar en MIPS
    
#     float pi = 3.141592;
  l.s $f20, const_pi
#     int r, s;
    
#     std::cout << "\nCalculo de Areas de Circulos\n";
  li $v0, 4
  la $a0, strTitulo
  syscall
#     std::cout << "para radios en rango [r, s]\n";
  li $v0, 4
  la $a0, strRango
  syscall
#     do {
  do_while:
#         std::cout << "\nLímite inferior r: ";
    li $v0, 4
    la $a0, strIntroR
    syscall
#         std::cin >> r;
    li $v0, 5
    syscall
    move $s0, $v0

#         std::cout << "Límite superior s: ";
    li $v0, 4
    la $a0, strIntroS
    syscall
#         std::cin >> s;
    li $v0, 5
    syscall
    move $s1, $v0
#     } while (r > s || r <= 0);
    ble $s0, $s1, for
    bgez $s0, do_while
    b for
  do_while_fin:
    
#     for (int radio = r; radio <= s; radio++) { 
  for:  
    bgt $s0, $s1, for_fin 
#         float area = pi * radio * radio;
    mtc1 $s0, $f0
    cvt.s.w $f0, $f0
    mul.s $f0, $f0, $f0
    mul.s $f21, $f20, $f0
#         std::cout << "Radio " << radio << ": Area = " << area;
    li $v0, 4
    la $a0, strRadio
    syscall
    
    li $v0, 1
    move $a0, $s0
    syscall

    li $v0, 4
    la $a0, strArea
    syscall

    li $v0, 2
    mov.s $f12, $f21
    syscall
#         if (area >= 50.0) {
    if:
      l.s $f0, const_umbral
      c.le.s $f0, $f21
      bc1f else
#             std::cout << " [GRANDE]"; 
      li $v0, 4
      la $a0, strGrande
      syscall
      b if_fin
      
#         } else {
    else:
#             std::cout << " [PEQUEÑO]";  
      li $v0, 4
      la $a0, strPequeno
      syscall
#         }
#         std::cout << '\n';
    if_fin:
      li $v0, 4
      la $a0, strNewline
      syscall
#     }
    addi $s0, 1
    b for
  for_fin:
    
#     std::cout << "\nTermina el programa\n";
Fin:
  li $v0, 4
  la $a0, strTermina
  syscall

  li $v0, 10
  syscall
# }
