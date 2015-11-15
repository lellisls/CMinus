#include "globals.h"
#include <stdio.h>
#include <string.h>

#define SIZE 211 /* número primo para melhorar a distribuição */
/* em uma tabela de hashing com até 211 registros */
#define SHIFT 4

typedef TokenType DataType;

typedef enum idtype { VAR, FUN, VET } IdType;

typedef struct entradaTab {
  char idName[ 128 ]; /* Nome do id */
  IdType idType; /* Tipo de ID ( Cariável, Função ou Vetor) */
  DataType dType; /* Tipo de dado (int, float ou void) */
  struct entradaTab *escopo; /* Escopo (apenas para variavel e vetor) */
  int nLinhas; /* Numero de linhas em que aparece */
  unsigned int linhas[ 128 ]; /* As linhas em que aparece */
  struct entradaTab *prox; /* Proxima chave na lista que tem mesma hash */
} EntradaTabela;

/* Função de hashing define a posição na hash de acordo com uma string */
int hash( char *key ) {
  int temp = 0;
  int i = 0;
  while( key[ i ] != '\0' ) {
    temp = ( ( temp << SHIFT ) + key[ i ] ) % SIZE;
    /*
     * O perador << faz deslocamentos de bits para a esquerda
     * no valor de temp (4 bits).
     * Este recurso está sendo usado para evitar sobrecarga
     * em temp.
     */
    ++i;
  }
  return( temp );
}

EntradaTabela *tabelaSimbolos[ SIZE ];

void inicializaTabela( ) {
  for( int i = 0; i < SIZE; ++i ) {
    tabelaSimbolos[ i ] = NULL;
  }
}

EntradaTabela* criaEntrada( char idName[ 128 ], IdType idType, DataType dType, EntradaTabela *escopo, int linha ) {
  EntradaTabela *e = ( EntradaTabela* ) malloc( sizeof( EntradaTabela ) );
  strcpy( e->idName, idName );
  e->idType = idType;
  e->dType = dType;
  e->escopo = escopo;
  e->nLinhas = 1;
  e->linhas[ 0 ] = linha;
  e->prox = NULL;
  return( e );
}

int insereNovaEntrada( EntradaTabela *entrada ) {
  int pos = hash( entrada->idName );
  if( tabelaSimbolos[ pos ] == NULL ) {
    tabelaSimbolos[ pos ] = entrada;
  }
  else {
    EntradaTabela *p = tabelaSimbolos[ pos ];
    while( p->prox != NULL ) {
      p = p->prox;
    }
    p->prox = entrada;
  }
  return( pos );
}

void imprimeEntrada( EntradaTabela *entrada ) {
  printf("Entrada '%s':\n", entrada->idName);
  printf(" - Tipo de ID: %d\n", entrada->idType);
  printf(" - Tipo de Dado: %s\n", tokenToString(entrada->dType));
  if(entrada->escopo != NULL){
    printf(" - Escopo: %s\n", entrada->idName);
  }else{
    printf(" - Escopo: GLOBAL\n");
  }
  printf(" - Linhas: ");
  for(int i = 0; i < entrada->nLinhas; ++i){
    printf("%d ", entrada->linhas[i]);
  }
  printf("\n");

}

int main( ) {
  EntradaTabela * ent = criaEntrada( "Hakuna Matata", VAR, INT, NULL, 10 );
  int pos = insereNovaEntrada( ent );
  printf( "Entrada '%s'inserida na posição %d\n", ent->idName, pos );
  imprimeEntrada(ent);
  return( 0 );
}
