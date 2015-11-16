/****************************************************/
/* File: cminus.l                                   */
/* Lex specification for C-                         */
/* Lucas Lellis, Maira Tayana Menegas               */
/****************************************************/

%{
#include "globals.h"
#include "tabela.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int linenbr = 1; /* source line number for listing */
int whileCounter = 0;
int ifCounter = 0;
int elseCounter = 0;
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
{newline}       {linenbr++;}
{whitespace}    {/* skip whitespace */}
<<EOF>>         {return ENDFILE;}
"/*"             { char c1,c2;
                  do
                  { c1 = input();
                    if (c1 == EOF) break;
                    if (c1 == '\n') linenbr++;
          					if (c1 == '*'){
          					  c2 = input();
                      if (c2 == EOF) break;
          					  if (c2 == '\n') linenbr++;
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
    linenbr++;
    yyin = source;
  }
  currentToken = yylex();
  strncpy(tokenString,yytext,MAXTOKENLEN);
  return currentToken;
}*/
char escopo[255];

DataType lastDType = VOID;
char lastId[128];
void tipoDeclaracao(TokenType tok) {

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
       ent = criaEntrada( lastId, FUN, lastDType, "", linenbr );
       empilha(lastId);
      break;
    }
    case LBOX:{
      DEBUG(printf("VET: %s %s[];\n", tokenToString(lastDType), lastId);)
      //VET
      empilha(lastId);
      ent = criaEntrada( concatenaPilha(), VET, lastDType, temp, linenbr );
      desempilha();
      break;
    }
    case SEMI:
    case COLON:
    case RPAREN:{
      DEBUG(printf("VAR: %s %s;\n", tokenToString(lastDType), lastId);)
      //VAR
      empilha(lastId);
      ent = criaEntrada( concatenaPilha(), VAR, lastDType, temp, linenbr );
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

void global( TokenType tok ) {
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

int main(int argc, char *argv[]) {
  if(argc == 2 ){
    if(source = fopen(argv[1],"r"))  yyin = source;
    else  perror(argv[0]);
  }else{
    yyin = stdin;
  }
  inicializaTabela( );
  int token;
  while ((token=yylex())!=ENDFILE) {
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
        desempilha();
        if(parenCounter < 0){
          printf("\033[31mUnbalanced parentheses.\033[m\n");
        }
      }else if(token == WHILE ){
        char temp[255] = "while";
        char buffer[255];
        snprintf(buffer,16, "%d", whileCounter++);
        strcat(temp, buffer);
        empilha(temp);
      }else if(token == IF){
        char temp[255] = "if";
        char buffer[255];
        snprintf(buffer,16, "%d", ifCounter++);
        strcat(temp, buffer);
        empilha(temp);
      }else if(token == ELSE){
        char temp[255] = "else";
        char buffer[255];
        snprintf(buffer,16, "%d", elseCounter++);
        strcat(temp, buffer);
        empilha(temp);
      }
    }
  }
  imprimeTabela(stdout);
  printf("\n\n");
  apagaTabela();
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
