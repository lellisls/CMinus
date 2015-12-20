#include "semantica.h"
#include "tabela.h"
#include "util.h"


void analiseRec( TreeNode *node ) {
  if( node->nodekind == StmtK ) {
    if(node->kind.stmt == AssignK){
      TreeNode * dir = node->child[1];
      if(dir!=NULL && dir->nodekind ==StmtK && dir->kind.stmt == AtivacaoK ){
        EntradaTabela * e = buscaFuncao(dir->attr.name);
        if(e != NULL && e->dType == VOID ){
          //  \'%s\' is of type \'%s\' and
          printf( "\033[31mError found at line %d: Invalid attribution. '%s' returns \'void\'.\033[m\n",
                node->linenbr,
                dir->attr.name );
        }
      }
    }
    if( node->kind.stmt == FunDecK ) {
      if( buscaFuncao( node->attr.name ) == NULL ) {
        printf( "\033[31mError found at line %d: Function '%s' was not declared yet.\033[m\n",
                node->linenbr,
                node->attr.name );
      }
      empilha( node->attr.name );
      printf( ">>>> Função %s\n", node->attr.name );
    }
    else if( node->kind.stmt == AtivacaoK ) {
      if( buscaFuncao( node->attr.name ) == NULL ) {
        printf( "\033[31mError found at line %d: Function '%s' was not declared yet.\033[m\n",
                node->linenbr,
                node->attr.name );
      }
      printf( ">>>> Função %s\n", node->attr.name );
    }
    else if( node->kind.stmt == VarDecK ) {
      EntradaTabela * e = buscaFuncao( node->attr.name);
      if(e != NULL){
        printf( "\033[31mError found at line %d: Variable '%s' was already declared as a function.\033[m\n",
                node->linenbr,
                node->attr.name );
      }
      e = buscaNaPilha( node->attr.name );
      if( e != NULL && e->dType == VOID) {
        printf( "\033[31mError found at line %d: Variable '%s' cannot be void type.\033[m\n",
                node->linenbr,
                node->attr.name );
      }
      if(e != NULL && e->linhas[0] != node->linenbr){
        printf( "\033[31mError found at line %d: Variable '%s' was already declared in this scope.\033[m\n",
                node->linenbr,
                node->attr.name );
      }
    }
  }
  if( node->nodekind == ExpK ) {
    if( ( node->kind.exp == IdK ) || ( node->kind.exp == VetIdK ) ) {
      if( buscaNaPilha( node->attr.name ) == NULL ) {
        printf( "\033[31mError found at line %d: '%s' was not declared yet.\033[m\n", node->linenbr, node->attr.name );
      }
    }
  }
  for( size_t i = 0; i < MAXCHILDREN; ++i ) {
    if(node->child[i] != NULL)
      analiseRec( node->child[ i ] );
  }
  if( node->nodekind == StmtK ) {
    if( node->kind.stmt == FunDecK ) {
      desempilha();
    }
  }
  if( node->sibling != NULL ) {
    analiseRec( node->sibling );
  }
}

void analiseSemantica( TreeNode *tree ) {
  analiseRec( tree );
  if( buscaEntrada( "main" ) == NULL ) {
    printf( "\033[31mFunction 'main()' was not declared.\033[m\n" );
  }
}
