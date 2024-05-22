#include <cstring>
#include <iostream>
#include <fstream>
#include "ast.hpp"
Lines *result = 0;
#include "parse.tab.h"

extern FILE *yyin;

int main(int argc, char *argv[]) {
	std::ofstream output;
	bool hasOutput = false;
	if (argc > 1) {
		yyin = fopen(argv[1], "r");
		if (argc > 2) {
			if (argv[1] == argv[2]) {
				std::cout << "\033[0;31mFlagError: \033[0;0 cannot read from and write to the same file\n";
				exit(1);
			}
			output = std::ofstream(argv[2], std::ofstream::trunc);
			hasOutput = true;
		}
	}
	else {
		std::cout << "InputError: found no file to open\n";
		exit(1);
	}
	yyparse();
	interpretConsts(result);
	std::string str = result->Str();
		if (hasOutput)
			output.write(str.data(), str.size());
		else
			std::cout << str << std::endl;
	/*Float num(11.2);
	std::cout << "Float initialized successfully" << std::endl;
	num.codegen();
	std::cout << "Float to LLVM IR successful\n";*/

	return 0;
}
