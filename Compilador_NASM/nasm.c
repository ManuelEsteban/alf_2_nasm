/*********************************************
* File: nasm.c
*
* Fichero que contiene el código de las funciones definidas en nasm.h
* utilizadas para generacion de código ensamblador.
*
*********************************************/

#include "nasm.h"

/*
* Escritura del segmento de datos 'segment .bbs', declara las variables segun
* el contenido de la tabla de simbolos al inicio de las declaraciones.
* 
* @param f Fichero en el que se va a escribir
* @param tabla Tabla hash con los elementos
* @param variables Arrar que contiene el nombre de las variables a guardar
* @param ult Posicion del ultimo elemnto del array 
*
*/
void gc_segment_bss(FILE *f, hash_node_t *tabla, char variables[][MAX_LONG_ID+1], int ult) {
    int i=0;
    
    fprintf(f, "segment .bss\n");
    
    for (i = 0; i < ult; i++) {
        if (get_clase (tabla, variables[i]) == ESCALAR)
            fprintf(f, "_%s resd 1\n", variables[i]);
        
        else
            fprintf(f, "_%s resd %d\n", variables[i], hash_get(tabla, variables[i]));
    }
}

/*
* Escritura del segmento de datos 'segment .data'
*
* @param f Fichero en el que se va a escribir
*
*/
void gc_segment_data(FILE *f){
    
    fprintf(f, "segment .data\nmensaje_1 db \"Indice fuera de rango\" , 0\nmensaje_2 db \"División por cero\" , 0\n");    
    
}

/*
* Escritura del segmento de datos 'segment .text'
*
* @param f Fichero en el que se va a escribir
*
*/
void gc_segment_text(FILE *f){
    
    fprintf(f, "segment .text\nglobal main\nextern scan_int, scan_boolean\nextern print_int, print_boolean, print_string, print_blank, print_endofline\n");
    
}

/*
* Codigo nasm para guardar el valor de una constante lógica o entera
*
* @param f Fichero en el que se va a escribir
* @param v Valor de la constante
*
*/
void gc_constante(FILE *f, int v){
    fprintf(f, "\tpush dword %d\n", v); /*  ¿?¿?¿??¿? */
}

/*
* Suma de expresiones de tipo entero
* 
* @param f Fichero en el que se va a escribir
* @param es_direccion_op1 Indica si es direccion el operando 1
* @param es_direccion_op2 Indica si es direccion el operando 2
*
*/
void gc_suma_enteros(FILE *f, int es_direccion_op1, int es_direccion_op2){
    fprintf(f, "; Cargar en edx el operando 2\n");
    fprintf(f, "pop dword edx\n");
    if (es_direccion_op2 == 1) 
        fprintf(f, "mov dword edx, [edx]\n");

    fprintf(f, "; Cargar en eax el operando 1\n");
    fprintf(f, "pop dword eax\n");
    if (es_direccion_op1 == 1) 
        fprintf(f, "mov dword eax, [eax]\n");

    fprintf(f, "; realizar la suma y dejar el resultado en eax\n");
    fprintf(f, "add eax, edx\n");

    fprintf(f, "; apilar el resultado\n");
    fprintf(f, "push dword eax\n");
}


/*
* Resta de expresiones de tipo entero
* 
* @param f Fichero en el que se va a escribir
* @param es_direccion_op1 Indica si es direccion el operando 1
* @param es_direccion_op2 Indica si es direccion el operando 2
*
*/
void gc_resta_enteros(FILE *f, int es_direccion_op1, int es_direccion_op2){
    fprintf(f, "; Cargar en edx el operando 2\n");
    fprintf(f, "pop dword edx\n");
    if (es_direccion_op2 == 1) 
        fprintf(f, "mov dword edx, [edx]\n");

    fprintf(f, "; Cargar en eax el operando 1\n");
    fprintf(f, "pop dword eax\n");
    if (es_direccion_op1 == 1) 
        fprintf(f, "mov dword eax, [eax]\n");
    
    fprintf(f, "; realizar la suma y dejar el resultado en eax\n");
    fprintf(f, "sub eax, edx\n");

    fprintf(f, "; apilar el resultado\n");
    fprintf(f, "push dword eax\n");
}

/*
* Multiplicaion de expresiones de tipo entero
* 
* @param f Fichero en el que se va a escribir
* @param es_direccion_op1 Indica si es direccion el operando 1
* @param es_direccion_op2 Indica si es direccion el operando 2
*
*/
void gc_mul_enteros(FILE *f, int es_direccion_op1, int es_direccion_op2){
    fprintf(f, "; Cargar en edx el operando 2\n");
    fprintf(f, "pop dword edx\n");
    if (es_direccion_op2 == 1) 
        fprintf(f, "mov dword edx, [edx]\n");

    fprintf(f, "; Cargar en eax el operando 1\n");
    fprintf(f, "pop dword eax\n");
    if (es_direccion_op1 == 1) 
        fprintf(f, "mov dword eax, [eax]\n");
    
    fprintf(f, "; realizar la suma y dejar el resultado en eax\n");
    fprintf(f, "imul edx\n");

    fprintf(f, "; apilar el resultado\n");
    fprintf(f, "push dword eax\n");
}

/*
* Division de expresiones de tipo entero
* 
* @param f Fichero en el que se va a escribir
* @param es_direccion_op1 Indica si es direccion el operando 1
* @param es_direccion_op2 Indica si es direccion el operando 2
*
*/
void gc_div_enteros(FILE *f, int es_direccion_op1, int es_direccion_op2){
    fprintf(f, "; Cargar en edx el divisor\n");
    fprintf(f, "pop dword ecx\n");
    if (es_direccion_op2 == 1) 
        fprintf(f, "mov dword ecx, [ecx]\n");

    fprintf(f, "; Cargar en eax el dividendo\n");
    fprintf(f, "pop dword eax\n");
    if (es_direccion_op1 == 1) 
        fprintf(f, "mov dword eax, [eax]\n");


    fprintf(f, "cmp ecx, 0\n");
    fprintf(f, "je near error_division\n");

    fprintf(f, "; Extender dividendo en edx:eax\n");
    fprintf(f, "cdq\n");
    
    fprintf(f, "; realizar la division y dejar el resultado en eax\n");
    fprintf(f, "idiv ecx\n");
    
    fprintf(f, "; apilar el resultado\n");
    fprintf(f, "push dword eax\n");
}

/*
* Negacion de expresiones de tipo entero
* 
* @param f Fichero en el que se va a escribir
* @param es_direccion_op Indica si es direccion el operando
*
*/
void gc_neg_enteros(FILE *f, int es_direccion_op){
    fprintf(f, "; cargar el operando en eax\n");
    fprintf(f, "pop dword eax\n");
    if(es_direccion_op == 1)
        fprintf(f, "mov dword eax , [eax]\n");

    fprintf(f, "; realizar la negación. El resultado en eax\n");
    fprintf(f, "neg eax\n");

    fprintf(f, "; apilar el resultado\n");
    fprintf(f, "push dword eax\n");
}

/*
* AND logico de expresiones de tipo logico
* 
* @param f Fichero en el que se va a escribir
* @param es_direccion_op1 Indica si es direccion el operando 1
* @param es_direccion_op2 Indica si es direccion el operando 2
*
*/
void gc_and_logico(FILE *f, int es_direccion_op1, int es_direccion_op2){
    fprintf(f, "; cargar el segundo operando en edx\n");
    fprintf(f, "pop dword edx\n");
    if(es_direccion_op2 == 1)
    fprintf(f, "mov dword edx , [edx]\n");
    
    fprintf(f, "; cargar el primer operando en eax\n");
    fprintf(f, "pop dword eax\n");
    if(es_direccion_op2 == 1)
        fprintf(f, "mov dword eax , [eax]\n");

    fprintf(f, "; realizar la conjunción y dejar el resultado en eax\n");
    fprintf(f, "and eax , edx\n");

    fprintf(f, "; apilar el resultado\n");
    fprintf(f, "push dword eax\n");
}

/*
* OR logico de expresiones de tipo logico
* 
* @param f Fichero en el que se va a escribir
* @param es_direccion_op1 Indica si es direccion el operando 1
* @param es_direccion_op2 Indica si es direccion el operando 2
*
*/
void gc_or_logico(FILE *f, int es_direccion_op1, int es_direccion_op2){
    fprintf(f, "; cargar el segundo operando en edx\n");
    fprintf(f, "pop dword edx\n");
    if(es_direccion_op2 == 1)
    fprintf(f, "mov dword edx , [edx]\n");
    
    fprintf(f, "; cargar el primer operando en eax\n");
    fprintf(f, "pop dword eax\n");
    if(es_direccion_op2 == 1)
        fprintf(f, "mov dword eax , [eax]\n");

    fprintf(f, "; realizar la conjunción y dejar el resultado en eax\n");
    fprintf(f, "or eax , edx\n");

    fprintf(f, "; apilar el resultado\n");
    fprintf(f, "push dword eax\n");
}

/*
* Negacion de expresiones de tipo logico
* 
* @param f Fichero en el que se va a escribir
* @param es_direccion_op Indica si es direccion el operando
* @param tag Etiqueta ensamblador utilizada para la comparacion
*
*/
void gc_neg_logico(FILE *f, int es_direccion_op, int tag){
    fprintf(f, "; cargar el operando en eax\n");
    fprintf(f, "pop dword eax\n");
    if(es_direccion_op == 1)
        fprintf(f, "mov dword eax , [eax]\n");
    
    fprintf(f, "; ver si eax es 0 y en ese caso saltar a negar_falso\n");
    fprintf(f, "or eax , eax\n");
    fprintf(f, "jz near negar_falso%d\n", tag);

    fprintf(f, "; cargar 0 en eax (negación de verdadero) y saltar al final\n");
    fprintf(f, "mov dword eax,0\n");
    fprintf(f, "jmp near fin_negacion%d\n", tag);

    fprintf(f, "; cargar 1 en eax (negación de falso)\n");
    
    fprintf(f, "negar_falso%d: mov dword eax,1\n", tag);
    
    fprintf(f, "; apilar eax\n");
    fprintf(f, "fin_negacion%d: push dword eax\n", tag);
}

/*
* Comparacion de tipo exp == exp
* 
* @param f Fichero en el que se va a escribir
* @param es_direccion_op1 Indica si es direccion el operando 1
* @param es_direccion_op2 Indica si es direccion el operando 2
* @param tag Etiqueta ensamblador utilizada para la comparacion
*
*/
void gc_igual(FILE *f, int es_direccion_op1, int es_direccion_op2, int tag) {
    fprintf(f, "; cargar la segunda expresión en edx\n");
    fprintf(f, "pop dword edx\n");
    if(es_direccion_op2 == 1)
        fprintf(f, "mov dword edx , [edx]\n");

    fprintf(f, "; cargar la primera expresión en eax\n");
    fprintf(f, "pop dword eax\n");
    if(es_direccion_op1 == 1)
        fprintf(f, "mov dword eax , [eax]\n");
    
    fprintf(f, "; comparar y apilar el resultado\n");
    fprintf(f, "cmp eax, edx\n");
    fprintf(f, "je near igual%d\n", tag);

    fprintf(f, "push dword 0\n");
    fprintf(f, "jmp near fin_igual%d\n", tag);

    fprintf(f, "igual%d: push dword 1\n", tag);
    fprintf(f, "fin_igual%d:\n", tag);
}

/*
* Comparacion de tipo exp != exp
* 
* @param f Fichero en el que se va a escribir
* @param es_direccion_op1 Indica si es direccion el operando 1
* @param es_direccion_op2 Indica si es direccion el operando 2
* @param tag Etiqueta ensamblador utilizada para la comparacion
*
*/
void gc_distinto(FILE *f, int es_direccion_op1, int es_direccion_op2, int tag){
    fprintf(f, "; cargar la segunda expresión en edx\n");
    fprintf(f, "pop dword edx\n");
    if(es_direccion_op2 == 1)
    fprintf(f, "mov dword edx , [edx]\n");

    fprintf(f, "; cargar la primera expresión en eax\n");
    fprintf(f, "pop dword eax\n");
    if(es_direccion_op1 == 1)
        fprintf(f, "mov dword eax , [eax]\n");

    fprintf(f, "; comparar y apilar el resultado\n");
    fprintf(f, "cmp eax, edx\n");
    fprintf(f, "jne near distinto%d\n", tag);

    fprintf(f, "push dword 0\n");
    fprintf(f, "jmp near fin_distinto%d\n", tag);
    
    fprintf(f, "distinto%d: push dword 1\n", tag);
    fprintf(f, "fin_distinto%d:\n", tag);
}

/*
* Comparacion de tipo exp <= exp
* 
* @param f Fichero en el que se va a escribir
* @param es_direccion_op1 Indica si es direccion el operando 1
* @param es_direccion_op2 Indica si es direccion el operando 2
* @param tag Etiqueta ensamblador utilizada para la comparacion
*
*/
void gc_menor_igual(FILE *f, int es_direccion_op1, int es_direccion_op2, int tag){
    fprintf(f, "; cargar la segunda expresión en edx\n");
    fprintf(f, "pop dword edx\n");
    if(es_direccion_op2 == 1)
        fprintf(f, "mov dword edx , [edx]\n");

    fprintf(f, "; cargar la primera expresión en eax\n");
    fprintf(f, "pop dword eax\n");
    if(es_direccion_op1 == 1)
        fprintf(f, "mov dword eax , [eax]\n");

    fprintf(f, "; comparar y apilar el resultado\n");
    fprintf(f, "cmp eax, edx\n");
    fprintf(f, "jle near menorigual%d\n", tag);

    fprintf(f, "push dword 0\n");
    fprintf(f, "jmp near fin_menorigual%d\n", tag);

    fprintf(f, "menorigual%d: push dword 1\n", tag);
    fprintf(f, "fin_menorigual%d:\n", tag);
}

/*
* Comparacion de tipo exp >= exp
* 
* @param f Fichero en el que se va a escribir
* @param es_direccion_op1 Indica si es direccion el operando 1
* @param es_direccion_op2 Indica si es direccion el operando 2º
* @param tag Etiqueta ensamblador utilizada para la comparacion
*
*/
void gc_mayor_igual(FILE *f, int es_direccion_op1, int es_direccion_op2, int tag){
    fprintf(f, "; cargar la segunda expresión en edx\n");
    fprintf(f, "pop dword edx\n");
    if(es_direccion_op2 == 1)
        fprintf(f, "mov dword edx , [edx]\n");

    fprintf(f, "; cargar la primera expresión en eax\n");
    fprintf(f, "pop dword eax\n");
    if(es_direccion_op1 == 1)
        fprintf(f, "mov dword eax , [eax]\n");

    fprintf(f, "; comparar y apilar el resultado\n");
    fprintf(f, "cmp eax, edx\n");
    fprintf(f, "jge near mayorigual%d\n", tag);

    fprintf(f, "push dword 0\n");
    fprintf(f, "jmp near fin_mayorigual%d\n", tag);

    fprintf(f, "mayorigual%d: push dword 1\n", tag);
    fprintf(f, "fin_mayorigual%d:\n", tag);
}

/*
* Comparacion de tipo exp < exp
* 
* @param f Fichero en el que se va a escribir
* @param es_direccion_op1 Indica si es direccion el operando 1
* @param es_direccion_op2 Indica si es direccion el operando 2
* @param tag Etiqueta ensamblador utilizada para la comparacion
*
*/
void gc_menor(FILE *f, int es_direccion_op1, int es_direccion_op2, int tag){
    fprintf(f, "; cargar la segunda expresión en edx\n");
    fprintf(f, "pop dword edx\n");
    if(es_direccion_op2 == 1)
        fprintf(f, "mov dword edx , [edx]\n");

    fprintf(f, "; cargar la primera expresión en eax\n");
    fprintf(f, "pop dword eax\n");
    if(es_direccion_op1 == 1)
        fprintf(f, "mov dword eax , [eax]\n");

    fprintf(f, "; comparar y apilar el resultado\n");
    fprintf(f, "cmp eax, edx\n");
    fprintf(f, "jl near menor%d\n", tag);

    fprintf(f, "push dword 0\n");
    fprintf(f, "jmp near fin_menor%d\n", tag);

    fprintf(f, "menor%d: push dword 1\n", tag);
    fprintf(f, "fin_menor%d:\n", tag);
}

/*
* Comparacion de tipo exp > exp
* 
* @param f Fichero en el que se va a escribir
* @param es_direccion_op1 Indica si es direccion el operando 1
* @param es_direccion_op2 Indica si es direccion el operando 2
* @param tag Etiqueta ensamblador utilizada para la comparacion
*
*/
void gc_mayor(FILE *f, int es_direccion_op1, int es_direccion_op2, int tag){
    fprintf(f, "; cargar la segunda expresión en edx\n");
    fprintf(f, "pop dword edx\n");
    if(es_direccion_op2 == 1)
        fprintf(f, "mov dword edx , [edx]\n");

    fprintf(f, "; cargar la primera expresión en eax\n");
    fprintf(f, "pop dword eax\n");
    if(es_direccion_op1 == 1)
        fprintf(f, "mov dword eax , [eax]\n");

    fprintf(f, "; comparar y apilar el resultado\n");
    fprintf(f, "cmp eax, edx\n");
    fprintf(f, "jg near mayor%d\n", tag);

    fprintf(f, "push dword 0\n");
    fprintf(f, "jmp near fin_mayor%d\n", tag);

    fprintf(f, "mayor%d: push dword 1\n", tag);
    fprintf(f, "fin_mayor%d:\n", tag);
}

/*
* Generar código para comprobar, en tiempo de ejecución, que el índice está dentro del
* rango permitido y dejar en la cima de la pila la dirección del elemento indexado.
* 
* @param f Fichero en el que se va a escribir
* @param es_direccion_op Indica si es direccion el operando 1
* @param tam Tamaño del vector
* @param name Nombre del vector
*
*/
void gc_elemento_vector (FILE *f, int es_direccion_op, int tam, char *name){
    fprintf(f, "; Carga del valor del índice en eax\n");
    fprintf(f, "pop dword eax\n");
    if (es_direccion_op == 1) 
        fprintf(f, "mov dword eax, [eax]\n");
    /* Comprobacion */
    fprintf(f, "; Si el índice es menor que 0, error en tiempo de ejecución\n");
    fprintf(f, "cmp eax, 0\n");
    fprintf(f, "jl near error_indice");

    fprintf(f, "; Si el índice es mayor de lo permitido , error en tiempo de ejecución\n");
    fprintf(f, "cmp eax, %d\n", tam-1);
    fprintf(f, "jg near error_indice");

    /* Direccion del elemento */
    fprintf(f, "; Cargar en edx la dirección de inicio del vector\n");
    fprintf(f, "mov dword edx, _%s \n", name);
    fprintf(f, "; Cargar en eax la dirección del elemento indexado\n");
    fprintf(f, "lea eax, [edx + eax*4]\n");
    fprintf(f, "; Apilar la dirección del elemento indexado\n");
    fprintf(f, "push dword eax\n");

    return;
}

/*
* Produce las instrucciones en ensamblador que cargan el valor de la constante en la
* posición de memoria que ocupa el identificador
* 
* @param f Fichero en el que se va a escribir
* @param es_direccion_op Indica si es direccion el operando 1
* @param id Nombre (lexema) del identificador
*
*/
void gc_asignacion_identificador (FILE *f, int es_direccion_op, char *id){
    fprintf(f, "; Cargar en eax la parte derecha de la asignación\n");
    fprintf(f, "pop dword eax\n");

    if (es_direccion_op == 1) 
        fprintf(f, "mov dword eax, [eax]\n");
    fprintf(f, "; Hacer la asignación efectiva\n");
    fprintf(f, "mov dword [_%s] , eax\n", id);

    return;
}


/*
* Produce las instrucciones en ensamblador que cargan el valor de la constante en la
* posición de memoria que ocupa el identificador
* 
* @param f Fichero en el que se va a escribir
* @param es_direccion_op Indica si es direccion el operando 1
* @param id Nombre (lexema) del identificador
*
*/
void gc_asignacion_identificador_funcion (FILE *f, int es_direccion_op){
    fprintf(f, "; Cargar en eax la parte derecha de la asignación\n");
    fprintf(f, "pop dword ebx\n");
    fprintf(f, "pop dword eax\n");

    if (es_direccion_op == 1) 
        fprintf(f, "mov dword eax, [eax]\n");
    fprintf(f, "; Hacer la asignación efectiva\n");
    fprintf(f, "mov dword [ebx] , eax\n");

    return;
}


/*
* Produce las instrucciones en ensamblador que cargan el valor de la constante en la
* posición de memoria que ocupa el elemento vector
* 
* @param f Fichero en el que se va a escribir
* @param es_direccion_op Indica si es direccion el operando 1
*
*/
void gc_asignacion_elem_vector (FILE *f, int es_direccion_op){
    fprintf(f, "; Cargar en eax la parte derecha de la asignación\n");
    fprintf(f, "pop dword eax\n");

    if (es_direccion_op == 1) 
        fprintf(f, "mov dword eax, [eax]\n");

    fprintf(f, "; Cargar en edx la parte izquierda de la asignación\n");
    fprintf(f, "pop dword edx\n");
    fprintf(f, "; Hacer la asignación efectiva\n");
    fprintf(f, "mov dword [edx] , eax\n");

    return;
}

/*
* Código para entrada de datos haciendo uso de la funcion scanf
* 
* @param f Fichero en el que se va a escribir
* @param tipo Indica si el identificador es INT o BOOLEAN
* @param id Nombre (lexema) del identificador
*
*/
void gc_scanf (FILE *f, int tipo, char *id){
    fprintf(f, ";  apila la dirección de memoria que será destino del dato leído\n");
    fprintf(f, "push dword _%s\n", id);

    if (tipo == INT)
        fprintf(f, "call scan_int\n");
    else
        fprintf(f, "call scan_boolean\n");
    
    fprintf(f, "add esp, 4\n");

    return;
}

/*
* Código para entrada de datos haciendo uso de la funcion scanf
* 
* @param f Fichero en el que se va a escribir
* @param tipo Indica si el identificador es INT o BOOLEAN
* @param id Nombre (lexema) del identificador
*
*/
void gc_scanf_funcion (FILE *f, int tipo){
    fprintf(f, ";  apila la dirección de memoria que será destino del dato leído\n");

    if (tipo == INT)
        fprintf(f, "call scan_int\n");
    else
        fprintf(f, "call scan_boolean\n");
    
    fprintf(f, "add esp, 4\n");

    return;
}

/*
* Código para salida de datos haciendo uso de la funcion printf
* 
* @param f Fichero en el que se va a escribir
* @param tipo Indica si el identificador es INT o BOOLEAN
* @param es_direccion_op Indica si es direccion el operando 1 
*
*/
void gc_printf (FILE *f, int tipo, int es_direccion_op){
    fprintf(f, "; Acceso al valor de exp si es distinto de constante\n");
    if (es_direccion_op == 1) {
        fprintf(f, "pop dword eax\n");
        fprintf(f, "mov dword eax , [eax]\n");
        fprintf(f, "push dword eax\n");
    }

    fprintf(f, "; Si la expresión es de tipo entero\n");
    if (tipo == INT)
        fprintf(f, "call print_int\n");
    else
        fprintf(f, "call print_boolean\n");

    fprintf(f, ";  Restauración del puntero de pila\n");
    fprintf(f, "add esp, 4\n");

    fprintf(f, ";  Salto de línea\n");
    fprintf(f, "call print_endofline\n");

    return;
}

/*
* Generación de código de las sentencias condicionales aplicada en la regla
* 'if_exp' (no se escribe el fin de la condicion)
*
* @param f Fichero en el que se va a escribir
* @param es_direccion_op Indica si es direccion el operando 1
* @param tag Etiqueta ensamblador utilizada para la comparacion
*
*/
void gc_if (FILE *f, int es_direccion_op, int tag){
    fprintf(f, "pop eax\n");
    if (es_direccion_op == 1) 
        fprintf(f, "mov eax, [eax]\n");
    
    fprintf(f, "cmp eax, 0\n");
    fprintf(f, "je near fin_si%d\n", tag);

    return;
}

/*
* Generación de código de las sentencias condicionales aplicada en la regla
* 'condicional -> if_exp...' (solo se escribe el fin de la condicion)
*
* @param f Fichero en el que se va a escribir
* @param tag Etiqueta ensamblador utilizada para la comparacion
*
*/
void gc_end_if (FILE *f, int tag){
    fprintf(f, "fin_si%d:\n", tag);
    return;
}

/*
* Generación de código de las sentencias condicionales aplicada en la regla
* 'else_exp' (no se escribe el fin de la condicion)
*
* @param f Fichero en el que se va a escribir
* @param tag Etiqueta ensamblador utilizada para la comparacion
*
*/
void gc_else (FILE *f, int tag){
    fprintf(f, "jmp near fin_sino%d\n", tag);
    fprintf(f, "fin_si%d:\n", tag);
    return;
}

/*
* Generación de código de las sentencias condicionales aplicada en la regla
* 'condicional -> else_exp...' (solo se escribe el fin de la condicion)
*
* @param f Fichero en el que se va a escribir
* @param tag Etiqueta ensamblador utilizada para la comparacion
*
*/
void gc_end_else (FILE *f, int tag){
    fprintf(f, "fin_sino%d:\n", tag);
    return;
}

/*
* Generación de código para sentencias iterativas aplicado en la regla
* 'while -> ...'
*
* @param f Fichero en el que se va a escribir
* @param tag Etiqueta ensamblador utilizada para la comparacion
*
*/
void gc_while_ini (FILE *f, int tag){
    fprintf(f, "inicio_while%d:\n", tag);
    return;
}

/*
* Generación de código para sentencias iterativas aplicado en la regla
* 'while -> ...'
*
* @param f Fichero en el que se va a escribir
* @param tag Etiqueta ensamblador utilizada para la comparacion
* @param es_direccion_op Indica si es direccion el operando 1 
*
*/
void gc_while_med (FILE *f, int tag, int es_direccion_op){
    fprintf(f, "pop eax\n");
    if (es_direccion_op == 1)
        fprintf(f, "mov eax , [eax]\n");
    fprintf(f, "cmp eax, 0\n");
    fprintf(f, "je near fin_while%d\n", tag);
    return;
}

/*
* Generación de código para sentencias iterativas aplicado en la regla
* 'bucle -> ...'
*
* @param f Fichero en el que se va a escribir
* @param tag Etiqueta ensamblador utilizada para la comparacion
*
*/
void gc_while_fin (FILE *f, int tag){
    fprintf(f, "jmp near inicio_while%d\n", tag);
    fprintf(f, "fin_while%d:\n", tag);
    return;
}

/*
* Generación de código para funciones. Utilizado en fn_declaracion
*
* @param f Fichero en el que se va a escribir
* @param name Nombre de la funcion
* @param nvar Numero de variables locales
*
*/
void gc_funcion_ini (FILE *f, char *name, int nvar){
    fprintf(f, "_%s:\n", name); 
    fprintf(f, "push ebp\n");   
    fprintf(f, "mov ebp, esp\n");   
    fprintf(f, "sub esp, %d\n", 4*nvar);    
    return;
}

/*
* Generación de código para funciones. 
* Utilizado en exp->idf_llamada_funcion...
*
* @param f Fichero en el que se va a escribir
* @param name Nombre de la funcion
* @param nparam Numero de parametros de la funcion
*
*/
void gc_funcion_call (FILE *f, char *name, int nparam){
    fprintf(f, "call _%s\n", name);
    fprintf(f, "add esp, %d\n", 4*nparam);
    fprintf(f, "push dword eax\n");
}

/*
* Generación de código para el retorno de funciones. 
* Utilizado en retorno_funcion->...
*
* @param f Fichero en el que se va a escribir
* @param es_direccion_op Indica si es direccion el operando 1  
*
*/
void gc_funcion_return (FILE *f, int es_direccion_op){
    fprintf(f, "pop dword eax\n");

    if (es_direccion_op == 1)
        fprintf(f, "mov eax, [eax]\n");

    fprintf(f, "mov dword esp, ebp\n");
    fprintf(f, "pop dword ebp\n");
    fprintf(f, "ret\n");

    return;
}

/*
* Generación de código para funciones. Utilizado en funcion->...
* Escribe las últimas instrucciones en el cuerpo de una función 
*
* @param f Fichero en el que se va a escribir
*
*/
void gc_funcion_fin (FILE *f){
    fprintf(f, "mov esp, ebp\n");
    fprintf(f, "pop ebp\n");
    fprintf(f, "ret\n");
}


/*
* Generación de código para tratamiento de identificadores globales
*
* @param f Fichero en el que se va a escribir
* @param name Nombre del identificador 
* @param en_explist 0 = declaracion variable, 1 = variable en llamada a funcion
*
*/
void gc_identificadores (FILE *f, char *name, int en_explist){
    if (en_explist == 0)
        fprintf(f, "push dword _%s\n", name);
    else
        fprintf(f, "push dword [_%s]\n", name);

    return;
}

/*
* Generación de código para tratamiento de identificadores dentro de una funcion
*
* @param f Fichero en el que se va a escribir
* @param categoria Categoria del identificador 
* @param posParam Posicion del parametro en la llamada a la funcion 
* @param posVar Posicion de la variable local 
* @param nparam Numero de parametros de la funcion 
* @param paramFunc 0 = identificador no pertenece a los parametros, 1 = pertenece
*
*/
void gc_identificadores_funcion (FILE *f, int categoria, int posParam, int nparam, int posVar, int paramFunc){
    if(paramFunc == 0){
        if(categoria == PARAMETRO){
            fprintf(f, "lea eax, [ebp+%d]\n", 4+4*(nparam - posParam));
            fprintf(f, "push dword eax\n");
        }
        else{
            fprintf(f, "lea eax, [ebp-%d]\n", 4*(posVar));
            fprintf(f, "push dword eax\n");
        }
    }
    else{
        if(categoria == PARAMETRO){
            fprintf(f, "lea eax, [ebp+%d]\n", 4+4*(nparam - posParam));
            fprintf(f, "push dword [eax]\n");
        }
        else{
            fprintf(f, "lea eax, [ebp-%d]\n", 4*(posVar));
            fprintf(f, "push dword [eax]\n");
        }
    }
    
    return;
}

/*
* Estructura de la zona para las etiquetas en las que se informa 
* al usuario de un error de ejecucion
*
* @param f Fichero en el que se va a escribir
*
*/
void gc_error(FILE *f){
    fprintf(f, "error_indice: push dword mensaje_1\n");
    fprintf(f, "call print_string\n");
    fprintf(f, "add esp, 4\n");
    fprintf(f, "call print_endofline\n");
    fprintf(f, "jmp near fin\n");

    fprintf(f, "error_division: push dword mensaje_2\n");
    fprintf(f, "call print_string\n");
    fprintf(f, "add esp, 4\n");
    fprintf(f, "call print_endofline\n");
    fprintf(f, "jmp near fin\n");
                
    fprintf(f, "fin: ret\n");
}
