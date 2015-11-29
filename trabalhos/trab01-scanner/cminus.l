/****************************************************/
/* File: cminus.l                                   */
/* Lex specification for C-                         */
/* Lucas Lellis, Maira Tayana Menegas               */
/****************************************************/

%{
#include "globals.h"

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
