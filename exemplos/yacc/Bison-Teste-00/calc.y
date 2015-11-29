%{
//GLC para gerar parser para calculadora simples
#include <stdio.h>
void yyerror(char *);
extern "C"
{
  int yylex();
  void abrirArq(); 
}
%}

%start entrada
%token NUM ERRO FIMLIN

%%

entrada :	/* entrada vazia */
	| 	entrada lin
	;
lin	:	FIMLIN
	|	exp FIMLIN
	;
exp	:	exp '+' termo 	
	|	exp '-' termo 	
	|	termo 		
	;
termo	:	termo '*' fator	
	|	fator	
	;
fator	:	'('exp')'	
	|	NUM 		
	;
%%

int main()
{
  printf("\nParser em execução...\n");
  abrirArq();
  if (yyparse()==0) printf("\nAnálise sintática OK\n");
  else printf("\nAnálise sintática apresenta ERRO\n");
  return 0;
}

void yyerror(char * msg)
{
  extern char* yytext;
  extern int linha;
  printf("\n%s : %s  Linha: %d\n", msg, yytext, linha);
}

