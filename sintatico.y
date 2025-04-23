%{
    #include <iostream>
    #include <string>
    #include <sstream>
	#include <vector>

    #define YYSTYPE atributos

    using namespace std;

	int label_num;

	string gerar_label();

    struct atributos{
        string label;
        string traducao;
		string tipo;
    };

	typedef struct{
		string nome_variavel;
		string tipo_variavel;
	} TIPO_SIMBOLO;

	vector<TIPO_SIMBOLO> tabela_simbolos;

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

%left '+' '-'
%left '*' '/'

%%

S 			: TOKEN_TIPO_INT TOKEN_MAIN '(' ')' BLOCO {
				cout << "/*Compilador SLA*/\n" << "#include <iostream>\n#include <string.h>\n#include <stdio.h>\nint main(void){\n\n" << $5.traducao << "\treturn 0;\n}" << endl; 
			}
			;

BLOCO		: '{' COMANDOS '}' {
				$$.traducao = $2.traducao;
			}
			;

COMANDOS	: COMANDO COMANDOS {
				$$.traducao = $1.traducao + $2.traducao;
			}
			|
			{
				$$.traducao = "";
			}
			;

COMANDO 	: E ';'
			| TOKEN_TIPO_INT TOKEN_ID ';' {
				TIPO_SIMBOLO valor;
				valor.nome_variavel = $2.label;
				valor.tipo_variavel = $1.label;

				tabela_simbolos.push_back(valor);
				
				$$.traducao = "";
				$$.label = "";
			}
			;

E 			: E '+' E {
				$$.label = gerar_label();
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " + " + $3.label + ";\n";
			}
			| E '-' E {
				$$.label = gerar_label();
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " - " + $3.label + ";\n";
			}
			| E '*' E {
				$$.label = gerar_label();
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " * " + $3.label + ";\n";
			}
			| E '/' E {
				$$.label = gerar_label();
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " / " + $3.label + ";\n";
			}
			|TOKEN_ID '=' E {
				$$.traducao = $1.traducao + $3.traducao + "\t" + $1.label + " = " + $3.label + ";\n";
			}
			| TOKEN_DIGIT {
				$$.tipo = "int"; //CUIDADOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO
				$$.label = gerar_label();
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| TOKEN_ID {
				bool encontrado = false;
				TIPO_SIMBOLO variavel;
				for(int i = 0; i < tabela_simbolos.size(); i++){
					if(tabela_simbolos[i].nome_variavel == $1.label){
						variavel = tabela_simbolos[i];
						encontrado = true;
					}
				}
				if(!encontrado){
					yyerror("Voce nao declarou a variavel!");
				}
				$$.tipo = variavel.tipo_variavel;
                $$.label = gerar_label();
                $$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
            }
			;

%%

#include "lex.yy.c"

int yyparse();

string gerar_label(){
	label_num++;
    return "t" + std::to_string(label_num);
}

int main( int argc, char* argv[] ) {

	label_num = 0;
	yyparse();

	return 0;
}

void yyerror( string MSG )
{
	cout << MSG << endl;
	exit (0);
}