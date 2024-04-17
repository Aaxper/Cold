cold:	cold.l cold.y
	bison -d cold.y
	flex cold.l
	cc -o $@ cold.tab.c lex.yy.c -lfl
	rm cold.tab.c cold.tab.h lex.yy.c