%{
#include "calc.tab.h"
extern YYSTYPE yylval;
void abrirArq();
int linha=1;

%}

spaco [ \t]+

%%
[0-9]+	{ return NUM; }
\+	{ return '+'; }
\-	{ return '-'; }
\*	{ return '*'; }
\(	{ return '('; }
\)	{ return ')'; }
\n	{linha++; return FIMLIN;}
{spaco} { }
.       {return ERRO; }
%%

void abrirArq()
{
  yyin = fopen("entrada.txt", "r");
}
	 
