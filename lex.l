%option noyywrap

%{
#include <string>

#define YY_DECL int yylex()

std::string currentLine = "";
int currentColumn = 0;
bool isNewLine = true;
int lineCount = 1;

#define YY_USER_ACTION if (isNewLine) currentColumn = 0; if (yytext[0] != '\n' && yytext[0] != '\t') isNewLine = false; if (yytext[0] != '\t') currentColumn += yyleng;

#include "parse.tab.h"

int indent = 0;
%}

%%

[^\n]* { if (isNewLine) { currentLine = yytext; while (currentLine[0] == '\t') currentLine.erase(0, 1); } REJECT; }

[0-9]+\.[0-9]* { yylval.floatType = atof(yytext); return FLOAT; }
[0-9]+ { yylval.intType = atoi(yytext); return INT; }
\"[^\"]*\" { std::string *str = new std::string; *str = yytext; *str = str->substr(1, str->length()-2); yylval.strType = str; return STRING; }

#[^\n]* { lineCount++; if (!isNewLine) { isNewLine = true; return NEWLINE; } }

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
\n { lineCount++; if (!isNewLine) { isNewLine = true; return NEWLINE; } }

<<EOF>> { static int once = 0; if (!once) { if (isNewLine) return 0; once++; return NEWLINE; } return 0; }

. { yyerror(((std::string)"syntax error, unexpected '" + yytext + "'").data()); }

%%
