#include "tabela.h"

const char* idTypeToStr( IdType type ) {
  switch( type ) {
      case VAR:
      return( "VAR" );
      break;
      case FUN:
      return( "FUN" );
      break;
      case VET:
      return( "VET" );
      break;
  }
}
/* Função de hashing define a posição na hash de acordo com uma string */
int hashFunction( const char *key ) {
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

void apagaTabela( ) {
  for( int i = 0; i < SIZE; ++i ) {
    if(tabelaSimbolos[ i ] != NULL){
      free(tabelaSimbolos[ i ]);
      tabelaSimbolos[ i ] = NULL;
    }
  }
}

EntradaTabela* criaEntrada( const char * idName, const char *idVarName, IdType idType, DataType dType, const char * escopo, int linha ) {
  EntradaTabela *e = ( EntradaTabela* ) malloc( sizeof( EntradaTabela ) );
  strcpy( e->idName, idName );
  strcpy( e->idVarName, idVarName );
  e->idType = idType;
  e->dType = dType;
  strcpy(e->escopo, escopo);
  if(linha >= 0){
    e->nLinhas = 1;
    e->linhas[ 0 ] = linha;
  }else{
    e->nLinhas = 0;
  }
  e->prox = NULL;
  return( e );
}

EntradaTabela* buscaEntrada( const char * idName ) {
  // printf("Buscando por \'%s\'\n", idName );
  int pos = hashFunction( idName );
  // printf("Pos %d\n", pos);
  EntradaTabela *e = tabelaSimbolos[ pos ];
  while( e != NULL && strcmp( idName, e->idName ) != 0 ) {
    e = e->prox;
  }
  // printf("Encontrei %s\n", e->idName);
  return( e );
}

int insereNovaEntrada( EntradaTabela *entrada ) {
  int pos = hashFunction( entrada->idName );
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

void inicializaTabela( ) {
  for( int i = 0; i < SIZE; ++i ) {
    tabelaSimbolos[ i ] = NULL;
  }
  insereNovaEntrada( criaEntrada("input","input",FUN,VOID,"",-1) );
  insereNovaEntrada( criaEntrada("output","output",FUN,VOID,"",-1) );
}

void adicionaLinha( EntradaTabela *e, int linha ) {
  e->linhas[ e->nLinhas ] = linha;
  e->nLinhas++;
}

void imprimeEntrada( EntradaTabela *entrada ) {
  printf( "Entrada '%s':\n", entrada->idName );
  printf( " - Tipo de ID: %s\n", idTypeToStr( entrada->idType ) );
  printf( " - Tipo de Dado: %s\n", tokenToString( entrada->dType ) );
  printf( " - Escopo: %s\n", entrada->escopo );
  printf( " - Linhas: " );
  for( int i = 0; i < entrada->nLinhas; ++i ) {
    printf( "%d ", entrada->linhas[ i ] );
  }
  printf( "\n" );
}

void imprimeTabela( FILE *listing ) {
  int i;
  fprintf( listing, "\nNome variavel  Tipo ID  Tipo Dado  Escopo         Nro das Linhas\n" );
  fprintf( listing, "-------------  -------  ---------  -------------  --------------\n" );
  for( i = 0; i < SIZE; ++i ) {
    EntradaTabela *l = tabelaSimbolos[ i ];
    if( l != NULL ) {
      while( l != NULL ) {
        fprintf( listing, "%-14s ", l->idVarName );
        fprintf( listing, "%-9s", idTypeToStr( l->idType ) );
        fprintf( listing, "%-11s", tokenToString( l->dType ) );
        fprintf( listing, "%-15s", l->escopo );
                /* fprintf(listing,"%-8d  ",l->memloc); */
        for( int i = 0; i < l->nLinhas; ++i ) {
          fprintf( listing, "%d ", l->linhas[ i ] );
        }
        fprintf( listing, "\n" );
        l = l->prox;
      }
    }
  }
} /* printSymTab */

char pilha[32][255];
char texto[255];
int tamanhoPilha = 0;

char * concatenaPilha(){
  texto[0] = '\0';
  // if(tamanhoPilha > 0){
  //   strcpy(texto,pilha[0]);
  // }
  for(int i = 0; i < tamanhoPilha; ++i){
    strcat(texto,pilha[i]);
  }
  return texto;
}

void empilha(const char * idName){
  strcpy(pilha[tamanhoPilha], idName);
  DEBUG(printf("Empilha %s\n", pilha[tamanhoPilha]);)
  tamanhoPilha ++;
  DEBUG(printf("Pilha atual: %s\n", concatenaPilha());)
}

void desempilha(){
  DEBUG(printf("Desempilha %s\n", pilha[tamanhoPilha-1]);)
  tamanhoPilha--;
  if(tamanhoPilha<0){
    printf("Erro! Pilha desbalanceada.\n");
    exit(1);
  }
}

const char * topoPilha(){
  return pilha[tamanhoPilha-1];
}

EntradaTabela * buscaNaPilha(const char * id){
  for( int i = tamanhoPilha-1; i >= 0; --i ){
    texto[0] = '\0';
    for(int j = 0; j <= i; ++j ){
      strcat(texto,pilha[j]);
    }
    strcat(texto, id);
    // printf("Buscando por %s\n", texto);
    EntradaTabela * e = buscaEntrada(texto);
    if(e != NULL){
      return e;
    }
  }
  return buscaEntrada(id);
}
