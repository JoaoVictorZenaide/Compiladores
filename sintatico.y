%{
    #include <iostream>
    #include <string>
    #include <sstream>
	#include <vector>

    #define YYSTYPE atributos

    using namespace std;

	int label_num;

	void add_na_tabela_simbolos(string valor_nome_variavel, string valor_tipo_variavel);

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
%token TOKEN_TIPO_FLOAT
%token TOKEN_TIPO_STRING
%token TOKEN_TIPO_BOOL
%token TOKEN_VARIAVEL_INT
%token TOKEN_VARIAVEL_FLOAT
%token TOKEN_VARIAVEL_STRING
%token TOKEN_VARIAVEL_BOOL
%token TOKEN_ID
%token TOKEN_MAIN
%token TOKEN_FIM
%token TOKEN_ERROR

%start S

%left '='
%left '+' '-'
%left '*' '/'

%%

S 			: TOKEN_TIPO_INT TOKEN_MAIN '(' ')' BLOCO {

				string declaracoes = "";
				for(int i = 0; i < tabela_simbolos.size(); i++){
					declaracoes = declaracoes + "\t" + tabela_simbolos[i].tipo_variavel + " " + tabela_simbolos[i].nome_variavel + ";\n";
				}

				cout << "/*Compilador SLA*/\n" << "#include <iostream>\n#include <string.h>\n#include <stdio.h>\nint main(void){\n\n" << declaracoes << "\n" <<$5.traducao << "\n\treturn 0;\n}" << endl;
				
				for(int i = 0; i < tabela_simbolos.size(); i++){ //imprimi o que tem na tabela de simbolos 
					cout << "Nome: " << tabela_simbolos[i].nome_variavel
						<< ", Tipo: " << tabela_simbolos[i].tipo_variavel << endl;
				}
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
				$$.label = "";
				$$.traducao = "";
				$$.tipo = "";

				add_na_tabela_simbolos($2.label, $1.label);
			}
			| TOKEN_TIPO_FLOAT TOKEN_ID ';' {
				$$.label = "";
				$$.traducao = "";
				$$.tipo = "";

				add_na_tabela_simbolos($2.label, $1.label);
			}
			| TOKEN_TIPO_STRING TOKEN_ID ';' {
				$$.label = "";
				$$.traducao = "";
				$$.tipo = "";

				add_na_tabela_simbolos($2.label, $1.label);
			}
			| TOKEN_TIPO_BOOL TOKEN_ID ';' {
				$$.label = "";
				$$.traducao = "";
				$$.tipo = "";

				add_na_tabela_simbolos($2.label, $1.label);
			}
			;

E 			: E '+' E {
				if($1.tipo == "float" || $3.tipo == "float"){
					$$.tipo = "float";
				}
				$$.label = gerar_label();
				add_na_tabela_simbolos($$.label, $$.tipo);

				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " + " + $3.label + ";\n";
			}
			| E '-' E {
				if($1.tipo == "float" || $3.tipo == "float"){
					$$.tipo = "float";
				}
				$$.label = gerar_label();
				add_na_tabela_simbolos($$.label, $$.tipo);
				
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " - " + $3.label + ";\n";
			}
			| E '*' E {
				if($1.tipo == "float" || $3.tipo == "float"){
					$$.tipo = "float";
				}
				$$.label = gerar_label();
				add_na_tabela_simbolos($$.label, $$.tipo);

				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " * " + $3.label + ";\n";
			}
			| E '/' E {
				if($1.tipo == "float" || $3.tipo == "float"){
					$$.tipo = "float";
				}
				$$.label = gerar_label();
				add_na_tabela_simbolos($$.label, $$.tipo);

				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " / " + $3.label + ";\n";
			}
			| '(' E ')' {
				$$.label = $2.label;
				$$.tipo = $2.tipo;
				$$.traducao = $2.traducao;
			}
			| TOKEN_ID '=' E {
				$$.traducao = $1.traducao + $3.traducao + "\t" + $1.label + " = " + $3.label + ";\n";
			}
			| TOKEN_VARIAVEL_INT {
				$$.tipo = "int";
				$$.label = gerar_label();
				add_na_tabela_simbolos($$.label, $$.tipo);
				
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| TOKEN_VARIAVEL_FLOAT {
				$$.tipo = "float";
				$$.label = gerar_label();
				add_na_tabela_simbolos($$.label, $$.tipo);
				
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| TOKEN_VARIAVEL_STRING {
				$$.tipo = "string";
				$$.label = gerar_label();
				add_na_tabela_simbolos($$.label, $$.tipo);
				
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| TOKEN_VARIAVEL_BOOL {
				$$.tipo = "bool";
				$$.label = gerar_label();
				add_na_tabela_simbolos($$.label, $$.tipo);

				char var_aux;
				if ($1.label == "true") { var_aux = '1'; }
				else if ($1.label == "false") { var_aux = '0'; }
				
				$$.traducao = "\t" + $$.label + " = " + var_aux + ";\n";
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
				add_na_tabela_simbolos($$.label, $$.tipo);

                $$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
            }
			;

%%

#include "lex.yy.c"

int yyparse();

void add_na_tabela_simbolos(string valor_nome_variavel, string valor_tipo_variavel){

	TIPO_SIMBOLO valor;
	valor.nome_variavel = valor_nome_variavel;
	valor.tipo_variavel = valor_tipo_variavel;

	tabela_simbolos.push_back(valor);
}

string gerar_label(){
	for(int i = 0; i < tabela_simbolos.size(); i++){ //caso o usuário declare uma variável "t1" por exemplo
		if(tabela_simbolos[i].nome_variavel == "t" + to_string(label_num)){
			label_num++;
		}
	}
    return "t" + std::to_string(label_num);
}

int main( int argc, char* argv[] ) {

	label_num = 1;
	yyparse();

	return 0;
}

void yyerror( string MSG )
{
	cout << MSG << endl;
	exit (0);
}