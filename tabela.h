#ifndef TABELA_H
#define TABELA_H

#include "globals.h"
#include <stdio.h>
#include <string.h>
#include "parser.tab.h"
#include "util.h"

#define SIZE 211 /* número primo para melhorar a distribuição */
/* em uma tabela de hashing com até 211 registros */
#define SHIFT 4

typedef int DataType;

typedef enum idtype { VAR, FUN, VET } IdType;

typedef struct entradaTab {
  char idName[ 256 ]; /* Nome do id para calculo do hash */
  char idVarName [ 256 ]; /* Nome da variavel */
  IdType idType; /* Tipo de ID ( Cariável, Função ou Vetor) */
  DataType dType; /* Tipo de dado (int, float ou void) */
  char escopo[255]; /* Escopo (apenas para variavel e vetor) */
  int nLinhas; /* Numero de linhas em que aparece */
  unsigned int linhas[ 256 ]; /* As linhas em que aparece */
  struct entradaTab *prox; /* Proxima chave na lista que tem mesma hash */
} EntradaTabela;

const char* idTypeToStr( IdType type );

/* Função de hashing define a posição na hash de acordo com uma string */
int hashFunction( const char *key );

void apagaTabela( );

EntradaTabela* criaEntrada( const char * idName, const char * idVarName, IdType idType, DataType dType, const char * escopo, int linha );

EntradaTabela* buscaEntrada( const char * idName );

int insereNovaEntrada( EntradaTabela *entrada );

void inicializaTabela( );

void adicionaLinha( EntradaTabela *e, int linha );

void imprimeEntrada( EntradaTabela *entrada );

void imprimeTabela( FILE *listing );

char * concatenaPilha();

void empilha(const char * idName);

void desempilha();

const char * topoPilha();

EntradaTabela * buscaNaPilha(const char * id);

#endif
