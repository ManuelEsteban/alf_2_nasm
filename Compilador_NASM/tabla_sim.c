#include <sys/types.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "tabla_sim.h"

#define TAMHASH 100000

/**
 * Obtiene el codigo hash de la cadena dada.
 * @param k Cadena con la cual sacar el codigo hash.
 *  
 * @return Codigo hash para la cadena.
 */
int hash_key(const char *k) {
    int x = strlen(k);
    return (x * (x + 11)) % TAMHASH;
}

/**
 * Crea una tabla hash
 * 
 * @return Puntero al inicio de la tabla
 */
hash_node_t *hash_create(void) {
    hash_node_t *hash;
    int i;

    hash = malloc(sizeof (hash_node_t) * TAMHASH);
    for (i = 0; i < TAMHASH; i++) {
        hash[i].datos = malloc(sizeof (hash_datos_t));
        hash[i].num_datos = 0;
        hash[i].num_max_datos = 1;       
    }

    return hash;
}

/**
 * Inserta un elemento en una tabla hash
 * 
 * @param hash Tabla en la que insertar el elemento
 * @param clave Elemento a guardar como clave
 * @param categoria categoria de la clave
 * @return 0 si se ha insertado correctamente, -1 en caso contrario
 */
int hash_add(hash_node_t *hash, const char *clave, const int categoria, const int tipo, const int clase, const int tam, const int posV, const int numV, const int posP, const int numP) {
    int ind;
    int i;

    ind = hash_key(clave);

    /* comprobamos si existe */
    for (i = 0; i < hash[ind].num_datos; i++) {
        if (strcmp(hash[ind].datos[i].key, clave) == 0)
            break;
    }

   /* no se ha encontrado la información, creamos un elemento nuevo */
    if (i == hash[ind].num_datos) {
        /* si hemos llegado al máximo ampliamos */
        if (hash[ind].num_datos == hash[ind].num_max_datos) {
            hash[ind].num_max_datos += 1;
            hash[ind].datos = realloc(hash[ind].datos,
                    sizeof (hash_datos_t) * hash[ind].num_max_datos);
        }

        /*memcpy(hash[ind].datos[i].key, p, sizeof(int)*5);*/
        hash[ind].datos[i].key = (char*)malloc(sizeof(char) * strlen(clave)+1);
        strcpy(hash[ind].datos[i].key, clave);
        hash[ind].datos[i].categoria = categoria;
        hash[ind].datos[i].tipo = tipo;
        hash[ind].datos[i].clase = clase;
        hash[ind].datos[i].tam = tam;
        hash[ind].datos[i].pos_variable = posV;
        hash[ind].datos[i].num_variables = numV;
        hash[ind].datos[i].pos_parametro = posP;
        hash[ind].datos[i].num_parametros = numP;

        hash[ind].num_datos++;
    }       

    else
        return -1;
    return hash[ind].datos[i].categoria;
}

/**
 * Obtiene un elemento de una tabla 
 * @param hash Tabla hash en la que buscar el elemento
 * @param clave Clave del elemento
 * 
 * @return Si el elemento existe se devuelve el valor, -1 en caso contrario
 */
int hash_get(hash_node_t *hash, char *clave) {
    int i, ind, ret = -1;

    ind = hash_key(clave);

    /* comprobamos si existe */
    for (i = 0; i < hash[ind].num_datos; i++) {
        if (strcmp(hash[ind].datos[i].key, clave) == 0) {
            ret = hash[ind].datos[i].tam;
            break;
        }
    }

    return ret;
}

/**
 * Actualiza la informacion sobre el numero de parametros de una tabla 
 *
 * @param hash Tabla en la que se actualiza el dato
 * @param clave Clave del elemento
 * @param num Numero de parametros
 *
 */
void actualizar (hash_node_t *hash, char *clave, int num){
    int i, ind;
    ind = hash_key(clave);

     /* comprobamos si existe */
    for (i = 0; i < hash[ind].num_datos; i++) {
        if (strcmp(hash[ind].datos[i].key, clave) == 0)
            break;
    }
    /* Existe y actualizamos el numero de parametros */
    if (i != hash[ind].num_datos) 
        hash[ind].datos[i].num_parametros = num;
}


/**
 * Libera la memoria reservada para una tabla hash y todo su contenido 
 *
 * @param hash Tabla a eliminar
 */
void hash_destroy(hash_node_t* hash){
    int i, j;
    if (hash == NULL)
        return;
    for (i = 0; i < TAMHASH; i++) {
        for(j = 0; j < hash[i].num_datos; j++){
            if (hash[i].datos[j].key != NULL)
                free(hash[i].datos[j].key);
        }
        if(j == hash[i].num_datos)
            free(hash[i].datos);
    }
    
    free(hash);
    hash = NULL;
}


/* GETTERS */

/**
 * Devuelve la posicion, si existe, de un elemento
 *
 * @param hash Tabla en la que se actualiza el dato
 * @param clave Clave del elemento
 *
 * @return posicion, -1 en caso de no existir el elemento
 */
int get_index (hash_node_t *hash, char *clave) {
    int i, ind;
    ind = hash_key(clave);

    /* comprobamos si existe */
    for (i = 0; i < hash[ind].num_datos; i++) {
        if (strcmp(hash[ind].datos[i].key, clave) == 0)
            break;
    }

    if (i != hash[ind].num_datos)
        return i;
    return -1;
}

/**
 *
 * @param hash Tabla en la que se actualiza el dato
 * @param clave Clave del elemento
 *
 * @return categoria del elemento
 */
int get_categoria (hash_node_t* hash, char *clave) {
    int i, ind;
    ind =  hash_key(clave);

    i = get_index(hash, clave);

    if (i != -1)
        return hash[ind].datos[i].categoria;
    return -1;
}

/**
 *
 * @param hash Tabla en la que se actualiza el dato
 * @param clave Clave del elemento
 *
 * @return tipo del elemento
 */
int get_tipo (hash_node_t* hash, char *clave) {
    int i, ind;
    ind =  hash_key(clave);

    i = get_index(hash, clave);

    if (i != -1)
        return hash[ind].datos[i].tipo;
    return -1;
}

/**
 *
 * @param hash Tabla en la que se actualiza el dato
 * @param clave Clave del elemento
 *
 * @return clase del elemento
 */
int get_clase (hash_node_t* hash, char *clave) {
    int i, ind;
    ind =  hash_key(clave);

    i = get_index(hash, clave);

    if (i != -1)
        return hash[ind].datos[i].clase;
    return -1;
}


/**
 *
 * @param hash Tabla en la que se actualiza el dato
 * @param clave Clave del elemento
 *
 * @return numero de parametros del elemento
 */
int get_num_param (hash_node_t* hash, char *clave) {
    int i, ind;
    ind =  hash_key(clave);

    i = get_index(hash, clave);

    if (i != -1)
        return hash[ind].datos[i].num_parametros;
    return -1;
}

/**
 *
 * @param hash Tabla en la que se actualiza el dato
 * @param clave Clave del elemento
 *
 * @return tamaño del elemento 
 */
int get_tam (hash_node_t* hash, char *clave) {
    int i, ind;
    ind =  hash_key(clave);

    i = get_index(hash, clave);

    if (i != -1)
        return hash[ind].datos[i].tam;
    return -1;
}

/**
 *
 * @param hash Tabla en la que se actualiza el dato
 * @param clave Clave del elemento
 *
 * @return tamaño del elemento 
 */
int get_pos_parametro (hash_node_t* hash, char *clave) {
    int i, ind;
    ind =  hash_key(clave);

    i = get_index(hash, clave);

    if (i != -1)
        return hash[ind].datos[i].pos_parametro;
    return -1;
}

/**
 *
 * @param hash Tabla en la que se actualiza el dato
 * @param clave Clave del elemento
 *
 * @return tamaño del elemento 
 */
int get_pos_variable (hash_node_t* hash, char *clave) {
    int i, ind;
    ind =  hash_key(clave);

    i = get_index(hash, clave);

    if (i != -1)
        return hash[ind].datos[i].pos_variable;
    return -1;
}
