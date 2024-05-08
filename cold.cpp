#include <cstring>
#include <iostream>
#include <fstream>
#include "compile.cpp"
Lines *result = 0;
#include "parse.tab.h"

extern FILE *yyin;

int main(int argc, char *argv[]) {
	if (argc > 1) {
		yyin = fopen(argv[1], "r");
	}
	else {
		std::cout << "Error: found no file to open\n";
		exit(1);
	}
	yyparse();
	std::cout << result->Str() << std::endl;
	/*Float num(11.2);
	std::cout << "Float initialized successfully\n";
	num.codegen();
	std::cout << "Float to LLVM IR successful\n";*/

	return 0;
}