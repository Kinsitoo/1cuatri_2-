#include <iostream>
#using namespace std;

#int main() {
    #int n1, n2;
    
    #cout << "Introduce el primer numero: ";
    #in >> n1;
    
    #out << "Introduce el segundo numero: ";
    #cin >> n2;
    
    #if (n1 < 0 || n2 < 0) {
       #cout << "Error: Numeros negativos no permitidos" << endl;
    #} else {
        #float media = (float)(n1 + n2) / 2.0;
        #cout << "La media es: " << media << endl;
    #}
    
    #eturn 0;
#}


.data
    # Mensajes de entrada (prompts)
    prompt1:    .asciiz "Introduce el primer numero: "
    prompt2:    .asciiz "Introduce el segundo numero: "
    
    # Mensajes de salida
    msg_error:  .asciiz "Error: Numeros negativos no permitidos\n"
    msg_media:  .asciiz "La media es: "
    newline:    .asciiz "\n"
    
    # Constante flotante para el calculo (divisor)
    divisor:    .float  2.0


.text

main:

#Tabla de registros

#$s0 = n1
#$s1 = n2 
#$f20 = n1 en float
#$f22 = n2 en float
#$f24 = float media

#include <iostream>
#using namespace std;

#int main() {
    #int n1, n2;
    
    #cout << "Introduce el primer numero: ";

    li $v0, 4
    la $a0, prompt1
    syscall

    #in >> n1;

    li $v0, 5
    syscall
    move $s0, $v0
    
    #out << "Introduce el segundo numero: ";

    li $v0, 4
    la $a0, prompt2
    syscall

    #cin >> n2;

    li $v0, 5
    syscall
    move $s1, $v0
    
    #if (n1 < 0 || n2 < 0) {

    if:

      bgez $s0, else
      bgez $s1, else

      #cout << "Error: Numeros negativos no permitidos" << endl;

      li $v0, 4
      la $a0, msg_error
      syscall

      b Fin
      
    #} else {

      else:
      
        #float media = (float)(n1 + n2) / 2.0;

        mtc1 $s0, $f0
        cvt.s.w $f20, $f0

        mtc1 $s1, $f2
        cvt.s.w $f22, $f2
        
        add.s $f24, $f20, $f22
        l.s $f6, divisor
        div.s $f24, $f24, $f6

        #cout << "La media es: " << media << endl;

        li $v0, 4
        la $a0, msg_media
        syscall

        li $v0, 2
        mov.s $f12, $f24
        syscall

    #}
    
    #return 0;

Fin:

  li $v0, 10
  syscall
#}
  



