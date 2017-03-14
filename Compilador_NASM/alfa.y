
%{

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#define _POSIX_C_SOURCE 1
#include "alfa.h"
#include "tabla_sim.h"
#include "y.tab.h"
#include "nasm.h"

 
int yyerror(char *cadena);
extern int yylex();
extern char* yytext;
extern int linea, columna, yyleng, error;
extern FILE* salida;

hash_node_t *tabla_global = NULL;
hash_node_t *tabla_local = NULL;
int existe_local = FALSE; /* Es true cuando se trabaja en ese ambito de funcion */
int tipo_actual = -1, tipo_local_actual = -1, clase_actual = -1, clase_local_actual = -1, tamanio_vector_actual = 0, pos_variable_local_actual = 0, num_variables_locales_actual = 0;
int pos_parametro_actual = 0, num_parametros_actual = 0,  num_parametros_llamada_actual = 0, error_tam_vector = FALSE;
int aux; /* variable auxiliar para guardad datos temporales */
int en_explist = 0; /* Se utiliza para comprobar que no hay una llamada a funcion en lugar de un parametro */
int retorno = FALSE; /* util para comprobar si una fucion tiene retorno */
int etiqueta = 0; /* utilizado para generacion de codigo condicional e iterativo */
int ult = 0; /* utilizado para almacenar las varibles a escribir en el segment bss*/
int esfunc = 0; /* utilizado para saber si el nombre de una variable es el de una funcion */
char nombre_funcion[MAX_LONG_ID+1];
char variables[MAX_VAR][MAX_LONG_ID+1];



%}

%union {
    tipo_atributos atributos;
}

/*Palabrasreservadas*/
%token TOK_MAIN
%token TOK_INT
%token TOK_BOOLEAN
%token TOK_ARRAY
%token TOK_FUNCTION
%token TOK_IF
%token TOK_ELSE
%token TOK_WHILE
%token TOK_SCANF
%token TOK_PRINTF
%token TOK_RETURN


/*Simbolos*/
%token TOK_PUNTOYCOMA
%token TOK_COMA
%token TOK_PARENTESISIZQUIERDO
%token TOK_PARENTESISDERECHO
%token TOK_CORCHETEIZQUIERDO
%token TOK_CORCHETEDERECHO
%token TOK_LLAVEIZQUIERDA
%token TOK_LLAVEDERECHA
%token TOK_ASIGNACION
%token TOK_MAS
%token TOK_MENOS
%token TOK_DIVISION
%token TOK_ASTERISCO
%token TOK_AND
%token TOK_OR
%token TOK_NOT
%token TOK_IGUAL
%token TOK_DISTINTO
%token TOK_MENORIGUAL
%token TOK_MAYORIGUAL
%token TOK_MENOR
%token TOK_MAYOR


/*Identificadores*/
%token <atributos> TOK_IDENTIFICADOR

/*Constantes*/

%token <atributos> TOK_CONSTANTE_ENTERA
%token TOK_TRUE
%token TOK_FALSE

/*Errores*/
%token TOK_ERROR

%left TOK_IGUAL TOK_DISTINTO TOK_MENORIGUAL TOK_MAYORIGUAL TOK_MAYOR TOK_MENOR
%left TOK_MAS TOK_MENOS TOK_OR
%left TOK_ASTERISCO TOK_DIVISION TOK_AND
%left TOK_PARENTESISIZQUIERDO TOK_PARENTESISDERECHO
%right TOK_NOT MENOS

%type <atributos> exp
%type <atributos> comparacion
%type <atributos> asignacion
%type <atributos> vector
%type <atributos> funcion
%type <atributos> fn_declaration
%type <atributos> constante_logica
%type <atributos> constante_entera
%type <atributos> constante
%type <atributos> idpf
%type <atributos> fn_name
%type <atributos> idf_llamada_funcion 
%type <atributos> elemento_vector 
%type <atributos> if_exp
%type <atributos> else_exp
%type <atributos> while
%type <atributos> while_exp
%type <atributos> condicional 
%type <atributos> bucle


%start programa

%% 

programa: inicioTabla TOK_MAIN TOK_LLAVEIZQUIERDA declaraciones escritura_TS funciones escritura_main sentencias TOK_LLAVEDERECHA   {
    fprintf(salida, ";R1:\t<programa> ::= main { <declaraciones> <funciones> <sentencias> }\n");
    fprintf(salida, "ret\n");
    gc_error(salida);
    hash_destroy(tabla_global);
};

inicioTabla: {
    tabla_global = hash_create();
    if (tabla_global == NULL) {
        printf("Error al crear el ambito global.\n");
        return -1;
    }

}

escritura_main: {
    /* Codigo nasm de etiqueta main */
    fprintf(salida, "main:\n");
}

escritura_TS : {
    gc_segment_bss(salida, tabla_global, variables, ult);
    gc_segment_data(salida);
    gc_segment_text(salida);
}


declaraciones: declaracion {
        fprintf(salida,";R2:\t<declaraciones> ::= <declaracion> \n");
    }
    | 
    declaracion declaraciones {
        fprintf(salida, ";R3:\t<declaraciones> ::= <declaracion> <declaraciones> \n");
    };

declaracion: clase identificadores TOK_PUNTOYCOMA {
    fprintf(salida, ";R4:\t<declaracion> ::= <clase> <identificadores> ; \n");
};


clase: escalar 
    {
        clase_actual = ESCALAR;
        fprintf(salida, ";R5:\t<clase> ::= <clase_escalar>\n");
    }
    | vector {
        clase_actual = VECTOR;
        fprintf(salida, ";R7:\t<clase> ::= <clase_vector>\n");
    };

clase_funcion: escalar_funcion
    {
        clase_local_actual = ESCALAR;
        fprintf(salida, ";R5:\t<clase_funcion> ::= <clase_escalar>\n");
    }
    | vector_funcion {
        clase_local_actual = VECTOR;
        fprintf(salida, ";R7:\t<clase_funcion> ::= <clase_vector>\n");
    };
   

escalar: tipo 
    {
        fprintf(salida, ";R9:\t<clase_escalar> ::= <tipo>\n");
    };

escalar_funcion: tipo_funcion 
    {
        fprintf(salida, ";R9:\t<clase_escalar_funcion> ::= <tipo>\n");
    };

tipo: TOK_INT {
        tipo_actual = INT;
        fprintf(salida, ";R10:\t<tipo> ::= int\n");
    }
    | 
    TOK_BOOLEAN 
    {
        tipo_actual = BOOLEAN;
        fprintf(salida, ";R11:\t<tipo> ::= boolean\n");
    };

tipo_funcion: TOK_INT {
        tipo_local_actual = INT;
        fprintf(salida, ";R10:\t<tipo_funcion> ::= int\n");
    }
    | 
    TOK_BOOLEAN 
    {
        tipo_local_actual = BOOLEAN;
        fprintf(salida, ";R11:\t<tipo_funcion> ::= boolean\n");
    };


vector: TOK_ARRAY tipo TOK_CORCHETEDERECHO constante_entera TOK_CORCHETEIZQUIERDO {
        tamanio_vector_actual = $4.valor_entero;
        if ($4.valor_entero <= 0 || $4.valor_entero > MAX_TAMANIO_VECTOR) {
            error_tam_vector = TRUE;
        }

        fprintf(salida, ";R15:\t<clase_vector> ::= array <tipo> [ <constante_entera> ]\n");
    };

vector_funcion: TOK_ARRAY tipo_funcion TOK_CORCHETEIZQUIERDO constante_entera TOK_CORCHETEDERECHO {
        tamanio_vector_actual = $4.valor_entero;
        if ($4.valor_entero <= 0 || $4.valor_entero > MAX_TAMANIO_VECTOR) {
            error_tam_vector = TRUE;
        }

        fprintf(salida, ";R15:\t<clase_vector> ::= array <tipo> [ <constante_entera> ]\n");
    };
    
identificadores: identificador
    {
        fprintf(salida, ";R18:\t<identificadores> ::= <identificador>\n");
    }
    | 
    identificador TOK_COMA identificadores
    {
        fprintf(salida, ";R19:\t<identificadores> ::= <identificador> , <identificadores>\n");
    };


funciones: funcion funciones {
        fprintf(salida, ";R20:\t<funciones> ::= <funcion> <funciones> \n");
    }
    |
    {
        fprintf(salida, ";R21:\t<funciones> ::=\n");
    };

fn_name: TOK_FUNCTION tipo TOK_IDENTIFICADOR {
    if (hash_get(tabla_global, $3.lexema) == ERROR){
        tabla_local = hash_create();
        num_variables_locales_actual = 0; 
        pos_variable_local_actual = 1; 
        num_parametros_actual = 0; 
        pos_parametro_actual = 0; 
        hash_add(tabla_global, $3.lexema, FUNCION, tipo_actual, clase_actual, tamanio_vector_actual, pos_variable_local_actual, num_variables_locales_actual, pos_parametro_actual, num_parametros_actual);
        hash_add(tabla_local, $3.lexema, FUNCION, tipo_actual, clase_actual, tamanio_vector_actual, pos_variable_local_actual, num_variables_locales_actual, pos_parametro_actual, num_parametros_actual);
        strcpy ($$.lexema, $3.lexema);
        strcpy (nombre_funcion, $3.lexema);
        existe_local = TRUE;
    }
    else {
        fprintf(stderr, "****Error semantico en lin %d: Declaracion duplicada.\n", linea);
        return -1;
    }
    retorno = FALSE;
};

fn_declaration: fn_name TOK_PARENTESISIZQUIERDO parametros_funcion TOK_PARENTESISDERECHO TOK_LLAVEIZQUIERDA declaraciones_funcion {
    actualizar(tabla_local, $1.lexema, num_parametros_actual);
    strcpy($$.lexema, $1.lexema);
    gc_funcion_ini(salida, $1.lexema, num_variables_locales_actual);
};

funcion: fn_declaration sentencias TOK_LLAVEDERECHA {
    if (retorno == FALSE) {
        fprintf(stderr, "****Error semantico en lin %d: Funcion <%s> sin sentencia de retorno.\n", linea, $1.lexema);
        return -1;
    }
    hash_destroy(tabla_local);
    existe_local = FALSE;
    actualizar(tabla_global, $1.lexema, num_parametros_actual);
    fprintf(salida, ";R22:\t<funcion> ::= function <tipo> <identificador> ( <parametros_funcion> ) { <declaraciones_funcion> <sentencias> }\n");
    gc_funcion_fin(salida);
};

parametros_funcion: parametro_funcion resto_parametros_funcion {
        fprintf(salida, ";R23:\t<parametros_funcion> ::= <parametro_funcion> <resto_parametros_funcion>\n");
    }
    | 
    {
        fprintf(salida, ";R24:\t<parametros_funcion> ::=\n");
    };
    
resto_parametros_funcion : TOK_PUNTOYCOMA parametro_funcion resto_parametros_funcion {
        fprintf(salida, ";R25:\t<resto_parametros_funcion> ::= ; <parametro_funcion> <resto_parametros_funcion>\n");
    }
    | 
    {
        fprintf(salida, ";R26:\t<resto_parametros_funcion> ::=\n");
    };

parametro_funcion: clase_funcion idpf {
        fprintf(salida, ";R27:\t<parametro_funcion> ::= <tipo> <identificador>\n");
        
    };

declaraciones_funcion: declaraciones {
        fprintf(salida, ";R28:\t<declaraciones_funcion> ::= <declaraciones>\n");
    }
    |
    {
        fprintf(salida, ";R29:\t<declaraciones_funcion> ::=\n");
    };
sentencias: sentencia {
        fprintf(salida, ";R30:\t<sentencias> ::= <sentencia> \n");
    }
    |
    sentencia sentencias {
        fprintf(salida, ";R31:\t<sentencias> ::= <sentencia> <sentencias> \n");
    }
;

sentencia: sentencia_simple TOK_PUNTOYCOMA {
        fprintf(salida, ";R32:\t<sentencia> ::= <sentencia_simple> ;\n");
    }
    |
    bloque {
        fprintf(salida, ";R33:\t<sentencia> ::= <bloque>\n");
    };

sentencia_simple: asignacion {
        fprintf(salida, ";R34:\t<sentencia_simple> ::= <asignacion>\n");
    }
    | 
    lectura {
        fprintf(salida, ";R35:\t<sentencia_simple> ::= <lectura>\n");
    }
    | escritura 
    {
        fprintf(salida, ";R36:\t<sentencia_simple> ::= <escritura>\n");
    }
    |
    retorno_funcion {
        fprintf(salida, ";R38:\t<sentencia_simple> ::= <retorno_funcion>\n");
    };

bloque: condicional {
        fprintf(salida, ";R40:\t<bloque> ::= <condicional>\n");
    }
    | 
    bucle {
        fprintf(salida, ";R41:\t<bloque> ::= <bucle>\n");
    };

asignacion: TOK_IDENTIFICADOR TOK_ASIGNACION exp {
        /* Ambito global */
        if (existe_local == FALSE) {
            if (hash_get(tabla_global, $1.lexema) == ERROR) {
                fprintf(stderr, "****Error semantico en lin %d: Acceso a variable no declarada (<%s>).\n", linea, $1.lexema);
                return -1;
            }
            else {
                if (get_categoria(tabla_global, $1.lexema) == FUNCION) {
                    fprintf(stderr, "****Error semantico en lin %d: Asignacion incompatible.\n", linea);
                    return -1;
                }
                if (get_clase(tabla_global, $1.lexema) == VECTOR) {
                    fprintf(stderr, "****Error semantico en lin %d: Asignacion incompatible.\n", linea);
                    return -1;
                }
                if (get_tipo(tabla_global, $1.lexema) != $3.tipo ) {
                    fprintf(stderr, "****Error semantico en lin %d: Asignacion incompatible.\n", linea);
                    return -1;
                }
            }
            gc_asignacion_identificador(salida, $3.es_direccion, $1.lexema);
        }
        /* Ambito local */
        else {
            if (hash_get(tabla_local, $1.lexema) == ERROR) {
                if (hash_get(tabla_global, $1.lexema) == ERROR) {
                    fprintf(stderr, "****Error semantico en lin %d: Acceso a variable no declarada (<%s>).\n", linea, $1.lexema);
                    return -1;
                }
                else {
                    if (get_categoria(tabla_global, $1.lexema) == FUNCION) {
                        fprintf(stderr, "****Error semantico en lin %d: Asignacion incompatible.\n", linea);
                        return -1;
                    }
                    if (get_clase(tabla_global, $1.lexema) == VECTOR) {
                        fprintf(stderr, "****Error semantico en lin %d: Asignacion incompatible.\n", linea);
                        return -1;
                    }
                    if (get_tipo(tabla_global, $1.lexema) != $3.tipo ) {
                        fprintf(stderr, "****Error semantico en lin %d: Asignacion incompatible.\n", linea);
                        return -1;
                    }
                    gc_asignacion_identificador(salida, $3.es_direccion, $1.lexema);
                }
            }
            else {
                if (get_categoria(tabla_local, $1.lexema) == FUNCION) {
                    fprintf(stderr, "****Error semantico en lin %d: Asignacion incompatible.\n", linea);
                    return -1;
                }
                if (get_clase(tabla_local, $1.lexema) == VECTOR) {
                    fprintf(stderr, "****Error semantico en lin %d: Asignacion incompatible.\n", linea);
                    return -1;
                }
                if (get_tipo(tabla_local, $1.lexema) != $3.tipo ) {
                    fprintf(stderr, "****Error semantico en lin %d: Asignacion incompatible.\n", linea);
                    return -1;
                }
                gc_identificadores_funcion(salida, get_categoria(tabla_local, $1.lexema), get_pos_parametro(tabla_local, $1.lexema), num_parametros_actual, get_pos_variable(tabla_local, $1.lexema), esfunc);
                gc_asignacion_identificador_funcion(salida, $3.es_direccion);
            }
        }
        fprintf(salida, ";R43:\t<asignacion> ::= <identificador> = <exp>\n");
    }
    |   
    elemento_vector TOK_ASIGNACION exp {
        if ($1.tipo != $3.tipo){
            fprintf(stderr, "****Error semantico en lin %d:  Asignacion incompatible.\n", linea); 
            return -1;
        }
        fprintf(salida, ";R44:\t<asignacion> ::= <elemento_vector> = <exp>\n");
        gc_asignacion_elem_vector(salida, $3.es_direccion);
    };

elemento_vector: TOK_IDENTIFICADOR TOK_CORCHETEIZQUIERDO exp TOK_CORCHETEDERECHO {
         /* Ambito global */
        if (existe_local == FALSE) {
            if (hash_get(tabla_global, $1.lexema) == ERROR) {
                fprintf(stderr, "****Error semantico en lin %d: Acceso a variable no declarada (<%s>).\n", linea, $1.lexema);
                return -1;
            }
            else {
                if (get_categoria(tabla_global, $1.lexema) == FUNCION) {
                    fprintf(stderr, "****Error semantico en lin %d: Intento de indexacion de una variable que no es de tipo vector.\n", linea);
                    return -1;
                }
                if (get_clase(tabla_global, $1.lexema) == VECTOR) {
                    if ($3.tipo == INT) {
                        $$.tipo = get_tipo(tabla_global, $1.lexema);
                        $$.es_direccion = 1;
                    }
                    else {
                        fprintf(stderr, "****Error semantico en lin %d: El indice en una operacion de indexacion tiene que ser de tipo entero.\n", linea);
                        return -1;
                    }
                    gc_elemento_vector(salida, $3.es_direccion, get_tam(tabla_global, $1.lexema),$1.lexema);
                }
                else {
                    fprintf(stderr, "****Error semantico en lin %d: Intento de indexacion de una variable que no es de tipo vector.\n", linea);
                    return -1;
                }
            }
        }
        /* Ambito local */
        else {
            if (hash_get(tabla_local, $1.lexema) == ERROR) {
                if (hash_get(tabla_global, $1.lexema) == ERROR) {
                    fprintf(stderr, "****Error semantico en lin %d: Acceso a variable no declarada (<%s>).\n", linea, $1.lexema);
                    return -1;
                }
                else {
                    if (get_categoria(tabla_global, $1.lexema) == FUNCION) {
                        fprintf(stderr, "****Error semantico en lin %d: Intento de indexacion de una variable que no es de tipo vector.\n", linea);
                        return -1;
                    }
                    if (get_clase(tabla_global, $1.lexema) == VECTOR) {
                        if ($3.tipo == INT) {
                            if($3.valor_entero < 0 || $3.valor_entero > tamanio_vector_actual){
                                fprintf(stderr, "****Error semantico en lin %d: El indice fuera del tamaño definido para el vector.\n", linea);
                                return -1;
                            }
                            $$.tipo = get_tipo(tabla_global, $1.lexema);
                            $$.es_direccion = 1;
                        }
                        else {
                            fprintf(stderr, "****Error semantico en lin %d: El indice en una operacion de indexacion tiene que ser de tipo entero.\n", linea);
                            return -1;
                        }
                        gc_elemento_vector(salida, $3.es_direccion, get_tam(tabla_global, $1.lexema),$1.lexema);
                    }
                    else {
                        fprintf(stderr, "****Error semantico en lin %d: Intento de indexacion de una variable que no es de tipo vector.\n", linea);
                        return -1;
                    }
                }
            }
            else {
                if (get_categoria(tabla_local, $1.lexema) == FUNCION) {
                        fprintf(stderr, "****Error semantico en lin %d: Intento de indexacion de una variable que no es de tipo vector.\n", linea);
                        return -1;
                    }
                if (get_clase(tabla_local, $1.lexema) == VECTOR) {
                    if ($3.tipo == INT) {
                        if($3.valor_entero < 0 || $3.valor_entero > tamanio_vector_actual){
                            fprintf(stderr, "****Error semantico en lin %d: El indice fuera del tamaño definido para el vector.\n", linea);
                            return -1;
                        } 
                        $$.tipo = get_tipo(tabla_local, $1.lexema);
                        $$.es_direccion = 1;
                    }
                    else {
                        fprintf(stderr, "****Error semantico en lin %d: El indice en una operacion de indexacion tiene que ser de tipo entero.\n", linea);
                        return -1;
                    }
                    gc_elemento_vector(salida, $3.es_direccion, get_tam(tabla_local, $1.lexema),$1.lexema);
                }
                else {
                    fprintf(stderr, "****Error semantico en lin %d: Intento de indexacion de una variable que no es de tipo vector.\n", linea);
                    return -1;
                }
            }
        }
        fprintf(salida, ";R48:\t<elemento_vector> ::= <identificador> [ <exp> ]\n");
    };

if_exp: TOK_IF TOK_PARENTESISIZQUIERDO exp {
    if ($3.tipo != BOOLEAN) {
        fprintf(stderr, "****Error semantico en lin %d: Condicional con condicion de tipo int.\n", linea); 
        return -1;
    }
    $$.etiqueta = etiqueta;
    etiqueta++;
    gc_if(salida, $3.es_direccion, $$.etiqueta);
};

else_exp: if_exp TOK_PARENTESISDERECHO TOK_LLAVEIZQUIERDA sentencias TOK_LLAVEDERECHA {
    $$.etiqueta = $1.etiqueta;
    gc_else(salida, $$.etiqueta);
};


while: TOK_WHILE TOK_PARENTESISIZQUIERDO {
    $$.etiqueta = etiqueta;
    etiqueta++;
    gc_while_ini(salida, $$.etiqueta);
};

while_exp: while exp TOK_PARENTESISDERECHO {
    if ($2.tipo != BOOLEAN) {
        fprintf(stderr, "****Error semantico en lin %d: Bucle con condicion de tipo int.\n", linea);
        return -1;
    }
    $$.etiqueta = $1.etiqueta;
    gc_while_med(salida, $$.etiqueta, $2.es_direccion);
};

condicional: if_exp TOK_PARENTESISDERECHO TOK_LLAVEIZQUIERDA sentencias TOK_LLAVEDERECHA {
        fprintf(salida, ";R50:\t<condicional> ::=  if ( <exp> ) { <sentencias> }\n");
        gc_end_if(salida, $1.etiqueta);
    }
    | else_exp TOK_ELSE TOK_LLAVEIZQUIERDA sentencias TOK_LLAVEDERECHA {
        fprintf(salida, ";R51:\t<condicional> ::=  if ( <exp> ) { <sentencias> } else { <sentencias> }\n");
        gc_end_else(salida, $1.etiqueta);
    };

bucle: while_exp TOK_LLAVEIZQUIERDA sentencias TOK_LLAVEDERECHA {
        fprintf(salida, ";R52:\t<bucle> ::=  while ( <exp> ) { <sentencias> }\n");
        $$.etiqueta = $1.etiqueta;
        gc_while_fin(salida, $$.etiqueta);
    };

lectura: TOK_SCANF TOK_IDENTIFICADOR
    {
        /* Ambito global */
        if (existe_local == FALSE) {
            if (hash_get(tabla_global, $2.lexema) == ERROR) {
                fprintf(stderr, "****Error semantico en lin %d: Acceso a variable no declarada (<%s>).\n", linea, $2.lexema);
                return -1;
            }
            else {
                if (get_categoria(tabla_global, $2.lexema) == FUNCION) {
                    fprintf(stderr, "****Error semantico en lin %d: La categoria no puede ser funcion en scanf.\n", linea);
                    return -1;
                }
                if (get_clase(tabla_global, $2.lexema) == VECTOR) {
                    fprintf(stderr, "****Error semantico en lin %d: La clase no puede ser vector en scanf.\n", linea);
                    return -1;
                }
            }
            gc_scanf(salida, get_tipo(tabla_global, $2.lexema), $2.lexema);
        }
        /* Ambito local */
        else {
            if (hash_get(tabla_local, $2.lexema) == ERROR) {
                if (hash_get(tabla_global, $2.lexema) == ERROR) {
                    fprintf(stderr, "****Error semantico en lin %d: Acceso a variable no declarada (<%s>).\n", linea, $2.lexema);
                    return -1;
                }
                else {
                    if (get_categoria(tabla_global, $2.lexema) == FUNCION) {
                        fprintf(stderr, "****Error semantico en lin %d: La categoria no puede ser funcion en scanf.\n", linea);
                        return -1;
                    }
                    if (get_clase(tabla_global, $2.lexema) == VECTOR) {
                        fprintf(stderr, "****Error semantico en lin %d: La clase no puede ser vector en scanf.\n", linea);
                        return -1;
                    }
                }
                gc_scanf(salida, get_tipo(tabla_global, $2.lexema), $2.lexema);
            }
            else {
                if (get_categoria(tabla_local, $2.lexema) == FUNCION) {
                        fprintf(stderr, "****Error semantico en lin %d: La categoria no puede ser funcion en scanf.\n", linea);
                        return -1;
                }
                if (get_clase(tabla_local, $2.lexema) == VECTOR) {
                    fprintf(stderr, "****Error semantico en lin %d: La clase no puede ser vector en scanf.\n", linea);
                    return -1;
                }
                gc_identificadores_funcion(salida, get_categoria(tabla_local, $2.lexema), get_pos_parametro(tabla_local, $2.lexema), num_parametros_actual, get_pos_variable(tabla_local, $2.lexema), esfunc);
                gc_scanf_funcion(salida, get_tipo(tabla_local, $2.lexema));
            }
        }
        fprintf(salida, ";R54:\t<lectura> ::= scanf <identificador>\n");
    };

escritura: TOK_PRINTF exp
    {
        fprintf(salida, ";R56:\t<escritura> ::= printf <exp>\n");
        gc_printf(salida, $2.tipo, $2.es_direccion);

    };

retorno_funcion: TOK_RETURN exp
    {
        if (existe_local == FALSE) {
            fprintf(stderr, "****Error semantico en lin %d: Sentencia de retorno fuera del cuerpo de una función.\n", linea);
            return -1;
        }
        if (get_tipo(tabla_global, nombre_funcion) != $2.tipo){
            fprintf(stderr, "****Error semantico en lin %d: Sentencia de retorno de un tipo distinto al definido en <%s>.\n", linea, nombre_funcion);
            return -1;
        }
        retorno = TRUE;
        fprintf(salida, ";R61:\t<retorno_funcion> ::= return <exp>\n");
        gc_funcion_return(salida, $2.es_direccion);
    };


exp: exp TOK_MAS exp 
    {
        if($1.tipo != INT || $3.tipo != INT){
            fprintf(stderr, "****Error semantico en lin %d:  Operacion aritmetica con operandos boolean.\n", linea); 
            return -1;
        }
        $$.tipo = INT;  
        $$.es_direccion = 0; 
        fprintf(salida, ";R72:\t<exp> ::= <exp> + <exp>\n");
        gc_suma_enteros(salida, $1.es_direccion, $3.es_direccion);
    }
    |
    exp TOK_MENOS exp 
    {
        if($1.tipo != INT || $3.tipo != INT){
            fprintf(stderr, "****Error semantico en lin %d:  Operacion aritmetica con operandos boolean.\n", linea); 
            return -1;
        }
        $$.tipo = INT;  
        $$.es_direccion = 0; 
        fprintf(salida, ";R73:\t<exp> ::= <exp> - <exp>\n");
        gc_resta_enteros(salida, $1.es_direccion, $3.es_direccion);
    }
    | 
    exp TOK_DIVISION exp {
        if($1.tipo != INT || $3.tipo != INT){
            fprintf(stderr, "****Error semantico en lin %d:  Operacion aritmetica con operandos boolean.\n", linea); 
            return -1;
        }
        $$.tipo = INT;  
        $$.es_direccion = 0;  
        fprintf(salida, ";R74:\t<exp> ::= <exp> / <exp>\n");
        gc_div_enteros(salida, $1.es_direccion, $3.es_direccion);
    }
    | 
    exp TOK_ASTERISCO exp {
        if($1.tipo != INT || $3.tipo != INT){
            fprintf(stderr, "****Error semantico en lin %d:  Operacion aritmetica con operandos boolean.\n", linea); 
            return -1;
        }
        $$.tipo = INT;  
        $$.es_direccion = 0; 
        fprintf(salida, ";R75:\t<exp> ::= <exp> * <exp>\n");
        gc_mul_enteros(salida, $1.es_direccion, $3.es_direccion);
    }
    | 
    TOK_MENOS exp %prec MENOS {
        if($2.tipo != INT){
            fprintf(stderr, "****Error semantico en lin %d:  Operacion aritmetica con operandos boolean.\n", linea); 
            return -1;
        }
        $$.tipo = INT;  
        $$.es_direccion = 0; 
        $$.valor_entero = -($2.valor_entero);
        fprintf(salida, ";R76:\t<exp> ::= - <exp>\n");
        gc_neg_enteros(salida, $2.es_direccion);
    }
    | 
    exp TOK_AND exp {
        if($1.tipo != BOOLEAN || $3.tipo != BOOLEAN){
            fprintf(stderr, "****Error semantico en lin %d:  Operacion logica con operandos int.\n", linea); 
            return -1;
        }
        $$.tipo = BOOLEAN;  
        $$.es_direccion = 0;
        fprintf(salida, ";R77:\t<exp> ::= <exp> && <exp>\n");
        gc_and_logico(salida, $1.es_direccion, $3.es_direccion);
    }
    | 
    exp TOK_OR exp {
        if($1.tipo != BOOLEAN || $3.tipo != BOOLEAN){
            fprintf(stderr, "****Error semantico en lin %d:  Operacion logica con operandos int.\n", linea); 
            return -1;
        }
        $$.tipo = BOOLEAN;  
        $$.es_direccion = 0; 
        fprintf(salida, ";R78:\t<exp> ::= <exp> || <exp>\n");
        gc_or_logico(salida, $1.es_direccion, $3.es_direccion);
    }
    | 
    TOK_NOT exp {
        if ($2.tipo != BOOLEAN){
            fprintf(stderr, "****Error semantico en lin %d:  Operacion logica con operandos int.\n", linea); 
            return -1;
        }
        $$.tipo = BOOLEAN;
        $$.es_direccion = 0; 
        fprintf(salida, ";R79:\t<exp> ::= !<exp>\n");
        gc_neg_logico(salida, $2.es_direccion, etiqueta);
        etiqueta++;
    }
    | 
    TOK_IDENTIFICADOR {
        /* Ambito global */
        if (existe_local == FALSE) {
            if (hash_get(tabla_global, $1.lexema) == ERROR) {
                fprintf(stderr, "****Error semantico en lin %d: Acceso a variable no declarada (<%s>).\n", linea, $1.lexema);
                return -1;
            }
            else {
                if (get_categoria(tabla_global, $1.lexema) == FUNCION) {
                    fprintf(stderr, "****Error semantico en lin %d: La categoria no puede ser funcion en exp.\n", linea);
                    return -1;
                }
                if (get_clase(tabla_global, $1.lexema) == VECTOR) {
                    fprintf(stderr, "****Error semantico en lin %d: La clase no puede ser vector en exp.\n", linea);
                    return -1;
                }
            }
            $$.tipo = get_tipo(tabla_global, $1.lexema);
            $$.es_direccion = 1;
            gc_identificadores(salida, $1.lexema, en_explist);
        }
        /* Ambito local */
        else {
            if (hash_get(tabla_local, $1.lexema) == ERROR) {
                if (hash_get(tabla_global, $1.lexema) == ERROR) {
                    fprintf(stderr, "****Error semantico en lin %d: Acceso a variable no declarada (<%s>).\n", linea, $1.lexema);
                    return -1;
                }
                else {
                    if (get_categoria(tabla_global, $1.lexema) == FUNCION) {
                        fprintf(stderr, "****Error semantico en lin %d: La categoria no puede ser funcion en exp.\n", linea);
                        return -1;
                    }
                    if (get_clase(tabla_global, $1.lexema) == VECTOR) {
                        fprintf(stderr, "****Error semantico en lin %d: La clase no puede ser vector en exp.\n", linea);
                        return -1;
                    }
                }
                $$.tipo = get_tipo(tabla_global, $1.lexema);
                $$.es_direccion = 1;
                gc_identificadores(salida, $1.lexema, en_explist);
            }
            else {
                if (get_categoria(tabla_local, $1.lexema) == FUNCION) {
                        fprintf(stderr, "****Error semantico en lin %d: La categoria no puede ser funcion en exp.\n", linea);
                        return -1;
                }
                if (get_clase(tabla_local, $1.lexema) == VECTOR) {
                    fprintf(stderr, "****Error semantico en lin %d: La clase no puede ser vector en exp.\n", linea);
                    return -1;
                }
                $$.tipo = get_tipo(tabla_local, $1.lexema);
                $$.es_direccion = 1;
                gc_identificadores_funcion(salida, get_categoria(tabla_local, $1.lexema), get_pos_parametro(tabla_local, $1.lexema), num_parametros_actual, get_pos_variable(tabla_local, $1.lexema), esfunc);
            }
        }
        fprintf(salida, ";R80:\t<exp> ::= <identificador>\n");
    }
    | 
    constante {
        $$.tipo = $1.tipo; 
        $$.es_direccion = $1.es_direccion;
        if ($1.tipo == INT)
            $$.valor_entero = $1.valor_entero;
        fprintf(salida, ";R81:\t<exp> ::= <constante>\n");
    }
    | 
    TOK_PARENTESISIZQUIERDO exp TOK_PARENTESISDERECHO {
        $$.tipo = $2.tipo; 
        $$.es_direccion = $2.es_direccion;
        fprintf(salida, ";R82:\t<exp> ::= ( <exp> )\n");
    }
    |
    TOK_PARENTESISIZQUIERDO comparacion TOK_PARENTESISDERECHO {
        $$.tipo = $2.tipo; 
        $$.es_direccion = $2.es_direccion;
        fprintf(salida, ";R83:\t<exp> ::= ( <comparacion> )\n");
    }
    |
    elemento_vector {
        $$.tipo = $1.tipo; 
        $$.es_direccion = $1.es_direccion;
        fprintf(salida, ";R85:\t<exp> ::= <elemento_vector>\n");
    }
    |
    idf_llamada_funcion TOK_PARENTESISIZQUIERDO lista_expresiones TOK_PARENTESISDERECHO {
        esfunc = 0;
        /* Ambito global */
        if (existe_local == FALSE){
            if (num_parametros_llamada_actual != get_num_param(tabla_global, $1.lexema)){
                fprintf(stderr, "****Error semantico en lin %d: Numero incorrecto de parametros en llamada a funcion.\n", linea);
                return -1;
            }
            en_explist = 0;
            $$.tipo = get_tipo(tabla_global, $1.lexema);
            $$.es_direccion = 0;
            gc_funcion_call(salida, $1.lexema, num_parametros_actual);
        }
        /* Ambito local */
        else {
            if (strcmp(nombre_funcion, $1.lexema) == 0){
                if (num_parametros_llamada_actual != get_num_param(tabla_local, $1.lexema)){
                    fprintf(stderr, "****Error semantico en lin %d: Numero incorrecto de parametros en llamada a funcion.\n", linea);
                    return -1;
                }
                en_explist = 0;
                $$.tipo = get_tipo(tabla_global, $1.lexema);
                $$.es_direccion = 0;
                gc_funcion_call(salida, $1.lexema, num_parametros_actual);
            }
            else {
                if (num_parametros_llamada_actual != get_num_param(tabla_global, $1.lexema)){
                    fprintf(stderr, "****Error semantico en lin %d: Numero incorrecto de parametros en llamada a funcion.\n", linea);
                    return -1;
                }
                en_explist = 0;
                $$.tipo = get_tipo(tabla_global, $1.lexema);
                $$.es_direccion = 0;
                gc_funcion_call(salida, $1.lexema, num_parametros_llamada_actual);
            }
        }
        fprintf(salida, ";R88:\t<exp> ::= <identificador> ( <lista_expresiones> )\n");
    };

lista_expresiones: exp resto_lista_expresiones {
        num_parametros_llamada_actual++;
        fprintf(salida, ";R89:\t<lista_expresiones> ::= <exp> <resto_lista_expresiones>\n");
    }
    | 
    {
        fprintf(salida, ";R90:\t<lista_expresiones> ::=\n");
    };

resto_lista_expresiones: TOK_COMA exp resto_lista_expresiones {
        num_parametros_llamada_actual++;
        fprintf(salida, ";R91:\t<resto_lista_expresiones> ::=  , <exp> <resto_lista_expresiones>\n");
    }
    | 
    {
        fprintf(salida, ";R92:\t<resto_lista_expresiones> ::=\n");
    };

comparacion: exp TOK_IGUAL exp {
        if($1.tipo != INT || $3.tipo != INT){
            fprintf(stderr, "****Error semantico en lin %d:  Comparacion con operandos boolean.\n", linea); 
            return -1;
        }
        $$.tipo = BOOLEAN;   
        $$.es_direccion = 0; 
        fprintf(salida, ";R93:\t<comparacion> ::= <exp> == <exp>\n");
        gc_igual(salida, $1.es_direccion, $3.es_direccion, etiqueta);
        etiqueta++;
    }
    |
    exp TOK_DISTINTO exp {
        if($1.tipo != INT || $3.tipo != INT){
            fprintf(stderr, "****Error semantico en lin %d:  Comparacion con operandos boolean.\n", linea); 
            return -1;
        }
        $$.tipo = BOOLEAN;   
        $$.es_direccion = 0;
        fprintf(salida, ";R94:\t<comparacion> ::= <exp> != <exp>\n");
        gc_distinto(salida, $1.es_direccion, $3.es_direccion, etiqueta);
        etiqueta++;
    }
    |
    exp TOK_MENORIGUAL exp {
        if($1.tipo != INT || $3.tipo != INT){
            fprintf(stderr, "****Error semantico en lin %d:  Comparacion con operandos boolean.\n", linea); 
            return -1;
        }
        $$.tipo = BOOLEAN;   
        $$.es_direccion = 0;
        fprintf(salida, ";R95:\t<comparacion> ::= <exp> <= <exp>\n");
        gc_menor_igual(salida, $1.es_direccion, $3.es_direccion, etiqueta);
        etiqueta++;
    }
    |
    exp TOK_MAYORIGUAL exp {
        if($1.tipo != INT || $3.tipo != INT){
            fprintf(stderr, "****Error semantico en lin %d:  Comparacion con operandos boolean.\n", linea); 
            return -1;
        }
        $$.tipo = BOOLEAN;   
        $$.es_direccion = 0;
        fprintf(salida, ";R96:\t<comparacion> ::= <exp> >= <exp>\n");
        gc_mayor_igual(salida, $1.es_direccion, $3.es_direccion, etiqueta);
        etiqueta++;
    }
    |
    exp TOK_MENOR exp {
        if($1.tipo != INT || $3.tipo != INT){
            fprintf(stderr, "****Error semantico en lin %d:  Comparacion con operandos boolean.\n", linea); 
            return -1;
        }
        $$.tipo = BOOLEAN;   
        $$.es_direccion = 0; 
        fprintf(salida, ";R97:\t<comparacion> ::= <exp> < <exp>\n");
        gc_menor(salida, $1.es_direccion, $3.es_direccion, etiqueta);
        etiqueta++;
    }
    |
    exp TOK_MAYOR exp {
        if($1.tipo != INT || $3.tipo != INT){
            fprintf(stderr, "****Error semantico en lin %d:  Comparacion con operandos boolean.\n", linea); 
            return -1;
        }
        $$.tipo = BOOLEAN;   
        $$.es_direccion = 0;
        fprintf(salida, ";R98:\t<comparacion> ::= <exp> > <exp>\n");
        gc_mayor(salida, $1.es_direccion, $3.es_direccion, etiqueta);
        etiqueta++;
    };

constante: constante_logica {
        $$.tipo = $1.tipo;
        $$.es_direccion = $1.es_direccion;
        fprintf(salida, ";R99:\t<constante> ::= <constante_logica>\n");
    }
    |
    constante_entera {
        $$.tipo = $1.tipo;
        $$.es_direccion = $1.es_direccion;
        fprintf(salida, ";R100:\t<constante> ::= <constante_entera>\n");
    };

constante_logica: TOK_TRUE {
        $$.tipo = BOOLEAN;
        $$.es_direccion = 0;
        fprintf(salida, ";R102:\t<constante_logica> ::= true\n");
        gc_constante(salida, TRUE);
    }
    |
    TOK_FALSE {
        $$.tipo = BOOLEAN;
        $$.es_direccion = 0;
        fprintf(salida, ";R103:\t<constante_logica> ::= false\n");
        gc_constante(salida, FALSE);
    };

constante_entera: TOK_CONSTANTE_ENTERA {
        $$.tipo =  INT;
        $$.es_direccion = 0;
        $$.valor_entero = $1.valor_entero;
        fprintf(salida, ";R104:\t<constante_entera> ::= TOK_CONSTANTE_ENTERA\n");
        gc_constante(salida, $1.valor_entero);
    };

idpf: TOK_IDENTIFICADOR {
    if(hash_get(tabla_local, $1.lexema) == ERROR){
        hash_add(tabla_local, $1.lexema, PARAMETRO, tipo_local_actual, clase_local_actual, tamanio_vector_actual, pos_variable_local_actual, num_variables_locales_actual, pos_parametro_actual, num_parametros_actual);
        strcpy($$.lexema, $1.lexema);
        pos_parametro_actual++;
        num_parametros_actual++;
    } 
    else {
        fprintf(stderr, "****Error semantico en lin %d. Declaracion duplicada.\n", linea);
        return -1;
    }
    fprintf(salida, ";R108:\t<identificador> ::= TOK_IDENTIFICADOR\n");
}

idf_llamada_funcion: TOK_IDENTIFICADOR {
    esfunc = 0;
    if (hash_get(tabla_global, $1.lexema) == ERROR) {
        fprintf(stderr, "****Error semantico en lin %d: Acceso a variable no declarada (<%s>).\n", linea, $1.lexema);
        return -1;
    }
    
    if (get_categoria(tabla_global, $1.lexema) == FUNCION && en_explist != 1) {
        num_parametros_llamada_actual = 0;
        en_explist = 1;
        strcpy($$.lexema, $1.lexema);
        if(strcmp(nombre_funcion, $1.lexema)!=0){
            esfunc=1;
        }
    }
    else {
        if(en_explist == 1){
            fprintf(stderr, "****Error semantico en lin %d: No esta permitido el uso de llamadas a funciones como parametros de otras funciones.\n", linea);
            return -1;
        }

        fprintf(stderr, "****Error semantico en lin %d: La categoria debe ser de tipo funcion.\n", linea);
        return -1;
    }
}

identificador: TOK_IDENTIFICADOR
    {
        if (error_tam_vector == TRUE) {
            fprintf(stderr, "****Error semantico en lin %d: El tamanyo del vector <%s> excede los limites permitidos (1,64)\n", linea, $1.lexema);
            return -1;
        }
        strcpy(variables[ult], $1.lexema);
        ult++;
        /* Ambito global */
        if (existe_local == FALSE) {
            if (hash_get(tabla_global, $1.lexema) == ERROR) {
                hash_add(tabla_global, $1.lexema, VARIABLE, tipo_actual, clase_actual, tamanio_vector_actual, pos_variable_local_actual, num_variables_locales_actual, pos_parametro_actual, num_parametros_actual);
            }
            else {
                fprintf(stderr, "****Error semantico en lin %d. Declaracion duplicada.\n", linea);
                return -1;
            }
        } 
        /* Ambito local */
        else {
             if (hash_get(tabla_local, $1.lexema) == ERROR) {
                if (clase_actual == ESCALAR) {
                    hash_add(tabla_local, $1.lexema, VARIABLE, tipo_actual, clase_actual, tamanio_vector_actual, pos_variable_local_actual, num_variables_locales_actual, pos_parametro_actual, num_parametros_actual);
                    pos_variable_local_actual++;
                    num_variables_locales_actual++;
                }
                else {
                    fprintf(stderr, "****Error semantico en lin %d. Variable local de tipo no escalar.\n", linea);
                    return -1;
                }
            }
            else {
                fprintf(stderr, "****Error semantico en lin %d. Declaracion duplicada.\n", linea);
                return -1;
            }
        }
        /*pos_variable_local_actual++;*/
        fprintf(salida, ";R108:\t<identificador> ::= TOK_IDENTIFICADOR\n");
    };

%%

int yyerror(char *cadena){
    if(error == -1){
        fprintf(stderr,"****Error sintactico en [lin %d, col %d]\n", linea, columna);
    }
    error = -1;
    return error;
}

