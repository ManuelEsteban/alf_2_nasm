#include <stdio.h>
#include <stdlib.h>
#include "alfa.h"
#include "y.tab.h"
 
extern int yyparse();
extern FILE* yyin;
FILE *salida;
 
int main(int argc, char** argv) {
 
  int aux_return;
 
  if (argc != 3)  {
    printf("Error en el número de argumentos: ./alfa entrada salida\n");
    return 1;
  } else {
    yyin = fopen(argv[1],"r");
    if (!yyin) {
      printf("Error al abrir el fichero de entrada %s\n",argv[1]);
      return 1;
    }
    salida = fopen(argv[2],"w");
    if (!salida) {
      printf("Error al abrir el fichero de salida %s\n",argv[2]);
      fclose(yyin);
      return 1;
    }
 
  }
 
  aux_return = yyparse();
 
  if (aux_return != 0)
    printf("HUBO UN ERROR EN LA COMPILACION\n");
  else
    printf("COMPILACION TERMINADA EXITOSAMENTE.\nEXIT VALUE %d\n", aux_return);
 
  fclose(yyin);
  fclose(salida);
  return aux_return; 
}