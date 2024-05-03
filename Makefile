.PHONY: cold
cold:
	bison -d parse.y
	flex lex.l
	clang++ cold.cpp parse.tab.c lex.yy.c -o cold -I `llvm-config-12 --includedir --libs`
	rm parse.tab.c parse.tab.h lex.yy.c