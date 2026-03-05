# #include <iostream>
# using namespace std;

# int main() {
#     float peso, altura, imc;
    
#     cout << "Introduce tu peso (kg): ";
#     cin >> peso;
    
#     cout << "Introduce tu altura (m): ";
#     cin >> altura;
    
#     if (peso <= 0 || altura <= 0) {
#         cout << "Error: Datos invalidos" << endl;
#         return 0;
#     }
    
#     imc = peso / (altura * altura);
    
#     cout << "Tu IMC es: " << imc << endl;
    
#     if (imc < 18.5) {
#         cout << "Estado: Bajo peso" << endl;
#     } else if (imc < 25.0) {
#         cout << "Estado: Peso normal" << endl;
#     } else {
#         cout << "Estado: Sobrepeso" << endl;
#     }
    
#     return 0;
# }

.data
    prompt_peso:    .asciiz "Introduce tu peso (kg): "
    prompt_altura:  .asciiz "Introduce tu altura (m): "
    msg_error:      .asciiz "Error: Datos invalidos\n"
    msg_imc:        .asciiz "Tu IMC es: "
    msg_bajo:       .asciiz "Estado: Bajo peso\n"
    msg_normal:     .asciiz "Estado: Peso normal\n"
    msg_sobre:      .asciiz "Estado: Sobrepeso\n"
    newline:        .asciiz "\n"
    
    # Constantes flotantes para comparaciones
    umbral_bajo:    .float  18.5
    umbral_normal:  .float  25.0
    cero:           .float  0.0


.text

#Tabla de registros
#$f20 = peso
#$f21 = altura



main:
# int main() {
#     float peso, altura, imc;
    
#     cout << "Introduce tu peso (kg): ";
  li $v0, 4
  la $a0, prompt_peso
  syscall

#     cin >> peso;
  li $v0, 6
  syscall
  mov.s $f20, $f0
  
    
#     cout << "Introduce tu altura (m): ";
  li $v0, 4
  la $a0, prompt_altura 
  syscall

#     cin >> altura;
  li $v0, 6
  syscall
  mov.s $f21, $f0
    
#     if (peso <= 0 || altura <= 0) {
  if:
    l.s $f0, cero
    c.lt.s $f20, $f0
    bc1f then

    c.lt.s $f21, $f0
    bc1f then
    
#         cout << "Error: Datos invalidos" << endl;
#         return 0;
    li $v0, 4
    la $a0, msg_error
    syscall
    b Fin
#     }
  
  then:
#     imc = peso / (altura * altura);
    mul.s $f21, $f21, $f21
    div.s $f22, $f20, $f21
#     cout << "Tu IMC es: " << imc << endl;

    li $v0, 4
    la $a0, msg_imc
    syscall

    
#     if (imc < 18.5) {
#         cout << "Estado: Bajo peso" << endl;
#     } else if (imc < 25.0) {
#         cout << "Estado: Peso normal" << endl;
#     } else {
#         cout << "Estado: Sobrepeso" << endl;
#     }
    
#     return 0;
Fin:
  li $v0, 10
  syscall
# }