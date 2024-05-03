#include <cstring>
#include <iostream>
#include <fstream>
#include "parse.tab.h"

extern FILE *yyin;

int main(int argc, char *argv[]) {
	bool debug = false;
	if (argc > 1) {
		yyin = fopen(argv[1], "r");
	} else {
		std::cout << "Error: found no file to open\n";
		exit(1);
	}
	yyparse();

	return 0;
}