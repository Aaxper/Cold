%option noyywrap

%{
#include <string>

#define YY_DECL int yylex()

std::string currentLine = "";
int currentColumn = 0;
int lineCount = 0;
bool isNewLine = true;
bool isIndent = true;

#include "parse.tab.h"
%}

%%

[^ \t].* { if (isNewLine) { isNewLine = false; lineCount++; currentColumn = 0; currentLine = yytext; } REJECT; }

[0-9]+\.[0-9]* { yylval.floatType = atof(yytext); currentColumn += yyleng; return FLOAT; }
[0-9]+ { yylval.intType = atoi(yytext); currentColumn += yyleng; return INT; }
\"[^\"\n]*\" { std::string *str = new std::string; *str = yytext; *str = str->substr(1, str->length() - 2); yylval.strType = str; currentColumn += yyleng; return STRING; }

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
"," { currentColumn++; return COMMA; }

"true" { currentColumn += 4; yylval.boolType = 1; return BOOL; }
"false" { currentColumn += 5; yylval.boolType = 0; return BOOL; }
"if" { currentColumn += 2; return IF; }
"while" { currentColumn += 5; return WHILE; }

[a-zA-Z][a-zA-Z0-9]* { currentColumn += yyleng; std::string *str = new std::string; *str = yytext; yylval.strType = str; return ID; }

" " { currentColumn++; }
(\t|"    ") { return INDENT; }
\n { currentColumn++; isNewLine = true; return NEWLINE; }

<<EOF>> { static int once = 0; if (!once) { once++; return NEWLINE; } return 0; }

. { currentColumn++; yyerror(((std::string)"syntax error, unexpected '" + yytext + "'").data()); }

%%
