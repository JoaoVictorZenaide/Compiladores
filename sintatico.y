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

//declarações tokens:

%token TOKEN_TIPO_INT
%token TOKEN_TIPO_FLOAT
%token TOKEN_TIPO_STRING
%token TOKEN_TIPO_BOOL

%token TOKEN_OPERADOR_MAIS_MENOS
%token TOKEN_OPERADOR_VEZES_DIVIDIDO
%token TOKEN_OPERADOR_RESTO

%token TOKEN_OPERADOR_RELACIONAL
%token TOKEN_OPERADOR_E_OU
%token TOKEN_OPERADOR_MENOR_MAIOR
%token TOKEN_OPERADOR_NEGADO
%token TOKEN_OPERADOR_IGUAL

%token TOKEN_VARIAVEL_INT
%token TOKEN_VARIAVEL_FLOAT
%token TOKEN_VARIAVEL_STRING
%token TOKEN_VARIAVEL_BOOL

%token TOKEN_ID
%token TOKEN_MAIN
%token TOKEN_FUNC 
%token TOKEN_NOVA_LINHA

//precedências:

%right TOKEN_OPERADOR_IGUAL 									// =
%left TOKEN_OPERADOR_E_OU										// && ||
%left TOKEN_OPERADOR_RELACIONAL TOKEN_OPERADOR_MENOR_MAIOR 		// < > <= >= != ==
%nonassoc CAST													// precedência para o casting
%left TOKEN_OPERADOR_MAIS_MENOS									// + -
%left TOKEN_OPERADOR_RESTO										// %
%left TOKEN_OPERADOR_VEZES_DIVIDIDO								// * /
%right unario													// + e - unario 
%right TOKEN_OPERADOR_NEGADO									// !

//não terminal inicial S

%start S

%%

S 			: TOKEN_FUNC TOKEN_MAIN '(' ')' BLOCO {

				string declaracoes = "";
				for(int i = 0; i < tabela_simbolos.size(); i++){
					string tipo_em_c = tabela_simbolos[i].tipo_variavel; //impede bool no código intermediário

    				if (tipo_em_c == "bool") { tipo_em_c = "int"; }

					declaracoes = declaracoes + "\t" + tipo_em_c + " " + tabela_simbolos[i].nome_variavel_temporaria + ";\n";
				}

				cout << "/*Compilador jpl*/\n" << "#include <iostream>\n#include <string.h>\n#include <stdio.h>\nint main(void){\n\n" << declaracoes << "\n" <<$5.traducao << "\n\treturn 0;\n}" << endl;
				
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

E 			: E TOKEN_OPERADOR_MAIS_MENOS E {
				$$.tipo = tipo_resultante($1, $3);

				if(necessario_conversao_implicita_tipo($1.tipo, $3.tipo)){
					string comando_extra;
					string label_extra = gerar_label();
					add_na_tabela_simbolos("", label_extra, $$.tipo);

					comando_extra = "\t" + label_extra + " = " + '(' + $$.tipo + ") " + (($1.tipo != tipo_resultante($1, $3))? $1.label: $3.label) + ";\n";

					$$.label = gerar_label();
					add_na_tabela_simbolos("", $$.label, $$.tipo);

					$$.traducao = $1.traducao + $3.traducao + comando_extra + "\t" + $$.label + " = " + 
						(($1.tipo != tipo_resultante($1, $3))? label_extra + " " + $2.label + " " + $3.label: $1.label + " " + $2.label + " " + label_extra) + ";\n";
				}
				else{
					$$.label = gerar_label();
					add_na_tabela_simbolos("", $$.label, $$.tipo);

					$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " " + $2.label + " " + $3.label + ";\n";
				}
			}
			| E TOKEN_OPERADOR_VEZES_DIVIDIDO E {
				$$.tipo = tipo_resultante($1, $3);

				if(necessario_conversao_implicita_tipo($1.tipo, $3.tipo)){
					string comando_extra;
					string label_extra = gerar_label();
					add_na_tabela_simbolos("", label_extra, $$.tipo);

					comando_extra = "\t" + label_extra + " = " + '(' + $$.tipo + ") " + (($1.tipo != tipo_resultante($1, $3))? $1.label: $3.label) + ";\n";

					$$.label = gerar_label();
					add_na_tabela_simbolos("", $$.label, $$.tipo);

					$$.traducao = $1.traducao + $3.traducao + comando_extra + "\t" + $$.label + " = " + 
						(($1.tipo != tipo_resultante($1, $3))? label_extra + " " + $2.label + " " + $3.label: $1.label + " " + $2.label + " " + label_extra) + ";\n";
				}
				else{
					$$.label = gerar_label();
					add_na_tabela_simbolos("", $$.label, $$.tipo);

					$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " " + $2.label + " " + $3.label + ";\n";
				}
			}
			| TOKEN_OPERADOR_MAIS_MENOS E %prec unario {
				if($2.tipo == "float" || $2.tipo == "int"){
					$$.label = gerar_label();
					$$.tipo = $2.tipo;
					add_na_tabela_simbolos("", $$.label, $$.tipo);

					$$.traducao = $2.traducao + "\t" + $$.label + " = " + $1.label + $2.label + ";\n";
				}
				else{
					yyerror("operação com tipo inválido!");
				}
			}
			| E TOKEN_OPERADOR_RESTO E {
				if($1.tipo == "int" && $3.tipo == "int"){
					$$.label = gerar_label();
					$$.tipo = "int";
					add_na_tabela_simbolos("", $$.label, $$.tipo);

					$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " " + $2.label + " " + $3.label + ";\n";
				}
				else{
					yyerror("para realizar o modulo os numeros precisam ser int!");
				}
			}
			| '(' E ')' {
				$$.label = $2.label;
				$$.tipo = $2.tipo;
				$$.traducao = $2.traducao;
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
			| TOKEN_ID TOKEN_OPERADOR_IGUAL E {

				TIPO_SIMBOLO valor_dolar1 = buscar_na_tabela_simbolos($1);

				if(necessario_conversao_implicita_tipo(valor_dolar1.tipo_variavel, $3.tipo)){
					$$.traducao = $1.traducao + $3.traducao + "\t" + valor_dolar1.nome_variavel_temporaria + " = (" + valor_dolar1.tipo_variavel + ") " + 
						$3.label + ";\n";
				}
				else {
					$$.traducao = $1.traducao + $3.traducao + "\t" + valor_dolar1.nome_variavel_temporaria + " = " + $3.label + ";\n";
				}
			}
			| E TOKEN_OPERADOR_MENOR_MAIOR E {
				$$.tipo = "bool";

				string tipo_conversao = tipo_resultante($1, $3);

				if(necessario_conversao_implicita_tipo($1.tipo, $3.tipo)){
					string comando_extra;
					string label_extra = gerar_label();
					add_na_tabela_simbolos("", label_extra, tipo_conversao);

					comando_extra = "\t" + label_extra + " = " + '(' + tipo_conversao + ") " + (($1.tipo != tipo_conversao)? $1.label: $3.label) + ";\n";

					$$.label = gerar_label();
					add_na_tabela_simbolos("", $$.label, tipo_conversao);

					$$.traducao = $1.traducao + $3.traducao + comando_extra + "\t" + $$.label + " = " + 
						(($1.tipo != tipo_conversao)? label_extra + " " + $2.label + " " + $3.label: $1.label + " " + $2.label + " " + label_extra) + ";\n";
				}
				else{
					$$.label = gerar_label();
					add_na_tabela_simbolos("", $$.label, $$.tipo);

					$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " " + $2.label + " " + $3.label + ";\n";
				}
			}
			| E TOKEN_OPERADOR_RELACIONAL E {
				$$.tipo = "bool";

				string tipo_conversao = tipo_resultante($1, $3);

				if(necessario_conversao_implicita_tipo($1.tipo, $3.tipo)){
					string comando_extra;
					string label_extra = gerar_label();
					add_na_tabela_simbolos("", label_extra, tipo_conversao);

					comando_extra = "\t" + label_extra + " = " + '(' + tipo_conversao + ") " + (($1.tipo != tipo_conversao)? $1.label: $3.label) + ";\n";

					$$.label = gerar_label();
					add_na_tabela_simbolos("", $$.label, tipo_conversao);

					$$.traducao = $1.traducao + $3.traducao + comando_extra + "\t" + $$.label + " = " + 
						(($1.tipo != tipo_conversao)? label_extra + " " + $2.label + " " + $3.label: $1.label + " " + $2.label + " " + label_extra) + ";\n";
				}
				else{
					$$.label = gerar_label();
					add_na_tabela_simbolos("", $$.label, $$.tipo);

					$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " " + $2.label + " " + $3.label + ";\n";
				}
			}
			| E TOKEN_OPERADOR_E_OU E {
				$$.tipo = "bool";

				string tipo_conversao = tipo_resultante($1, $3);

				if(necessario_conversao_implicita_tipo($1.tipo, $3.tipo)){
					string comando_extra;
					string label_extra = gerar_label();
					add_na_tabela_simbolos("", label_extra, tipo_conversao);

					comando_extra = "\t" + label_extra + " = " + '(' + tipo_conversao + ") " + (($1.tipo != tipo_conversao)? $1.label: $3.label) + ";\n";

					$$.label = gerar_label();
					add_na_tabela_simbolos("", $$.label, tipo_conversao);

					$$.traducao = $1.traducao + $3.traducao + comando_extra + "\t" + $$.label + " = " + 
						(($1.tipo != tipo_conversao)? label_extra + " " + $2.label + " " + $3.label: $1.label + " " + $2.label + " " + label_extra) + ";\n";
				}
				else{
					$$.label = gerar_label();
					add_na_tabela_simbolos("", $$.label, $$.tipo);

					$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " " + $2.label + " " + $3.label + ";\n";
				}
			}
			| TOKEN_OPERADOR_NEGADO E {
				$$.tipo = "bool";
				$$.label = gerar_label();
				add_na_tabela_simbolos("", $$.label, $$.tipo);

				$$.traducao = $2.traducao + "\t" + $$.label + " = " + $1.label + $2.label + ";\n";
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
				$$.tipo = "bool";
				add_na_tabela_simbolos("", $$.label, "bool");
				
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
	valor.tipo_variavel = tipo_variavel;

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

	bool erro = 0;

	if(tipo1 == "int" && tipo2 == "int"){ return false; }
	else if(tipo1 == "int" && tipo2 == "float"){ return true; }
	else if(tipo1 == "int" && tipo2 == "string"){ erro = 1; }
	else if(tipo1 == "int" && tipo2 == "bool"){ erro = 1; }

	else if(tipo1 == "float" && tipo2 == "int"){ return true; }
	else if(tipo1 == "float" && tipo2 == "float"){ return false; }
	else if(tipo1 == "float" && tipo2 == "string"){ erro = 1; }
	else if(tipo1 == "float" && tipo2 == "bool"){ erro = 1; }

	else if(tipo1 == "string" && tipo2 == "int"){ erro = 1; }
	else if(tipo1 == "string" && tipo2 == "float"){ erro = 1; }
	else if(tipo1 == "string" && tipo2 == "string"){ return false; }
	else if(tipo1 == "string" && tipo2 == "bool"){ erro = 1; }

	else if(tipo1 == "bool" && tipo2 == "int"){ erro = 1; }
	else if(tipo1 == "bool" && tipo2 == "float"){ erro = 1; }
	else if(tipo1 == "bool" && tipo2 == "string"){ erro = 1; }
	else if(tipo1 == "bool" && tipo2 == "bool"){ return false; }

	if(erro == 1){
		yyerror("Não é possível realizar operações com casting implícito nesses tipos!");
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
		else if(dolar1.tipo == "string"){
			return "string";
		}
		else if(dolar1.tipo == "bool"){
			return "bool";
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