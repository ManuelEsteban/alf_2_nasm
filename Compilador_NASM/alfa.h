#ifndef _ALFA_H
#define _ALFA_H

#define MAX_LONG_ID 100
#define MAX_TAMANIO_VECTOR 64
#define TRUE 1
#define FALSE 0
#define ERROR -1
#define MAX_VAR 200 /* Numero maximo de variables que puede tener un programa */

/* Categorias */
#define VARIABLE 0
#define PARAMETRO 1
#define FUNCION 2
/* Tipos */
#define INT 0
#define BOOLEAN 1
/* Clases */
#define ESCALAR 0
#define VECTOR 1

typedef struct {
	char lexema[MAX_LONG_ID+1];	/* guarda el lexema de los identificadores */
	int tipo;					/* tipo de una expresion */
	int valor_entero; 			/* valor entero */
	int es_direccion; 			/* indica si un simbolo es una dirección de memoria o es un valor constante */
	int etiqueta; 				/* necesario gestion de sentencias condicionales e iterativas */
} tipo_atributos;

#endif
