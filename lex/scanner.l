/****************************************************/
/* File: cminus.l                                   */
/* Lex specification for C-                         */
/* Lucas Lellis, Maira Tayana Menegas               */
/****************************************************/

/*yyrestart*/

%{
#include "parser.tab.h"
#include "globals.h"
// #include "tabela.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern YYSTYPE yylval;
void abrirArq(char * fileName);

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
"int"           {return INT;}
"float"         {return FLOAT;}
"void"          {return VOID;}
"return"        {return RETURN;}
"while"         {return WHILE;}
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
{fnum}          {return FNUM;}
{number}        {return NUM;}
{identifier}    {return ID;}
{newline}       {linenbr++;}
{whitespace}    {/* skip whitespace */}
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


/*int main(int argc, char *argv[]) {
  if(argc == 2 ){

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
  return(0);
}*/

void abrirArq(char * fileName){
  if(source = fopen(fileName,"r"))
    yyin = source;
  else
    printf("Could not open file %s\n", fileName);
}

/*int main( ) {
  EntradaTabela * myFunc  = criaEntrada( "MyFunc", FUN, INT, NULL, 10 );
  EntradaTabela * ent = criaEntrada( "HakunaMatata", VAR, INT, myFunc, 10 );
  int pos = insereNovaEntrada( ent );
  printf( "Entrada '%s'inserida na posição %d\n", ent->idName, pos );
  imprimeEntrada(ent);
  return( 0 );
}*/
