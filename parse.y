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
    Func *funcType;
    Expression *exprType;
    std::vector<std::string> *idListType;
}

%define parse.error verbose

%token<intType> INT "integer"
%token<floatType> FLOAT "float"
%token<strType> STRING "string" ID "identifier"
%token<boolType> BOOL "boolean"
%token ADD "addition" SUB "subtraction" MUL "multiplication" DIV "division" MOD "modulus" COMMA "comma" LPAREN "opening parenthesis" RPAREN "closing parenthesis" EQUAL "equality" GREATER "greater than comparison" LESS "less than comparison" GREATEREQUAL "greater than or equal to comparison" LESSEQUAL "less than or equal to comparison" COLON "colon"
%token NEWLINE "new line" INDENT "indent"
%token IF "if" WHILE "while" FUNC "function"
%left COMMA
%left EQUAL GREATEREQUAL GREATER LESSEQUAL LESS
%left ADD SUB
%left MUL DIV MOD

%type<exprType> expr 
%type<funcType> func
%type<lineType> line
%type<linesType> lines
%type<idListType> id_list

%start result

%%

result: lines { result = $1; }
;

lines: line { $$ = new Lines($1); }
    | lines line { $$ = $1; if ($2) $$->AddLine($2); }
;

id_list: ID { $$ = new std::vector<std::string> { *$1 }; }
    | id_list COMMA ID { $$ = $1; $$->push_back(*$3); }
;

line: NEWLINE { $$ = nullptr; }
    | ID EQUAL expr NEWLINE { $$ = new Assign{ $1, $3, 0 }; $$->self = currentLine + "\n"; $$->num = lineCount; }
    | IF expr NEWLINE { $$ = new If{ $2, nullptr, 0 }; $$->self = currentLine + "\n"; $$->num = lineCount; }
    | WHILE expr NEWLINE { $$ = new While{ $2, nullptr, 0 }; $$->self = currentLine + "\n"; $$->num = lineCount; }
    | FUNC ID NEWLINE { $$ = new Function{ $2, nullptr, 0 }; $$->self = currentLine + "\n"; $$->num = lineCount; }
    | FUNC ID id_list NEWLINE { $$ = new Function{ $2, $3, nullptr, 0 }; $$->self = currentLine + "\n"; $$->num = lineCount; }
	| INDENT line { if ($2) $2->Indent(); $$ = $2; $$->self = currentLine + "\n"; $$->num = lineCount; }
    | func NEWLINE { $$ = new Assign{ nullptr, $1, 0 }; $$->self = currentLine + "\n"; $$->num = lineCount; }
;

expr: INT { $$ = new Int( $1 ); }
    | FLOAT { $$ = new Float( $1 ); }
    | STRING { $$ = new String( $1 ); }
    | BOOL { $$ = new Bool( $1 ); }
    | ID { $$ = new Var( $1 ); }
    | SUB expr { $$ = new BinOp{ new Int(0), $2, "-" }; }
	| expr ADD expr	{ $$ = new BinOp( $1, $3, "+" ); }
	| expr SUB expr	{ $$ = new BinOp( $1, $3, "-" ); }
	| expr MUL expr	{ $$ = new BinOp( $1, $3, "*" ); }
    | expr DIV expr	{ $$ = new BinOp( $1, $3, "/" ); }
    | expr MOD expr	{ $$ = new BinOp( $1, $3, "%" ); }
    | expr EQUAL expr { $$ = new BinOp( $1, $3, "=" ); }
    | expr GREATEREQUAL expr { $$ = new BinOp( $1, $3, ">=" ); }
    | expr GREATER expr { $$ = new BinOp( $1, $3, ">" ); }
    | expr LESSEQUAL expr { $$ = new BinOp( $1, $3, "<=" ); }
    | expr LESS expr { $$ = new BinOp( $1, $3, "<" ); }
    | expr COMMA expr { 
        if ($1->isList) 
            if ($3->isList) { 
                for (int i = 0; i < ((List*)$3)->contents.size(); i++) 
                    ((List*)$1)->contents.push_back(((List*)$3)->contents[i]); $$ = $1; 
            } else { 
                ((List*)$1)->contents.push_back($3); 
                $$ = $1; 
            } 
        else { 
            List *list = new List($1); 
            list->contents.push_back($3); 
            $$ = list; 
        } 
    }
	| LPAREN expr RPAREN { $2->isList = false; $$ = $2; }
    | func { $$ = $1; }
;

func: ID expr { $$ = new Func(*$1, $2); }
    | ID LPAREN RPAREN { $$ = new Func(*$1, nullptr); }

%%

void yyerror(const char *s) {
    std::string errorString = s;
	std::cout << "\033[0;31mSyntaxError: \033[0;0m" << errorString.substr(14, errorString.size() - 1) << '\n';
    std::cout << lineCount << " | " << currentLine << '\n';
    std::cout << std::string(currentColumn + 2 + (std::to_string(lineCount)).size(), ' ') << "\033[0;31m^\033[0;0m" << std::endl;
	exit(1);
}