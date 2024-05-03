%require "3.2"

%code requires {
    #include <iostream>
	#include <vector>
    #include "ast.hpp"

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

%token<intType> INT 
%token<floatType> FLOAT 
%token<strType> STRING ID
%token<boolType> BOOL
%token ADD SUB MUL DIV LPAREN RPAREN EQUAL COLON
%token NEWLINE INDENT
%token IF
%left EQUAL
%left ADD SUB
%left MUL DIV

%type<exprType> expr
%type<lineType> line
%type<linesType> lines

%start result

%%

result: lines { std::cout << $1->Str() << "\n"; }
;

lines: line { $$ = new Lines($1); }
    | lines line { if ($2) $1->AddLine($2); $$ = $1; }
;

line: NEWLINE { $$ = nullptr; }
    | ID EQUAL expr NEWLINE { $$ = new Assign{ $1, $3, 0 }; }
    | IF expr COLON NEWLINE line { $$ = new If{ $2, Lines{$5}, 0 }; }
	| INDENT line { if ($2) $2->indent++; $$ = $2; }
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
	| LPAREN expr RPAREN { $$ = $2; }
;

%%

void yyerror(const char* s) {
	std::cout << "\033[0;31mError: \033[0;0m" << s << "\n";
	exit(1);
}