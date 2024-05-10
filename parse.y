%require "3.2"

%code requires {
    #include <iostream>
	#include <vector>
    #include <string>
    #include "ast.hpp"

    extern std::string currentLine;
    extern int currentColumn;
    extern int lineCount;

    extern Lines *result;
    extern int yylex();
    extern int yyparse();
    void yyerror(const char* s);
}

%union {
    int intType;
    float floatType;
    std::string *strType;
    bool boolType;
	Line *lineType;
	Lines *linesType;
    Expression *exprType;
}

%define parse.error verbose

%token<intType> INT "integer"
%token<floatType> FLOAT "float"
%token<strType> STRING "string" ID "identifier"
%token<boolType> BOOL "boolean"
%token ADD "addition" SUB "subtraction" MUL "multiplication" DIV "division" LPAREN "opening parenthesis" RPAREN "closing parenthesis" EQUAL "equality" GREATER "greater than comparison" LESS "less than comparison" GREATEREQUAL "greater than or equal to comparison" LESSEQUAL "less than or equal to comparison" COLON "colon"
%token NEWLINE "new line" INDENT "indent"
%token IF "if" WHILE "while"
%left EQUAL GREATEREQUAL GREATER LESSEQUAL LESS
%left ADD SUB
%left MUL DIV

%type<exprType> expr
%type<lineType> line
%type<linesType> lines

%start result

%%

result: lines { result = $1; }
;

lines: line { $$ = new Lines($1); }
    | lines line { $$ = $1; if ($2) $$->AddLine($2); }
;

line: NEWLINE { $$ = nullptr; }
    | ID EQUAL expr NEWLINE { $$ = new Assign{ $1, $3, 0 }; }
    | IF expr COLON line { $$ = new If{ $2, $4, 0 }; }
    | WHILE expr COLON line { $$ = new While{ $2, $4, 0 }; }
	| INDENT line { if ($2) $2->Indent(); $$ = $2; }
;
expr: INT { $$ = new Int{ $1 }; }
    | FLOAT { $$ = new Float{ $1 }; }
    | STRING { $$ = new String{ $1 }; }
    | BOOL { $$ = new Bool{ $1 }; }
    | ID { $$ = new Var{ $1 }; }
	| expr ADD expr	{ $$ = new BinOp{ $1, $3, "+" }; }
	| expr SUB expr	{ $$ = new BinOp{ $1, $3, "-" }; }
	| expr MUL expr	{ $$ = new BinOp{ $1, $3, "*" }; }
    | expr DIV expr	{ $$ = new BinOp{ $1, $3, "/" }; }
    | expr EQUAL expr { $$ = new BinOp{ $1, $3, "=" }; }
    | expr GREATEREQUAL expr { $$ = new BinOp{ $1, $3, ">=" }; }
    | expr GREATER expr { $$ = new BinOp{ $1, $3, ">" }; }
    | expr LESSEQUAL expr { $$ = new BinOp{ $1, $3, "<=" }; }
    | expr LESS expr { $$ = new BinOp{ $1, $3, "<" }; }
	| LPAREN expr RPAREN { $$ = $2; }
;

%%

void yyerror(const char *s) {
    std::string errorString = s;
	std::cout << "\033[0;31mSyntaxError: \033[0;0m" << errorString.substr(14, errorString.size() - 1) << '\n';
    std::cout << lineCount << " | " << currentLine << '\n';
    std::cout << std::string(currentColumn + 2 + (std::to_string(lineCount)).size(), ' ') << "\033[0;31m^\033[0;0m" << std::endl;
	exit(1);
}