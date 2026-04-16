// Solución PR3 curso 25-26
// Manejo de matrices con funciones

#include <iostream>
#include <iomanip>
#include <tuple>

typedef struct {
  int nFil;
  int nCol;
  double elementos[];
} structMat;


structMat mat0 {
  6,
  6,
  {
    11.125, 12.125, 13.125, 14.125, 15.125, 16.125,
    21.125, 22.125, 23.125, 24.125, 25.375, 26.375,
    31.375, 32.375, 33.375, 34.375, 35.375, 36.375,
    41.375, 42.375, 43.375, 44.375, 45.375, 46.375,
    51.625, 52.625, 53.625, 54.625, 55.625, 56.625,
    61.625, 62.625, 63.625, 64.625, 65.625, 66.625,

  }
};

structMat mat1 {
  10,
  7,
  {
    -36.9375, -58.1875, 78.65625, 19.09375, -50.8125, 33.96875, -59.5625,
    12.34375, 57.28125, -1.96875, -86.8125, -81.8125, 54.59375, -22.5625,
    88.21875, 64.34375, 52.90625, 47.90625, -83.5625, 19.03125, 4.265625,
    -31.9375, 82.53125, 27.40625, 56.53125, 39.46875, 18.40625, 97.03125,
    76.90625, 14.59375, 67.78125, -9.84375, -97.9375, 32.34375, -18.4375,
    -43.4375, 39.84375, 87.65625, -31.9375, -17.8125, 30.09375, 87.65625,
    -6.90625, 64.59375, -85.0625, 70.53125, -48.8125, -62.6875, -60.1875,
    -5.53125, 84.34375, -51.6875, 93.15625, -10.8125, 32.09375, 98.34375,
    69.46875, 73.84375, 3.734375, 57.21875, -41.5625, -17.4375, -64.1875,
    -71.3125, -97.9375, 7.109375, -79.0625, 33.84375, 63.53125, -96.1875,

  }
};

structMat mat2 {
  1,
  8,
  {
    -36.75, 35.375, 79.125, -58.75, -55.25, -19.25, -88.75, -93.75,
  }
};

structMat mat3 {
  16,
  1,
  {
    -90.75, -65.25, -58.25, -73.25, -89.25, -79.25, 16.875, 66.375,
    -96.25, -97.25, -24.75, 5.3125, -33.75, -13.25, 27.125, -74.75,

  }
};

structMat mat4 {
  1,
  1,
  { 78.875 }
};

structMat mat5 {
  0,
  0,
  { 0 }
};

#define NUM_MATRICES  6
structMat* matrices[NUM_MATRICES] = {&mat0, &mat1, &mat2, &mat3, &mat4, &mat5};

void print_mat(structMat* mat) {
  int nFil = mat->nFil;
  int nCol = mat->nCol;
  double* datos = mat->elementos;
  std::cout << "\n\nLa matriz tiene dimension " << nFil
      << 'x' << nCol << '\n';
  for(int f = 0; f < nFil; f++) {
    for(int c = 0; c < nCol; c++) {
      std::cout << datos[f*nCol + c] << ' ';  // datos[f][c]
    }
    std::cout << '\n';
  }
  std::cout << '\n';
}

void change_elto(structMat* mat, int indF, int indC, double valor) {
  int numCol = mat->nCol;
  double* datos = mat->elementos;
  datos[indF * numCol + indC] = valor;  // datos[indF][indC]
}

void swap(double* e1, double* e2) {
  double temp1 = *e1;
  double temp2 = *e2;
  *e1 = temp2;
  *e2 = temp1;
}

void intercambia(structMat* mat, int indF, int indC) {
  int numCol = mat->nCol;
  int numFil = mat->nFil;
  double* datos = mat->elementos;
  // e1 = &(datos[indF][indC]);
  double* e1 = datos + (indF * numCol + indC);
  int indFilaOpuesta = (numFil - indF - 1);
  int indColOpuesta = (numCol - indC - 1);
  // e1 = &(datos[indFilaOpuesta][indColOpuesta])
  double* e2 = datos + (indFilaOpuesta * numCol + indColOpuesta);
  swap(e1, e2);
}

void procesa_cols(structMat* mat, int indC1, int indC2) {
  int numCol = mat->nCol;
  int numFil = mat->nFil;
  double* datos = mat->elementos;
  for(int fa = 0; fa < numFil; fa++) {
    // e1 = &(datos[fa][indC1]);
    double* e1 = datos + (fa * numCol + indC1);
    // e2 = &(datos[fa][indC2]);
    double* e2 = datos + (fa * numCol + indC2);
    double val1 = *e1;
    double val2 = *e2;
    if(val1 > val2) {
      *e1 = val1 / 2.0;
    } else {
      swap(e1, e2);
    }
    *e2 = *e2 + 0.5625;
  }
}

double find_max(structMat* mat) {
  int numCol = mat->nCol;
  int numFil = mat->nFil;
  double* datos = mat->elementos;
  double max = datos[0];
  for(int f = 0; f < numFil; f++) {
    for(int c = 0; c < numCol; c++) {
      double valor = datos[f * numCol + c];  // datos[f][c]
      if (valor > max) {
        max = valor;
        std::cout << "\nNuevo maximo " << max;
      }
    }
  }
  return max;
}

int leeFila(int numFilas) {
  int indFil;
  std::cin >> indFil;
  if ((indFil < 0) || (indFil >= numFilas)) {
    std::cout << "Error: Numero de fila incorrecto\n";
    return -1;
  }
  return indFil;
}

int leeColumna(int numColumnas) {
  int indCol;
  std::cin >> indCol;
  if ((indCol < 0) || (indCol >= numColumnas)){
    std::cout << "Error: Numero de columna incorrecto\n";
    return -1;
  }
  return indCol;
}

std::tuple<int, int> pideFilaYColumna(structMat* mat) {
  std::cout << "\nIndice de fila: ";
  int indFil = leeFila(mat->nFil);
  if (indFil < 0) {
    return {-1, -1};
  }
  std::cout << "Indice de columna: ";
  int indCol = leeColumna(mat->nCol);
  if (indCol < 0) {
    return {-1, -1};
  }
  return {indFil, indCol};
}

int main() {
  std::cout << std::setprecision(18); // Ignorar
  std::cout << "\nComienza programa manejo matrices con funciones";

  structMat* matTrabajo = matrices[0];
  int opcion;
  do {
    print_mat(matTrabajo);
    std::cout <<
    "(0) Terminar el programa\n"
    "(1) Cambiar la matriz de trabajo\n"
    "(3) Cambiar el valor de un elemento\n"
    "(4) Intercambiar un elemento con su opuesto\n"
    "(5) Procesa columnas\n"
    "(7) Encuentra maximo\n"
    "\nIntroduce opción elegida: ";

    std::cin >> opcion;

    int indFil;
    int indCol;
    switch (opcion) {
      // Opción 0 ////////////////////////////////////////////////////////////
      case 0:
        std::cout << "\nElegida opción de salir";
        break; // salimos del switch
      // Opción 1 ////////////////////////////////////////////////////////////
      case 1:
        std::cout << "\nElije la matriz de trabajo: ";
        int matT;
        std::cin >> matT;
        if ((matT < 0) || (matT >= NUM_MATRICES)) {
          std::cout << "Numero de matriz de trabajo incorrecto\n";
          break; // salimos del switch
        }
        matTrabajo = matrices[matT];
        break; // salimos del switch

      // Opción 3 ////////////////////////////////////////////////////////////
      case 3:
        std::tie(indFil, indCol) = pideFilaYColumna(matTrabajo);
        if (indFil < 0)
          break; // salimos del switch
        std::cout << "Nuevo valor para el elemento: ";
        double valor;
        std::cin >> valor;

        change_elto(matTrabajo, indFil, indCol, valor);

        break; // salimos del switch

      // Opción 4 ////////////////////////////////////////////////////////////
      case 4:
        std::tie(indFil, indCol) = pideFilaYColumna(matTrabajo);
        if (indFil < 0)
          break; // salimos del switch

        intercambia(matTrabajo, indFil, indCol);

        break; // salimos del switch

      // Opción 5 ////////////////////////////////////////////////////////////
      case 5:
        std::cout << "\nPrimera columna a procesar: ";
        int indC1;
        indC1 = leeColumna(matTrabajo->nCol);
        if (indC1 < 0) {
          break; // salimos del switch
        }
        std::cout << "Segunda columna a procesar: ";
        int indC2;
        indC2 = leeColumna(matTrabajo->nCol);
        if (indC2 < 0) {
          break;  // salimos del switch
        }

        procesa_cols(matTrabajo, indC1, indC2);
        break;  // salimos del switch

      // Opción 7 ////////////////////////////////////////////////////////////
      case 7:
        double maximo;
        maximo = find_max(matTrabajo);
        std::cout << "\nEl valor maximo en la matriz es " << maximo;
        break; // salimos del switch

      default:
        // Opción Incorrecta ////////////////////////////////////////////////
        std::cout << "Error: opcion incorrecta\n";
    }  // fin del switch
    std::cout << "\nTerminada la opción " << opcion;
  } while (opcion != 0);
  std::cout << "\n\nTermina el programa\n";
}
