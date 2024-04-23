.PHONY: cold
cold:
	bison -d parse.y
	mv parse.tab.c parse.tab.cpp
	mv parse.tab.h parse.tab.hpp
	flex lex.l
	mv lex.yy.c lex.yy.cpp
	clang++ -c parse.tab.cpp
	clang++ -c lex.yy.cpp parse.tab.hpp
	clang++ compile.cpp parse.tab.o lex.yy.o -o cold
	rm parse.tab.cpp parse.tab.hpp parse.tab.hpp.gch parse.tab.o lex.yy.cpp lex.yy.o