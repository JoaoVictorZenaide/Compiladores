%{
    #include <iostream>
    #include <string>
    #include <sstream>
	#include <vector>

    #define YYSTYPE atributos

    using namespace std;

	int label_num;

    struct atributos{
        string label;
        string traducao;
		string tipo;
    };

	typedef struct{
		string nome_variavel_real;
		string nome_variavel_temporaria;
		string tipo_variavel;
	} TIPO_SIMBOLO;

	vector<TIPO_SIMBOLO> tabela_simbolos;

	void add_na_tabela_simbolos(string nome_variavel_real, string nome_variavel_temporaria, string tipo_variavel);

	string gerar_label();

	TIPO_SIMBOLO buscar_na_tabela_simbolos(atributos a1);

	bool necessario_conversao_implicita_tipo(string tipo1, string tipo2);

	string tipo_resultante(atributos dolar1, atributos dolar3);

	bool possivel_realizar_casting_explicito(string tipo_token, atributos dolar4);

    int yylex(void);
    void yyerror(string);
%}

%token TOKEN_TIPO_INT
%token TOKEN_TIPO_FLOAT
%token TOKEN_TIPO_STRING
%token TOKEN_TIPO_BOOL
%token TOKEN_E_LOGICO
%token TOKEN_OU_LOGICO
%token TOKEN_DIFERENTE
%token TOKEN_IGUAL_IGUAL
%token TOKEN_MENOR_IGUAL
%token TOKEN_MAIOR_IGUAL
%token TOKEN_VARIAVEL_INT
%token TOKEN_VARIAVEL_FLOAT
%token TOKEN_VARIAVEL_STRING
%token TOKEN_VARIAVEL_BOOL
%token TOKEN_ID
%token TOKEN_MAIN
%token TOKEN_FUNC 
%token TOKEN_NOVA_LINHA
%token TOKEN_FIM
%token TOKEN_ERROR

%start S

%right '='
%left LOGICO TOKEN_E_LOGICO TOKEN_OU_LOGICO
%left RELACIONAL TOKEN_DIFERENTE TOKEN_IGUAL_IGUAL TOKEN_MENOR_IGUAL TOKEN_MAIOR_IGUAL
%nonassoc CAST
%left '<' '>'
%left '+' '-'
%left '*' '/'
%right '!'

%%

S 			: TOKEN_FUNC TOKEN_MAIN '(' ')' BLOCO {

				string declaracoes = "";
				for(int i = 0; i < tabela_simbolos.size(); i++){
					declaracoes = declaracoes + "\t" + tabela_simbolos[i].tipo_variavel + " " + tabela_simbolos[i].nome_variavel_temporaria + ";\n";
				}

				cout << "/*Compilador SLA*/\n" << "#include <iostream>\n#include <string.h>\n#include <stdio.h>\nint main(void){\n\n" << declaracoes << "\n" <<$5.traducao << "\n\treturn 0;\n}" << endl;
				
				for(int i = 0; i < tabela_simbolos.size(); i++){ //imprimir o que tem na tabela de simbolos 
					cout << "Nome real: " << tabela_simbolos[i].nome_variavel_real
						<< ", Nome temporario: " << tabela_simbolos[i].nome_variavel_temporaria 
						<< ", Tipo: " << tabela_simbolos[i].tipo_variavel << endl;
				}
			}
			;

NOVA_LINHA	: NOVA_LINHA TOKEN_NOVA_LINHA
			| TOKEN_NOVA_LINHA
			;

BLOCO		: '{' NOVA_LINHA COMANDOS '}' {
				$$.traducao = $3.traducao;
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

COMANDO 	: E NOVA_LINHA
			| TOKEN_TIPO_INT TOKEN_ID NOVA_LINHA {
				$$.label = "";
				$$.tipo = "";
				$$.traducao = "";

				add_na_tabela_simbolos($2.label, gerar_label(), $1.label);
			}
			| TOKEN_TIPO_FLOAT TOKEN_ID NOVA_LINHA {
				$$.label = "";
				$$.tipo = "";
				$$.traducao = "";

				add_na_tabela_simbolos($2.label, gerar_label(), $1.label);
			}
			| TOKEN_TIPO_STRING TOKEN_ID NOVA_LINHA {
				$$.label = "";
				$$.tipo = "";
				$$.traducao = "";

				add_na_tabela_simbolos($2.label, gerar_label(), $1.label);
			}
			| TOKEN_TIPO_BOOL TOKEN_ID NOVA_LINHA {
				$$.label = "";
				$$.tipo = "";
				$$.traducao = "";

				add_na_tabela_simbolos($2.label, gerar_label(), $1.label);
			}
			;

E 			: E '+' E {
				$$.tipo = tipo_resultante($1, $3);

				if(necessario_conversao_implicita_tipo($1.tipo, $3.tipo)){
					string comando_extra;
					string label_extra = gerar_label();
					add_na_tabela_simbolos("", label_extra, $$.tipo);

					comando_extra = "\t" + label_extra + " = " + '(' + $$.tipo + ") " + (($1.tipo != tipo_resultante($1, $3))? $1.label: $3.label) + ";\n";

					$$.label = gerar_label();
					add_na_tabela_simbolos("", $$.label, $$.tipo);

					$$.traducao = $1.traducao + $3.traducao + comando_extra + "\t" + $$.label + " = " + 
						(($1.tipo != tipo_resultante($1, $3))? label_extra + " + " + $3.label: $1.label + " + " + label_extra) + ";\n";
				}
				else{
					$$.label = gerar_label();
					add_na_tabela_simbolos("", $$.label, $$.tipo);

					$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " + " + $3.label + ";\n";
				}
			}
			| E '-' E {
				$$.tipo = tipo_resultante($1, $3);

				if(necessario_conversao_implicita_tipo($1.tipo, $3.tipo)){
					string comando_extra;
					string label_extra = gerar_label();
					add_na_tabela_simbolos("", label_extra, $$.tipo);

					comando_extra = "\t" + label_extra + " = " + '(' + $$.tipo + ") " + (($1.tipo != tipo_resultante($1, $3))? $1.label: $3.label) + ";\n";

					$$.label = gerar_label();
					add_na_tabela_simbolos("", $$.label, $$.tipo);

					$$.traducao = $1.traducao + $3.traducao + comando_extra + "\t" + $$.label + " = " + 
						(($1.tipo != tipo_resultante($1, $3))? label_extra + " - " + $3.label: $1.label + " - " + label_extra) + ";\n";
				}
				else{
					$$.label = gerar_label();
					add_na_tabela_simbolos("", $$.label, $$.tipo);

					$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " - " + $3.label + ";\n";
				}
			}
			| E '*' E {
				$$.tipo = tipo_resultante($1, $3);

				if(necessario_conversao_implicita_tipo($1.tipo, $3.tipo)){
					string comando_extra;
					string label_extra = gerar_label();
					add_na_tabela_simbolos("", label_extra, $$.tipo);

					comando_extra = "\t" + label_extra + " = " + '(' + $$.tipo + ") " + (($1.tipo != tipo_resultante($1, $3))? $1.label: $3.label) + ";\n";

					$$.label = gerar_label();
					add_na_tabela_simbolos("", $$.label, $$.tipo);

					$$.traducao = $1.traducao + $3.traducao + comando_extra + "\t" + $$.label + " = " + 
						(($1.tipo != tipo_resultante($1, $3))? label_extra + " * " + $3.label: $1.label + " * " + label_extra) + ";\n";
				}
				else{
					$$.label = gerar_label();
					add_na_tabela_simbolos("", $$.label, $$.tipo);

					$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " * " + $3.label + ";\n";
				}
			}
			| E '/' E {
				$$.tipo = tipo_resultante($1, $3);

				if(necessario_conversao_implicita_tipo($1.tipo, $3.tipo)){
					string comando_extra;
					string label_extra = gerar_label();
					add_na_tabela_simbolos("", label_extra, $$.tipo);

					comando_extra = "\t" + label_extra + " = " + '(' + $$.tipo + ") " + (($1.tipo != tipo_resultante($1, $3))? $1.label: $3.label) + ";\n";

					$$.label = gerar_label();
					add_na_tabela_simbolos("", $$.label, $$.tipo);

					$$.traducao = $1.traducao + $3.traducao + comando_extra + "\t" + $$.label + " = " + 
						(($1.tipo != tipo_resultante($1, $3))? label_extra + " / " + $3.label: $1.label + " / " + label_extra) + ";\n";
				}
				else{
					$$.label = gerar_label();
					add_na_tabela_simbolos("", $$.label, $$.tipo);

					$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " / " + $3.label + ";\n";
				}
			}
			| TOKEN_ID '=' E {

				TIPO_SIMBOLO valor_dolar1 = buscar_na_tabela_simbolos($1);

				if(necessario_conversao_implicita_tipo(valor_dolar1.tipo_variavel, $3.tipo)){
					$$.traducao = $1.traducao + $3.traducao + "\t" + valor_dolar1.nome_variavel_temporaria + " = (" + valor_dolar1.tipo_variavel + ") " + 
						$3.label + ";\n";
				}
				else {
					$$.traducao = $1.traducao + $3.traducao + "\t" + valor_dolar1.nome_variavel_temporaria + " = " + $3.label + ";\n";
				}
			}
			| '(' E ')' {
				$$.label = $2.label;
				$$.tipo = $2.tipo;
				$$.traducao = $2.traducao;
			}
			| E '<' E {
				$$.tipo = "int";
				$$.label = gerar_label();
				add_na_tabela_simbolos("", $$.label, $$.tipo);

				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " < " + $3.label + ";\n";
			}
			| E '>' E {
				$$.tipo = "int";
				$$.label = gerar_label();
				add_na_tabela_simbolos("", $$.label, $$.tipo);

				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " > " + $3.label + ";\n";
			}
			| '!' E {
				$$.tipo = "int";
				$$.label = gerar_label();
				add_na_tabela_simbolos("", $$.label, $$.tipo);

				$$.traducao = $2.traducao + "\t" + $$.label + " = " + "!" + $2.label + ";\n";
			}
			| E TOKEN_MENOR_IGUAL E {
				$$.tipo = "int";
				$$.label = gerar_label();
				add_na_tabela_simbolos("", $$.label, $$.tipo);

				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " <= " + $3.label + ";\n";
			}
			| E TOKEN_MAIOR_IGUAL E {
				$$.tipo = "int";
				$$.label = gerar_label();
				add_na_tabela_simbolos("", $$.label, $$.tipo);

				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " >= " + $3.label + ";\n";
			}
			| E TOKEN_IGUAL_IGUAL E {
				$$.tipo = "int";
				$$.label = gerar_label();
				add_na_tabela_simbolos("", $$.label, $$.tipo);

				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " == " + $3.label + ";\n";
			}
			| E TOKEN_DIFERENTE E {
				$$.tipo = "int";
				$$.label = gerar_label();
				add_na_tabela_simbolos("", $$.label, $$.tipo);

				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " != " + $3.label + ";\n";
			}
			| E TOKEN_OU_LOGICO E {
				$$.tipo = "int";
				$$.label = gerar_label();
				add_na_tabela_simbolos("", $$.label, $$.tipo);

				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " || " + $3.label + ";\n";
			}
			| E TOKEN_E_LOGICO E {
				$$.tipo = "int";
				$$.label = gerar_label();
				add_na_tabela_simbolos("", $$.label, $$.tipo);

				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " && " + $3.label + ";\n";
			}
			| TOKEN_TIPO_INT '(' E ')' %prec CAST {
				if(possivel_realizar_casting_explicito("int", $3)){
					$$.label = gerar_label();
					$$.tipo = "int";
					add_na_tabela_simbolos("", $$.label, $$.tipo);

					$$.traducao = $3.traducao + "\t" + $$.label + " = " + "(int) " + $3.label + ";\n";
				}
			}
			| TOKEN_TIPO_FLOAT '(' E ')' %prec CAST {
				if(possivel_realizar_casting_explicito("float", $3)){
					$$.label = gerar_label();
					$$.tipo = "float";
					add_na_tabela_simbolos("", $$.label, $$.tipo);

					$$.traducao = $3.traducao + "\t" + $$.label + " = " + "(float) " + $3.label + ";\n";
				}
			}
			| TOKEN_VARIAVEL_INT {
				$$.label = gerar_label();
				$$.tipo = "int";
				add_na_tabela_simbolos("", $$.label, $$.tipo);
				
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| TOKEN_VARIAVEL_FLOAT {
				$$.label = gerar_label();
				$$.tipo = "float";
				add_na_tabela_simbolos("", $$.label, $$.tipo);
				
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| TOKEN_VARIAVEL_STRING {
				$$.label = gerar_label();
				$$.tipo = "string";
				add_na_tabela_simbolos("", $$.label, $$.tipo);
				
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| TOKEN_VARIAVEL_BOOL {
				string var_aux;
				if ($1.label == "true") { var_aux = "1"; }
				else if ($1.label == "false") { var_aux = "0"; }

				$$.label = gerar_label();
				$$.tipo = "int";
				add_na_tabela_simbolos("", $$.label, $$.tipo);
				
				$$.traducao = "\t" + $$.label + " = " + var_aux + ";\n";
			}
			| TOKEN_ID { //eu só sou chamado quando acontece alguma expressão do tipo: E = TOKEN_ID + E
				bool encontrado = false;
				TIPO_SIMBOLO variavel;
				for(int i = 0; i < tabela_simbolos.size(); i++){
					if(tabela_simbolos[i].nome_variavel_real == $1.label){
						variavel = tabela_simbolos[i];
						encontrado = true;
					}
				}
				if(!encontrado){
					yyerror("Voce nao declarou essa variavel!");
				}
				$$.tipo = variavel.tipo_variavel;
                $$.label = variavel.nome_variavel_temporaria;

                $$.traducao = "";
            }
			;

%%

#include "lex.yy.c"

int yyparse();

void add_na_tabela_simbolos(string nome_variavel_real, string nome_variavel_temporaria, string tipo_variavel){

	for(int i = 0; i < tabela_simbolos.size(); i++){ //caso o usuário tente declarar a mesma variável
		if(nome_variavel_real != "" && tabela_simbolos[i].nome_variavel_real == nome_variavel_real){
			yyerror("Não é possível declarar a mesma variável duas vezes!");
		}
	}

	TIPO_SIMBOLO valor;
	valor.nome_variavel_real = nome_variavel_real;
	valor.nome_variavel_temporaria = nome_variavel_temporaria;

	if(tipo_variavel == "bool"){
		valor.tipo_variavel = "int";
	}
	else{
		valor.tipo_variavel = tipo_variavel;
	}

	tabela_simbolos.push_back(valor);
}

string gerar_label(){
	for(int i = 0; i < tabela_simbolos.size(); i++){ //caso o usuário declare uma variável "t1" por exemplo
		if(tabela_simbolos[i].nome_variavel_temporaria == "t" + to_string(label_num)){
			label_num++;
		}
	}
    return "t" + std::to_string(label_num);
}

TIPO_SIMBOLO buscar_na_tabela_simbolos(atributos a1){
	for(int i = 0; i < tabela_simbolos.size(); i++){
		if(a1.label == tabela_simbolos[i].nome_variavel_real){
			return tabela_simbolos[i];
		}
	}
	yyerror("Voce nao declarou essa variavel!");
}

bool necessario_conversao_implicita_tipo(string tipo1, string tipo2){
	if(tipo1 != tipo2){
		if(tipo1 == "int" && tipo2 == "float"){
			return true;
		}
		else if(tipo1 == "float" && tipo2 == "int"){
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
		/*
		else if(dolar1.tipo == "bool"){ //não tem tipo bool no código intermediário
			return "bool";
		}
		*/
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
	cout << "erro na linha " << yylineno << ": " << MSG << endl;
	exit (0);
}