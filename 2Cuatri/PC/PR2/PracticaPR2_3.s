# #include <iostream>
# using namespace std;

# int main() {
#     float precio, total;
#     int cantidad;
    
#     cout << "Introduce precio unitario: ";
#     cin >> precio;
    
#     cout << "Introduce cantidad: ";
#     cin >> cantidad;
    
#     if (cantidad <= 0) {
#         cout << "Error: Cantidad invalida" << endl;
#         return 0;
#     }
    
#     // Ojo: Multiplicar float por int requiere conversión
#     total = precio * (float)cantidad;
    
#     if (total > 100.0) {
#         total = total * 0.9; // Aplicar descuento
#     }
    
#     cout << "El total a pagar es: " << total << endl;
    
#     return 0;
# # }

.data
    prompt_precio: .asciiz "Introduce precio unitario: "
    prompt_cant:   .asciiz "Introduce cantidad: "
    msg_error:     .asciiz "Error: Cantidad invalida\n"
    msg_total:     .asciiz "El total a pagar es: "
    newline:       .asciiz "\n"
    
    # Constantes flotantes para lógica
    umbral:        .float  100.0
    descuento:     .float  0,9

.text

#Tabla de registros

#$s1 = cantidad
#$f20 = precio en float
#$f22 = cantidad en float
#$f24 = total

main:

# int main() {
#     float precio, total;
#     int cantidad;
    
#     cout << "Introduce precio unitario: ";
  li $v0, 4
  la $a0, prompt_precio
  syscall

#     cin >> precio;
  li $v0, 6
  syscall
  mov.s $f20, $f0
    
#     cout << "Introduce cantidad: ";
  li $v0, 4
  la $a0, prompt_cant
  syscall

#     cin >> cantidad;
  li $v0, 5
  syscall
  move $s1, $v0
    
#     if (cantidad <= 0) {
  if:
    bgtz $s1, if_2
#         cout << "Error: Cantidad invalida" << endl;
#         return 0;
    li $v0, 4
    la $a0, msg_error
    syscall

    b Fin
#     }
    

#     if (total > 100.0) {
  if_2:
  
    mtc1 $s1, $f0
    cvt.s.w $f22, $f0

#     total = precio * (float)cantidad;

    mul.s $f24, $f20, $f22


    l.s $f26, umbral
    c.lt.s $f26 ,$f24
    bc1f Fin
    
#         total = total * 0.9; // Aplicar descuento
    l.s $f4, descuento
    mul.s $f24, $f24, $f4

#}
    
#  cout << "El total a pagar es: " << total << endl;
    li $v0, 4
    la $a0, msg_total
    syscall
    
    li $v0, 2
    mov.s $f12, $f24
    syscall
#  return 0;

Fin:

  li $v0, 10
  syscall
# }

