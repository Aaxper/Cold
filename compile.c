#include <stdio.h>

extern FILE* yyin;
extern int yyparse();

int main() {
	yyin = fopen("example.cold", "r");
	yyparse();
	return 0;
}