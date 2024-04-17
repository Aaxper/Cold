%option noyywrap

%{
#include <stdio.h>

#define YY_DECL int yylex()

#include "cold.tab.h"

%}

%%

[0-9]+\.[0-9]* { yylval.floatType = atof(yytext); return FLOAT; }
[0-9]+ { yylval.intType = atoi(yytext); return INT; }
\"[^\"]*\" { yylval.strType = yytext; size_t len = strlen(yylval.strType); yylval.strType[len - 1] = '\0'; memmove(yylval.strType, yylval.strType + 1, len - 1); return STRING; }

"+" { return ADD; }
"-"	{ return SUB; }
"*"	{ return MUL; }
"/"	{ return DIV; }
"("	{ return LPAREN; }
")"	{ return RPAREN; }

[ \t];
\n { return NEWLINE; }

<<EOF>> { static int once = 0; return (once = !once) ? NEWLINE : 0; }

%%