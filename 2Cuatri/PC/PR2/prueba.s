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
		c.lt.s $f0, $f20
		bc1f error	
		c.lt.s $f0, $f21
		bc1f error
#         cout << "Error: Datos invalidos" << endl;
#         return 0;
#     }
    
#     imc = peso / (altura * altura);
	mul.s $f22, $f21, $f21
	div.s $f23, $f20, $f22
    
#     cout << "Tu IMC es: " << imc << endl;
	li $v0, 4
	la $a0, msg_imc
	syscall


	li $v0, 2
	mov.s $f12, $f23
  syscall

	li $v0, 4
	la $a0, newline
	syscall

#     if (imc < 18.5) {
	if_2:
		l.s $f0, umbral_bajo
		c.lt.s $f0, $f23
		bc1t elif
#         cout << "Estado: Bajo peso" << endl;
		li $v0, 4
		la $a0, msg_bajo
		syscall
		b Fin
#     } else if (imc < 25.0) {
	elif:
		l.s $f0, umbral_normal
		c.lt.s $f0, $f23
		bc1t else
#         cout << "Estado: Peso normal" << endl;
		li $v0, 4
		la $a0, msg_normal
		syscall
		b Fin
#     } else {
	else:
#         cout << "Estado: Sobrepeso" << endl;
		li $v0, 4
		la $a0, msg_sobre
		syscall
		b Fin
#     }
    
#     return 0;
# }

error:
	li $v0, 4
	la $a0 msg_error
	syscall

Fin:
	li $v0, 10
	syscall