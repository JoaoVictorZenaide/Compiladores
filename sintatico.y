%{
    #include <iostream>
    #include <string>
	#include <cstring>
    #include <sstream>
	#include <vector>

    #define YYSTYPE atributos

    using namespace std;

	int label_num;
	int rotulo_num;

	int escopo_atual;

    struct atributos{
        string label;
        string traducao;
		string tipo;
		string tamanho_vetor; //no caso de ser um vetor
		string valor_armazenado;
    };

	typedef struct{
		string nome_variavel_real;
		string nome_variavel_temporaria;
		string tipo_variavel;
		string tamanho_variavel_vetor; //no caso de ser um vetor
		string valor_variavel_armazenado;
	} TIPO_SIMBOLO;

	vector<vector<TIPO_SIMBOLO>> pilha_tabela_simbolos;
	vector<vector<TIPO_SIMBOLO>> memoria_pilha_tabela_simbolos;

	vector<string> pilha_rotulo_fim;
	vector<string> pilha_rotulo_meio;
	vector<string> pilha_rotulo_inicio;

	string rotulo_loop_inicio_tmp;
	string rotulo_loop_meio_tmp;
	string rotulo_loop_fim_tmp;

	void add_na_tabela_simbolos(int escopo, string nome_variavel_real, string nome_variavel_temporaria, string tipo_variavel, 
			string tamanho_variavel_vetor, string valor_variavel_armazenado);

	string gerar_label();

	string gerar_rotulo();

	TIPO_SIMBOLO buscar_na_tabela_simbolos(int escopo, atributos a1);

	void mudar_tamanho_vetor_na_pilha_tabela_simbolos(int escopo, atributos a1, atributos a2);

	void mudar_valor_armazenado_na_pilha_tabela_simbolos(int escopo, atributos a1, atributos a2);

	bool necessario_conversao_implicita_tipo(string tipo1, string tipo2);

	string tipo_resultante(atributos dolar1, atributos dolar3);

	bool possivel_realizar_casting_explicito(string tipo_token, atributos dolar4);

	int strlen_da_shopee(string a);

    int yylex(void);
	
    void yyerror(string);
%}

//declarações tokens:

%token TOKEN_TIPO_INT
%token TOKEN_TIPO_FLOAT
%token TOKEN_TIPO_STRING
%token TOKEN_TIPO_BOOL

%token TOKEN_IF
%token TOKEN_ELSE
%token TOKEN_WHILE
%token TOKEN_DO
%token TOKEN_FOR
%token TOKEN_SWITCH
%token TOKEN_BREAK
%token TOKEN_CONTINUE

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
%token TOKEN_INPUT
%token TOKEN_OUTPUT

//precedências:

%right TOKEN_OPERADOR_IGUAL 									// =
%left TOKEN_OPERADOR_E_OU										// && ||
%left TOKEN_OPERADOR_RELACIONAL TOKEN_OPERADOR_MENOR_MAIOR 		// < > <= >= != ==
%nonassoc CAST													// precedência para o casting
%left '[' ']'													// precedência para x[y]
%left TOKEN_OPERADOR_MAIS_MENOS									// + -
%left TOKEN_OPERADOR_RESTO										// %
%left TOKEN_OPERADOR_VEZES_DIVIDIDO								// * /
%right unario													// + e - unario 
%right TOKEN_OPERADOR_NEGADO									// !

//não terminal inicial S

%start S

%%

S 			: COMANDOS TOKEN_FUNC TOKEN_MAIN '(' ')' BLOCO {

				string declaracoes = "";

				for(int i = 0; i < memoria_pilha_tabela_simbolos.size(); i++){

					for(int j = 0; j < memoria_pilha_tabela_simbolos[i].size(); j++){

						string tipo_em_jpl = memoria_pilha_tabela_simbolos[i][j].tipo_variavel; //impede bool no código intermediário
						string tipo_em_c;
						string complemento_vetor = "";

    					if (tipo_em_jpl == "bool") { 
							tipo_em_c = "int"; 
						}
						else if(tipo_em_jpl == "string"){
							tipo_em_c = "char"; 
						}
						else{
							tipo_em_c = tipo_em_jpl;
						}

						if(memoria_pilha_tabela_simbolos[i][j].tamanho_variavel_vetor != ""){
							complemento_vetor = "[" + std::to_string(atoi(memoria_pilha_tabela_simbolos[i][j].tamanho_variavel_vetor.c_str()) + 1) + "]";
						}

						declaracoes = declaracoes + "\t" + tipo_em_c + " " + memoria_pilha_tabela_simbolos[i][j].nome_variavel_temporaria + complemento_vetor + ";\n";
					}
				}
				cout << "\n/*Compilador jpl*/\n" << "#include <iostream>\n\nint main(void){\n\n" << declaracoes << "\n" <<$6.traducao << "\n\treturn 0;\n}" << endl;

				for(int i = 0 ; i < memoria_pilha_tabela_simbolos.size(); i++){

					cout << "\nEscopo " << i << ":\n";

					for(int j = 0; j < memoria_pilha_tabela_simbolos[i].size(); j++){ //imprimir o que tem na tabela de simbolos 
						cout << "Nome real: " << memoria_pilha_tabela_simbolos[i][j].nome_variavel_real
							<< ", Nome temp: " << memoria_pilha_tabela_simbolos[i][j].nome_variavel_temporaria 
							<< ", Tipo: " << memoria_pilha_tabela_simbolos[i][j].tipo_variavel
							<< ", Tam(vetor): " << memoria_pilha_tabela_simbolos[i][j].tamanho_variavel_vetor 
							<< ", Val: " << memoria_pilha_tabela_simbolos[i][j].valor_variavel_armazenado << endl;
					}
				}
			}
			;

NOVA_LINHA	: NOVA_LINHA TOKEN_NOVA_LINHA
			| TOKEN_NOVA_LINHA
			;

BLOCO_LOOP	: '{' { 	// a mesma coisa que BLOCO: '{' NOVA_LINHA COMANDOS '}' 

				cout << "inicio producao bloco" << endl;

				rotulo_loop_inicio_tmp = gerar_rotulo();
				rotulo_loop_meio_tmp = gerar_rotulo();
				rotulo_loop_fim_tmp = gerar_rotulo();

				pilha_rotulo_inicio.push_back(rotulo_loop_inicio_tmp);
				pilha_rotulo_meio.push_back(rotulo_loop_meio_tmp);
				pilha_rotulo_fim.push_back(rotulo_loop_fim_tmp);

				cout << pilha_rotulo_fim.back() << "a2" << rotulo_loop_inicio_tmp << endl;
				
				escopo_atual++;
				pilha_tabela_simbolos.push_back(vector<TIPO_SIMBOLO>());
				memoria_pilha_tabela_simbolos.push_back(vector<TIPO_SIMBOLO>());

			} NOVA_LINHA COMANDOS '}' {

				escopo_atual--;
				pilha_tabela_simbolos.pop_back();

				$$.traducao = $4.traducao;

				cout << "fim producao bloco" << endl;
			}
			;

BLOCO		: '{' { 	// a mesma coisa que BLOCO: '{' NOVA_LINHA COMANDOS '}' 

				escopo_atual++;
				pilha_tabela_simbolos.push_back(vector<TIPO_SIMBOLO>());
				memoria_pilha_tabela_simbolos.push_back(vector<TIPO_SIMBOLO>());

			} NOVA_LINHA COMANDOS '}' {

				escopo_atual--;
				pilha_tabela_simbolos.pop_back();

				$$.traducao = $4.traducao;

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
				$$.tamanho_vetor = "";
				$$.valor_armazenado = "";

				add_na_tabela_simbolos(escopo_atual, $2.label, gerar_label(), $1.label, $$.tamanho_vetor, $$.valor_armazenado);
			}
			| TOKEN_TIPO_FLOAT TOKEN_ID NOVA_LINHA {
				$$.label = "";
				$$.tipo = "";
				$$.traducao = "";
				$$.tamanho_vetor = "";
				$$.valor_armazenado = "";

				add_na_tabela_simbolos(escopo_atual, $2.label, gerar_label(), $1.label, $$.tamanho_vetor, $$.valor_armazenado);
			}
			| TOKEN_TIPO_STRING TOKEN_ID NOVA_LINHA {
				$$.label = "";
				$$.tipo = "";
				$$.traducao = "";
				$$.tamanho_vetor = "";
				$$.valor_armazenado = "";

				add_na_tabela_simbolos(escopo_atual, $2.label, gerar_label(), $1.label, $$.tamanho_vetor, $$.valor_armazenado);
			}
			| TOKEN_TIPO_BOOL TOKEN_ID NOVA_LINHA {
				$$.label = "";
				$$.tipo = "";
				$$.traducao = "";
				$$.tamanho_vetor = "";
				$$.valor_armazenado = "";

				add_na_tabela_simbolos(escopo_atual, $2.label, gerar_label(), $1.label, $$.tamanho_vetor, $$.valor_armazenado);
			}
			| TOKEN_IF '(' E ')' BLOCO NOVA_LINHA {
				if($3.tipo == "bool"){
					$$.label = "";
					$$.tipo = "";
					$$.tamanho_vetor = "";
					$$.valor_armazenado = "";

					cout << "if" << endl;
					
					string rotulo_if = gerar_rotulo();
					string rotulo_fim = gerar_rotulo();

					$$.traducao = $3.traducao + 
						"\t" + "if(" + $3.label + ") goto " + rotulo_if + ";\n" + 
						"\t" + "goto " + rotulo_fim + ";\n" +
						"\t" + rotulo_if + ":\n" + 
						$5.traducao + 
						"\t" + rotulo_fim + ":\n";
				}
			}
			| TOKEN_IF '(' E ')' BLOCO NOVA_LINHA TOKEN_ELSE BLOCO NOVA_LINHA {
				if($3.tipo == "bool"){
					$$.label = "";
					$$.tipo = "";
					$$.tamanho_vetor = "";
					$$.valor_armazenado = "";
					
					string rotulo_if = gerar_rotulo();
					string rotulo_else = gerar_rotulo();
					string rotulo_fim = gerar_rotulo();

					$$.traducao = $3.traducao + "\t" + "if(" + $3.label + ") goto " + rotulo_if + ";\n" + 
						"\t" + "else goto " + rotulo_else + ";\n" + 
						"\t" + rotulo_if + ":\n" + 
						$5.traducao + "\t" + "goto " + rotulo_fim + ";\n" +
						"\t" + rotulo_else + ":\n" + 
						$8.traducao + "\t" + "goto " + rotulo_fim + ";\n" +
						"\t" + rotulo_fim + ":\n";
				}
			}
			| TOKEN_WHILE '(' E ')' BLOCO_LOOP NOVA_LINHA {
				if($3.tipo == "bool"){
					$$.label = "";
					$$.tipo = "";
					$$.tamanho_vetor = "";
					$$.valor_armazenado = "";
					
					string rotulo_inicio = rotulo_loop_inicio_tmp;
					string rotulo_meio = rotulo_loop_meio_tmp;
					string rotulo_fim = rotulo_loop_fim_tmp;

					$$.traducao = "\t" + rotulo_inicio + ":\n" + 
						$3.traducao +
						"\t" + "if (" + $3.label + ") goto " + rotulo_meio + ";\n" +
						"\t" + "goto " + rotulo_fim + ";\n" +
						"\t" + rotulo_meio + ":\n" + 
						$5.traducao +
						"\t" + "goto " + rotulo_inicio + ";\n" +
						"\t" + rotulo_fim + ":\n";

					pilha_rotulo_inicio.pop_back();
					pilha_rotulo_meio.pop_back();
					pilha_rotulo_fim.pop_back();
				}
			}
			| TOKEN_DO BLOCO_LOOP TOKEN_WHILE '(' E ')' NOVA_LINHA {
				if($5.tipo == "bool"){
					$$.label = "";
					$$.tipo = "";
					$$.tamanho_vetor = "";
					$$.valor_armazenado = "";
					
					string rotulo_inicio = rotulo_loop_inicio_tmp;
					string rotulo_fim = rotulo_loop_fim_tmp;

					$$.traducao =
						"\t" + rotulo_inicio + ":\n" +
						$2.traducao +
						$5.traducao +
						"\t" + "if (" + $5.label + ") goto " + rotulo_inicio + ";\n" +
						"\t" + rotulo_fim + ":\n";

					pilha_rotulo_inicio.pop_back();
					pilha_rotulo_fim.pop_back();
				}
			}
			| TOKEN_FOR '(' TOKEN_ID TOKEN_OPERADOR_IGUAL E ';' TOKEN_ID TOKEN_OPERADOR_MENOR_MAIOR E ';' TOKEN_ID TOKEN_OPERADOR_IGUAL E ')' BLOCO_LOOP NOVA_LINHA {
				if($3.label == $7.label && $3.label == $11.label && $7.label == $11.label){
					$$.label = "";
					$$.tipo = "";
					$$.tamanho_vetor = "";
					$$.valor_armazenado = "";

					string novo_label = gerar_label();
					add_na_tabela_simbolos(escopo_atual, "", novo_label, $7.tipo, "", "");

					string rotulo_inicio = rotulo_loop_inicio_tmp;
					string rotulo_meio = rotulo_loop_meio_tmp;
					string rotulo_fim = rotulo_loop_fim_tmp;

					TIPO_SIMBOLO valor_dolar3 = buscar_na_tabela_simbolos(escopo_atual, $3);
					TIPO_SIMBOLO valor_dolar11 = buscar_na_tabela_simbolos(escopo_atual, $11);
					
					$$.traducao = $5.traducao + $9.traducao +
						"\t" + valor_dolar3.nome_variavel_temporaria + " = " + $5.label + ";\n" +
						"\t" + rotulo_inicio + ":\n" +
						"\t" + novo_label + " = " + valor_dolar3.nome_variavel_temporaria + " " + $8.label + " " + $9.label + ";\n" +
						$8.traducao +
						"\tif (" + novo_label + ") goto " + rotulo_meio + ";\n" +
						"\tgoto " + rotulo_fim + ";\n" +

						"\t" + rotulo_meio + ":\n" +
						$15.traducao +
						$13.traducao +
						$11.traducao +
						"\t" + valor_dolar11.nome_variavel_temporaria + " = " + $13.label + ";\n" +

						"\tgoto " + rotulo_inicio + ";\n" +
						"\t" + rotulo_fim + ":\n";

					pilha_rotulo_inicio.pop_back();
					pilha_rotulo_meio.pop_back();
					pilha_rotulo_fim.pop_back();
				}
				else{
					yyerror("erro no for!");
				}
			}
			| TOKEN_FOR '(' TOKEN_ID TOKEN_OPERADOR_IGUAL E ';' TOKEN_ID TOKEN_OPERADOR_RELACIONAL E ';' TOKEN_ID TOKEN_OPERADOR_IGUAL E ')' BLOCO_LOOP NOVA_LINHA {
				if($3.label == $7.label && $3.label == $11.label && $7.label == $11.label && ($8.label == "<=" || $8.label == ">=")){
					$$.label = "";
					$$.tipo = "";
					$$.tamanho_vetor = "";
					$$.valor_armazenado = "";

					string novo_label = gerar_label();
					add_na_tabela_simbolos(escopo_atual, "", novo_label, $7.tipo, "", "");

					string rotulo_inicio = rotulo_loop_inicio_tmp;
					string rotulo_meio = rotulo_loop_meio_tmp;
					string rotulo_fim = rotulo_loop_fim_tmp;

					TIPO_SIMBOLO valor_dolar3 = buscar_na_tabela_simbolos(escopo_atual, $3);
					TIPO_SIMBOLO valor_dolar11 = buscar_na_tabela_simbolos(escopo_atual, $11);

					$$.traducao = $5.traducao + $9.traducao +
						"\t" + valor_dolar3.nome_variavel_temporaria + " = " + $5.label + ";\n" +
						"\t" + rotulo_inicio + ":\n" +
						"\t" + novo_label + " = " + valor_dolar3.nome_variavel_temporaria + " " + $8.label + " " + $9.label + ";\n" +
						$8.traducao +
						"\tif (" + novo_label + ") goto " + rotulo_meio + ";\n" +
						"\tgoto " + rotulo_fim + ";\n" +

						"\t" + rotulo_meio + ":\n" +
						$15.traducao +
						$13.traducao +
						$11.traducao +
						"\t" + valor_dolar11.nome_variavel_temporaria + " = " + $13.label + ";\n" +

						"\tgoto " + rotulo_inicio + ";\n" +
						"\t" + rotulo_fim + ":\n";

					pilha_rotulo_inicio.pop_back();
					pilha_rotulo_meio.pop_back();
					pilha_rotulo_fim.pop_back();
				}
				else{
					yyerror("erro no for!");
				}
			}
			| TOKEN_SWITCH '(' E ')' {
				
			}
			| TOKEN_BREAK NOVA_LINHA {
    			if (pilha_rotulo_fim.empty()) {
        			yyerror("Comando break fora de um laço!");
    			} 
				else {
					cout << "break" << endl;
        			$$.traducao = "\tgoto " + pilha_rotulo_fim.back() + ";\n";
    			}
			}
			| TOKEN_CONTINUE NOVA_LINHA {
    			if (pilha_rotulo_inicio.empty()) {
        			yyerror("Comando continue fora de um laço!");
    			} 
				else {
        			$$.traducao = "\tgoto " + pilha_rotulo_inicio.back() + ";\n";
    			}
			}
			;

E 			: BLOCO
			| E TOKEN_OPERADOR_MAIS_MENOS E {
				if(($1.tipo == "string" && $1.tamanho_vetor != "") && ($3.tipo == "string" && $3.tamanho_vetor != "" && ($2.label == "+"))){ //filtra strings
					$$.tipo = "string";
					$$.label = gerar_label();

					int tamanho_string = atoi($1.tamanho_vetor.c_str()) + atoi($3.tamanho_vetor.c_str());
					$$.tamanho_vetor = to_string(tamanho_string);

					string declaracao_caracteres;
					char string_resultante[tamanho_string];
					int cont = 0;

					//valor armazenado tem "", mas o tamanho_vetor não conta com as ""

					for(int i = 0; i < atoi($1.tamanho_vetor.c_str())+2; i++){
						if($1.valor_armazenado[i] != '"'){
							string_resultante[cont] = $1.valor_armazenado[i];
							cont++;
						}
					}
					for(int j = 0; j < atoi($3.tamanho_vetor.c_str())+2; j++){
						if($3.valor_armazenado[j] != '"'){
							string_resultante[cont] = $3.valor_armazenado[j];
							cont++;
						}
					}

					int cont2 = 0;

					for(int k = 0; k < tamanho_string; k++){
						declaracao_caracteres = declaracao_caracteres + "\t" + $$.label + "[" + to_string(cont2) + "]" + " = " + "'" + string_resultante[k] + "'" + ";\n";
						cont2++;
					}

					$$.valor_armazenado = '"' + std::string(string_resultante) + '"';

					add_na_tabela_simbolos(escopo_atual, "", $$.label, $$.tipo, $$.tamanho_vetor, $$.valor_armazenado);
				
					$$.traducao = $1.traducao + $3.traducao + declaracao_caracteres + "\t" + $$.label + "[" + to_string(tamanho_string) + "]" + " = " + "'" + "\\" + "0" + "'" + ";\n";
				}
				else{
					$$.tipo = tipo_resultante($1, $3);
					$$.tamanho_vetor = "";
					$$.valor_armazenado = "";

					if(necessario_conversao_implicita_tipo($1.tipo, $3.tipo)){
						string comando_extra;
						string label_extra = gerar_label();
						add_na_tabela_simbolos(escopo_atual, "", label_extra, $$.tipo, $$.tamanho_vetor, $$.valor_armazenado);

						comando_extra = "\t" + label_extra + " = " + '(' + $$.tipo + ") " + (($1.tipo != tipo_resultante($1, $3))? $1.label: $3.label) + ";\n";

						$$.label = gerar_label();
						add_na_tabela_simbolos(escopo_atual, "", $$.label, $$.tipo, $$.tamanho_vetor, $$.valor_armazenado);

						$$.traducao = $1.traducao + $3.traducao + comando_extra + "\t" + $$.label + " = " + 
							(($1.tipo != tipo_resultante($1, $3))? label_extra + " " + $2.label + " " + $3.label: $1.label + " " + $2.label + " " + label_extra) + ";\n";
					}
					else{
						$$.label = gerar_label();
						add_na_tabela_simbolos(escopo_atual, "", $$.label, $$.tipo, $$.tamanho_vetor, $$.valor_armazenado);

						$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " " + $2.label + " " + $3.label + ";\n";
					}
				}
			}
			| E TOKEN_OPERADOR_VEZES_DIVIDIDO E {
				$$.tipo = tipo_resultante($1, $3);
				$$.tamanho_vetor = "";
				$$.valor_armazenado = "";

				if(necessario_conversao_implicita_tipo($1.tipo, $3.tipo)){
					string comando_extra;
					string label_extra = gerar_label();
					add_na_tabela_simbolos(escopo_atual, "", label_extra, $$.tipo, $$.tamanho_vetor, $$.valor_armazenado);

					comando_extra = "\t" + label_extra + " = " + '(' + $$.tipo + ") " + (($1.tipo != tipo_resultante($1, $3))? $1.label: $3.label) + ";\n";

					$$.label = gerar_label();
					add_na_tabela_simbolos(escopo_atual, "", $$.label, $$.tipo, $$.tamanho_vetor, $$.valor_armazenado);

					$$.traducao = $1.traducao + $3.traducao + comando_extra + "\t" + $$.label + " = " + 
						(($1.tipo != tipo_resultante($1, $3))? label_extra + " " + $2.label + " " + $3.label: $1.label + " " + $2.label + " " + label_extra) + ";\n";
				}
				else{
					$$.label = gerar_label();
					add_na_tabela_simbolos(escopo_atual, "", $$.label, $$.tipo, $$.tamanho_vetor, $$.valor_armazenado);

					$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " " + $2.label + " " + $3.label + ";\n";
				}
			}
			| TOKEN_OPERADOR_MAIS_MENOS E %prec unario {
				if($2.tipo == "float" || $2.tipo == "int"){
					$$.label = gerar_label();
					$$.tipo = $2.tipo;
					$$.tamanho_vetor = "";
					$$.valor_armazenado = "";
					add_na_tabela_simbolos(escopo_atual, "", $$.label, $$.tipo, $$.tamanho_vetor, $$.valor_armazenado);

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
					$$.tamanho_vetor = "";
					$$.valor_armazenado = "";
					add_na_tabela_simbolos(escopo_atual, "", $$.label, $$.tipo, $$.tamanho_vetor, $$.valor_armazenado);

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
				$$.tamanho_vetor = $2.tamanho_vetor;
				$$.valor_armazenado = $2.valor_armazenado;
			}
			| TOKEN_TIPO_INT '(' E ')' %prec CAST {
				if(possivel_realizar_casting_explicito("int", $3)){
					$$.label = gerar_label();
					$$.tipo = "int";
					$$.tamanho_vetor = "";
					$$.valor_armazenado = "";
					add_na_tabela_simbolos(escopo_atual, "", $$.label, $$.tipo, $$.tamanho_vetor, $$.valor_armazenado);

					$$.traducao = $3.traducao + "\t" + $$.label + " = " + "(int) " + $3.label + ";\n";
				}
			}
			| TOKEN_TIPO_FLOAT '(' E ')' %prec CAST {
				if(possivel_realizar_casting_explicito("float", $3)){
					$$.label = gerar_label();
					$$.tipo = "float";
					$$.tamanho_vetor = "";
					$$.valor_armazenado = "";
					add_na_tabela_simbolos(escopo_atual, "", $$.label, $$.tipo, $$.tamanho_vetor, $$.valor_armazenado);

					$$.traducao = $3.traducao + "\t" + $$.label + " = " + "(float) " + $3.label + ";\n";
				}
			}
			| TOKEN_ID TOKEN_OPERADOR_IGUAL E {

				TIPO_SIMBOLO valor_dolar1 = buscar_na_tabela_simbolos(escopo_atual, $1);

				if(necessario_conversao_implicita_tipo(valor_dolar1.tipo_variavel, $3.tipo)){ // se for uma string, nunca vai entrar nesse if e sim no else

					$$.traducao = $1.traducao + $3.traducao + "\t" + valor_dolar1.nome_variavel_temporaria + " = (" + valor_dolar1.tipo_variavel + ") " + 
						$3.label + ";\n";
				}
				else {
					if($3.tamanho_vetor != ""){ // no caso de um t1 que está sem o [x] (t1[x])
						mudar_tamanho_vetor_na_pilha_tabela_simbolos(escopo_atual, $1, $3);
					}
					if($3.valor_armazenado != ""){ // no caso de a = concatencação(b,c)
						mudar_valor_armazenado_na_pilha_tabela_simbolos(escopo_atual, $1, $3);
					}

					if($3.tamanho_vetor != "" && $3.valor_armazenado != ""){
						$$.traducao = $1.traducao + $3.traducao + "\t" + "strcpy(" + valor_dolar1.nome_variavel_temporaria + ", " + $3.label + ")" + ";\n";
					}
					else{
						$$.traducao = $1.traducao + $3.traducao + "\t" + valor_dolar1.nome_variavel_temporaria + " = " + $3.label + ";\n";
					}
				}
			}
			| E TOKEN_OPERADOR_MENOR_MAIOR E {
				$$.tipo = "bool";
				$$.tamanho_vetor = "";
				$$.valor_armazenado = "";

				string tipo_conversao = tipo_resultante($1, $3);

				if(necessario_conversao_implicita_tipo($1.tipo, $3.tipo)){
					string comando_extra;
					string label_extra = gerar_label();
					add_na_tabela_simbolos(escopo_atual, "", label_extra, tipo_conversao, $$.tamanho_vetor, $$.valor_armazenado);

					comando_extra = "\t" + label_extra + " = " + '(' + tipo_conversao + ") " + (($1.tipo != tipo_conversao)? $1.label: $3.label) + ";\n";

					$$.label = gerar_label();
					add_na_tabela_simbolos(escopo_atual, "", $$.label, tipo_conversao, $$.tamanho_vetor, $$.valor_armazenado);

					$$.traducao = $1.traducao + $3.traducao + comando_extra + "\t" + $$.label + " = " + 
						(($1.tipo != tipo_conversao)? label_extra + " " + $2.label + " " + $3.label: $1.label + " " + $2.label + " " + label_extra) + ";\n";
				}
				else{
					$$.label = gerar_label();
					add_na_tabela_simbolos(escopo_atual, "", $$.label, $$.tipo, $$.tamanho_vetor, $$.valor_armazenado);

					$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " " + $2.label + " " + $3.label + ";\n";
				}
			}
			| E TOKEN_OPERADOR_RELACIONAL E {
				$$.tipo = "bool";
				$$.tamanho_vetor = "";
				$$.valor_armazenado = "";

				string tipo_conversao = tipo_resultante($1, $3);

				if(necessario_conversao_implicita_tipo($1.tipo, $3.tipo)){
					string comando_extra;
					string label_extra = gerar_label();
					add_na_tabela_simbolos(escopo_atual, "", label_extra, tipo_conversao, $$.tamanho_vetor, $$.valor_armazenado);

					comando_extra = "\t" + label_extra + " = " + '(' + tipo_conversao + ") " + (($1.tipo != tipo_conversao)? $1.label: $3.label) + ";\n";

					$$.label = gerar_label();
					add_na_tabela_simbolos(escopo_atual, "", $$.label, tipo_conversao, $$.tamanho_vetor, $$.valor_armazenado);

					$$.traducao = $1.traducao + $3.traducao + comando_extra + "\t" + $$.label + " = " + 
						(($1.tipo != tipo_conversao)? label_extra + " " + $2.label + " " + $3.label: $1.label + " " + $2.label + " " + label_extra) + ";\n";
				}
				else{
					$$.label = gerar_label();
					add_na_tabela_simbolos(escopo_atual, "", $$.label, $$.tipo, $$.tamanho_vetor, $$.valor_armazenado);

					$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " " + $2.label + " " + $3.label + ";\n";
				}
			}
			| E TOKEN_OPERADOR_E_OU E {
				$$.tipo = "bool";
				$$.tamanho_vetor = "";
				$$.valor_armazenado = "";

				string tipo_conversao = tipo_resultante($1, $3);

				if(necessario_conversao_implicita_tipo($1.tipo, $3.tipo)){
					string comando_extra;
					string label_extra = gerar_label();
					add_na_tabela_simbolos(escopo_atual, "", label_extra, tipo_conversao, $$.tamanho_vetor, $$.valor_armazenado);

					comando_extra = "\t" + label_extra + " = " + '(' + tipo_conversao + ") " + (($1.tipo != tipo_conversao)? $1.label: $3.label) + ";\n";

					$$.label = gerar_label();
					add_na_tabela_simbolos(escopo_atual, "", $$.label, tipo_conversao, $$.tamanho_vetor, $$.valor_armazenado);

					$$.traducao = $1.traducao + $3.traducao + comando_extra + "\t" + $$.label + " = " + 
						(($1.tipo != tipo_conversao)? label_extra + " " + $2.label + " " + $3.label: $1.label + " " + $2.label + " " + label_extra) + ";\n";
				}
				else{
					$$.label = gerar_label();
					add_na_tabela_simbolos(escopo_atual, "", $$.label, $$.tipo, $$.tamanho_vetor, $$.valor_armazenado);

					$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " " + $2.label + " " + $3.label + ";\n";
				}
			}
			| TOKEN_OPERADOR_NEGADO E {
				$$.tipo = "bool";
				$$.label = gerar_label();
				$$.tamanho_vetor = "";
				$$.valor_armazenado = "";
				add_na_tabela_simbolos(escopo_atual, "", $$.label, $$.tipo, $$.tamanho_vetor, $$.valor_armazenado);

				$$.traducao = $2.traducao + "\t" + $$.label + " = " + $1.label + $2.label + ";\n";
			}
			| TOKEN_ID TOKEN_OPERADOR_IGUAL TOKEN_INPUT '(' E ')'{
				if($5.tipo == "string"){
					TIPO_SIMBOLO valor_dolar1 = buscar_na_tabela_simbolos(escopo_atual, $1);

					$$.tipo = valor_dolar1.tipo_variavel;
					$$.label = gerar_label();
					$$.tamanho_vetor = valor_dolar1.tamanho_variavel_vetor;
					$$.valor_armazenado = valor_dolar1.valor_variavel_armazenado;
					add_na_tabela_simbolos(escopo_atual, "", $$.label, $$.tipo, $$.tamanho_vetor, $$.valor_armazenado);

					$$.traducao = $5.traducao + "\t" + "std::cout << " + $5.label + " << std::endl;\n" 
					+ "\t" + "std::cin >> " + $$.label + ";\n";
				}
			}
			| TOKEN_ID TOKEN_OPERADOR_IGUAL TOKEN_INPUT '(' ')'{
				TIPO_SIMBOLO valor_dolar1 = buscar_na_tabela_simbolos(escopo_atual, $1);

				$$.tipo = valor_dolar1.tipo_variavel;
				$$.label = valor_dolar1.nome_variavel_temporaria;
				$$.tamanho_vetor = valor_dolar1.tamanho_variavel_vetor;
				$$.valor_armazenado = valor_dolar1.valor_variavel_armazenado;

				string teste = "std::cin >> " + $$.label + ";\n";

				$$.traducao = "\t" + teste; // "\t" + "std::cin >> " + $$.label + ";\n"; tava dando erro não sei pq então criei string teste
			}
			| TOKEN_OUTPUT '(' E ')'{
				if($3.tipo == "string"){
					$$.traducao = $3.traducao + "\t" + "std::cout << " + $3.label + " << std::endl;\n";
				}
			}
			| E '[' E ']' { // CUIDADO, precisa de casting implicito
				if($1.tipo == "string" && $3.tipo == "int"){
					$$.label = gerar_label();
					$$.tipo = $1.tipo;
					$$.tamanho_vetor = "";
					$$.valor_armazenado = "";
					add_na_tabela_simbolos(escopo_atual, "", $$.label, $$.tipo, $$.tamanho_vetor, $$.valor_armazenado);

					$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + "[" + $3.label + "]" + ";\n";
				}
				else if($1.tipo == "string" && $3.tipo == "float"){
					$$.tamanho_vetor = "";
					$$.valor_armazenado = "";

					string label_extra = gerar_label();
					add_na_tabela_simbolos(escopo_atual, "", label_extra, "int", $$.tamanho_vetor, $$.valor_armazenado);

					string comando_extra = "\t" + label_extra + " = " + "int(" + $3.label + ")" + ";\n"; 
					
					$$.label = gerar_label();
					$$.tipo = $1.tipo;
					add_na_tabela_simbolos(escopo_atual, "", $$.label, $$.tipo, $$.tamanho_vetor, $$.valor_armazenado);

					$$.traducao = $1.traducao + $3.traducao + comando_extra + "\t" + $$.label + " = " + $1.label + "[" + label_extra + "]" + ";\n";
				}
				else{
					yyerror("não é possível efetuar esse comando!");
				}
			}
			| TOKEN_VARIAVEL_INT {
				$$.label = gerar_label();
				$$.tipo = "int";
				$$.tamanho_vetor = "";
				$$.valor_armazenado = $1.label;
				add_na_tabela_simbolos(escopo_atual, "", $$.label, $$.tipo, $$.tamanho_vetor, $$.valor_armazenado);
				
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| TOKEN_VARIAVEL_FLOAT {
				$$.label = gerar_label();
				$$.tipo = "float";
				$$.tamanho_vetor = "";
				$$.valor_armazenado = $1.label;
				add_na_tabela_simbolos(escopo_atual, "", $$.label, $$.tipo, $$.tamanho_vetor, $$.valor_armazenado);
				
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| TOKEN_VARIAVEL_STRING {
				$$.label = gerar_label();
				$$.tipo = "string";
				$$.valor_armazenado = $1.label;

				int tamanho_string = strlen_da_shopee($1.label)-2; // n conta as ""
				$$.tamanho_vetor = to_string(tamanho_string); // tmb n conta as ""

				add_na_tabela_simbolos(escopo_atual, "", $$.label, $$.tipo, $$.tamanho_vetor, $$.valor_armazenado);

				string declaracao_caracteres;
				int cont = 0;

				for(int i = 0; i < tamanho_string+2; i++){ // +2 para ser contadas tmb as posições com ""
					if($1.label[i] != '"'){
						declaracao_caracteres = declaracao_caracteres + "\t" + $$.label + "[" + to_string(cont) + "]" + " = " + "'" + $1.label[i] + "'" + ";\n";
						cont++;
					}
				}
				
				$$.traducao = declaracao_caracteres + "\t" + $$.label + "[" + to_string(cont) + "]" + " = " + "'" + "\\" + "0" + "'" + ";\n";
			}
			| TOKEN_VARIAVEL_BOOL {
				string var_aux;
				if ($1.label == "true") { var_aux = "1"; }
				else if ($1.label == "false") { var_aux = "0"; }

				$$.label = gerar_label();
				$$.tipo = "bool";
				$$.tamanho_vetor = "";
				$$.valor_armazenado = $1.label;
				add_na_tabela_simbolos(escopo_atual, "", $$.label, "bool", $$.tamanho_vetor, $$.valor_armazenado);
				
				$$.traducao = "\t" + $$.label + " = " + var_aux + ";\n";
			}
			| TOKEN_ID { //eu só sou chamado quando acontece alguma expressão do tipo: E = TOKEN_ID + E
				bool encontrado = false;
				TIPO_SIMBOLO variavel;
				
				for(int i = escopo_atual; i >= 0; i--){
					for(int j = pilha_tabela_simbolos[i].size() - 1; j >= 0; j--){
						if(pilha_tabela_simbolos[i][j].nome_variavel_real == $1.label){
							variavel = pilha_tabela_simbolos[i][j];
							encontrado = true;
							break;
						}
					}
					if(encontrado) { break; }
				}
				if(!encontrado){
					yyerror("Voce nao declarou essa variavel!");
				}
				$$.tipo = variavel.tipo_variavel;
                $$.label = variavel.nome_variavel_temporaria;
				$$.tamanho_vetor = variavel.tamanho_variavel_vetor;
				$$.valor_armazenado = variavel.valor_variavel_armazenado;

                $$.traducao = "";
            }
			;

%%

#include "lex.yy.c"

int yyparse();

void add_na_tabela_simbolos(int escopo, string nome_variavel_real, string nome_variavel_temporaria, string tipo_variavel, string tamanho_variavel_vetor, string valor_variavel_armazenado){

	for(int i = 0; i < pilha_tabela_simbolos[escopo].size(); i++){ //caso o usuário tente declarar a mesma variável
		if(nome_variavel_real != "" && pilha_tabela_simbolos[escopo][i].nome_variavel_real == nome_variavel_real){
			yyerror("Não é possível declarar a mesma variável duas vezes!");
		}
	}

	TIPO_SIMBOLO valor;
	valor.nome_variavel_real = nome_variavel_real;
	valor.nome_variavel_temporaria = nome_variavel_temporaria;
	valor.tipo_variavel = tipo_variavel;
	valor.tamanho_variavel_vetor = tamanho_variavel_vetor;
	valor.valor_variavel_armazenado = valor_variavel_armazenado;

	pilha_tabela_simbolos[escopo].push_back(valor);
	memoria_pilha_tabela_simbolos[escopo].push_back(valor);
}

string gerar_label(){

	label_num++;

    return "t" + std::to_string(label_num);
}

string gerar_rotulo(){

	rotulo_num++;

	return "rotulo" + std::to_string(rotulo_num);
}

TIPO_SIMBOLO buscar_na_tabela_simbolos(int escopo, atributos a1){
	for(int i = escopo; i >= 0; i--){
		for(int j = 0; j < pilha_tabela_simbolos[i].size(); j++){
			if(a1.label == pilha_tabela_simbolos[i][j].nome_variavel_real){
				return pilha_tabela_simbolos[i][j];
			}
		}
	}
	yyerror("Voce nao declarou essa variavel!");
}

void mudar_tamanho_vetor_na_pilha_tabela_simbolos(int escopo, atributos a1, atributos a2){
	for(int i = escopo; i >= 0; i--){
		for(int j = 0; j < pilha_tabela_simbolos[i].size(); j++){
			if(a1.label == pilha_tabela_simbolos[i][j].nome_variavel_real){
				pilha_tabela_simbolos[i][j].tamanho_variavel_vetor = a2.tamanho_vetor;
				memoria_pilha_tabela_simbolos[i][j].tamanho_variavel_vetor = a2.tamanho_vetor;
			}
		}
	}
}

void mudar_valor_armazenado_na_pilha_tabela_simbolos(int escopo, atributos a1, atributos a2){
	for(int i = escopo; i >= 0; i--){
		for(int j = 0; j < pilha_tabela_simbolos[i].size(); j++){
			if(a1.label == pilha_tabela_simbolos[i][j].nome_variavel_real){
				pilha_tabela_simbolos[i][j].valor_variavel_armazenado = a2.valor_armazenado;
				memoria_pilha_tabela_simbolos[i][j].valor_variavel_armazenado = a2.valor_armazenado;
			}
		}
	}
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

int strlen_da_shopee(string a){
	int cont = 0;
	while(true){
		if(a[cont] == '\0'){
			break;
		}
		else{
			cont++;
		}
	}
	return cont;
}

int main( int argc, char* argv[] ) {

	label_num = 0;
	rotulo_num = 0;

	pilha_tabela_simbolos.push_back(vector<TIPO_SIMBOLO>()); // inicializa escopo 0 (global)
	memoria_pilha_tabela_simbolos.push_back(vector<TIPO_SIMBOLO>()); 
	
	escopo_atual = 0;

	yyparse();

	return 0;
}

void yyerror( string MSG )
{
	cout << "erro na linha " << yylineno << ": " << MSG << endl;
	exit (0);
}