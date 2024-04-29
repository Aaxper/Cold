.PHONY: cold
cold:
	bison -d parse.y
	mv parse.tab.c parse.tab.cpp
	mv parse.tab.h parse.tab.hpp
	flex lex.l
	mv lex.yy.c lex.yy.cpp
	g++ cold.cpp parse.tab.cpp lex.yy.cpp -o cold -I `llvm-config-12 --includedir --libs`
	rm parse.tab.cpp parse.tab.hpp lex.yy.cpp
