cold:	lex.l parse.y compile.c
	bison -d parse.y
	flex lex.l
	cc -o $@ compile.c parse.tab.c lex.yy.c -lfl
	rm parse.tab.c parse.tab.h lex.yy.c