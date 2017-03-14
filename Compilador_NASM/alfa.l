%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "alfa.h"
#include "y.tab.h"

#define YY_NO_INPUT

extern FILE *salida;
int linea = 1,columna = 0, error = -1;

%}

%option nounput
%option noyywrap

BLANCOS 	[ \t\n\r]

COMENTARIO "//"[^\n]*("\n"|"\r")

MAIN	"main"

TIPO "int"|"boolean"

FUNCION "scanf"|"printf"|"function"|"array"

RETURN "return"

CONSTANTE [0-9]+

IDENTIFICADOR [a-zA-Z]([a-zA-Z0-9]){0,99}

IDENTIFICADOR_ERROR [a-zA-Z]([a-zA-Z0-9]){99,}

COMPARACION "=="|"!="|"<="|">="|"<"|">"

EXPRESION "+"|"-"|"*"|"/"|"&&"|"||"|"!"|"="

BUCLE "while"

CONDICIONAL "if"|"else"

BOOLEAN "true"|"false"

ERROR	.


%%

{BLANCOS} {
	if(strcmp("\t", yytext) == 0){
		columna+=yyleng;		
	}
	else if(strcmp(" ", yytext)==0)
		columna++;
	else if(strcmp("\n", yytext)==0){
		linea++;
		columna = 0;
	}
}

{COMENTARIO} {
	linea++;
	columna += yyleng;
}


{MAIN}	{ 
	fprintf(salida, ";D:\t%s\n", yytext);
	columna += yyleng;
	return TOK_MAIN;
}

{FUNCION} {
	fprintf(salida, ";D:\t%s\n", yytext);
	columna += yyleng;
	if(strcmp("scanf", yytext) == 0)
		return TOK_SCANF;
	if(strcmp("printf", yytext) == 0)
		return TOK_PRINTF;
	if(strcmp("function", yytext) == 0)
		return TOK_FUNCTION;
	if(strcmp("array", yytext) == 0)
		return TOK_ARRAY;
}

{RETURN} {
	fprintf(salida, ";D:\t%s\n", yytext);
	columna += yyleng;
	return TOK_RETURN;
}

{BUCLE} {
	fprintf(salida, ";D:\t%s\n", yytext);
	columna += yyleng;
	return TOK_WHILE;
}

{CONSTANTE} {
	fprintf(salida, ";D:\t%s\n", yytext);
	yylval.atributos.valor_entero = atoi(yytext);
	columna += yyleng;
	return TOK_CONSTANTE_ENTERA;
}

{TIPO} {
	fprintf(salida, ";D:\t%s\n", yytext);
	columna += yyleng;
	if(strcmp("int", yytext)==0)
		return TOK_INT;
	if(strcmp("boolean", yytext)==0)
		return TOK_BOOLEAN;	
}

{BOOLEAN} {
	fprintf(salida, ";D:\t%s\n", yytext);
	columna += yyleng;
	if(strcmp("true", yytext)==0)
		return TOK_TRUE;
	if(strcmp("false", yytext)==0)
		return TOK_FALSE;	
}

{CONDICIONAL} {
	fprintf(salida, ";D:\t%s\n", yytext);
	columna += yyleng;
	if(strcmp("if", yytext)==0)
		return TOK_IF;
	if(strcmp("else", yytext)==0)
		return TOK_ELSE;	
}

{COMPARACION} {
	fprintf(salida, ";D:\t%s\n", yytext);
	columna += yyleng;
	if(strcmp("==", yytext)==0)
		return TOK_IGUAL;
	if(strcmp("!=", yytext)==0)
		return TOK_DISTINTO;
	if(strcmp("<=", yytext)==0)
		return TOK_MENORIGUAL;
	if(strcmp(">=", yytext)==0)
		return TOK_MAYORIGUAL;
	if(strcmp(">", yytext)==0)
		return TOK_MAYOR;
	if(strcmp("<", yytext)==0)
		return TOK_MENOR;	
}

{EXPRESION} {
	fprintf(salida, ";D:\t%s\n", yytext);
	columna += yyleng;
	if(strcmp("=", yytext)==0)
		return TOK_ASIGNACION;
	if(strcmp("+", yytext)==0)
		return TOK_MAS;
	if(strcmp("-", yytext)==0)
		return TOK_MENOS;
	if(strcmp("/", yytext)==0)
		return TOK_DIVISION;
	if(strcmp("*", yytext)==0)
		return TOK_ASTERISCO;
	if(strcmp("&&", yytext)==0)
		return TOK_AND;
	if(strcmp("||", yytext)==0)
		return TOK_OR;
	if(strcmp("!", yytext)==0)
		return TOK_NOT;

}

"{" { 
	fprintf(salida, ";D:\t%s\n", yytext);
	columna += yyleng;
	return TOK_LLAVEIZQUIERDA;
}

"}"	{ 
	fprintf(salida, ";D:\t%s\n", yytext);
	columna += yyleng;
	return TOK_LLAVEDERECHA;
}

"," {
	fprintf(salida, ";D:\t%s\n", yytext);
	columna += yyleng;
	return TOK_COMA;	
}

";" {
	fprintf(salida, ";D:\t%s\n", yytext);
	columna += yyleng;
	return TOK_PUNTOYCOMA;
}

"(" { 
	fprintf(salida, ";D:\t%s\n", yytext);
	columna += yyleng;
	return TOK_PARENTESISIZQUIERDO; 
}

")"	{
	fprintf(salida, ";D:\t%s\n", yytext);
	columna += yyleng;
	return TOK_PARENTESISDERECHO; 
}

"[" { 
	fprintf(salida, ";D:\t%s\n", yytext);
	columna += yyleng;
	return TOK_CORCHETEIZQUIERDO; 
}

"]"	{
	fprintf(salida, ";D:\t%s\n", yytext);
	columna += yyleng;
	return TOK_CORCHETEDERECHO; 
}

{IDENTIFICADOR} {
	fprintf(salida, ";D:\t%s\n", yytext);
	strcpy(yylval.atributos.lexema, yytext);
	columna += yyleng;
	return TOK_IDENTIFICADOR;
}

{IDENTIFICADOR_ERROR} {
	fprintf(stderr, "****Error en [lin %d, col %d]: identificador demasiado largo (%s)\n", linea, columna, yytext);
	error = 1;
	return TOK_ERROR;
}

{ERROR} {
	columna += yyleng;
	fprintf(stderr,"****Error en [lin %d, col %d]: simbolo no permitido (%s)\n", linea, columna, yytext);
	error = 1;
	return TOK_ERROR;
}

%%
