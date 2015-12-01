%{
//GLC para gerar parser para calculadora simples
#include <stdio.h>
#include "tabela.h"
void yyerror(const char *);
extern "C"
{
  int yylex();
  int abrirArq(char * fileName);
  extern char* yytext;
  extern int linenbr;
}
%}

%start programa
%token IF ELSE INT FLOAT VOID RETURN WHILE
%token ID NUM FNUM
%token ASSIGN EQ NEQ LT LE GT GE PLUS MINUS
%token TIMES OVER LPAREN RPAREN SEMI COLON
%token LBOX RBOX LKEY RKEY
%token ERROR
%error-verbose
%printer { fprintf (yyoutput, "’%d’", $$); } NUM
%nonassoc "then"
%nonassoc ELSE
%%

programa :
	| declaracao-lista
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
selecao-decl : IF LPAREN expressao RPAREN statement %prec "then"
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
  | FNUM
  ;
ativacao : ID LPAREN args RPAREN
  ;
args : arg-lista
  | /* empty */
  ;
arg-lista : arg-lista COLON expressao
  | expressao
  ;
%%
char escopo[255];

DataType lastDType = VOID;
char lastId[128];
void tipoDeclaracao(int tok) {

  EntradaTabela * ent;
  char temp[255];
  if(strcmp(escopo,"")== 0){
    strcpy(temp, "global");
  }else{
    strcpy(temp, escopo);
  }
  switch (tok) {
    DEBUG(printf("FUNC: %s %s();\n", lastId, tokenToString(lastDType));)
    case LPAREN:{
      //Função
       ent = criaEntrada( lastId, lastId, FUN, lastDType, "", linenbr );
       empilha(lastId);
      break;
    }
    case LBOX:{
      DEBUG(printf("VET: %s %s[];\n", tokenToString(lastDType), lastId);)
      //VET
      empilha(lastId);
      ent = criaEntrada( concatenaPilha(), lastId, VET, lastDType, temp, linenbr );
      desempilha();
      break;
    }
    case SEMI:
    case COLON:
    case RPAREN:{
      DEBUG(printf("VAR: %s %s;\n", tokenToString(lastDType), lastId);)
      //VAR
      empilha(lastId);
      ent = criaEntrada( concatenaPilha(), lastId, VAR, lastDType, temp, linenbr );
      desempilha();
      break;
    }
    default:{
      printf("\033[31mError found at line %d: Cannot declare '%s'\033[m\n", linenbr, lastId);
      return;
      //ERRO!!!!!!!!!!!!!!!!!!!!!!!!!!
    }
  }
  // imprimeEntrada(ent);
  insereNovaEntrada(ent);
}

void global( int tok ) {
  // printf("Linha %d: %s\n", linenbr, yytext);
  switch (tok) {
    case ID:{
      EntradaTabela * ent = buscaNaPilha(yytext);
      if(ent != NULL){
        DEBUG(printf("Adicionando linha %d ao id: '%s'\n", linenbr, ent->idName));
        adicionaLinha(ent, linenbr);
      }else{
        printf("\033[31mError found at line %d: '%s' was not declared yet\033[m\n", linenbr, yytext);
        return;
      }
      break;
    }
    case FLOAT:
    case INT:
    case VOID:{
      lastDType = tok;
      tok = yylex();
      if(lastDType == VOID && tok == RPAREN){
        DEBUG(printf("func(void)\n");)
        return;
      }
      if(tok != ID ){
        printf("\033[31mError found at line %d: Expected id but it was %s \033[m\n", linenbr, yytext);
        return;
      }
      strcpy(lastId,yytext);
      // DEBUG(printf("ID \'%s\' : \'%s\'\n", lastId, tokenToString(tok)));
      strcpy(escopo, concatenaPilha());
      // DEBUG(printf("Escopo : \'%s\'\n", escopo));
      tok = yylex();
      // DEBUG(printf("\'%s\' : \'%s\'\n", yytext, tokenToString(tok)));
      tipoDeclaracao(tok);
      break;
    }
  }
}

int parenCounter = 0;

int main(int argc, char ** argv)
{
  if(argc != 2){
    printf("usage: %s <source code>\n", argv[0]);
    exit(1);
  }
  if(!abrirArq(argv[1]))
    return 1;
  printf("Gerando a tabela de símbolos...\n");
  inicializaTabela( );
  int token;
  while (token=yylex()) {
    if(token == ERROR){
      printf("Error found at line %d: %s\n", linenbr, yytext);
    }else{
      if(token == ID || token == FLOAT || token == INT || token == VOID ){
        // DEBUG(printf("\'%s\' : \'%s\'\n", yytext, tokenToString(token)));
        global(token);
      }else if(token == LKEY){
        parenCounter++;
      }else if(token == RKEY){
        parenCounter--;
        if(parenCounter == 0){
          desempilha();
        }
        if(parenCounter < 0){
          printf("\033[31mUnbalanced parentheses.\033[m\n");
        }
      }
    }
  }
  imprimeTabela(stdout);
  printf("\n\n");
  apagaTabela();
  abrirArq(argv[1]);
  printf("\nParser em execução...\n");
  if (yyparse()==0) printf("\nAnálise sintática OK\n");
  else printf("\nAnálise sintática apresenta ERRO\n");
  return 0;
}
void yyerror(const char * msg)
{
  if(yychar == ERROR){
    printf("\nLexical error : %s  Line: %d\n", yytext, linenbr);
  }else{
    printf("\n%s : %s  Line: %d\n", msg, yytext, linenbr);
  }
}
