%{
//GLC para gerar parser para calculadora simples
#include <stdio.h>

#define YYPARSER /* distinguishes Yacc output from other code files */

#include "globals.h"
#include "util.h"
#include "scan.h"

char tokenString[MAXTOKENLEN+1];
char lastIDName[MAXTOKENLEN+1];

#define YYSTYPE TreeNode *
static char * savedName; /* for use in assignments */
static char * savedFunctionName; /* for use in assignments */
static int savedLineNo;  /* ditto */
static TreeNode * savedTree; /* stores syntax tree for later return */
static TokenType savedDataType, savedOperator;

int TraceScan = FALSE;

#include "tabela.h"

void yyerror(const char *);

extern "C"
{
  int getToken(void);
  int abrirArq(char * fileName);
  extern char* yytext;
}

static int yylex(void)
{ return getToken(); }


int ok = TRUE;
%}

%start programa
%token IF ELSE INT FLOAT VOID RETURN WHILE
%token ID NUM FNUM
%token ASSIGN EQ NEQ LT LE GT GE PLUS MINUS
%token TIMES OVER LPAREN RPAREN SEMI COLON
%token LBOX RBOX LKEY RKEY
%token ERROR
%error-verbose

// %printer { fprintf (yyoutput, "’%d’", $$); } NUM

%nonassoc "then"
%nonassoc ELSE
%%

programa :
	| declaracao-lista { savedTree = $1;}
	;
declaracao-lista	:	declaracao-lista declaracao
                      { YYSTYPE t = $1;
                        if (t != NULL){
                          while (t->sibling != NULL)
                            t = t->sibling;
                          t->sibling = $2;
                          $$ = $1;
                        }
                        else{
                          $$ = $2;
                        }
                      }
	|	declaracao { $$ = $1; }
	;
declaracao : var-declaracao { $$ = $1; }
  | fun-declaracao { $$ = $1; }
  | error  { $$ = NULL; }
  ;
var-declaracao : tipo-especificador ID
                  {savedName = copyString(lastIDName);
                   savedLineNo = linenbr;}
                  SEMI
                    {$$ = newStmtNode(VarDecK);
                     $$->attr.name = savedName;
                     $$->linenbr = savedLineNo;
                     $$->type = savedDataType;}
  | tipo-especificador ID {savedName = copyString(lastIDName);
                   savedLineNo = linenbr;}
                   LBOX NUM
  {
    $$ = newExpNode(ConstK);
    $$->attr.val = atoi(tokenString);
  }
                   RBOX SEMI
  {
    $$ = newStmtNode(VarDecK);
    $$->attr.name = savedName;
    $$->linenbr = savedLineNo;
    $$->child[0] = $6;
    $$->type = savedDataType;
  }
  // | error SEMI {ok = FALSE; $$ = NULL;}
  ;
tipo-especificador : INT {savedDataType = INT;}
  | FLOAT {savedDataType = FLOAT;}
  | VOID {savedDataType = VOID;}
  ;
fun-declaracao : tipo-especificador ID
  {
   savedFunctionName = copyString(lastIDName);
   savedLineNo = linenbr;}
               LPAREN params RPAREN composto-decl
  {$$ = newStmtNode(FunDecK);
   $$->attr.name = savedFunctionName;
   $$->linenbr = savedLineNo;
   $$->type = savedDataType;
   $$->child[0] = $5;
   $$->child[1] = $7;
  }
  ;
params : param-lista {$$ = $1;}
  | VOID {$$ = NULL;}
  | error  {$$ = NULL; ok = FALSE;}
  ;
param-lista : param-lista COLON param
  { YYSTYPE t = $1;
    if (t != NULL){
      while (t->sibling != NULL)
        t = t->sibling;
      t->sibling = $3;
      $$ = $1;
    }
    else{
      $$ = $3;
    }
  }
  | param {$$ = $1;}
  ;
param : tipo-especificador ID
  {$$ = newStmtNode(VarDecK);
   $$->attr.name = copyString(lastIDName);
   $$->linenbr = linenbr;
   $$->type = savedDataType;}
  | tipo-especificador ID LBOX RBOX
  {$$ = newStmtNode(VarDecK);
   $$->attr.name = copyString(lastIDName);
   $$->linenbr = linenbr;
   $$->type = savedDataType;}
  ;
composto-decl : LKEY local-declaracoes statement-lista RKEY
  {
    $$ = newStmtNode(CompostoK);
    $$->child[0] = $2;
    $$->child[1] = $3;
  }
  ;
local-declaracoes : local-declaracoes var-declaracao
  {
    YYSTYPE t = $1;
    if (t != NULL){
      while (t->sibling != NULL)
        t = t->sibling;
      t->sibling = $2;
      $$ = $1;
    }
    else{
      $$ = $2;
    }
  }
  | /* empty */ {$$ = NULL;}
  ;
statement-lista : statement-lista statement
  {
    YYSTYPE t = $1;
    if (t != NULL){
      while (t->sibling != NULL)
        t = t->sibling;
      t->sibling = $2;
      $$ = $1;
    }
    else{
      $$ = $2;
    }
  }
  | /* empty */ {$$ = NULL;}
  ;
statement : expressao-decl {$$ = $1;}
  | composto-decl {$$ = $1;}
  | selecao-decl {$$ = $1;}
  | iteracao-decl {$$ = $1;}
  | retorno-decl {$$ = $1;}
  ;
expressao-decl :
  | expressao SEMI {$$ = $1;}
  ;
selecao-decl : IF LPAREN expressao RPAREN statement %prec "then"
  {
    $$ = newStmtNode(IfK);
    $$->child[0] = $3;
    $$->child[1] = $5;
  }
  | IF LPAREN expressao RPAREN statement ELSE statement
  {
    $$ = newStmtNode(IfK);
    $$->child[0] = $3;
    $$->child[1] = $5;
    $$->child[2] = $7;
  }
  ;
iteracao-decl : WHILE LPAREN expressao RPAREN statement
  {
    $$ = newStmtNode(WhileK);
    $$->child[0] = $3;
    $$->child[1] = $5;
  }
  ;
retorno-decl : RETURN SEMI
  {
    $$ = newStmtNode(ReturnK);
  }
  | RETURN expressao SEMI
  {
    $$ = newStmtNode(ReturnK);
    $$->child[0] = $2;
  }
  ;
expressao :
  var ASSIGN expressao
  {
    $$ = newStmtNode(AssignK);
    $$->child[0] = $1;
    $$->child[1] = $3;
    $$->linenbr = savedLineNo;
  }
  |simples-expressao {$$ = $1;}
  ;
var : ID { $$ = newExpNode(IdK);
           $$->attr.name = copyString(lastIDName);
         }
  | ID
  {
    savedName = copyString(lastIDName);
    savedLineNo = linenbr;
  }
  LBOX expressao RBOX
  {
    $$ = newExpNode(VetIdK);
    $$->attr.name = savedName;
    $$->child[0] = $4;
  }
  ;
simples-expressao : soma-expressao relacional soma-expressao
  {
    $$ = newExpNode(OpK);
    $$->child[0] = $1;
    $$->child[1] = $3;
    $$->attr.op = savedOperator;
  }
  | soma-expressao { $$ = $1;}
  ;
relacional : LE {savedOperator = LE;}
  | LT {savedOperator = LT;}
  | GT {savedOperator = GT;}
  | GE {savedOperator = GE;}
  | EQ {savedOperator = EQ;}
  | NEQ {savedOperator = NEQ;}
  ;
soma-expressao : soma-expressao soma termo
  {
    $$ = newExpNode(OpK);
    $$->child[0] = $1;
    $$->child[1] = $3;
    $$->attr.op = savedOperator;
  }
  | termo {$$ = $1;}
  ;
soma : PLUS {savedOperator = PLUS;}
  | MINUS {savedOperator = MINUS;}
  ;
termo : termo mult fator
  {
    $$ = newExpNode(OpK);
    $$->child[0] = $1;
    $$->child[1] = $3;
    $$->attr.op = savedOperator;
  }
  | fator {$$ = $1;}
  ;
mult : TIMES {savedOperator = TIMES;}
  | OVER {savedOperator = OVER;}
  ;
fator : LPAREN expressao RPAREN {$$ = $2;}
  | var {$$ = $1;}
  | ativacao {$$ = $1;}
  | NUM { $$ = newExpNode(ConstK);
          $$->attr.val = atoi(tokenString);
        }
  | FNUM { $$ = newExpNode(FConstK);
          $$->attr.val = atof(tokenString);
         }
  | error {ok = FALSE;}
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
FILE * listing = stdout;
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
  // imprimeTabela(stdout);
  // printf("\n\n");
  apagaTabela();
  abrirArq(argv[1]);
  printf("\nParser em execução...\n");
  if (yyparse()==0 && ok) printf("\nAnálise sintática OK\n");
  else printf("\nAnálise sintática apresenta ERRO\n");
  printf("\nÁrvore sintática:\n");
  printTree(savedTree);
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
