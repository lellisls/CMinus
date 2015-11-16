/****************************************************/
/* File: cminus.l                                   */
/* Lex specification for C-                         */
/* Lucas Lellis, Maira Tayana Menegas               */
/****************************************************/

%{
#include "globals.h"
#include "tabela.h"
int lineno = 1; /* source line number for listing */

//#include "util.h"
//#include "scan.h"
/* lexeme of identifier or reserved word */
char tokenString[MAXTOKENLEN+1];
%}

digit       [0-9]
number      {digit}+
fnum	    {digit}*\.{number}|{number}\.{digit}*
letter      [a-zA-Z]
identifier  {letter}+
newline     \n
whitespace  [ \t]+
OUTRO       [^0-9a-zA-Z;/=\-"+""*""("")""!"">""<""{""}""[""\]"","\n]

%%

"if"            {return IF;}
"else"          {return ELSE;}
"int"		{return INT;}
"float"		{return FLOAT;}
"void"		{return VOID;}
"return"	{return RETURN;}
"while"		{return WHILE;}
"=="            {return EQ;}
"!="            {return NEQ;}
"="             {return ASSIGN;}
"<"             {return LT;}
"<="            {return LE;}
">"             {return GT;}
">="            {return GE;}
"+"             {return PLUS;}
"-"             {return MINUS;}
"*"             {return TIMES;}
"/"             {return OVER;}
"("             {return LPAREN;}
")"             {return RPAREN;}
"["             {return LBOX;}
"]"             {return RBOX;}
"{"             {return LKEY;}
"}"             {return RKEY;}
";"             {return SEMI;}
","             {return COLON;}
{fnum}		    {return FNUM;}
{number}        {return NUM;}
{identifier}    {return ID;}
{newline}       {lineno++;}
{whitespace}    {/* skip whitespace */}
<<EOF>>         {return ENDFILE;}
"/*"             { char c1,c2;
                  do
                  { c1 = input();
                    if (c1 == EOF) break;
                    if (c1 == '\n') lineno++;
          					if (c1 == '*'){
          					  c2 = input();
                      if (c2 == EOF) break;
          					  if (c2 == '\n') lineno++;
          					}
                  } while (c1 != '*' || c2 != '/');
                }
{OUTRO}+        {return ERROR;}

%%

FILE* source;

/*TokenType getToken(void)
{ static int firstTime = TRUE;
  TokenType currentToken;
  if (firstTime)
  { firstTime = FALSE;
    lineno++;
    yyin = source;
  }
  currentToken = yylex();
  strncpy(tokenString,yytext,MAXTOKENLEN);
  return currentToken;
}*/

EntradaTabela * escopo = NULL;
DataType lastDType = VOID;
char lastId[128];
void tipoDeclaracao(TokenType tok) {

  EntradaTabela * ent;
  switch (tok) {
    case LPAREN:{
      //Func
       ent = criaEntrada( lastId, FUN, lastDType, NULL, lineno );
       escopo = ent;
      break;
    }
    case LBOX:{
      //VET
      ent = criaEntrada( lastId, VET, lastDType, escopo, lineno );
      escopo = ent;
      break;
    }
    case SEMI:
    case COLON:
    case RPAREN:{
      //VAR
      ent = criaEntrada( lastId, VAR, lastDType, escopo, lineno );
      break;
    }
    default:{
      printf("\033[1mError found at line %d: cannot declare '%s'\033[m\n", lineno, yytext);
      return;
      //ERRO!!!!!!!!!!!!!!!!!!!!!!!!!!
    }
  }
  imprimeEntrada(ent);
  insereNovaEntrada(ent);
}

void global( TokenType tok ) {
  switch (tok) {
    case ID:{
      EntradaTabela * ent = buscaEntrada(yytext);
      if( ent == NULL && escopo != NULL){
        printf("%s + %s\n", escopo->idName, yytext);
        char temp[128];
        strcpy(temp, escopo->idName);
        strcat(temp, yytext);
        printf("Buscando por '%s'\n", temp);
        ent = buscaEntrada(temp);
      }
      if(ent != NULL){
        adicionaLinha(ent, lineno);
      }else{
        printf("\033[1mError found at line %d: '%s' was not declared yet\033[m\n", lineno, yytext);
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
        return;
      }
      if(tok != ID ){
        printf("\033[1mError found at line %d: Expected id but it was %s \033[m\n", lineno, yytext);
        return;
      }
      if(escopo != NULL){
        strcpy(lastId, escopo->idName);
        strcat(lastId, yytext);
      }else{
        strcpy(lastId, yytext);
        printf("lastId = %s\n", yytext);
      }
      tok = yylex();
      tipoDeclaracao(tok);
      break;
    }
  }
}

int main(int argc, char *argv[]) {
  if(argc == 2 ){
    if(source = fopen(argv[1],"r"))  yyin = source;
    else  perror(argv[0]);
  }else{
    yyin = stdin;
  }
  int token;
  while ((token=yylex())!=ENDFILE) {
    if(token == ERROR){
      printf("Error found at line %d: %s\n", lineno, yytext);
    }else{
      if(token == ID || token == FLOAT || token == INT || token == VOID ){
        global(token);
        // printf("\'%s\' : \'%s\'\n", yytext, tokenToString(token));
      }else if(token == RKEY){
        escopo = NULL;
      }
    }
  }
  return(0);
}

/*int main( ) {
  EntradaTabela * myFunc  = criaEntrada( "MyFunc", FUN, INT, NULL, 10 );
  EntradaTabela * ent = criaEntrada( "HakunaMatata", VAR, INT, myFunc, 10 );
  int pos = insereNovaEntrada( ent );
  printf( "Entrada '%s'inserida na posição %d\n", ent->idName, pos );
  imprimeEntrada(ent);
  return( 0 );
}*/
