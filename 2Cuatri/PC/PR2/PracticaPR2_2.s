#include <iostream>
#using namespace std;

#int main() {
#     int n, suma, i;
    
#     cout << "Introduce un numero positivo: ";
#     cin >> n;
    
#     if (n <= 0) {
#         cout << "Error: El numero debe ser positivo" << endl;
#     } else {
#         suma = 0;
#         i = 1;
#         while (i <= n) {
#             suma = suma + i;
#             i = i + 1;
#         }
#         cout << "La suma de 1 a " << n << " es: " << suma << endl;
#     }
    
#     return 0;
# }

.data
    prompt:     .asciiz "Introduce un numero positivo: "
    msg_error:  .asciiz "Error: El numero debe ser positivo\n"
    msg_result: .asciiz "La suma de 1 a "
    msg_es:     .asciiz " es: "
    newline:    .asciiz "\n"

.text

#Tabla de registros

#$s0 = n
#$s1 = suma
#$s2 = i


main:

#include <iostream>
#using namespace std;

#int main() {
#     int n, suma, i;
    
#     cout << "Introduce un numero positivo: ";

  li $v0, 4
  la $a0, prompt
  syscall

#     cin >> n;

  li $v0, 5
  syscall
  move $s0, $v0

#     if (n <= 0) {
  
  if:
    bgtz $s0, else

#         cout << "Error: El numero debe ser positivo" << endl;
    
    li $v0, 4
    la $a0, msg_error
    syscall

    b Fin

#     } else {

  else:
#         suma = 0;
  li $s1, 0
#         i = 1;
  li $s2, 1
#         while (i <= n) {
    while:
      bgt $s2, $s0, Fin

#             suma = suma + i;
      add $s0, $s0, $s2
#             i = i + 1;
      addi $s2, 1 
#         }
#         cout << "La suma de 1 a " << n << " es: " << suma << endl;
      li $v0, 4
      la $a0, msg_result
      syscall

      li $v0, 1
      move $a0, $s0
      syscall

      li $v0, 4
      la $a0, msg_es
      syscall

      li $v0, 1
      move $a0, $s0
      syscall

#     }
    
#     return 0;
Fin:

  li $v0, 10
  syscall
# }