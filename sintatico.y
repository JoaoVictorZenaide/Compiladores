%{
    #include <iostream>
    #include <string>
    #include <sstream>
	#include <vector>

    #define YYSTYPE atributos

    using namespace std;

    struct atributos{
        string label;
        string traducao;
		string tipo;
    };

	int label_num;

	void add_na_tabela_simbolos(string valor_nome_variavel, string valor_tipo_variavel);

	string gerar_label();

	bool necessita_conversao_implicita_tipo(atributos dolar1, atributos dolar3);

	string tipo_resultante(atributos dolar1, atributos dolar3);

	bool possivel_realizar_casting_explicito(string tipo_token, atributos dolar4);

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
				$$.tipo = tipo_resultante($1, $3);

				if(necessita_conversao_implicita_tipo($1, $3)){
					string comando_extra;
					string label_extra = gerar_label();
					add_na_tabela_simbolos(label_extra, $$.tipo);

					comando_extra = "\t" + label_extra + " = " + '(' + $$.tipo + ") " + (($1.label != tipo_resultante($1, $3))? $1.label: $3.label) + ";\n";

					$$.label = gerar_label();
					add_na_tabela_simbolos($$.label, $$.tipo);

					$$.traducao = $1.traducao + $3.traducao + comando_extra + "\t" + $$.label + " = " + 
						(($1.label != tipo_resultante($1, $3))? label_extra + " + " + $3.label: $1.label + " + " + label_extra) + ";\n";
				}
				else{
					$$.label = gerar_label();
					add_na_tabela_simbolos($$.label, $$.tipo);

					$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " + " + $3.label + ";\n";
				}
			}
			| E '-' E {
				$$.tipo = tipo_resultante($1, $3);

				if(necessita_conversao_implicita_tipo($1, $3)){
					string comando_extra;
					string label_extra = gerar_label();
					add_na_tabela_simbolos(label_extra, $$.tipo);

					comando_extra = "\t" + label_extra + " = " + '(' + $$.tipo + ") " + (($1.label != tipo_resultante($1, $3))? $1.label: $3.label) + ";\n";

					$$.label = gerar_label();
					add_na_tabela_simbolos($$.label, $$.tipo);

					$$.traducao = $1.traducao + $3.traducao + comando_extra + "\t" + $$.label + " = " + 
						(($1.label != tipo_resultante($1, $3))? label_extra + " - " + $3.label: $1.label + " - " + label_extra) + ";\n";
				}
				else{
					$$.label = gerar_label();
					add_na_tabela_simbolos($$.label, $$.tipo);

					$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " - " + $3.label + ";\n";
				}
			}
			| E '*' E {
				$$.tipo = tipo_resultante($1, $3);

				if(necessita_conversao_implicita_tipo($1, $3)){
					string comando_extra;
					string label_extra = gerar_label();
					add_na_tabela_simbolos(label_extra, $$.tipo);

					comando_extra = "\t" + label_extra + " = " + '(' + $$.tipo + ") " + (($1.label != tipo_resultante($1, $3))? $1.label: $3.label) + ";\n";

					$$.label = gerar_label();
					add_na_tabela_simbolos($$.label, $$.tipo);

					$$.traducao = $1.traducao + $3.traducao + comando_extra + "\t" + $$.label + " = " + 
						(($1.label != tipo_resultante($1, $3))? label_extra + " * " + $3.label: $1.label + " * " + label_extra) + ";\n";
				}
				else{
					$$.label = gerar_label();
					add_na_tabela_simbolos($$.label, $$.tipo);

					$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " * " + $3.label + ";\n";
				}
			}
			| E '/' E {
				$$.tipo = tipo_resultante($1, $3);

				if(necessita_conversao_implicita_tipo($1, $3)){
					string comando_extra;
					string label_extra = gerar_label();
					add_na_tabela_simbolos(label_extra, $$.tipo);

					comando_extra = "\t" + label_extra + " = " + '(' + $$.tipo + ") " + (($1.label != tipo_resultante($1, $3))? $1.label: $3.label) + ";\n";

					$$.label = gerar_label();
					add_na_tabela_simbolos($$.label, $$.tipo);

					$$.traducao = $1.traducao + $3.traducao + comando_extra + "\t" + $$.label + " = " + 
						(($1.label != tipo_resultante($1, $3))? label_extra + " / " + $3.label: $1.label + " / " + label_extra) + ";\n";
				}
				else{
					$$.label = gerar_label();
					add_na_tabela_simbolos($$.label, $$.tipo);

					$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " / " + $3.label + ";\n";
				}
			}
			| '(' E ')' {
				$$.label = $2.label;
				$$.tipo = $2.tipo;
				$$.traducao = $2.traducao;
			}
			| '(' TOKEN_TIPO_INT ')' E {
				if(possivel_realizar_casting_explicito("int", $4)){
					$$.label = gerar_label();
					$$.tipo = "int";
					add_na_tabela_simbolos($$.label, $$.tipo);

					$$.traducao = $4.traducao + "\t" + $$.label + " = " + "(int) " + $4.label + ";\n";
				}
			}
			| '(' TOKEN_TIPO_FLOAT ')' E {
				if(possivel_realizar_casting_explicito("float", $4)){
					$$.label = gerar_label();
					$$.tipo = "float";
					add_na_tabela_simbolos($$.label, $$.tipo);

					$$.traducao = $4.traducao + "\t" + $$.label + " = " + "(float) " + $4.label + ";\n";
				}
			}
			| '(' TOKEN_TIPO_STRING ')' E {
				if(possivel_realizar_casting_explicito("string", $4)){
					$$.label = gerar_label();
					$$.tipo = "string";
					add_na_tabela_simbolos($$.label, $$.tipo);

					$$.traducao = $4.traducao + "\t" + $$.label + " = " + "(string) " + $4.label + ";\n";
				}
			}
			| '(' TOKEN_TIPO_BOOL ')' E {
				if(possivel_realizar_casting_explicito("bool", $4)){
					$$.label = gerar_label();
					$$.tipo = "bool";
					add_na_tabela_simbolos($$.label, $$.tipo);

					$$.traducao = $4.traducao + "\t" + $$.label + " = " + "(bool) " + $4.label + ";\n";
				}
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

bool necessita_conversao_implicita_tipo(atributos dolar1, atributos dolar3){
	if(dolar1.tipo != dolar3.tipo){
		if(dolar1.tipo == "int" && dolar3.tipo == "float"){
			return true;
		}
		else if(dolar1.tipo == "float" && dolar3.tipo == "int"){
			return true;
		}
		else{
			yyerror("Não é possível realizar operações com casting implícito nesses tipos!");
		}
	}
	else{
		return false;
	}
}

string tipo_resultante(atributos dolar1, atributos dolar3){
	if(dolar1.tipo == dolar3.tipo){
		if(dolar1.tipo == "int"){
			return "int";
		}
		else if(dolar1.tipo == "float"){
			return "float";
		}
		else if(dolar1.tipo == "bool"){
			return "bool";
		}
		else if(dolar1.tipo == "string"){
			return "string";
		}
	}
	else if(dolar1.tipo != dolar3.tipo){
		if(dolar1.tipo == "int" && dolar3.tipo == "float"){
			return "float";
		}
		else if(dolar1.tipo == "float" && dolar3.tipo == "int"){
			return "float";
		}
		else{
			yyerror("Não é possível realizar operações com esses tipos!");
		}
	}
}

bool possivel_realizar_casting_explicito(string tipo_token, atributos dolar4){
	if(dolar4.tipo == tipo_token){
		return true;
	}
	else if(dolar4.tipo != tipo_token) {
		if((dolar4.tipo == "int" && tipo_token == "float") || (dolar4.tipo == "float" && tipo_token == "int")){
			return true;
		}
		else{
			yyerror("Não é possível efetuar casting explícito com esses tipos!");
		}
	}
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