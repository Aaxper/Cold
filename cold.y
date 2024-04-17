%{

#include <stdio.h>
#include <stdlib.h>

#define NEW_EXPR(tag, ...) \
  new_expr((struct AST_EXPR){tag, {.tag=(struct tag){__VA_ARGS__}}})

extern int yylex();
extern int yyparse();
extern FILE* yyin;

void yyerror(const char* s);

struct AST_EXPR {
    enum {
        AST_VALUE,
        AST_ADD,
        AST_SUB,
        AST_MUL,
        AST_DIV
    } tag;
    union {
        struct AST_VALUE { union VAL_TYPES { int intVal; float floatVal; char *strVal; } TYPE; int typ; } AST_VALUE;
        struct AST_ADD { struct AST_EXPR *left; struct AST_EXPR *right; } AST_ADD;
        struct AST_SUB { struct AST_EXPR *left; struct AST_EXPR *right; } AST_SUB;
        struct AST_MUL { struct AST_EXPR *left; struct AST_EXPR *right; } AST_MUL;
        struct AST_DIV { struct AST_EXPR *left; struct AST_EXPR *right; } AST_DIV;
    } data;
};
struct AST_EXPR *new_expr(struct AST_EXPR ast) {
    struct AST_EXPR *ptr = malloc(sizeof(struct AST_EXPR));
    if (ptr) *ptr = ast;
    return ptr;
}

void ast_print(struct AST_EXPR *ptr) {
    struct AST_EXPR ast = *ptr;
    switch (ast.tag) {
    case AST_VALUE:
        if (ast.data.AST_VALUE.typ == 0) {
            printf("%d", ast.data.AST_VALUE.TYPE.intVal);
        } else if (ast.data.AST_VALUE.typ == 1) {
            printf("%f", ast.data.AST_VALUE.TYPE.floatVal);
        } else if (ast.data.AST_VALUE.typ == 2) {
            printf("%s", ast.data.AST_VALUE.TYPE.strVal);
        }
        return;
    case AST_ADD: {
        struct AST_ADD data = ast.data.AST_ADD;
        printf("(");
        ast_print(data.left);
        printf(" + ");
        ast_print(data.right);
        printf(")");
        return;
    }
    case AST_SUB: {
        struct AST_SUB data = ast.data.AST_SUB;
        printf("(");
        ast_print(data.left);
        printf(" - ");
        ast_print(data.right);
        printf(")");
        return;
    }
    case AST_MUL: {
        struct AST_MUL data = ast.data.AST_MUL;
        printf("(");
        ast_print(data.left);
        printf(" * ");
        ast_print(data.right);
        printf(")");
        return;
    }
    case AST_DIV: {
        struct AST_DIV data = ast.data.AST_DIV;
        printf("(");
        ast_print(data.left);
        printf(" / ");
        ast_print(data.right);
        printf(")");
        return;
    }
  }
}

%}

%union {
	int intType;
	float floatType;
    char *strType;
    struct AST_EXPR *exprType;
}

%define parse.error verbose

%token<intType> INT
%token<floatType> FLOAT
%token<strType> STRING
%token ADD SUB MUL DIV LPAREN RPAREN
%token NEWLINE
%left ADD SUB
%left MUL DIV

%type<exprType> expr

%start result

%%

result: lines
;

lines: /* empty */
    | lines line

line: NEWLINE
    | expr NEWLINE { ast_print($1); printf("\n"); }
;

expr: INT { union VAL_TYPES x; x.intVal = $1; $$ = NEW_EXPR(AST_VALUE, x, 0); }
    | FLOAT { union VAL_TYPES x; x.floatVal = $1; $$ = NEW_EXPR(AST_VALUE, x, 1); }
    | STRING { union VAL_TYPES x; x.strVal = $1; $$ = NEW_EXPR(AST_VALUE, x, 2); }
	| expr ADD expr	{ $$ = NEW_EXPR(AST_ADD, $1, $3); }
	| expr SUB expr	{ $$ = NEW_EXPR(AST_SUB, $1, $3); }
	| expr MUL expr	{ $$ = NEW_EXPR(AST_MUL, $1, $3); }
    | expr DIV expr	{ $$ = NEW_EXPR(AST_DIV, $1, $3); }
	| LPAREN expr RPAREN { $$ = $2; }
;

%%

int main() {
	yyin = fopen("example.cold", "r");

	do {
		yyparse();
	} while(!feof(yyin));

	return 0;
}

void yyerror(const char* s) {
	fprintf(stderr, "Error: %s\n", s);
	exit(1);
}