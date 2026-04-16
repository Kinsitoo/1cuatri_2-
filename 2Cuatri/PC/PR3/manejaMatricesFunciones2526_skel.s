# Autor: Kin Daniel Fortuno Pontillas
# Fecha: 16/04/2026

#LC_NUMERIC=en_US.UTF-8 qtspim
# // Manejo de matrices con funciones

# #include <iostream>
# #include <iomanip>
# #include <tuple>

# typedef struct {
#   int nFil;
#   int nCol;
#   double elementos[];
# } structMat;


# structMat mat0 {
#   6,
#   6,
#   {
#     11.125, 12.125, 13.125, 14.125, 15.125, 16.125,
#     21.125, 22.125, 23.125, 24.125, 25.375, 26.375,
#     31.375, 32.375, 33.375, 34.375, 35.375, 36.375,
#     41.375, 42.375, 43.375, 44.375, 45.375, 46.375,
#     51.625, 52.625, 53.625, 54.625, 55.625, 56.625,
#     61.625, 62.625, 63.625, 64.625, 65.625, 66.625,

#   }
# };

# structMat mat1 {
#   10,
#   7,
#   {
#     -36.9375, -58.1875, 78.65625, 19.09375, -50.8125, 33.96875, -59.5625,
#     12.34375, 57.28125, -1.96875, -86.8125, -81.8125, 54.59375, -22.5625,
#     88.21875, 64.34375, 52.90625, 47.90625, -83.5625, 19.03125, 4.265625,
#     -31.9375, 82.53125, 27.40625, 56.53125, 39.46875, 18.40625, 97.03125,
#     76.90625, 14.59375, 67.78125, -9.84375, -97.9375, 32.34375, -18.4375,
#     -43.4375, 39.84375, 87.65625, -31.9375, -17.8125, 30.09375, 87.65625,
#     -6.90625, 64.59375, -85.0625, 70.53125, -48.8125, -62.6875, -60.1875,
#     -5.53125, 84.34375, -51.6875, 93.15625, -10.8125, 32.09375, 98.34375,
#     69.46875, 73.84375, 3.734375, 57.21875, -41.5625, -17.4375, -64.1875,
#     -71.3125, -97.9375, 7.109375, -79.0625, 33.84375, 63.53125, -96.1875,

#   }
# };

# structMat mat2 {
#   1,
#   8,
#   {
#     -36.75, 35.375, 79.125, -58.75, -55.25, -19.25, -88.75, -93.75,
#   }
# };

# structMat mat3 {
#   16,
#   1,
#   {
#     -90.75, -65.25, -58.25, -73.25, -89.25, -79.25, 16.875, 66.375,
#     -96.25, -97.25, -24.75, 5.3125, -33.75, -13.25, 27.125, -74.75,

#   }
# };

# structMat mat4 {
#   1,
#   1,
#   { 78.875 }
# };

# structMat mat5 {
#   0,
#   0,
#   { 0 }
# };

# #define NUM_MATRICES  6
# structMat* matrices[NUM_MATRICES]={&mat0, &mat1, &mat2, &mat3, &mat4, &mat5};

# void print_mat(structMat* mat) {
#   int nFil = mat->nFil;
#   int nCol = mat->nCol;
#   double* datos = mat->elementos;
#   std::cout << "\n\nLa matriz tiene dimension " << nFil
#       << 'x' << nCol << '\n';
#   for(int f = 0; f < nFil; f++) {
#     for(int c = 0; c < nCol; c++) {
#       std::cout << datos[f*nCol + c] << ' ';  // datos[f][c]
#     }
#     std::cout << '\n';
#   }
#   std::cout << '\n';
# }

# void change_elto(structMat* mat, int indF, int indC, double valor) {
#   int numCol = mat->nCol;
#   double* datos = mat->elementos;
#   datos[indF * numCol + indC] = valor;  // datos[indF][indC]
# }

# void swap(double* e1, double* e2) {
#   double temp1 = *e1;
#   double temp2 = *e2;
#   *e1 = temp2;
#   *e2 = temp1;
# }

# void intercambia(structMat* mat, int indF, int indC) {
#   int numCol = mat->nCol;
#   int numFil = mat->nFil;
#   double* datos = mat->elementos;
#   // e1 = &(datos[indF][indC]);
#   double* e1 = datos + (indF * numCol + indC);
#   int indFilaOpuesta = (numFil - indF - 1);
#   int indColOpuesta = (numCol - indC - 1);
#   // e1 = &(datos[indFilaOpuesta][indColOpuesta])
#   double* e2 = datos + (indFilaOpuesta * numCol + indColOpuesta);
#   swap(e1, e2);
# }

# void procesa_cols(structMat* mat, int indC1, int indC2) {
#   int numCol = mat->nCol;
#   int numFil = mat->nFil;
#   double* datos = mat->elementos;
#   for(int fa = 0; fa < numFil; fa++) {
#     // e1 = &(datos[fa][indC1]);
#     double* e1 = datos + (fa * numCol + indC1);
#     // e2 = &(datos[fa][indC2]);
#     double* e2 = datos + (fa * numCol + indC2);
#     double val1 = *e1;
#     double val2 = *e2;
#     if(val1 > val2) {
#       *e1 = val1 / 2.0;
#     } else {
#       swap(e1, e2);
#     }
#     *e2 = *e2 + 0.5625;
#   }
# }

# double find_max(structMat* mat) {					
#   int numCol = mat->nCol;
#   int numFil = mat->nFil;
#   double* datos = mat->elementos;
#   double max = datos[0];
#   for(int f = 0; f < numFil; f++) {
#     for(int c = 0; c < numCol; c++) {
#       double valor = datos[f * numCol + c];  // datos[f][c]
#       if (valor > max) {
#         max = valor;
#         std::cout << "\nNuevo maximo " << max;
#       }
#     }
#   }
#   return max;
# }

# int leeFila(int numFilas) {
#   int indFil;
#   std::cin >> indFil;
#   if ((indFil < 0) || (indFil >= numFilas)) {
#     std::cout << "Error: Numero de fila incorrecto\n";
#     return -1;
#   }
#   return indFil;
# }

# int leeColumna(int numColumnas) {
#   int indCol;
#   std::cin >> indCol;
#   if ((indCol < 0) || (indCol >= numColumnas)){
#     std::cout << "Error: Numero de columna incorrecto\n";
#     return -1;
#   }
#   return indCol;
# }

# std::tuple<int, int> pideFilaYColumna(structMat* mat) {
#   std::cout << "\nIndice de fila: ";
#   int indFil = leeFila(mat->nFil);
#   if (indFil < 0) {
#     return {-1, -1};
#   }
#   std::cout << "Indice de columna: ";
#   int indCol = leeColumna(mat->nCol);
#   if (indCol < 0) {
#     return {-1, -1};
#   }
#   return {indFil, indCol};
# }

# int main() {
#   std::cout << std::setprecision(18); // Ignorar
#   std::cout << "\nComienza programa manejo matrices con funciones";

#   structMat* matTrabajo = matrices[0];
#   int opcion;
#   do {
#     print_mat(matTrabajo);
#     std::cout <<
#     "(0) Terminar el programa\n"
#     "(1) Cambiar la matriz de trabajo\n"
#     "(3) Cambiar el valor de un elemento\n"
#     "(4) Intercambiar un elemento con su opuesto\n"
#     "(5) Procesa columnas\n"
#     "(7) Encuentra maximo\n"
#     "\nIntroduce opción elegida: ";

#     std::cin >> opcion;

#     int indFil;
#     int indCol;
#     switch (opcion) {
#       // Opción 0 //////////////////////////////////////////////////////////
#       case 0:
#         std::cout << "\nEligida opción de salir";
#         break; // salimos del switch
#       // Opción 1 //////////////////////////////////////////////////////////
#       case 1:
#         std::cout << "\nElije la matriz de trabajo: ";
#         int matT;
#         std::cin >> matT;
#         if ((matT < 0) || (matT >= NUM_MATRICES)) {
#           std::cout << "Numero de matriz de trabajo incorrecto\n";
#           break; // salimos del switch
#         }
#         matTrabajo = matrices[matT];
#         break; // salimos del switch

#       // Opción 3 //////////////////////////////////////////////////////////
#       case 3:
#         std::tie(indFil, indCol) = pideFilaYColumna(matTrabajo);
#         if (indFil < 0)
#           break; // salimos del switch
#         std::cout << "Nuevo valor para el elemento: ";
#         double valor;
#         std::cin >> valor;

#         change_elto(matTrabajo, indFil, indCol, valor);

#         break; // salimos del switch

#       // Opción 4 //////////////////////////////////////////////////////////
#       case 4:
#         std::tie(indFil, indCol) = pideFilaYColumna(matTrabajo);
#         if (indFil < 0)
#           break; // salimos del switch

#         intercambia(matTrabajo, indFil, indCol);

#         break; // salimos del switch

#       // Opción 5 //////////////////////////////////////////////////////////
#       case 5:
#         std::cout << "\nPrimera columna a procesar: ";
#         int indC1;
#         indC1 = leeColumna(matTrabajo->nCol);
#         if (indC1 < 0) {
#           break; // salimos del switch
#         }
#         std::cout << "Segunda columna a procesar: ";
#         int indC2;
#         indC2 = leeColumna(matTrabajo->nCol);
#         if (indC2 < 0) {
#           break;  // salimos del switch
#         }

#         procesa_cols(matTrabajo, indC1, indC2);
#         break;  // salimos del switch

#       // Opción 7 //////////////////////////////////////////////////////////
#       case 7:
#         double maximo;
#         maximo = find_max(matTrabajo);
#         std::cout << "\nEl valor maximo en la matriz es " << maximo;
#         break; // salimos del switch

#       default:
#         // Opción Incorrecta ////////////////////////////////////////////////
#         std::cout << "Error: opcion incorrecta\n";
#     }  // fin del switch
#     std::cout << "\nTerminada la opción " << opcion;
#   } while (opcion != 0);
#   std::cout << "\n\nTermina el programa\n";
# }
    .data
mat0:   .word 6, 6
    .double 11.125, 12.125, 13.125, 14.125, 15.125, 16.125
    .double 21.125, 22.125, 23.125, 24.125, 25.375, 26.375
    .double 31.375, 32.375, 33.375, 34.375, 35.375, 36.375
    .double 41.375, 42.375, 43.375, 44.375, 45.375, 46.375
    .double 51.625, 52.625, 53.625, 54.625, 55.625, 56.625
    .double 61.625, 62.625, 63.625, 64.625, 65.625, 66.625

mat1:   .word 10, 7
    .double -36.9375, -58.1875, 78.65625, 19.09375, -50.8125, 33.96875, -59.5625
    .double 12.34375, 57.28125, -1.96875, -86.8125, -81.8125, 54.59375, -22.5625
    .double 88.21875, 64.34375, 52.90625, 47.90625, -83.5625, 19.03125, 4.265625
    .double -31.9375, 82.53125, 27.40625, 56.53125, 39.46875, 18.40625, 97.03125
    .double 76.90625, 14.59375, 67.78125, -9.84375, -97.9375, 32.34375, -18.4375
    .double -43.4375, 39.84375, 87.65625, -31.9375, -17.8125, 30.09375, 87.65625
    .double -6.90625, 64.59375, -85.0625, 70.53125, -48.8125, -62.6875, -60.1875
    .double -5.53125, 84.34375, -51.6875, 93.15625, -10.8125, 32.09375, 98.34375
    .double 69.46875, 73.84375, 3.734375, 57.21875, -41.5625, -17.4375, -64.1875
    .double -71.3125, -97.9375, 7.109375, -79.0625, 33.84375, 63.53125, -96.1875

mat2:   .word 1, 8
    .double -36.75, 35.375, 79.125, -58.75, -55.25, -19.25, -88.75, -93.75

mat3:   .word 16, 1
    .double -90.75, -65.25, -58.25, -73.25, -89.25, -79.25, 16.875, 66.375
    .double -96.25, -97.25, -24.75, 5.3125, -33.75, -13.25, 27.125, -74.75

mat4:   .word 1, 1
    .double 78.875
mat5:   .word 0, 0
    .double 0.0

# #define NUM_MATRICES  6
NUM_MATRICES = 6
tamD=8  # tamaño de un double en bytes
tamP=4  # tamaño de una palabra (dirección) en bytes
nFil=0  # desplazamiento para acceder a nFil en la estructura
nCol=4  # desplazamiento para acceder a nCol en la estructura
elementos=8  # desplazamiento para acceder a elementos en la estructura
# structMat* matrices[NUM_MATRICES]={&mat0, &mat1, &mat2, &mat3, &mat4, &mat5};
matrices:       .word mat0, mat1, mat2, mat3, mat4, mat5
cadTitulo:      .asciiz "\nComienza programa manejo matrices con funciones"
cadMenu:        .ascii "(0) Terminar el programa\n"
                .ascii "(1) Cambiar la matriz de trabajo\n"
                .ascii "(3) Cambiar el valor de un elemento\n"
                .ascii "(4) Intercambiar un elemento con su opuesto\n"
                .ascii "(5) Procesa columnas\n"
                .ascii "(7) Encuentra maximo\n"
                .asciiz "\nIntroduce opción elegida: ";
cadDim:         .asciiz "\n\nLa matriz tiene dimension "
cadErrorFila:   .asciiz "Error: Numero de fila incorrecto\n"
cadErrorCol:    .asciiz "Error: Numero de columna incorrecto\n"
pideFila:       .asciiz "\nIndice de fila: "
pideCol:        .asciiz "Indice de columna: "
cadNuevoMax:    .asciiz "\nNuevo maximo "
cadSalir:       .asciiz "\nElegida opción de salir"
cadEligeMat:    .asciiz "\nElije la matriz de trabajo: "
cadErrorMat:    .asciiz "Numero de matriz de trabajo incorrecto\n"
cadNuevoValor:  .asciiz "Nuevo valor para el elemento: "
cadTerOpc:      .asciiz "\nTerminada la opción "
cadErrorOpcion: .asciiz "Error: opcion incorrecta\n"
cadPrimCol:     .asciiz "\nPrimera columna a procesar: "
cadSegCol:      .asciiz "Segunda columna a procesar: "
cadMax:         .asciiz "\nEl valor maximo en la matriz es "
cadFin:         .asciiz "\n\nTermina el programa\n"

.text   

#TABLA DE REGISTROS
#$s0 = Dirección base de matriz (struct mat)
#s1 = Opción
#$s2 = nFil
#$s3 = nCol
#$s6 = Datos
#$s4 = indFil
#$s5 = indCol



	# double find_max(structMat* mat) {
	#Parámetros de entrada:
	#mat = $a0

	#Parámetros de salida: 
	#max = $f0

	#Funcion que no llama a otra: NO NECESITA USAR PILA

find_max:
	#PUSH: $ra, $s2, $s3, $s4, $s5, $s6, $f24, $f26
	addi $sp, $sp, -40
	sw $ra, 36($sp)
	sw $s2, 32($sp)
	sw $s3, 28($sp)
	sw $s4, 24($sp)
	sw $s5, 20($sp)
	sw $s6, 16($sp)
	s.d $f24, 8($sp)
	s.d $f26, 0($sp)

	#   int numCol = mat->nCol;
	lw $s3, nCol($a0)
	#   int numFil = mat->nFil;
	lw $s2, nFil($a0)
	#   double* datos = mat->elementos;
	la $s6, elementos($a0)
	#   double max = datos[0];
	l.d $f24, 0($s6)
	li $s4, 0
	#   for(int f = 0; f < numFil; f++) {
	for_find_max_f:
		bge $s4, $s2, for_find_max_f_fin
		li $s5, 0
	#     for(int c = 0; c < numCol; c++) {
		for_find_max_c:
			bge $s5, $s3, for_find_max_c_fin
	#       double valor = datos[f * numCol + c];  // datos[f][c]
			mul $t0, $s4, $s3
			add $t0, $t0, $s5
			mul $t0, $t0, tamD
			add $t0, $t0, $s6
			l.d $f26, 0($t0)
	#       if (valor > max) {
			if_find_max:
				c.lt.d $f24, $f26
				bc1f if_find_max_fin
	#         max = valor;
				mov.d $f24, $f26
	#         std::cout << "\nNuevo maximo " << max;
				li $v0, 4
				la $a0, cadNuevoMax
				syscall

				li $v0, 3
				mov.d $f12, $f24
				syscall
	#       }
			if_find_max_fin:

				addi $s5, 1
				b for_find_max_c
	#     }
		for_find_max_c_fin:
			addi $s4, 1
			b for_find_max_f
	#   }
	for_find_max_f_fin:
	#   return max;
		mov.d $f0, $f24

	#POP:$ra,$s2,$s3,$s4, $s5 ,$s6, $f24, $f26

		l.d $f26, 0($sp)
		l.d $f24, 8($sp)
		lw $s6, 16($sp)
		lw $s5, 20($sp)
		lw $s4, 24($sp)
		lw $s3, 28($sp)
		lw $s2, 32($sp)
		lw $ra, 36($sp)
		addi $sp, $sp, 40
		jr $ra
	# }
find_max__MARCAFIN:



	# void procesa_cols(structMat* mat, int indC1, int indC2) {
	#Parámetros de entrada
	#mat = a0
	#indC1 = a1
	#indC2 = a2

	#Parámetros de salida: Ninguno
	
	#Funcion que llama a otra: NECESITA USAR PILA

	#Registros a utilizar:
	#s3 = nCol
	#s2 = nFil
	#s6 = datos
	#s7 = e1
	#s1 = e2
	#s4 = indC1
	#s5 = indC2
	#$f20 = val1
	#$f22 = val2
	
procesa_cols:

	#PUSH: $ra, $s0, $s1, $s2, $s3, $s4, $s5, $s6, $s7, $f20, $f22
	addi $sp, $sp, -52
	sw $ra, 48($sp)
	sw $s0, 44($sp)
	sw $s1, 40($sp)
	sw $s2, 36($sp)
	sw $s3, 32($sp)
	sw $s4, 28($sp)
	sw $s5, 24($sp)
	sw $s6, 20($sp)
	sw $s7, 16($sp)
	s.d $f20, 8($sp)
	s.d $f22, 0($sp)

	move $s4, $a1
	move $s5, $a2
	#   int numCol = mat->nCol;
	lw $s3, nCol($a0)
	#   int numFil = mat->nFil;
	lw $s2, nFil($a0)
	#   double* datos = mat->elementos;
	la $s6, elementos($a0)
	li $s0, 0
	#   for(int fa = 0; fa < numFil; fa++) {
		for_procesa_cols:
			bge $s0, $s2, for_procesa_cols_fin
	#     // e1 = &(datos[fa][indC1]);
	#     double* e1 = datos + (fa * numCol + indC1);
			mul $s7, $s0, $s3
			add $s7, $s7, $s4
			mul $s7, $s7, tamD
			add $s7, $s7, $s6
	#     // e2 = &(datos[fa][indC2]);
	#     double* e2 = datos + (fa * numCol + indC2);
			mul $s1, $s0, $s3
			add $s1, $s1, $s5
			mul $s1, $s1, tamD
			add $s1, $s1, $s6
	#     double val1 = *e1;
			l.d $f20, 0($s7)
	#     double val2 = *e2;
			l.d $f22, 0($s1)
	#     if(val1 > val2) {
			if_procesa_cols:
				c.lt.d $f22, $f20
				bc1f if_procesa_cols_else
	#       *e1 = val1 / 2.0;
				li.d $f0, 2.0
				div.d $f20, $f20, $f0
				s.d $f20, 0($s7)
				b if_procesa_cols_fin
	#     } else {
			if_procesa_cols_else:
	#       swap(e1, e2);
				move $a0, $s7
				move $a1, $s1
				jal swap
	#     }
			if_procesa_cols_fin:
	#     *e2 = *e2 + 0.5625;
				l.d $f22, 0($s1)
				li.d $f2, 0.5625
				add.d $f22, $f22, $f2
				s.d $f22, 0($s1)

				addi $s0, 1
				b for_procesa_cols
	#   }
		for_procesa_cols_fin:

			l.d $f22, 0($sp)
			l.d $f20, 8($sp)
			lw $s7, 16($sp)
			lw $s6, 20($sp)
			lw $s5, 24($sp)
			lw $s4, 28($sp)
			lw $s3, 32($sp)
			lw $s2, 36($sp)
			lw $s1, 40($sp)
			lw $s0, 44($sp)
			lw $ra, 48($sp)	
			addi $sp, $sp, 52
			jr $ra

	# }
procesa_cols__MARCAFIN:


	#Parámetros de entrada:
	#mat = $a0
	#indF = $a1
	#indC = $a2

	#Parametros de salida: Ninguna

	#Función que llama a otra: USAMOS PILA

	# void intercambia(structMat* mat, int indF, int indC) {
intercambia:

	#PUSH: $ra
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	#   int numCol = mat->nCol;
	lw $t0, nCol($a0)
	#   int numFil = mat->nFil;
	lw $t1, nFil($a0)
	#   double* datos = mat->elementos;
	la $t2, elementos($a0)
	#   // e1 = &(datos[indF][indC]);
	#   double* e1 = datos + (indF * numCol + indC);
	mul $t3, $a1, $t0
	add $t3, $t3, $a2
	mul $t3, $t3, tamD
	add $t3, $t3, $t2

	#   int indFilaOpuesta = (numFil - indF - 1);
	sub $t4, $t1, $a1
	addi $t4, $t4 ,-1
	#   int indColOpuesta = (numCol - indC - 1);
	sub $t5, $t0, $a2
	addi $t5, $t5, -1
	#   // e1 = &(datos[indFilaOpuesta][indColOpuesta])
	#   double* e2 = datos + (indFilaOpuesta * numCol + indColOpuesta);
	mul $t6, $t4, $t0
	add $t6, $t6, $t5
	mul $t6, $t6, tamD
	add $t6, $t6, $t2

	#   swap(e1, e2);
	move $a0, $t3
	move $a1, $t6
	jal swap

	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr  $ra
	# }
intercambia__MARCAFIN:


	# void swap(double* e1, double* e2) {
	#Parámetros de entrada:
	#double* e1 = $a0
	#double* e2 = $a1

	#Paŕametros de salida: Ninguno

	#Función que no llama a otra: NO NECESITA USAR PILA

	#REGISTROS A UTILIZAR:
	#temp1 = $f10
	#temp2 = $f12
swap: 
	#   double temp1 = *e1;
		l.d $f10, 0($a0)
	#   double temp2 = *e2;
		l.d $f12, 0($a1)
	#   *e1 = temp2;
		s.d $f12, 0($a0)
	#   *e2 = temp1;
		s.d $f10, 0($a1)
	# }

	jr $ra
swap__MARCAFIN:


	#int leeFila(int numFilas) {
	#Parámetros de entrada: 
	#numFilas = $a0 = $s7

	#Parametros de salida:
	#indFil = $v0

	#Función que no llama a otra: NO NECESITA PILA
	
	#REGISTROS A UTILIZAR:
	#s4 = indFil
	#s7 = numFilas

leeFila:
	#PUSH: $ra, $s7, $s4
	addi $sp, $sp, -12
	sw $ra, 8($sp)
	sw $s7, 4($sp)
	sw $s4, 0($sp)
	#   int indFil;
	#   std::cin >> indFil;
		move $s7, $a0
		li $v0, 5
		syscall
		move $s4, $v0
	#   if ((indFil < 0) || (indFil >= numFilas)) {
		if_leeFila:
			bltz $s4, if_leeFila_error
			bge $s4, $s7, if_leeFila_error

			b if_leeFila_fin
			if_leeFila_error:
	#     std::cout << "Error: Numero de fila incorrecto\n";
		
			li $v0, 4
			la $a0, cadErrorFila
			syscall
		
	#     return -1;
			li $v0, -1

			#POP: $ra, $s7, $s4
			lw $s4, 0($sp)
			lw $s7, 4($sp)
			lw $ra, 8($sp)
			addi $sp, $sp, 12
			jr $ra
			
		if_leeFila_fin:
	#   }
	#   return indFil;
		move $v0, $s4

		#POP: $ra, $s7, $s4
		lw $s4, 0($sp)
		lw $s7, 4($sp)
		lw $ra, 8($sp)
		addi $sp, $sp, 12
		jr $ra
	# }
leeFila__MARCAFIN:


	# int leeColumna(int numColumnas) {
	#Parámetros de entrada:
	#numColumnas = $a0 = $s5

	#Parametros de salida:
	#indCol = $v0

	#Funcion que no llama a otra: NO NECESITA PILA

	#REGISTROS A UTILIZAR:
	#s5 = indCol
	#s7 = numColumnas

leeColumna:
	#   int indCol;
	#   std::cin >> indCol;
	#PUSH: $ra, $s5, $s7
	addi $sp, $sp, -12
	sw $ra, 8($sp)
	sw $s5, 4($sp)
	sw $s7, 0($sp)

	move $s7, $a0
	li $v0, 5
	syscall
	move $s5, $v0
	#   if ((indCol < 0) || (indCol >= numColumnas)){
	if_leeColumna:
		bltz $s5, if_leeColumna_error
		bge $s5, $s7, if_leeColumna_error

		b if_leeColumna_fin
		if_leeColumna_error:
	#     std::cout << "Error: Numero de columna incorrecto\n";
		li $v0, 4
		la $a0, cadErrorCol
		syscall
	#     return -1;

	#POP: $ra
		lw $s7, 0($sp)
		lw $s5, 4($sp)
		lw $ra, 8($sp)
		addi $sp, $sp, 12

		li $v0, -1
		jr $ra
	#   }
	if_leeColumna_fin:
	#   return indCol;
	move $v0, $s5

	#POP: #$ra, $s5, $s7
	lw $s7, 0($sp)
	lw $s5, 4($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12

	jr $ra
	# }
leeColumna__MARCAFIN:



	# std::tuple<int, int> pideFilaYColumna(structMat* mat) {
	#Parámetros de entrada: $a0

	#Parámetros de salida: 
	#v0 = indFil
	#v1 = indCol

	#Funcion que llama a otra: NECESITA USAR PILA

	#Registros a utilizar:
	#indFil = $s4
	#indCol = $s5
pideFilaYColumna:

	#PUSH: $ra, $s4, $s5, $s0
	addi $sp, $sp, -16
	sw $ra, 12($sp)
	sw $s4, 8($sp)
	sw $s5, 4($sp)
	sw $s0, 0($sp)

	move $s0, $a0
	#   std::cout << "\nIndice de fila: ";
	li $v0, 4
	la $a0, pideFila
	syscall
	#   int indFil = leeFila(mat->nFil);
	lw $a0, nFil($s0)
	jal leeFila
	move $s4, $v0
	#   if (indFil < 0) {
	if_pideFila:
		bgez $s4, if_pideFila_fin
	#     return {-1, -1};
		li $v0, -1
		li $v1, -1

	#POP: $ra, $s4, $s5, $s0

		lw $s0, 0($sp)
		lw $s5, 4($sp)
		lw $s4, 8($sp)
		lw $ra, 12($sp)
		addi $sp, $sp, 16
		jr $ra
	#   }
	if_pideFila_fin:
	#   std::cout << "Indice de columna: ";
	li $v0, 4
	la $a0, pideCol
	syscall
	#   int indCol = leeColumna(mat->nCol);
	lw $a0, nCol($s0)
	jal leeColumna
	move $s5, $v0
	#   if (indCol < 0) {
	if_pideCol:
		bgez $s5, if_pideCol_fin
	#     return {-1, -1};
		li $v0, -1
		li $v1, -1
		
	#POP: $ra, $s4, $s5, $s0

		lw $s0, 0($sp)
		lw $s5, 4($sp)
		lw $s4, 8($sp)
		lw $ra, 12($sp)
		addi $sp, $sp, 16
		jr $ra
	#   }
	if_pideCol_fin:
	#   return {indFil, indCol};
		move $v0, $s4
		move $v1, $s5

		#POP: $ra, $s4, $s5, $s0

		lw $s0, 0($sp)
		lw $s5, 4($sp)
		lw $s4, 8($sp)
		lw $ra, 12($sp)
		addi $sp, $sp, 16
		jr $ra
	# }
pideFilaYColumna__MARCAFIN:



	# void change_elto(structMat* mat, int indF, int indC, double valor) {
	#Parámetros de entrada:
	#mat = $a0
	#indF = $a1
	#indC = $a2
	#valor = $f12

	#Parámetros de salida: Ninguno

	#Funcion que no llama a otra: NO USAMOS PILA

	#Registros a utilizar:
	#t0 = numCol
	#t2 = datos
	#t1 = Cálculo
	#$f12 = valor
change_elto:
		#PUSH: $ra
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	#   int numCol = mat->nCol;
	lw $t0, nCol($a0)
	#   double* datos = mat->elementos;
	la $t2, elementos($a0)
	#   datos[indF * numCol + indC] = valor;  // datos[indF][indC]
	mul $t1, $a1, $t0
	add $t1, $t1, $a2
	mul $t1, $t1, tamD
	add $t1, $t1, $t2
	s.d $f12, 0($t1)
	# }
		#POP: $ra

		lw $ra, 0($sp)
		addi $sp, $sp, 4

		jr $ra
change_elto__MARCAFIN:


	#void print_mat(structMat* mat) {
	#Párametros de entrada
	#structMat* mat = $a0

	#Párametros de salida: Ningun
	
	#Función que llama a otra: NECESITA USAR PIlA

	#Registros a utilizar:
	#Direccion base mat = $s0
	#nFil: $s2
	#nCol: $s3
	#Datos: $s6
	# f = $s4
	# c = $s5

print_mat:
	#PUSH: $ra, $s0, $s2, $s3, $s4, $s5, $s6: 7 * 4 = 28
	addi $sp, $sp, -28
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)


	#   int nFil = mat->nFil;
	move $s0, $a0
	lw $s2, nFil($s0)
	#   int nCol = mat->nCol;
	lw $s3, nCol($s0)
	#   double* datos = mat->elementos;
	la $s6, elementos($s0)
	#   std::cout << "\n\nLa matriz tiene dimension " << nFil
	li $v0, 4
	la $a0, cadDim
	syscall

	li $v0,1
	move $a0, $s2
	syscall
	#       << 'x' << nCol << '\n';
	li $v0, 11
	li $a0, 'x'
	syscall

	li $v0, 1
	move $a0, $s3
	syscall

	li $v0, 11
	li $a0, '\n'
	syscall

	li $s4, 0
	#   for(int f = 0; f < nFil; f++) {
		for_print_mat_f:
			bge $s4, $s2, for_print_mat_f_fin
			li $s5, 0
	#     for(int c = 0; c < nCol; c++) {
				for_print_mat_c:
					bge $s5, $s3, for_print_mat_c_fin
	#       std::cout << datos[f*nCol + c] << ' ';  // datos[f][c]
					mul $t0, $s4, $s3
					add $t0, $t0, $s5
					mul $t0, $t0, tamD
					add $t0, $t0, $s6

					li $v0, 3											
					l.d $f12, 0($t0)
					syscall

					li $v0, 11
					li $a0, ' '
					syscall

					addi $s5, 1
					b for_print_mat_c
	#     }
				for_print_mat_c_fin:
	#     std::cout << '\n';
					li $v0, 11
					li $a0, '\n'
					syscall

					addi $s4, 1
					b for_print_mat_f
	#   }
		for_print_mat_f_fin:
	#   std::cout << '\n';
			li $v0, 11
			li $a0, '\n'
			syscall



	#POP: $ra, $s0, $s2, $s3, $s4, $s5, $s6: 7 * 4 = 28
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $s6, 24($sp)
	addi $sp, $sp, 28

	jr $ra
	# }
print_mat__MARCAFIN:



	# int main() {
main:
	#   std::cout << std::setprecision(18); // Ignorar
	#   std::cout << "\nComienza programa manejo matrices con funciones";
		li $v0, 4
		la $a0, cadTitulo
		syscall

	#   structMat* matTrabajo = matrices[0];
		la $s0 , mat0
	#   int opcion;	
	#   do {
		do_while:
	#     print_mat(matTrabajo);
			move $a0, $s0
			jal print_mat
	#     std::cout <<
	#     "(0) Terminar el programa\n"
	#     "(1) Cambiar la matriz de trabajo\n"
	#     "(3) Cambiar el valor de un elemento\n"
	#     "(4) Intercambiar un elemento con su opuesto\n"
	#     "(5) Procesa columnas\n"
	#     "(7) Encuentra maximo\n"
	#     "\nIntroduce opción elegida: ";

			li $v0, 4
			la $a0, cadMenu
			syscall

	#     std::cin >> opcion;

			li $v0, 5
			syscall
			move $s1, $v0

	#     int indFil;
	#     int indCol;
	#     switch (opcion) {

			switch:

	#       // Opción 0 //////////////////////////////////////////////////////////
	#       case 0:

				case0:
	#         std::cout << "\nEligida opción de salir";
					bnez $s1, case1

					li $v0, 4
					la $a0, cadSalir
					syscall
	#         break; // salimos del switch
					b switch_fin
	#       // Opción 1 //////////////////////////////////////////////////////////
	#       case 1:
				case1:
					bne $s1, 1, case3
	#         std::cout << "\nElije la matriz de trabajo: ";
					li $v0, 4
					la $a0, cadEligeMat
					syscall
	#         int matT;
	#         std::cin >> matT;
					li $v0, 5
					syscall
					move $t0, $v0
	#         if ((matT < 0) || (matT >= NUM_MATRICES)) {
					if_case1:
						bltz $t0, if_case1_error
						bge $t0, NUM_MATRICES, if_case1_error

						b if_case1_fin
						
						if_case1_error:
	#           std::cout << "Numero de matriz de trabajo incorrecto\n";
						li $v0, 4
						la $a0, cadErrorMat
						syscall
						b switch_fin
						
					if_case1_fin:
	#           break; // salimos del switch
	#         }
	#         matTrabajo = matrices[matT];
	#         break; // salimos del switch
					if_mat0: 
						bnez $t0, if_mat1
						la $t1, mat0
						b if_mat_fin

					if_mat1:
						bne $t0, 1, if_mat2
						la $t1, mat1
						b if_mat_fin

					if_mat2:
						bne $t0, 2, if_mat3
						la $t1, mat2
						b if_mat_fin
					
					if_mat3:
						bne $t0, 3, if_mat4
						la $t1, mat3
						b if_mat_fin
					
					if_mat4:
						bne $t0, 4, if_mat5
						la $t1, mat4
						b if_mat_fin
					
					if_mat5:
						bne $t0, 5, if_mat_fin
						la $t1, mat5
						
					if_mat_fin:
						move $s0, $t1
						b switch_fin
						
				case1_fin:


	#       // Opción 3 //////////////////////////////////////////////////////////
	#       case 3:
				case3:
					bne $s1, 3, case4
	#         std::tie(indFil, indCol) = pideFilaYColumna(matTrabajo);
					move $a0, $s0
					jal pideFilaYColumna
					move $s4, $v0
					move $s5, $v1
	#         if (indFil < 0)
					if_case3:
						bgez $s4, if_case3_fin
	#           break; // salimos del switch
						b switch_fin
					if_case3_fin:
	#         std::cout << "Nuevo valor para el elemento: ";
					li $v0, 4
					la $a0, cadNuevoValor
					syscall
	#         double valor;
	#         std::cin >> valor;
					li $v0, 7
					syscall

	#         change_elto(matTrabajo, indFil, indCol, valor);
					move $a0, $s0
					move $a1, $s4
					move $a2, $s5
					mov.d $f12, $f0
					jal change_elto

	#         break; // salimos del switch
					b switch_fin
					
				case3_fin:
	#       // Opción 4 //////////////////////////////////////////////////////////
	#       case 4:
				case4:
					bne $s1, 4, case5
	#         std::tie(indFil, indCol) = pideFilaYColumna(matTrabajo);
					move $a0, $s0
					jal pideFilaYColumna
					move $s4, $v0
					move $s5, $v1
	#         if (indFil < 0)
					if_case4:
						bltz $s4, switch_fin
	#           break; // salimos del switch
					if_case4_fin:

	#         intercambia(matTrabajo, indFil, indCol);
						move $a0, $s0
						move $a1, $s4
						move $a2, $s5
						jal intercambia

	#         break; // salimos del switch
						b switch_fin

	#       // Opción 5 //////////////////////////////////////////////////////////

	#       case 5:
				case5: 
					bne $s1, 5, case7
	#         std::cout << "\nPrimera columna a procesar: ";
					li $v0, 4
					la $a0, cadPrimCol
					syscall
	#         int indC1;
	#         indC1 = leeColumna(matTrabajo->nCol);
					lw $a0, nCol($s0)
					jal leeColumna
					move $s5, $v0
	#         if (indC1 < 0) {
					if_case5:
						bltz $s5, switch_fin
	#           break; // salimos del switch
	#         }
					if_case5_fin:
	#         std::cout << "Segunda columna a procesar: ";
					li $v0, 4
					la $a0, cadSegCol
					syscall
	#         int indC2;
	#         indC2 = leeColumna(matTrabajo->nCol);
					lw $a0, nCol($s0)
					jal leeColumna
					move $s7, $v0,
	#         if (indC2 < 0) {
					if_case5_2:
						bltz $s7, switch_fin
	#           break;  // salimos del switch
	#         }
					if_case5_2_fin:

	#         procesa_cols(matTrabajo, indC1, indC2);
					move $a0, $s0
					move $a1, $s5
					move $a2, $s7
					jal procesa_cols
	#         break;  // salimos del switch
					b switch_fin

	#       // Opción 7 //////////////////////////////////////////////////////////
	#       case 7:
				case7:
					bne $s1, 7, default
	#         double maximo;
	#         maximo = find_max(matTrabajo);
					move $a0, $s0
					jal find_max
					mov.d $f24, $f0
	#         std::cout << "\nEl valor maximo en la matriz es " << maximo;
					li $v0, 4
					la $a0, cadMax
					syscall

					li $v0, 3
					mov.d $f12, $f24
					syscall

	#         break; // salimos del switch
					b switch_fin

	#       default:
				default:
	#         // Opción Incorrecta ////////////////////////////////////////////////
	#         std::cout << "Error: opcion incorrecta\n";
					li $v0, 4
					la $a0, cadErrorOpcion
					syscall
	#     }  // fin del switch
			switch_fin:
	#     std::cout << "\nTerminada la opción " << opcion;
				li $v0, 4
				la $a0, cadTerOpc
				syscall

				li $v0, 1
				move $a0, $s1
				syscall

				beqz $s1, do_while_fin
				b do_while
	

	#   } while (opcion != 0);
		do_while_fin:

Fin:
	#   std::cout << "\n\nTermina el programa\n";
	li $v0, 4
	la $a0, cadFin
	syscall

	li $v0, 10
	syscall
	# }