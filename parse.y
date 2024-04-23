%require "3.2"

%code requires {
    #include <iostream>
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
    Node *nodeType;
    Expression *exprType;
}

%define parse.error verbose

%token<intType> INT 
%token<floatType> FLOAT 
%token<strType> STRING ID
%token<boolType> BOOL
%token ADD SUB MUL DIV LPAREN RPAREN EQUAL
%token NEWLINE
%left EQUAL
%left ADD SUB
%left MUL DIV

%type<exprType> expr
%type<nodeType> line

%start result

%%

result: lines
;

lines: /* empty */
    | lines line
;

line: NEWLINE { $$ = nullptr; }
    | ID EQUAL expr NEWLINE { $$ = new Assign( $1, $3 ); std::cout << $$->str << "\n"; }
;

expr: INT { $$ = new Int{ $1 }; }
    | FLOAT { $$ = new Float{ $1 }; }
    | STRING { $$ = new String{ $1 }; }
    | BOOL { $$ = new Bool{ $1 }; }
    | ID { $$ = new Var{ $1 }; }
	| expr ADD expr	{ $$ = new BinOp{ $1, $3, '+' }; }
	| expr SUB expr	{ $$ = new BinOp{ $1, $3, '-' }; }
	| expr MUL expr	{ $$ = new BinOp{ $1, $3, '*' }; }
    | expr DIV expr	{ $$ = new BinOp{ $1, $3, '/' }; }
    | expr EQUAL expr { $$ = new BinOp{ $1, $3, '=' }; }
	| LPAREN expr RPAREN { $$ = $2; }
;

%%

void yyerror(const char* s) {
	std::printf("Error: %s\n", s);
	exit(1);
}