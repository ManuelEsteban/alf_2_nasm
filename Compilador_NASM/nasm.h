/*********************************************
* File: nasm.h
*
* Fichero que contiene los prototipos de las funciones
* utilizadas para generacion de código ensamblador.
*
*********************************************/

#ifndef _NASM_H
#define _NASM_H

#include <stdio.h>
#include "tabla_sim.h"
#include "alfa.h"

void gc_segment_bss(FILE *f, hash_node_t *tabla, char variables[][MAX_LONG_ID+1], int ult);

void gc_segment_data(FILE *f);

void gc_segment_text(FILE *f);

void gc_constante(FILE *f, int v);

void gc_suma_enteros(FILE *f, int es_direccion_op1, int es_direccion_op2);

void gc_resta_enteros(FILE *f, int es_direccion_op1, int es_direccion_op2);

void gc_mul_enteros(FILE *f, int es_direccion_op1, int es_direccion_op2);

void gc_div_enteros(FILE *f, int es_direccion_op1, int es_direccion_op2);

void gc_neg_enteros(FILE *f, int es_direccion_op);

void gc_and_logico(FILE *f, int es_direccion_op1, int es_direccion_op2);

void gc_or_logico(FILE *f, int es_direccion_op1, int es_direccion_op2);

void gc_neg_logico(FILE *f, int es_direccion_op, int tag);

void gc_igual(FILE *f, int es_direccion_op1, int es_direccion_op2, int tag);

void gc_distinto(FILE *f, int es_direccion_op1, int es_direccion_op2, int tag);

void gc_menor_igual(FILE *f, int es_direccion_op1, int es_direccion_op2, int tag);

void gc_mayor_igual(FILE *f, int es_direccion_op1, int es_direccion_op2, int tag);

void gc_menor(FILE *f, int es_direccion_op1, int es_direccion_op2, int tag);

void gc_mayor(FILE *f, int es_direccion_op1, int es_direccion_op2, int tag);

/* ------------------------------------------------------------------------------------*/

void gc_elemento_vector (FILE *f, int es_direccion_op, int tam, char *name);

void gc_asignacion_identificador (FILE *f, int es_direccion_op, char *id);

void gc_asignacion_identificador_funcion (FILE *f, int es_direccion_op);

void gc_asignacion_elem_vector (FILE *f, int es_direccion_op);

void gc_scanf (FILE *f, int tipo, char *id);

void gc_scanf_funcion (FILE *f, int tipo);

void gc_printf (FILE *f, int tipo, int es_direccion_op);

void gc_if (FILE *f, int es_direccion_op, int tag);

void gc_end_if (FILE *f, int tag);

void gc_else (FILE *f, int tag);

void gc_end_else (FILE *f, int tag);

void gc_while_ini (FILE *f, int tag);

void gc_while_med (FILE *f, int tag, int es_direccion_op);

void gc_while_fin (FILE *f, int tag);

void gc_funcion_ini (FILE *f, char *name, int nvar);

void gc_funcion_call (FILE *f, char *name, int nparam);

void gc_funcion_return (FILE *f, int es_direccion_op);

void gc_funcion_fin (FILE *f);

void gc_identificadores (FILE *f, char *name, int en_explist);

void gc_identificadores_funcion (FILE *f, int categoria, int posParam, int nparam, int posVar, int paramFunc);

void gc_error(FILE *f);


#endif