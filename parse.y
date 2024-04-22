%require "3.2"

%code requires {
    #include <iostream>
    #include "ast.h"

    extern int yylex();
    extern int yyparse();
    void yyerror(const char* s);
}

%union {
    int intType;
    float floatType;
    std::string *strType;
    bool boolType;
    Node *nodeType;
    Expression *exprType;
}

%define parse.error verbose

%token<intType> INT 
%token<floatType> FLOAT 
%token<strType> STRING 
%token<boolType> BOOL
%token ADD SUB MUL DIV LPAREN RPAREN
%token NEWLINE
%left ADD SUB
%left MUL DIV

%type<exprType> expr line

%start result

%%

result: lines
;

lines: /* empty */
    | lines line
;

line: NEWLINE { $$ = nullptr; }
    | expr NEWLINE { std::cout << $1->str << "\n"; $$ = $1; }
;

expr: INT { $$ = new Int{ $1 }; }
    | FLOAT { $$ = new Float{ $1 }; }
    | STRING { $$ = new String{ $1 }; }
    | BOOL { $$ = new Bool{ $1 }; }
	| expr ADD expr	{ $$ = new BinOp{ $1, $3, '+' }; }
	| expr SUB expr	{ $$ = new BinOp{ $1, $3, '-' }; }
	| expr MUL expr	{ $$ = new BinOp{ $1, $3, '*' }; }
    | expr DIV expr	{ $$ = new BinOp{ $1, $3, '/' }; }
	| LPAREN expr RPAREN { $$ = $2; }
;

%%

void yyerror(const char* s) {
	std::printf("Error: %s\n", s);
	exit(1);
}