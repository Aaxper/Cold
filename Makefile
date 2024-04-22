.PHONY: cold
cold:
	bison -d parse.y
	mv parse.tab.c parse.tab.cpp
	flex lex.l
	mv lex.yy.c lex.yy.cpp
	g++ -c parse.tab.cpp
	g++ -c lex.yy.cpp parse.tab.h
	g++ compile.cpp parse.tab.o lex.yy.o -o cold
	rm parse.tab.cpp parse.tab.h parse.tab.h.gch parse.tab.o lex.yy.cpp lex.yy.o