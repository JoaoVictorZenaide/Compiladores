all:
	flex lexico.l
	bison -d sintatico.y
	gcc -o exemplo sintatico.tab.c lex.yy.c -lfl