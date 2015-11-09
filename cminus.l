/****************************************************/
/* File: cminus.l                                   */
/* Lex specification for C-                         */
/* Lucas Lellis, Maira Tayana Menegas               */
/****************************************************/

%{
#include "globals.h"

int lineno; /* source line number for listing */

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
"/*"            {return LCOMM;}
"*/"            {return RCOMM;}
";"             {return SEMI;}
","             {return COLON;}
{fnum}		{return FLOAT;}
{number}        {return NUM;}
{identifier}    {return ID;}
{newline}       {lineno++;}
{whitespace}    {/* skip whitespace */}
<<EOF>>         {return ENDFILE;}
.               {return ERROR;}

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
      printf("\'%s\' : \'%s\'\n", yytext, tokenToString(token));
    }
  }
  return(0);
}
