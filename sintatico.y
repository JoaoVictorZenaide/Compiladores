%{
    #include <iostream>
    #include <string>
    #include <sstream>

    #define YYSTYPE atributos

    using namespace std;

    struct atributos{
        string label;
        string traducao;
    };

    int yylex(void);
    void yyerror(string);
%}

%token TOKEN_TIPO_INT
%token TOKEN_DIGIT
%token TOKEN_ID
%token TOKEN_MAIN
%token TOKEN_FIM
%token TOKEN_ERROR

%start S

%left '+'

%%

S 			: TOKEN_TIPO_INT TOKEN_MAIN '(' ')' BLOCO
			{
				cout << "/*Compilador SLA*/\n" << "#include <iostream>\n#include <string.h>\n#include <stdio.h>\nint main(void){\n\n" << $5.traducao << "\treturn 0;\n}" << endl; 
			}
			;

BLOCO		: '{' COMANDOS '}'
			{
				$$.traducao = $2.traducao;
			}
			;

COMANDOS	: COMANDO COMANDOS
			|
			;

COMANDO 	: E ';'
			;

E 			: E '+' E
			{
                $$.label = "t2";
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " + " + $3.label + ";\n";
			}
			| TOKEN_DIGIT
			{
                $$.label = "t1";
				$$.traducao = "\tt1 = " + $1.label + ";\n";
			}
			| TOKEN_ID
            {
                $$.label = "t1";
                $$.traducao = "\tt1 = " + $1.label + ";\n";
            }
			;

%%

#include "lex.yy.c"

int yyparse();

int main( int argc, char* argv[] )
{
	yyparse();

	return 0;
}

void yyerror( string MSG )
{
	cout << MSG << endl;
	exit (0);
}