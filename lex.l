%option noyywrap

%{
#define YY_DECL int yylex()

#include "parse.tab.hpp"
%}

%%

[0-9]+\.[0-9]* { yylval.floatType = atof(yytext); return FLOAT; }
[0-9]+ { yylval.intType = atoi(yytext); return INT; }
\"[^\"]*\" { std::string *str = new std::string; *str = yytext; *str = str->substr(1, str->length()-2); yylval.strType = str; return STRING; }

#[^\n]* {}

"+" { return ADD; }
"-"	{ return SUB; }
"*"	{ return MUL; }
"/"	{ return DIV; }
"("	{ return LPAREN; }
")"	{ return RPAREN; }
"="	{ return EQUAL; }

"true" { yylval.boolType = 1; return BOOL; }
"false" { yylval.boolType = 0; return BOOL; }

[a-zA-Z][a-zA-Z0-9]* { std::string *str = new std::string; *str = yytext; yylval.strType = str; return ID; }

[ \t];
\n { return NEWLINE; }

<<EOF>> { static int once = 0; if (once == 0) { once = 1; return NEWLINE; } return 0; }

%%