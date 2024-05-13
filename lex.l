%option noyywrap

%{
#include <string>

#define YY_DECL int yylex()

std::string currentLine = "";
int currentColumn = 0;
int lineCount = 1;
bool isNewLine = false;

#include "parse.tab.h"
%}

%%

.* { if (currentLine == "") { currentLine = yytext; while (currentLine[0] == '\t' || currentLine[0] == ' ') { currentLine.erase(0, 1); currentColumn--; } } else if (isNewLine) { currentColumn = 0; currentLine = ""; lineCount++; isNewLine = false; } REJECT; }

[0-9]+\.[0-9]* { yylval.floatType = atof(yytext); currentColumn += yyleng; return FLOAT; }
[0-9]+ { yylval.intType = atoi(yytext); currentColumn += yyleng; return INT; }
\"[^\"\n]*\" { std::string *str = new std::string; *str = yytext; *str = str->substr(1, str->length()-2); yylval.strType = str; currentColumn += yyleng; return STRING; }

#.* {}

"+" { currentColumn++; return ADD; }
"-"	{ currentColumn++; return SUB; }
"*"	{ currentColumn++; return MUL; }
"/"	{ currentColumn++; return DIV; }
"%"	{ currentColumn++; return MOD; }
"("	{ currentColumn++; return LPAREN; }
")"	{ currentColumn++; return RPAREN; }
"="	{ currentColumn++; return EQUAL; }
">=" { currentColumn += 2; return GREATEREQUAL; }
">"	{ currentColumn++; return GREATER; }
"<=" { currentColumn += 2; return LESSEQUAL; }
"<"	{ currentColumn++; return LESS; }
":"	{ currentColumn++; return COLON; }

"true" { currentColumn += 4; yylval.boolType = 1; return BOOL; }
"false" { currentColumn += 5; yylval.boolType = 0; return BOOL; }
"if" { currentColumn += 2; return IF; }
"while" { currentColumn += 5; return WHILE; }

[a-zA-Z][a-zA-Z0-9]* { currentColumn += yyleng; std::string *str = new std::string; *str = yytext; yylval.strType = str; return ID; }

" " { currentColumn++; };
(\t|"    ") { currentColumn += yyleng; return INDENT; }
\n { isNewLine = true; return NEWLINE; }

<<EOF>> { static int once = 0; if (!once) { if (currentLine == "") return 0; once++; return NEWLINE; } return 0; }

. { yyerror(((std::string)"syntax error, unexpected '" + yytext + "'").data()); }

%%
