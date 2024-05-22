.PHONY: cold
cold:
	bison -d parse.y
	mv parse.tab.c parse.tab.cpp
	flex lex.l
	mv lex.yy.c lex.yy.cpp
	clang++ cold.cpp parse.tab.cpp lex.yy.cpp -o cold
	rm parse.tab.cpp parse.tab.h lex.yy.cpp