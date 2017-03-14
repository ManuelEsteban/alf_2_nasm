/* 
 * File:   tabla_sim.h
 * Author: Esteban Carrillo, Jose Mª Cortes
 *
 */

#ifndef TABLA_SIM_H
#define	TABLA_SIM_H

#ifdef	__cplusplus
extern "C" {
#endif
    
typedef struct {
    char *key;
    int categoria; 
    int tipo;
    int clase;
    int tam; 
    int pos_variable; /* guarda poscion de una variable de ambito local */
    int num_variables; /* almacena el numero de variables locales de una funcion */
    int pos_parametro; /* guarda poscion de un parametro de una funcion */
    int num_parametros; /* almacena el numero de parametros de una funcion */
} hash_datos_t;

typedef struct {
    hash_datos_t *datos;
    int num_datos;
    int num_max_datos;
} hash_node_t;

    
    int hash_key(const char *k);
    hash_node_t *hash_create(void);
    int hash_add(hash_node_t *hash, const char *clave, const int categoria, const int tipo, const int clase, const int tam, const int posV, const int numV, const int posP, const int numP);
    int hash_get(hash_node_t *hash, char *clave);
    void actualizar (hash_node_t *hash, char *clave, int num);
    void hash_destroy (hash_node_t *hash);

    int get_index (hash_node_t *hash, char *clave);
    int get_categoria (hash_node_t* hash, char *clave);
    int get_tipo (hash_node_t* hash, char *clave);
    int get_clase (hash_node_t* hash, char *clave);
    int get_num_param (hash_node_t* hash, char *clave);
    int get_tam (hash_node_t* hash, char *clave);
    int get_pos_parametro (hash_node_t* hash, char *clave);
    int get_pos_variable (hash_node_t* hash, char *clave);

#ifdef	__cplusplus
}
#endif

#endif	/* TABLA_SIM_H */

