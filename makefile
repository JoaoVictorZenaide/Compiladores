all: 	
		clear
		lex lexico.l
		yacc -d sintatico.y --debug --verbose
		g++ -o glf y.tab.c -ll

		./glf < exemplo.jpl