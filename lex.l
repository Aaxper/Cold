%option noyywrap

%{
#include <string>

#define YY_DECL int yylex()

std::string currentLine = "";
int currentColumn = 1;
int lineCount = 1;
bool nextIsReal = true;

#define YY_USER_ACTION if (yytext[0] == '\n') { currentLine = ""; nextIsReal = true; } else if (yytext[0] != '\t' && nextIsReal) { nextIsReal = false; currentColumn += yyleng; }

#include "parse.tab.h"

int indent = 0;
%}

%%

.* { if (currentLine == "") { currentLine = yytext; currentColumn = 1; lineCount++; nextIsReal = true; } REJECT; }

[0-9]+\.[0-9]* { yylval.floatType = atof(yytext); return FLOAT; }
[0-9]+ { yylval.intType = atoi(yytext); return INT; }
\"[^\"]*\" { std::string *str = new std::string; *str = yytext; *str = str->substr(1, str->length()-2); yylval.strType = str; return STRING; }

#.* { return NEWLINE; }

"+" { return ADD; }
"-"	{ return SUB; }
"*"	{ return MUL; }
"/"	{ return DIV; }
"("	{ return LPAREN; }
")"	{ return RPAREN; }
"="	{ return EQUAL; }
">"	{ return GREATER; }
"<"	{ return LESS; }
":"	{ return COLON; }

"true" { yylval.boolType = 1; return BOOL; }
"false" { yylval.boolType = 0; return BOOL; }
"if" { return IF; }
"while" { return WHILE; }

[a-zA-Z][a-zA-Z0-9]* { std::string *str = new std::string; *str = yytext; yylval.strType = str; return ID; }

" " {};
\t { return INDENT; }
\n { return NEWLINE; }

<<EOF>> { static int once = 0; if (!once) { if (currentLine == "") return 0; once++; return NEWLINE; } return 0; }

. { yyerror(((std::string)"syntax error, unexpected '" + yytext + "'").data()); }

%%
