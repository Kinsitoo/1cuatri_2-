# // Calcular la distancia en metros recorrida por un vehículo. Para ello,
# // se solicitarán dos números enteros por consola: la velocidad expresada
# // en Km/h y tiempo que ha circulado a esa velocidad
# // (expresada en segundos).
# // El programa mostrará por consola un número flotante de doble precisión
# // que representa los metros recorridos por el vehículo. Si la distancia
# // recorrida es mayor de 250.0 metros debe sacar mensaje indicando
# // que "LLEGA", caso contrario que "NO Llega".
# // El programa funcionará de forma cíclica (volviendo a solicitar
# // los valores de entrada) hasta que uno de los datos
# // introducidos sea un cero.

# #include <iostream>
# #include <iomanip>
# int main() {
#   std::cout << "\nDistancia Recorrida\n";
#
#   while(true) {
#     std::cout << std::setprecision(18); // Ignorar
#     int velocidad;
#     std::cout << "\nIntroduce la velocidad en Km/h (entero): ";
#     std::cin >> velocidad;
#
#     int segundos;
#     std::cout << "Introduce los segundos (entero): ";
#     std::cin >> segundos;
#
#     if ((velocidad == 0) || (segundos == 0)) {
#       break;
#     }
#     double distancia = 1000.0 / 3600.0 * velocidad * segundos;
#     std::cout << "Yendo a " << velocidad << "Km/h durante " << segundos
#       << " sg se recorre " << distancia << " metros.";
#     if (distancia > 250.0) {
#       std::cout << "\n- LLEGA\n";
#     } else {
#       std::cout << "\n- No Llega\n";
#     }
#   }
#   std::cout << "\nTermina el programa\n";
# }

	.data
strTitulo:	.asciiz	"\nDistancia Recorrida\n"
strIntroVel:	.asciiz	"\nIntroduce la velocidad en Km/h (entero): "
strIntroSg:	.asciiz	"Introduce los segundos (entero): "
strYendo:	.asciiz	"Yendo a "
strDurante:	.asciiz	"Km/h durante "
strRecorre:	.asciiz	" sg se recorre "
strMetros:	.asciiz	" metros."
strLlega:	.asciiz	"\n- LLEGA\n"
strNoLlega:	.asciiz	"\n- No Llega\n"
strTermina:	.asciiz	"\nTermina el programa\n"

.text

main:

# int main() {
#   std::cout << "\nDistancia Recorrida\n";
#
#   while(true) {
#     std::cout << std::setprecision(18); // Ignorar
#     int velocidad;
#     std::cout << "\nIntroduce la velocidad en Km/h (entero): ";
#     std::cin >> velocidad;
#
#     int segundos;
#     std::cout << "Introduce los segundos (entero): ";
#     std::cin >> segundos;
#
#     if ((velocidad == 0) || (segundos == 0)) {
#       break;
#     }
#     double distancia = 1000.0 / 3600.0 * velocidad * segundos;
#     std::cout << "Yendo a " << velocidad << "Km/h durante " << segundos
#       << " sg se recorre " << distancia << " metros.";
#     if (distancia > 250.0) {
#       std::cout << "\n- LLEGA\n";
#     } else {
#       std::cout << "\n- No Llega\n";
#     }
#   }
#   std::cout << "\nTermina el programa\n";
# }
