#include <cstring>
#include <iostream>
#include <fstream>
#include "parse.tab.hpp"

extern FILE *yyin;

int main(int argc, char *argv[]) {
	bool debug = false;
	if (argc > 1) {
		if (strcmp(argv[1], "--debug") == 0) {
			if (argc > 2) {
				yyin = fopen(argv[2], "r");
			} else {
				std::cout << "Error: found no file to open\n";
				exit(1);
			}
			debug = true;
		} else {
			yyin = fopen(argv[1], "r");
		}
	} else {
		std::cout << "Error: found no file to open\n";
		exit(1);
	}
	yyparse();

	return 0;
}