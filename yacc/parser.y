%{
//GLC para gerar parser para calculadora simples
#include <stdio.h>
void yyerror(char *);
extern "C"
{
  int yylex();
  void abrirArq(char * fileName);
}
%}

%start programa
%token IF ELSE INT FLOAT VOID RETURN WHILE
%token ID NUM FNUM
%token ASSIGN EQ NEQ LT LE GT GE PLUS MINUS
%token TIMES OVER LPAREN RPAREN SEMI COLON
%token LBOX RBOX LKEY RKEY LCOMM RCOMM
%token ENDFILE ERROR

%%

programa :	/* entrada vazia */
	| 	declaracao-lista
	;
declaracao-lista	:	declaracao-lista declaracao
	|	declaracao
	;
declaracao : var-declaracao
  | fun-declaracao
  ;
var-declaracao : tipo-especificador ID SEMI
  | tipo-especificador ID LBOX NUM RBOX SEMI
  ;
tipo-especificador : INT
  | FLOAT
  | VOID
  ;
fun-declaracao : tipo-especificador ID LPAREN params RPAREN composto-decl
  ;
params : param-lista
  | VOID
  ;
param-lista : param-lista COLON param
  | param
  ;
param : tipo-especificador ID
  | tipo-especificador ID LBOX RBOX
  ;
composto-decl : LKEY local-declaracoes statement-lista RKEY
  ;
local-declaracoes : local-declaracoes var-declaracao
  | /* empty */
  ;
statement-lista : statement-lista statement
  | /* empty */
  ;
statement : expressao-decl
  | composto-decl
  | selecao-decl
  | iteracao-decl
  | retorno-decl
  ;
expressao-decl : expressao SEMI
  | SEMI
  ;
selecao-decl : IF LPAREN expressao RPAREN statement
  | IF LPAREN expressao RPAREN statement ELSE statement
  ;
iteracao-decl : WHILE LPAREN expressao RPAREN statement
  ;
retorno-decl : RETURN SEMI
  | RETURN expressao SEMI
  ;
expressao : var ASSIGN expressao
  | simples-expressao
  ;
var : ID
  | ID LBOX expressao RBOX
  ;
simples-expressao : soma-expressao relacional soma-expressao
  | soma-expressao
  ;
relacional : LE
  | LT
  | GT
  | GE
  | EQ
  | NEQ
  ;
soma-expressao : soma-expressao soma termo
  | termo
  ;
soma : PLUS
  | MINUS
  ;
termo : termo mult fator
  | fator
  ;
mult : TIMES
  | OVER
  ;
fator : LPAREN expressao RPAREN
  | var
  | ativacao
  | NUM
  ;
ativacao : ID LPAREN args RPAREN
  ;
args : arg-lista
  | /* empty */
  ;
arg-lista : arg-lista COLON expressao
  | expressao

%%

int main(int argc, char ** argv)
{
  if(argc == 2){
    printf("usage: %s <source code>\n", argv[0]);
    exit(1);
  }
  printf("\nParser em execução...\n");
  abrirArq(argv[1]);
  if (yyparse()==0) printf("\nAnálise sintática OK\n");
  else printf("\nAnálise sintática apresenta ERRO\n");
  return 0;
}
void yyerror(char * msg)
{
  extern char* yytext;
  extern int linenbr;
  printf("\n%s : %s  Linha: %d\n", msg, yytext, linenbr);
}
