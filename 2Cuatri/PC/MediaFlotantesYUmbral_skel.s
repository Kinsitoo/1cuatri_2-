#Autor: Kin Daniel Fortuno Pontillas
#Fecha: 12/03/2025

# // En un bucle solicitar flotantes hasta que se meta un 0.0
# // (que no se tendrá en cuenta).
# // Al final indicar el número de números introducidos, el valor media.
# // Si la media supera 1.5 sacar mensaje indicando que se supera el umbral.

# include <iostream>
# include <iomanip>

# int main() {
#   std::cout << std::fixed << std::setprecision(8);  // Ignorar
#   std::cout << "\nMedia de flotantes y umbral\n";
#   float acumulado = 0.0;
#   int numValores = 0;
#   while(true) {
#     float valor;
#     std::cout << "Introduce valor (0.0 para terminar): ";
#     std::cin >> valor;
#     if(valor == 0.0) {
#       break;
#     }
#     acumulado += valor;
#     numValores++;
#   }
#   if (numValores > 0) {
#     float media = acumulado / numValores;
#     std::cout << "\nSe introdujeron " << numValores
#         << " valores. Su media es " << media;
#     if (media > 1.5) {
#       std::cout << "\nSe supera el umbral";
#     }
#   } else {
#     std::cout << "\nNo se introdujo ningún valor";
#   }
#   std::cout << "\n\nTerminamos\n";
# }

	.data
strTitulo:	.asciiz	"\nMedia de flotantes y umbral\n"
strIntroduce:	.asciiz	"Introduce valor (0.0 para terminar): "
strSeIntrodujo:	.asciiz	"\nSe introdujeron "
strValores:	.asciiz	" valores. Su media es "
strSupera:	.asciiz	"\nSe supera el umbral"
strNingun:	.asciiz	"\nNo se introdujo ningún valor"
strTerminamos:	.asciiz	"\n\nTerminamos\n"
float_acumulado:	 .float 0.0
int_acumulado:	.word 0

	.text

main:
# int main() {
#   std::cout << std::fixed << std::setprecision(8);  // Ignorar
#   std::cout << "\nMedia de flotantes y umbral\n";
#   float acumulado = 0.0;
#   int numValores = 0;
#   while(true) {
#     float valor;
#     std::cout << "Introduce valor (0.0 para terminar): ";
#     std::cin >> valor;
#     if(valor == 0.0) {
#       break;
#     }
#     acumulado += valor;
#     numValores++;
#   }
#   if (numValores > 0) {
#     float media = acumulado / numValores;
#     std::cout << "\nSe introdujeron " << numValores
#         << " valores. Su media es " << media;
#     if (media > 1.5) {
#       std::cout << "\nSe supera el umbral";
#     }
#   } else {
#     std::cout << "\nNo se introdujo ningún valor";
#   }
#   std::cout << "\n\nTerminamos\n";
# }