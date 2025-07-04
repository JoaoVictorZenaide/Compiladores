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
		string num_linhas; //no caso de ser uma matriz
		string num_colunas;
    };

	typedef struct{
		string nome_variavel_real;
		string nome_variavel_temporaria;
		string tipo_variavel;
		string tamanho_variavel_vetor; //no caso de ser um vetor
		string valor_variavel_armazenado;
		string num_linhas_variavel; //no caso de ser uma matriz
		string num_colunas_variavel;
	} TIPO_SIMBOLO;

	typedef struct{
		string tipo;
		string valor;
	} elemento_matriz;

	typedef struct{
		string nome;
		string tipo;
	} atributos_funcao;

	typedef struct{
		string tipo;
		string nome;
		vector<atributos_funcao> atributos;
	} funcoes;

	vector<vector<elemento_matriz>> pilha_pilha_matriz;

	vector<funcoes> vetor_funcoes;

	vector<atributos_funcao> atributos_aux;

	vector<atributos_funcao> atributos_aux2;

	vector<vector<TIPO_SIMBOLO>> pilha_tabela_simbolos;
	vector<vector<TIPO_SIMBOLO>> memoria_pilha_tabela_simbolos;

	vector<string> pilha_rotulo_fim;
	vector<string> pilha_rotulo_iteracao;
	vector<string> pilha_rotulo_meio;
	vector<string> pilha_rotulo_inicio;

	string rotulo_loop_inicio_tmp;
	string rotulo_loop_iteracao_tmp;
	string rotulo_loop_meio_tmp;
	string rotulo_loop_fim_tmp;

	string variavel_switch_global = "";

	bool proteger_matriz_val = false;

	void add_na_tabela_simbolos(int escopo, string nome_variavel_real, string nome_variavel_temporaria, string tipo_variavel, 
			string tamanho_variavel_vetor, string valor_variavel_armazenado, string valor_num_linhas, string valor_num_colunas);

	string gerar_label();

	string gerar_rotulo();

	TIPO_SIMBOLO buscar_na_tabela_simbolos(int escopo, atributos a1);

	TIPO_SIMBOLO buscar_na_tabela_simbolos_nome_variavel_temporaria(int escopo, atributos a1);

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
%token TOKEN_CASE
%token TOKEN_DEFAULT
%token TOKEN_BREAK
%token TOKEN_CONTINUE

%token TOKEN_OPERADOR_MAIS_MENOS
%token TOKEN_OPERADOR_MAIS_MAIS
%token TOKEN_OPERADOR_MENOS_MENOS
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
%token TOKEN_RETURN
%token TOKEN_VOID

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
%nonassoc TOKEN_OPERADOR_MAIS_MAIS TOKEN_OPERADOR_MENOS_MENOS	// ++ e --
%right TOKEN_OPERADOR_NEGADO									// !

//não terminal inicial PROGRAMA

%start PROGRAMA

%%

PROGRAMA	: S
			| S NOVA_LINHA



S 			: FUNCOES COMANDOS TOKEN_FUNC TOKEN_MAIN '(' ')' BLOCO {

				string declaracoes = "";

				for(int i = 0; i < memoria_pilha_tabela_simbolos.size(); i++){

					for(int j = 0; j < memoria_pilha_tabela_simbolos[i].size(); j++){

						string tipo_em_jpl = memoria_pilha_tabela_simbolos[i][j].tipo_variavel; //impede bool no código intermediário
						string tipo_em_c;
						string complemento = "";

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
							complemento = "[" + std::to_string(atoi(memoria_pilha_tabela_simbolos[i][j].tamanho_variavel_vetor.c_str()) + 1) + "]";
						}

						if(memoria_pilha_tabela_simbolos[i][j].num_linhas_variavel == "" && memoria_pilha_tabela_simbolos[i][j].num_colunas_variavel == ""){
							declaracoes = declaracoes + "\t" + tipo_em_c + " " + memoria_pilha_tabela_simbolos[i][j].nome_variavel_temporaria + complemento + ";\n";
						}
					}
				}
				cout << "\n/*Compilador jpl*/\n" << "#include <iostream>\n\n" << declaracoes << "\n" << $1.traducao << "\nint main(void){\n\n" << $2.traducao << 
					$7.traducao << "\n\treturn 0;\n}" << endl;

				for(int i = 0 ; i < memoria_pilha_tabela_simbolos.size(); i++){

					cout << "\nEscopo " << i << ":\n";

					for(int j = 0; j < memoria_pilha_tabela_simbolos[i].size(); j++){ //imprimir o que tem na tabela de simbolos 
						cout << "Nome real: " << memoria_pilha_tabela_simbolos[i][j].nome_variavel_real
							<< ", Nome temp: " << memoria_pilha_tabela_simbolos[i][j].nome_variavel_temporaria 
							<< ", Tipo: " << memoria_pilha_tabela_simbolos[i][j].tipo_variavel
							<< ", Tam(vetor): " << memoria_pilha_tabela_simbolos[i][j].tamanho_variavel_vetor 
							<< ", num_linhas: " << memoria_pilha_tabela_simbolos[i][j].num_linhas_variavel 
							<< ", num_colunas: " << memoria_pilha_tabela_simbolos[i][j].num_colunas_variavel
							<< ", Val: " << memoria_pilha_tabela_simbolos[i][j].valor_variavel_armazenado << endl;
					}
				}
			}
			;

NOVA_LINHA	: NOVA_LINHA TOKEN_NOVA_LINHA
			| TOKEN_NOVA_LINHA
			;

TIPO 		: TOKEN_TIPO_INT
			| TOKEN_TIPO_FLOAT
			| TOKEN_TIPO_BOOL
			| TOKEN_TIPO_STRING
			;

COM_ATRIBUTOS_FUNC
			: TIPO TOKEN_ID {
				atributos_funcao temp;
				temp.nome = gerar_label();
				temp.tipo = $1.label;
				atributos_aux.push_back(temp);
				
				add_na_tabela_simbolos(escopo_atual, $2.label, temp.nome, $1.label, "", "", "", "");
			}
			| TIPO TOKEN_ID ',' COM_ATRIBUTOS_FUNC {
				atributos_funcao temp;
				temp.nome = gerar_label();
				temp.tipo = $1.label;
				atributos_aux.push_back(temp);
				
				add_na_tabela_simbolos(escopo_atual, $2.label, temp.nome, $1.label, "", "", "", "");
			}
			;

SEM_ATRIBUTOS_FUNCAO
			: {
			}
			;

ATRIBUTOS_FUNCAO
			:COM_ATRIBUTOS_FUNC {
			}
			|SEM_ATRIBUTOS_FUNCAO {
			}
			;

FUNCOES 	: FUNCAO FUNCOES {
				$$.traducao = $1.traducao + $2.traducao;
			}
			| {
				$$.traducao = "";
			}
			;

FUNCAO 		: TOKEN_TIPO_INT TOKEN_ID '(' ATRIBUTOS_FUNCAO ')' BLOCO_RET NOVA_LINHA {
				$$.label = "";
				$$.tipo = $1.label;
				$$.tamanho_vetor = "";
				$$.valor_armazenado = "";
				$$.num_linhas = "";
				$$.num_colunas = "";

				funcoes f;
    			f.tipo = $1.label;
  				f.nome = $2.label;
				f.atributos = atributos_aux;

				bool funcao_ja_declarada = false;

				for (int i = 0; i < vetor_funcoes.size(); i++) {
					// Verifica se o nome é igual
					if (vetor_funcoes[i].nome == f.nome) {
						// Verifica se tem o mesmo número de atributos
						if (vetor_funcoes[i].atributos.size() == f.atributos.size()) {
							bool iguais = true;

							// Verifica se cada atributo é igual (tipo e nome)
							for (int j = 0; j < f.atributos.size(); j++) {
								if (f.atributos[j].tipo != vetor_funcoes[i].atributos[j].tipo) {
									iguais = false;
									break;
								}
							}

							if (iguais) {
								funcao_ja_declarada = true;
								break;
							}
						}
					}
				}

				if (funcao_ja_declarada) {
					yyerror("Função já declarada com os mesmos atributos!");
				} else {
					vetor_funcoes.push_back(f); // adiciona a nova função
				}

				string declaracoes_atributos = "";

				for(int i = atributos_aux.size()-1; i >= 0; i--){
					if(i == 0){
						declaracoes_atributos = declaracoes_atributos + atributos_aux[i].tipo + " " + atributos_aux[i].nome;
					}
					else{
						declaracoes_atributos = declaracoes_atributos + atributos_aux[i].tipo + " " + atributos_aux[i].nome + ", ";
					}
				}

				$$.traducao = $2.traducao + $$.tipo + " " + $2.label + "(" + declaracoes_atributos + ");\n\n" + 
					$$.tipo + " " + $2.label + "(" + declaracoes_atributos + ")" + "{\n" + $6.traducao + "\n}\n";

				atributos_aux.clear();
			}
			| TOKEN_TIPO_FLOAT TOKEN_ID '(' ATRIBUTOS_FUNCAO ')' BLOCO_RET NOVA_LINHA {
				$$.label = "";
				$$.tipo = $1.label;
				$$.tamanho_vetor = "";
				$$.valor_armazenado = "";
				$$.num_linhas = "";
				$$.num_colunas = "";

				funcoes f;
    			f.tipo = $1.label;
  				f.nome = $2.label;
				f.atributos = atributos_aux;

				bool funcao_ja_declarada = false;

				for (int i = 0; i < vetor_funcoes.size(); i++) {
					// Verifica se o nome é igual
					if (vetor_funcoes[i].nome == f.nome) {
						// Verifica se tem o mesmo número de atributos
						if (vetor_funcoes[i].atributos.size() == f.atributos.size()) {
							bool iguais = true;

							// Verifica se cada atributo é igual (tipo e nome)
							for (int j = 0; j < f.atributos.size(); j++) {
								if (f.atributos[j].tipo != vetor_funcoes[i].atributos[j].tipo) {
									iguais = false;
									break;
								}
							}

							if (iguais) {
								funcao_ja_declarada = true;
								break;
							}
						}
					}
				}

				if (funcao_ja_declarada) {
					yyerror("Função já declarada com os mesmos atributos!");
				} else {
					vetor_funcoes.push_back(f); // adiciona a nova função
				}

				string declaracoes_atributos = "";

				for(int i = atributos_aux.size()-1; i >= 0; i--){
					if(i == 0){
						declaracoes_atributos = declaracoes_atributos + atributos_aux[i].tipo + " " + atributos_aux[i].nome;
					}
					else{
						declaracoes_atributos = declaracoes_atributos + atributos_aux[i].tipo + " " + atributos_aux[i].nome + ", ";
					}
				}

				$$.traducao = $2.traducao + $$.tipo + " " + $2.label + "(" + declaracoes_atributos + ");\n\n" + 
					$$.tipo + " " + $2.label + "(" + declaracoes_atributos + ")" + "{\n" + $6.traducao + "\n}\n";

				atributos_aux.clear();
			}
			| TOKEN_TIPO_BOOL TOKEN_ID '(' ATRIBUTOS_FUNCAO ')' BLOCO_RET NOVA_LINHA {
				$$.label = "";
				$$.tipo = $1.label;
				$$.tamanho_vetor = "";
				$$.valor_armazenado = "";
				$$.num_linhas = "";
				$$.num_colunas = "";

				funcoes f;
    			f.tipo = $1.label;
  				f.nome = $2.label;
				f.atributos = atributos_aux;

				bool funcao_ja_declarada = false;

				for (int i = 0; i < vetor_funcoes.size(); i++) {
					// Verifica se o nome é igual
					if (vetor_funcoes[i].nome == f.nome) {
						// Verifica se tem o mesmo número de atributos
						if (vetor_funcoes[i].atributos.size() == f.atributos.size()) {
							bool iguais = true;

							// Verifica se cada atributo é igual (tipo e nome)
							for (int j = 0; j < f.atributos.size(); j++) {
								if (f.atributos[j].tipo != vetor_funcoes[i].atributos[j].tipo) {
									iguais = false;
									break;
								}
							}

							if (iguais) {
								funcao_ja_declarada = true;
								break;
							}
						}
					}
				}

				if (funcao_ja_declarada) {
					yyerror("Função já declarada com os mesmos atributos!");
				} else {
					vetor_funcoes.push_back(f); // adiciona a nova função
				}

				string declaracoes_atributos = "";

				for(int i = atributos_aux.size()-1; i >= 0; i--){
					if(i == 0){
						declaracoes_atributos = declaracoes_atributos + atributos_aux[i].tipo + " " + atributos_aux[i].nome;
					}
					else{
						declaracoes_atributos = declaracoes_atributos + atributos_aux[i].tipo + " " + atributos_aux[i].nome + ", ";
					}
				}

				$$.traducao = $2.traducao + $$.tipo + " " + $2.label + "(" + declaracoes_atributos + ");\n\n" + 
					$$.tipo + " " + $2.label + "(" + declaracoes_atributos + ")" + "{\n" + $6.traducao + "\n}\n";

				atributos_aux.clear();
			}
			| TOKEN_TIPO_STRING TOKEN_ID '(' ATRIBUTOS_FUNCAO ')' BLOCO_RET NOVA_LINHA {
				$$.label = "";
				$$.tipo = $1.label;
				$$.tamanho_vetor = "";
				$$.valor_armazenado = "";
				$$.num_linhas = "";
				$$.num_colunas = "";

				funcoes f;
    			f.tipo = $1.label;
  				f.nome = $2.label;
				f.atributos = atributos_aux;

				bool funcao_ja_declarada = false;

				for (int i = 0; i < vetor_funcoes.size(); i++) {
					// Verifica se o nome é igual
					if (vetor_funcoes[i].nome == f.nome) {
						// Verifica se tem o mesmo número de atributos
						if (vetor_funcoes[i].atributos.size() == f.atributos.size()) {
							bool iguais = true;

							// Verifica se cada atributo é igual (tipo e nome)
							for (int j = 0; j < f.atributos.size(); j++) {
								if (f.atributos[j].tipo != vetor_funcoes[i].atributos[j].tipo) {
									iguais = false;
									break;
								}
							}

							if (iguais) {
								funcao_ja_declarada = true;
								break;
							}
						}
					}
				}

				if (funcao_ja_declarada) {
					yyerror("Função já declarada com os mesmos atributos!");
				} else {
					vetor_funcoes.push_back(f); // adiciona a nova função
				}

				string declaracoes_atributos = "";

				for(int i = atributos_aux.size()-1; i >= 0; i--){
					if(i == 0){
						declaracoes_atributos = declaracoes_atributos + atributos_aux[i].tipo + " " + atributos_aux[i].nome;
					}
					else{
						declaracoes_atributos = declaracoes_atributos + atributos_aux[i].tipo + " " + atributos_aux[i].nome + ", ";
					}
				}

				$$.traducao = $2.traducao + $$.tipo + " " + $2.label + "(" + declaracoes_atributos + ");\n\n" + 
					$$.tipo + " " + $2.label + "(" + declaracoes_atributos + ")" + "{\n" + $6.traducao + "\n}\n";

				atributos_aux.clear();
			}
			| TOKEN_VOID TOKEN_ID '(' ATRIBUTOS_FUNCAO ')' BLOCO NOVA_LINHA {
				$$.label = "";
				$$.tipo = "void";
				$$.tamanho_vetor = "";
				$$.valor_armazenado = "";
				$$.num_linhas = "";
				$$.num_colunas = "";

				funcoes f;
    			f.tipo = $1.label;
  				f.nome = $2.label;
				f.atributos = atributos_aux;

				bool funcao_ja_declarada = false;

				for (int i = 0; i < vetor_funcoes.size(); i++) {
					// Verifica se o nome é igual
					if (vetor_funcoes[i].nome == f.nome) {
						// Verifica se tem o mesmo número de atributos
						if (vetor_funcoes[i].atributos.size() == f.atributos.size()) {
							bool iguais = true;

							// Verifica se cada atributo é igual (tipo e nome)
							for (int j = 0; j < f.atributos.size(); j++) {
								if (f.atributos[j].tipo != vetor_funcoes[i].atributos[j].tipo) {
									iguais = false;
									break;
								}
							}

							if (iguais) {
								funcao_ja_declarada = true;
								break;
							}
						}
					}
				}

				if (funcao_ja_declarada) {
					yyerror("Função já declarada com os mesmos atributos!");
				} else {
					vetor_funcoes.push_back(f); // adiciona a nova função
				}

				string declaracoes_atributos = "";

				for(int i = atributos_aux.size()-1; i >= 0; i--){
					if(i == 0){
						declaracoes_atributos = declaracoes_atributos + atributos_aux[i].tipo + " " + atributos_aux[i].nome;
					}
					else{
						declaracoes_atributos = declaracoes_atributos + atributos_aux[i].tipo + " " + atributos_aux[i].nome + ", ";
					}
				}

				$$.traducao = $2.traducao + $$.tipo + " " + $2.label + "(" + declaracoes_atributos + ");\n\n" + 
					$$.tipo + " " + $2.label + "(" + declaracoes_atributos + ")" + "{\n" + $6.traducao + "\n}\n";

				atributos_aux.clear();
			}
			;

RECURSAO_C_M: ',' E RECURSAO_C_M {
				if(proteger_matriz_val == false){ //primeira coisa a executar dentro de BLOCO_M
					pilha_pilha_matriz.push_back(vector<elemento_matriz>());
					proteger_matriz_val = true;
				}

				$$.label = $2.label;
				$$.tipo = $2.tipo;
				$$.tamanho_vetor = $2.tamanho_vetor;
				$$.valor_armazenado = $2.valor_armazenado;
				$$.num_linhas = $2.num_linhas;
				$$.num_colunas = $2.num_colunas;

				elemento_matriz dolar;
				dolar.tipo = $$.tipo;
				dolar.valor = $$.label;

				pilha_pilha_matriz.back().push_back(dolar);
			}
			| ',' E {
				if(proteger_matriz_val == false){ //primeira coisa a executar dentro de BLOCO_M
					pilha_pilha_matriz.push_back(vector<elemento_matriz>());
					proteger_matriz_val = true;
				}

				$$.label = $2.label;
				$$.tipo = $2.tipo;
				$$.tamanho_vetor = $2.tamanho_vetor;
				$$.valor_armazenado = $2.valor_armazenado;
				$$.num_linhas = $2.num_linhas;
				$$.num_colunas = $2.num_colunas;

				elemento_matriz dolar;
				dolar.tipo = $2.tipo;
				dolar.valor = $2.label;

				pilha_pilha_matriz.back().push_back(dolar);
			}
			|
			;

CELULA_M 	: E RECURSAO_C_M {
				if(proteger_matriz_val == false){ //primeira coisa a executar dentro de BLOCO_M
					pilha_pilha_matriz.push_back(vector<elemento_matriz>());
					proteger_matriz_val = true;
				}

				$$.label = $1.label;
				$$.tipo = $1.tipo;
				$$.tamanho_vetor = $1.tamanho_vetor;
				$$.valor_armazenado = $1.valor_armazenado;
				$$.num_linhas = $1.num_linhas;
				$$.num_colunas = $1.num_colunas;

				elemento_matriz dolar;
				dolar.tipo = $1.tipo;
				dolar.valor = $1.label;

				pilha_pilha_matriz.back().push_back(dolar);
			}			
			;

LINHA_M 	: '{' CELULA_M '}' {
			}
			| '{' CELULA_M '}' ',' LINHA_M {
			}
			;

BLOCO_M		: '{' LINHA_M '}' {
			}
			;

LISTA_ATR	: LISTA_ATR_VAZIA
			| LISTA_ATR_PREENCHIDA
			;

LISTA_ATR_PREENCHIDA			
			: E {
				atributos_funcao temp;
				temp.nome = $1.label;
				temp.tipo = $1.tipo;
				atributos_aux2.push_back(temp);
			}
			| E ',' LISTA_ATR {
				atributos_funcao temp;
				temp.nome = $1.label;
				temp.tipo = $1.tipo;
				atributos_aux2.push_back(temp);
			}
			;

LISTA_ATR_VAZIA: {
				atributos_aux2.clear();
			}
			;

BLOCO_CASE	: BLOCO_CASE TOKEN_CASE E NOVA_LINHA COMANDOS {
				string rotulo_inicio = gerar_rotulo();
				string rotulo_meio = gerar_rotulo();

				$$.traducao = $1.traducao + 
						"\t" + rotulo_inicio + ":\n" + 
						$3.traducao +
						"\t" + "if(" + variavel_switch_global + " == " + $3.label + ") goto " + rotulo_meio + ";\n" + 
						"\t" + "goto " + "rotulo" + to_string(rotulo_num+1) + ";\n" +
						"\t" + rotulo_meio + ":\n" + 
						$5.traducao +
						"\t" + "goto " + "rotulo_fim_switch" + ";\n";
			}
			| TOKEN_CASE E NOVA_LINHA COMANDOS {
				string rotulo_inicio = gerar_rotulo();
				string rotulo_meio = gerar_rotulo();

				$$.traducao = "\t" + rotulo_inicio + ":\n" +
						$2.traducao + 
						"\t" + "if(" + variavel_switch_global + " == " + $2.label + ") goto " + rotulo_meio + ";\n" + 
						"\t" + "goto " + "rotulo" + to_string(rotulo_num+1) + ";\n" +
						"\t" + rotulo_meio + ":\n" + 
						$4.traducao +
						"\t" + "goto " + "rotulo_fim_switch" + ";\n";
			}
			;

BLOCO_LOOP	: '{' { 	// a mesma coisa que BLOCO: '{' NOVA_LINHA COMANDOS '}' 

				rotulo_loop_inicio_tmp = gerar_rotulo();
				rotulo_loop_iteracao_tmp = gerar_rotulo();
				rotulo_loop_meio_tmp = gerar_rotulo();
				rotulo_loop_fim_tmp = gerar_rotulo();

				pilha_rotulo_inicio.push_back(rotulo_loop_inicio_tmp);
				pilha_rotulo_iteracao.push_back(rotulo_loop_iteracao_tmp);
				pilha_rotulo_meio.push_back(rotulo_loop_meio_tmp);
				pilha_rotulo_fim.push_back(rotulo_loop_fim_tmp);
				
				escopo_atual++;
				pilha_tabela_simbolos.push_back(vector<TIPO_SIMBOLO>());
				memoria_pilha_tabela_simbolos.push_back(vector<TIPO_SIMBOLO>());

			} NOVA_LINHA COMANDOS '}' {

				escopo_atual--;
				pilha_tabela_simbolos.pop_back();

				$$.traducao = $4.traducao;
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

BLOCO_RET	: '{' { //CUIDADO, não tem casting no retorno
				
				escopo_atual++;
				pilha_tabela_simbolos.push_back(vector<TIPO_SIMBOLO>());
				memoria_pilha_tabela_simbolos.push_back(vector<TIPO_SIMBOLO>());

			} NOVA_LINHA COMANDOS TOKEN_RETURN E NOVA_LINHA '}' {
				
				escopo_atual--;
				pilha_tabela_simbolos.pop_back();

				$$.traducao = $4.traducao + $6.traducao + "\t" + "return" + " " + $6.label + ";";
			}
			;

COMANDOS	: COMANDOS COMANDO  { // CUIDADO, antes era COMANDO COMANDOS, tirei o shift/reduce
				$$.traducao = $1.traducao + $2.traducao;
			}
			| {
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

				add_na_tabela_simbolos(escopo_atual, $2.label, gerar_label(), $1.label, $$.tamanho_vetor, $$.valor_armazenado, "", "");
			}
			| TOKEN_TIPO_FLOAT TOKEN_ID NOVA_LINHA {
				$$.label = "";
				$$.tipo = "";
				$$.traducao = "";
				$$.tamanho_vetor = "";
				$$.valor_armazenado = "";

				add_na_tabela_simbolos(escopo_atual, $2.label, gerar_label(), $1.label, $$.tamanho_vetor, $$.valor_armazenado, "", "");
			}
			| TOKEN_TIPO_STRING TOKEN_ID NOVA_LINHA {
				$$.label = "";
				$$.tipo = "";
				$$.traducao = "";
				$$.tamanho_vetor = "";
				$$.valor_armazenado = "";

				add_na_tabela_simbolos(escopo_atual, $2.label, gerar_label(), $1.label, $$.tamanho_vetor, $$.valor_armazenado, "", "");
			}
			| TOKEN_TIPO_BOOL TOKEN_ID NOVA_LINHA {
				$$.label = "";
				$$.tipo = "";
				$$.traducao = "";
				$$.tamanho_vetor = "";
				$$.valor_armazenado = "";

				add_na_tabela_simbolos(escopo_atual, $2.label, gerar_label(), $1.label, $$.tamanho_vetor, $$.valor_armazenado, "", "");
			}
			| TOKEN_TIPO_INT TOKEN_ID TOKEN_OPERADOR_IGUAL E NOVA_LINHA {
				$$.tipo = $1.label;
				$$.tamanho_vetor = "";
				$$.valor_armazenado = "";

				if(necessario_conversao_implicita_tipo($1.label, $4.tipo)){

					$$.label = gerar_label();
					add_na_tabela_simbolos(escopo_atual, $2.label, $$.label, $1.label, $$.tamanho_vetor, $$.valor_armazenado, "", "");

					$$.traducao = $2.traducao + $4.traducao + "\t" + $$.label + " = " + "(int) " + $4.label + ";\n";
				}
				else{
					$$.label = gerar_label();
					add_na_tabela_simbolos(escopo_atual, $2.label, $$.label, $1.label, $$.tamanho_vetor, $$.valor_armazenado, "", "");

					$$.traducao = $2.traducao + $4.traducao + "\t" + $$.label + " = " + $4.label + ";\n";
				}
			}
			| TOKEN_TIPO_FLOAT TOKEN_ID TOKEN_OPERADOR_IGUAL E NOVA_LINHA {
				$$.tipo = $1.label;
				$$.tamanho_vetor = "";
				$$.valor_armazenado = "";

				if(necessario_conversao_implicita_tipo($1.label, $4.tipo)){

					$$.label = gerar_label();
					add_na_tabela_simbolos(escopo_atual, $2.label, $$.label, $1.label, $$.tamanho_vetor, $$.valor_armazenado, "", "");

					$$.traducao = $2.traducao + $4.traducao + "\t" + $$.label + " = " + "(float) " + $4.label + ";\n";
				}
				else{
					$$.label = gerar_label();
					add_na_tabela_simbolos(escopo_atual, $2.label, $$.label, $1.label, $$.tamanho_vetor, $$.valor_armazenado, "", "");

					$$.traducao = $2.traducao + $4.traducao + "\t" + $$.label + " = " + $4.label + ";\n";
				}
			}
			| TOKEN_TIPO_BOOL TOKEN_ID TOKEN_OPERADOR_IGUAL E NOVA_LINHA {
				$$.tipo = $1.label;
				$$.tamanho_vetor = "";
				$$.valor_armazenado = "";

				if(necessario_conversao_implicita_tipo($1.label, $4.tipo)){ // nunca entra aqui

					$$.label = gerar_label();
					add_na_tabela_simbolos(escopo_atual, $2.label, $$.label, $1.label, $$.tamanho_vetor, $$.valor_armazenado, "", "");

					$$.traducao = $2.traducao + $4.traducao + "\t" + $$.label + " = " + "(bool) " + $4.label + ";\n";
				}
				else{
					$$.label = gerar_label();
					add_na_tabela_simbolos(escopo_atual, $2.label, $$.label, $1.label, $$.tamanho_vetor, $$.valor_armazenado, "", "");

					$$.traducao = $2.traducao + $4.traducao + "\t" + $$.label + " = " + $4.label + ";\n";
				}
			}
			| TOKEN_TIPO_STRING TOKEN_ID TOKEN_OPERADOR_IGUAL E NOVA_LINHA {
				$$.tipo = $1.label;
				$$.tamanho_vetor = $4.tamanho_vetor;
				$$.valor_armazenado = $4.valor_armazenado;

				if(necessario_conversao_implicita_tipo($1.label, $4.tipo)){ // nunca entra aqui

					$$.label = gerar_label();
					add_na_tabela_simbolos(escopo_atual, $2.label, $$.label, $1.label, $$.tamanho_vetor, $$.valor_armazenado, "", "");

					$$.traducao = $2.traducao + $4.traducao + "\t" + $$.label + " = " + "(string) " + $4.label + ";\n";
				}
				else{
					$$.label = gerar_label();
					add_na_tabela_simbolos(escopo_atual, $2.label, $$.label, $1.label, $$.tamanho_vetor, $$.valor_armazenado, "", "");

					$$.traducao = $2.traducao + $4.traducao + "\t" + "strcpy(" + $4.label + ", " + $$.label + ");\n";
				}
			}
			| TOKEN_TIPO_INT TOKEN_ID '[' E ']' '[' E ']' NOVA_LINHA { // PRECISA CONVERSAO IMPLICITA
				if($4.tipo == "int" && $7.tipo == "int"){
					$$.tipo = $1.label;
					$$.tamanho_vetor = ""; //no caso de ser um vetor
					$$.valor_armazenado = "";
					$$.num_linhas = $4.label; //no caso de ser uma matriz
					$$.num_colunas = $7.label;

					$$.label = gerar_label();
					add_na_tabela_simbolos(escopo_atual, $2.label, $$.label, $$.tipo, $$.tamanho_vetor, $$.valor_armazenado, $$.num_linhas, $$.num_colunas);

					$$.traducao = $2.traducao + $4.traducao + $7.traducao + "\t" + $$.tipo + " " + $$.label + "[" + $4.label + "][" + $7.label + "];\n";
				}
			}
			| TOKEN_TIPO_FLOAT TOKEN_ID '[' E ']' '[' E ']' NOVA_LINHA { // PRECISA CONVERSAO IMPLICITA
				if($4.tipo == "int" && $7.tipo == "int"){
					$$.tipo = $1.label;
					$$.tamanho_vetor = ""; //no caso de ser um vetor
					$$.valor_armazenado = "";
					$$.num_linhas = $4.label; //no caso de ser uma matriz
					$$.num_colunas = $7.label;

					$$.label = gerar_label();
					add_na_tabela_simbolos(escopo_atual, $2.label, $$.label, $$.tipo, $$.tamanho_vetor, $$.valor_armazenado, $$.num_linhas, $$.num_colunas);

					$$.traducao = $2.traducao + $4.traducao + $7.traducao + "\t" + $$.tipo + " " + $$.label + "[" + $4.label + "][" + $7.label + "];\n";
				}
			}
			| TOKEN_TIPO_BOOL TOKEN_ID '[' E ']' '[' E ']' NOVA_LINHA { // PRECISA CONVERSAO IMPLICITA
				if($4.tipo == "int" && $7.tipo == "int"){
					$$.tipo = $1.label;
					$$.tamanho_vetor = ""; //no caso de ser um vetor
					$$.valor_armazenado = "";
					$$.num_linhas = $4.label; //no caso de ser uma matriz
					$$.num_colunas = $7.label;

					$$.label = gerar_label();
					add_na_tabela_simbolos(escopo_atual, $2.label, $$.label, $$.tipo, $$.tamanho_vetor, $$.valor_armazenado, $$.num_linhas, $$.num_colunas);

					$$.traducao = $2.traducao + $4.traducao + $7.traducao + "\t" + $$.tipo + " " + $$.label + "[" + $4.label + "][" + $7.label + "];\n";
				}
			}
			| TOKEN_TIPO_STRING TOKEN_ID '[' E ']' '[' E ']' NOVA_LINHA { // PRECISA CONVERSAO IMPLICITA
				if($4.tipo == "int" && $7.tipo == "int"){
					$$.tipo = $1.label;
					$$.tamanho_vetor = ""; //no caso de ser um vetor
					$$.valor_armazenado = "";
					$$.num_linhas = $4.label; //no caso de ser uma matriz
					$$.num_colunas = $7.label;

					$$.label = gerar_label();
					add_na_tabela_simbolos(escopo_atual, $2.label, $$.label, $$.tipo, $$.tamanho_vetor, $$.valor_armazenado, $$.num_linhas, $$.num_colunas);

					$$.traducao = $2.traducao + $4.traducao + $7.traducao + "\t" + "char" + " " + $$.label + "[" + $4.label + "][" + $7.label + "];\n";
				}
			}
			| TOKEN_VOID TOKEN_ID '[' E ']' '[' E ']' NOVA_LINHA { // PRECISA CONVERSAO IMPLICITA
				if($4.tipo == "int" && $7.tipo == "int"){
					$$.tipo = "void";
					$$.tamanho_vetor = ""; //no caso de ser um vetor
					$$.valor_armazenado = "";
					$$.num_linhas = $4.label; //no caso de ser uma matriz
					$$.num_colunas = $7.label;

					$$.label = gerar_label();
					add_na_tabela_simbolos(escopo_atual, $2.label, $$.label, $$.tipo, $$.tamanho_vetor, $$.valor_armazenado, $$.num_linhas, $$.num_colunas);

					$$.traducao = $2.traducao + $4.traducao + $7.traducao + "\t" + $$.tipo + " " + $$.label + "[" + $4.label + "][" + $7.label + "];\n";
				}
			}
			| TOKEN_IF '(' E ')' BLOCO NOVA_LINHA {
				if($3.tipo == "bool"){
					$$.label = "";
					$$.tipo = "";
					$$.tamanho_vetor = "";
					$$.valor_armazenado = "";
					
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
					add_na_tabela_simbolos(escopo_atual, "", novo_label, $7.tipo, "", "", "", "");

					string rotulo_inicio = rotulo_loop_inicio_tmp;
					string rotulo_iteracao = rotulo_loop_iteracao_tmp;
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

						"\t" + rotulo_iteracao + ":\n" +
						$13.traducao +
						$11.traducao +
						"\t" + valor_dolar11.nome_variavel_temporaria + " = " + $13.label + ";\n" +

						"\tgoto " + rotulo_inicio + ";\n" +
						"\t" + rotulo_fim + ":\n";

					pilha_rotulo_inicio.pop_back();
					pilha_rotulo_iteracao.pop_back();
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
					add_na_tabela_simbolos(escopo_atual, "", novo_label, $7.tipo, "", "", "", "");

					string rotulo_inicio = rotulo_loop_inicio_tmp;
					string rotulo_iteracao = rotulo_loop_iteracao_tmp;
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

						"\t" + rotulo_iteracao + ":\n" +
						$13.traducao +
						$11.traducao +
						"\t" + valor_dolar11.nome_variavel_temporaria + " = " + $13.label + ";\n" +

						"\tgoto " + rotulo_inicio + ";\n" +
						"\t" + rotulo_fim + ":\n";

					pilha_rotulo_inicio.pop_back();
					pilha_rotulo_iteracao.pop_back();
					pilha_rotulo_meio.pop_back();
					pilha_rotulo_fim.pop_back();
				}
				else{
					yyerror("erro no for!");
				}
			}
			| TOKEN_SWITCH '(' E ')' { //inicio do switch

				escopo_atual++;
				pilha_tabela_simbolos.push_back(vector<TIPO_SIMBOLO>());
				memoria_pilha_tabela_simbolos.push_back(vector<TIPO_SIMBOLO>());

				variavel_switch_global = $3.label;

			} '{' NOVA_LINHA BLOCO_CASE TOKEN_DEFAULT NOVA_LINHA COMANDOS '}' NOVA_LINHA { //meio e fim do switch

				escopo_atual--;
				pilha_tabela_simbolos.pop_back();

				string rotulo_inicio = gerar_rotulo();

				$$.traducao = $3.traducao + $8.traducao + "\t" + rotulo_inicio + ":\n" + $11.traducao + "\t" + "rotulo_fim_switch" + ":\n";
			}
			| TOKEN_BREAK NOVA_LINHA {
    			if (pilha_rotulo_fim.empty()) {
        			yyerror("Comando break precisa estar dentro de um laço! (nessa LP)");
    			} 
				else {
        			$$.traducao = "\tgoto " + pilha_rotulo_fim.back() + ";\n";
    			}
			}
			| TOKEN_CONTINUE NOVA_LINHA {
    			if (pilha_rotulo_inicio.empty()) {
        			yyerror("Comando continue fora de um laço!");
    			} 
				else {
        			$$.traducao = "\tgoto " + pilha_rotulo_iteracao.back() + ";\n";
    			}
			}
			;

E 			: BLOCO
			| E TOKEN_OPERADOR_MAIS_MAIS {
				if(($1.tipo == "int" || $1.tipo == "float")){
					$$.tipo = $1.tipo;
					$$.tamanho_vetor = "";
					$$.valor_armazenado = std::to_string(atoi($1.valor_armazenado.c_str()) + 1);

					$$.label = gerar_label();
					add_na_tabela_simbolos(escopo_atual, "", $$.label, $$.tipo, $$.tamanho_vetor, $$.valor_armazenado, "", "");

					$$.traducao = $1.traducao + "\t" + $$.label + " = " + $1.label + " + " + "1" + ";\n" + "\t" + $1.label + " = " + $$.label + ";\n";
				}
			}
			| E TOKEN_OPERADOR_MENOS_MENOS {
				if(($1.tipo == "int" || $1.tipo == "float")){
					$$.tipo = $1.tipo;
					$$.tamanho_vetor = "";
					$$.valor_armazenado = std::to_string(atoi($1.valor_armazenado.c_str()) - 1);

					$$.label = gerar_label();
					add_na_tabela_simbolos(escopo_atual, "", $$.label, $$.tipo, $$.tamanho_vetor, $$.valor_armazenado, "", "");

					$$.traducao = $1.traducao + "\t" + $$.label + " = " + $1.label + " - " + "1" + ";\n" + "\t" + $1.label + " = " + $$.label + ";\n";
				}
			}
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

					add_na_tabela_simbolos(escopo_atual, "", $$.label, $$.tipo, $$.tamanho_vetor, $$.valor_armazenado, "", "");
				
					$$.traducao = $1.traducao + $3.traducao + declaracao_caracteres + "\t" + $$.label + "[" + to_string(tamanho_string) + "]" + " = " + "'" + "\\" + "0" + "'" + ";\n";
				}
				else{
					$$.tipo = tipo_resultante($1, $3);
					$$.tamanho_vetor = "";
					$$.valor_armazenado = "";

					if(necessario_conversao_implicita_tipo($1.tipo, $3.tipo)){
						string comando_extra;
						string label_extra = gerar_label();
						add_na_tabela_simbolos(escopo_atual, "", label_extra, $$.tipo, $$.tamanho_vetor, $$.valor_armazenado, "", "");

						comando_extra = "\t" + label_extra + " = " + '(' + $$.tipo + ") " + (($1.tipo != tipo_resultante($1, $3))? $1.label: $3.label) + ";\n";

						$$.label = gerar_label();
						add_na_tabela_simbolos(escopo_atual, "", $$.label, $$.tipo, $$.tamanho_vetor, $$.valor_armazenado, "", "");

						$$.traducao = $1.traducao + $3.traducao + comando_extra + "\t" + $$.label + " = " + 
							(($1.tipo != tipo_resultante($1, $3))? label_extra + " " + $2.label + " " + $3.label: $1.label + " " + $2.label + " " + label_extra) + ";\n";
					}
					else{
						$$.label = gerar_label();
						add_na_tabela_simbolos(escopo_atual, "", $$.label, $$.tipo, $$.tamanho_vetor, $$.valor_armazenado, "", "");

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
					add_na_tabela_simbolos(escopo_atual, "", label_extra, $$.tipo, $$.tamanho_vetor, $$.valor_armazenado, "", "");

					comando_extra = "\t" + label_extra + " = " + '(' + $$.tipo + ") " + (($1.tipo != tipo_resultante($1, $3))? $1.label: $3.label) + ";\n";

					$$.label = gerar_label();
					add_na_tabela_simbolos(escopo_atual, "", $$.label, $$.tipo, $$.tamanho_vetor, $$.valor_armazenado, "", "");

					$$.traducao = $1.traducao + $3.traducao + comando_extra + "\t" + $$.label + " = " + 
						(($1.tipo != tipo_resultante($1, $3))? label_extra + " " + $2.label + " " + $3.label: $1.label + " " + $2.label + " " + label_extra) + ";\n";
				}
				else{
					$$.label = gerar_label();
					add_na_tabela_simbolos(escopo_atual, "", $$.label, $$.tipo, $$.tamanho_vetor, $$.valor_armazenado, "", "");

					$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " " + $2.label + " " + $3.label + ";\n";
				}
			}
			| TOKEN_OPERADOR_MAIS_MENOS E %prec unario {
				if($2.tipo == "float" || $2.tipo == "int"){
					$$.label = gerar_label();
					$$.tipo = $2.tipo;
					$$.tamanho_vetor = "";
					$$.valor_armazenado = "";
					add_na_tabela_simbolos(escopo_atual, "", $$.label, $$.tipo, $$.tamanho_vetor, $$.valor_armazenado, "", "");

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
					add_na_tabela_simbolos(escopo_atual, "", $$.label, $$.tipo, $$.tamanho_vetor, $$.valor_armazenado, "", "");

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
					add_na_tabela_simbolos(escopo_atual, "", $$.label, $$.tipo, $$.tamanho_vetor, $$.valor_armazenado, "", "");

					$$.traducao = $3.traducao + "\t" + $$.label + " = " + "(int) " + $3.label + ";\n";
				}
			}
			| TOKEN_TIPO_FLOAT '(' E ')' %prec CAST {
				if(possivel_realizar_casting_explicito("float", $3)){
					$$.label = gerar_label();
					$$.tipo = "float";
					$$.tamanho_vetor = "";
					$$.valor_armazenado = "";
					add_na_tabela_simbolos(escopo_atual, "", $$.label, $$.tipo, $$.tamanho_vetor, $$.valor_armazenado, "", "");

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
			| TOKEN_ID '(' LISTA_ATR ')' {
				$$.label = gerar_label();
				$$.tipo = $1.tipo;
				$$.tamanho_vetor = "";
				$$.valor_armazenado = "";
				$$.num_linhas = "";
				$$.num_colunas = "";

				int indice_funcao;
				int acertos = 0;
				bool erro;
				int tamanho;

				bool encontrou_funcao_compatível = false;

				for (size_t i = 0; i < vetor_funcoes.size(); ++i) {
					if ($1.label == vetor_funcoes[i].nome) {
						if (atributos_aux2.size() == vetor_funcoes[i].atributos.size()) {
							bool tipos_batem = true;
							for (size_t j = 0; j < atributos_aux2.size(); ++j) {
								if (atributos_aux2[j].tipo != vetor_funcoes[i].atributos[j].tipo) {
									tipos_batem = false;
									break;
								}
							}

							if (tipos_batem) {
								indice_funcao = i;
								encontrou_funcao_compatível = true;
								break;
							}
						}
					}
				}

				if (!encontrou_funcao_compatível) {
					yyerror("é necessário que a função seja compatível com números e tipos de atributos!");
				}

				add_na_tabela_simbolos(escopo_atual, "", $$.label, $$.tipo, $$.tamanho_vetor, $$.valor_armazenado, "", "");

				string declaracoes = "";

				for(int i = atributos_aux2.size()-1; i >= 0; i--){
					if(i == 0){
						declaracoes = declaracoes + atributos_aux2[i].nome;
					}
					else{
						declaracoes = declaracoes + atributos_aux2[i].nome + ", ";
					}
				}

				$$.traducao = "\t" + $$.label + " = " + $1.label + "(" + declaracoes + ")" + ";\n";

				atributos_aux2.clear();
			}
			| TOKEN_ID TOKEN_OPERADOR_IGUAL BLOCO_M {
				$$.label = "";
				$$.tipo = "";
				$$.tamanho_vetor = "";
				$$.valor_armazenado = "";
				$$.num_linhas = "";
				$$.num_colunas = "";

				vector<string> pilha_temporarios;

				string declaracoes;

				int ultima_posicao = pilha_pilha_matriz.size() - 1;
				vector<elemento_matriz>& ultima_pilha = pilha_pilha_matriz[ultima_posicao];

				TIPO_SIMBOLO pegar_tipo_misteriosamente_errado = buscar_na_tabela_simbolos(escopo_atual, $1); // CUIDADO !!!

				if(pegar_tipo_misteriosamente_errado.tipo_variavel == "string"){
					string declaracao_caracteres = "";

					for (int i = 0; i < ultima_pilha.size(); i++) {
						if(ultima_pilha[i].tipo == "string"){

							atributos temp;
							temp.label = ultima_pilha[i].valor;
							temp.tipo = ultima_pilha[i].tipo;
							TIPO_SIMBOLO valor_dolar = buscar_na_tabela_simbolos_nome_variavel_temporaria(escopo_atual, temp);

							atributos temp2;
							temp2.label = valor_dolar.nome_variavel_temporaria;

							TIPO_SIMBOLO valor_interno = buscar_na_tabela_simbolos_nome_variavel_temporaria(escopo_atual, temp2);

							int tamanho_string = strlen_da_shopee(valor_interno.valor_variavel_armazenado)-2; // n conta as ""
							string tamanho_vetor = to_string(tamanho_string); // tmb n conta as ""

							int cont = 0;

							for(int i = 0; i < tamanho_string+2; i++) { // +2 para ser contadas tmb as posições com ""
								if(valor_interno.valor_variavel_armazenado[i] != '"'){
									declaracao_caracteres = declaracao_caracteres + "\t" + valor_interno.nome_variavel_temporaria + 
										"[" + to_string(cont) + "]" + " = " + "'" + valor_interno.valor_variavel_armazenado[i] + "'" + ";\n";
									cont++;
								}
							}

							declaracao_caracteres = declaracao_caracteres + "\t" + valor_dolar.nome_variavel_temporaria + "[" + to_string(cont) + "]" + " = " + "'" + "\\" + "0" + "'" + ";\n";
							pilha_temporarios.push_back(valor_dolar.nome_variavel_temporaria);
						}
						else{
							yyerror("não é possível realizar o casting implicito com esses tipos !");
						}
					}
					declaracoes = declaracao_caracteres;
				}
				else{
					for (int i = 0; i < ultima_pilha.size(); i++) {
						atributos temp;
						temp.label = ultima_pilha[i].valor;
						temp.tipo = ultima_pilha[i].tipo;
						TIPO_SIMBOLO valor_dolar = buscar_na_tabela_simbolos_nome_variavel_temporaria(escopo_atual, temp);

						if(necessario_conversao_implicita_tipo(pegar_tipo_misteriosamente_errado.tipo_variavel, temp.tipo)){
							string comando_extra;
							string label_extra = gerar_label();
							add_na_tabela_simbolos(escopo_atual, "", label_extra, pegar_tipo_misteriosamente_errado.tipo_variavel, "", "" , "", "");

							comando_extra = "\t" + label_extra + " = " + '(' + pegar_tipo_misteriosamente_errado.tipo_variavel + ") " + 
								valor_dolar.nome_variavel_temporaria + ";\n";

							declaracoes = declaracoes + "\t" + valor_dolar.nome_variavel_temporaria + " = " + valor_dolar.valor_variavel_armazenado + ";\n" + comando_extra;
							pilha_temporarios.push_back(label_extra);
						}
						else{
							declaracoes = declaracoes + "\t" + valor_dolar.nome_variavel_temporaria + " = " + valor_dolar.valor_variavel_armazenado + ";\n";
							pilha_temporarios.push_back(valor_dolar.nome_variavel_temporaria);
						}
					}
				}	

				atributos temp2;
				temp2.label = buscar_na_tabela_simbolos(escopo_atual, $1).nome_variavel_real;

				TIPO_SIMBOLO valor_dolar_i = buscar_na_tabela_simbolos(escopo_atual, temp2);
				TIPO_SIMBOLO valor_dolar_j = buscar_na_tabela_simbolos(escopo_atual, temp2);

				atributos temp3;
				atributos temp4;
				temp3.label = valor_dolar_i.nome_variavel_temporaria;
				temp4.label = valor_dolar_j.nome_variavel_temporaria;

				atributos temp5;
				atributos temp6;
				temp3.label = buscar_na_tabela_simbolos_nome_variavel_temporaria(escopo_atual, temp3).num_linhas_variavel;
				temp4.label = buscar_na_tabela_simbolos_nome_variavel_temporaria(escopo_atual, temp4).num_colunas_variavel;

				TIPO_SIMBOLO valor_linhas = buscar_na_tabela_simbolos_nome_variavel_temporaria(escopo_atual, temp3);
				TIPO_SIMBOLO valor_colunas = buscar_na_tabela_simbolos_nome_variavel_temporaria(escopo_atual, temp4);

				string bloco_matriz = "";
				int cont = atoi(valor_linhas.valor_variavel_armazenado.c_str()) * atoi(valor_colunas.valor_variavel_armazenado.c_str()) - 1;

				vector<string> aux;

				if(cont+1 == pilha_pilha_matriz.back().size()){
					for (int i = atoi(valor_linhas.valor_variavel_armazenado.c_str())-1; i >= 0; i--) {
						bloco_matriz = bloco_matriz + "{";
						for(int j = atoi(valor_colunas.valor_variavel_armazenado.c_str())-1; j >= 0; j--){
							if(j == 0){
								bloco_matriz = bloco_matriz + pilha_temporarios[cont];
							}
							else{
								bloco_matriz = bloco_matriz + pilha_temporarios[cont] + ", ";
							}

							cont--;
						}
						bloco_matriz = bloco_matriz + "}";
						aux.push_back(bloco_matriz);
						bloco_matriz = "";
					}	
				}
				else{
					yyerror("os dados da matriz não batem !");
				}

				string matriz_final_ordenada = "{";

				for (int i = aux.size()-1; i >=0; i--) {
					if(i == 0){
						matriz_final_ordenada = matriz_final_ordenada + aux[i];
					}
					else{
						matriz_final_ordenada = matriz_final_ordenada + aux[i] + ", ";
					}
				}

				TIPO_SIMBOLO nome_val_temp = buscar_na_tabela_simbolos(escopo_atual, $1);

				string declaracoes_finais = "";

				if(pegar_tipo_misteriosamente_errado.tipo_variavel == "string"){
					for (int i = 0; i < ultima_pilha.size(); i++) {
						declaracoes_finais = declaracoes_finais + "\t" + "strcpy(" + nome_val_temp.nome_variavel_temporaria + 
							"[" + to_string(i) + "], " + pilha_temporarios[i] + ")" + ";\n";
					}
					$$.traducao = declaracoes + declaracoes_finais;
				}
				else{
					$$.traducao = declaracoes + "\t" + nome_val_temp.nome_variavel_temporaria + " = " + matriz_final_ordenada + "};\n";
				}

				proteger_matriz_val = false;
			}
			| E TOKEN_OPERADOR_MENOR_MAIOR E {
				$$.tipo = "bool";
				$$.tamanho_vetor = "";
				$$.valor_armazenado = "";

				string tipo_conversao = tipo_resultante($1, $3);

				if(necessario_conversao_implicita_tipo($1.tipo, $3.tipo)){
					string comando_extra;
					string label_extra = gerar_label();
					add_na_tabela_simbolos(escopo_atual, "", label_extra, tipo_conversao, $$.tamanho_vetor, $$.valor_armazenado, "", "");

					comando_extra = "\t" + label_extra + " = " + '(' + tipo_conversao + ") " + (($1.tipo != tipo_conversao)? $1.label: $3.label) + ";\n";

					$$.label = gerar_label();
					add_na_tabela_simbolos(escopo_atual, "", $$.label, tipo_conversao, $$.tamanho_vetor, $$.valor_armazenado, "", "");

					$$.traducao = $1.traducao + $3.traducao + comando_extra + "\t" + $$.label + " = " + 
						(($1.tipo != tipo_conversao)? label_extra + " " + $2.label + " " + $3.label: $1.label + " " + $2.label + " " + label_extra) + ";\n";
				}
				else{
					$$.label = gerar_label();
					add_na_tabela_simbolos(escopo_atual, "", $$.label, $$.tipo, $$.tamanho_vetor, $$.valor_armazenado, "", "");

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
					add_na_tabela_simbolos(escopo_atual, "", label_extra, tipo_conversao, $$.tamanho_vetor, $$.valor_armazenado, "", "");

					comando_extra = "\t" + label_extra + " = " + '(' + tipo_conversao + ") " + (($1.tipo != tipo_conversao)? $1.label: $3.label) + ";\n";

					$$.label = gerar_label();
					add_na_tabela_simbolos(escopo_atual, "", $$.label, tipo_conversao, $$.tamanho_vetor, $$.valor_armazenado, "", "");

					$$.traducao = $1.traducao + $3.traducao + comando_extra + "\t" + $$.label + " = " + 
						(($1.tipo != tipo_conversao)? label_extra + " " + $2.label + " " + $3.label: $1.label + " " + $2.label + " " + label_extra) + ";\n";
				}
				else{
					$$.label = gerar_label();
					add_na_tabela_simbolos(escopo_atual, "", $$.label, $$.tipo, $$.tamanho_vetor, $$.valor_armazenado, "", "");

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
					add_na_tabela_simbolos(escopo_atual, "", label_extra, tipo_conversao, $$.tamanho_vetor, $$.valor_armazenado, "", "");

					comando_extra = "\t" + label_extra + " = " + '(' + tipo_conversao + ") " + (($1.tipo != tipo_conversao)? $1.label: $3.label) + ";\n";

					$$.label = gerar_label();
					add_na_tabela_simbolos(escopo_atual, "", $$.label, tipo_conversao, $$.tamanho_vetor, $$.valor_armazenado, "", "");

					$$.traducao = $1.traducao + $3.traducao + comando_extra + "\t" + $$.label + " = " + 
						(($1.tipo != tipo_conversao)? label_extra + " " + $2.label + " " + $3.label: $1.label + " " + $2.label + " " + label_extra) + ";\n";
				}
				else{
					$$.label = gerar_label();
					add_na_tabela_simbolos(escopo_atual, "", $$.label, $$.tipo, $$.tamanho_vetor, $$.valor_armazenado, "", "");

					$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " " + $2.label + " " + $3.label + ";\n";
				}
			}
			| TOKEN_OPERADOR_NEGADO E {
				$$.tipo = "bool";
				$$.label = gerar_label();
				$$.tamanho_vetor = "";
				$$.valor_armazenado = "";
				add_na_tabela_simbolos(escopo_atual, "", $$.label, $$.tipo, $$.tamanho_vetor, $$.valor_armazenado, "", "");

				$$.traducao = $2.traducao + "\t" + $$.label + " = " + $1.label + $2.label + ";\n";
			}
			| TOKEN_ID TOKEN_OPERADOR_IGUAL TOKEN_INPUT '(' E ')'{
				if($5.tipo == "string"){
					TIPO_SIMBOLO valor_dolar1 = buscar_na_tabela_simbolos(escopo_atual, $1);

					$$.tipo = valor_dolar1.tipo_variavel;
					$$.label = valor_dolar1.nome_variavel_temporaria;
					$$.tamanho_vetor = "200";
					$$.valor_armazenado = valor_dolar1.valor_variavel_armazenado;

					mudar_tamanho_vetor_na_pilha_tabela_simbolos(escopo_atual, $1, $$);

					$$.traducao = $5.traducao + "\t" + "std::cout << " + $5.label + " << std::endl;\n" 
					+ "\t" + "std::cin >> " + $$.label + ";\n";
				}
				else{
					yyerror("a mensagem precisa ser do tipo string !");
				}
			}
			| TOKEN_ID TOKEN_OPERADOR_IGUAL TOKEN_INPUT '(' ')'{
				TIPO_SIMBOLO valor_dolar1 = buscar_na_tabela_simbolos(escopo_atual, $1);

				$$.tipo = valor_dolar1.tipo_variavel;
				$$.label = valor_dolar1.nome_variavel_temporaria;
				$$.tamanho_vetor = "200";
				$$.valor_armazenado = valor_dolar1.valor_variavel_armazenado;

				mudar_tamanho_vetor_na_pilha_tabela_simbolos(escopo_atual, $1, $$);

				string teste = "std::cin >> " + $$.label + ";\n";

				$$.traducao = "\t" + teste; // "\t" + "std::cin >> " + $$.label + ";\n"; tava dando erro não sei pq então criei string teste
			}
			| TOKEN_OUTPUT '(' E ')'{
				$$.traducao = $3.traducao + "\t" + "std::cout << " + $3.label + " << std::endl;\n";
			}
			| E '[' E ']' { // CUIDADO, precisa de casting implicito
				if($1.tipo == "string" && $3.tipo == "int"){
					$$.label = gerar_label();
					$$.tipo = $1.tipo;
					$$.tamanho_vetor = "";
					$$.valor_armazenado = "";
					add_na_tabela_simbolos(escopo_atual, "", $$.label, $$.tipo, $$.tamanho_vetor, $$.valor_armazenado, "", "");

					$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + "[" + $3.label + "]" + ";\n";
				}
				else if($1.tipo == "string" && $3.tipo == "float"){
					$$.tamanho_vetor = "";
					$$.valor_armazenado = "";

					string label_extra = gerar_label();
					add_na_tabela_simbolos(escopo_atual, "", label_extra, "int", $$.tamanho_vetor, $$.valor_armazenado, "", "");

					string comando_extra = "\t" + label_extra + " = " + "int(" + $3.label + ")" + ";\n"; 
					
					$$.label = gerar_label();
					$$.tipo = $1.tipo;
					add_na_tabela_simbolos(escopo_atual, "", $$.label, $$.tipo, $$.tamanho_vetor, $$.valor_armazenado, "", "");

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
				add_na_tabela_simbolos(escopo_atual, "", $$.label, $$.tipo, $$.tamanho_vetor, $$.valor_armazenado, "", "");
				
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| TOKEN_VARIAVEL_FLOAT {
				$$.label = gerar_label();
				$$.tipo = "float";
				$$.tamanho_vetor = "";
				$$.valor_armazenado = $1.label;
				add_na_tabela_simbolos(escopo_atual, "", $$.label, $$.tipo, $$.tamanho_vetor, $$.valor_armazenado, "", "");
				
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| TOKEN_VARIAVEL_STRING {
				$$.label = gerar_label();
				$$.tipo = "string";
				$$.valor_armazenado = $1.label;

				int tamanho_string = strlen_da_shopee($1.label)-2; // n conta as ""
				$$.tamanho_vetor = to_string(tamanho_string); // tmb n conta as ""

				add_na_tabela_simbolos(escopo_atual, "", $$.label, $$.tipo, $$.tamanho_vetor, $$.valor_armazenado, "", "");

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
				add_na_tabela_simbolos(escopo_atual, "", $$.label, "bool", $$.tamanho_vetor, $$.valor_armazenado, "", "");
				
				$$.traducao = "\t" + $$.label + " = " + var_aux + ";\n";
			}
			| TOKEN_ID {
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

void add_na_tabela_simbolos(int escopo, string nome_variavel_real, string nome_variavel_temporaria, string tipo_variavel, string tamanho_variavel_vetor, 
	string valor_variavel_armazenado, string valor_num_linhas, string valor_num_colunas){

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
	valor.num_linhas_variavel = valor_num_linhas;
	valor.num_colunas_variavel = valor_num_colunas;

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

TIPO_SIMBOLO buscar_na_tabela_simbolos_nome_variavel_temporaria(int escopo, atributos a1){
	for(int i = escopo; i >= 0; i--){
		for(int j = 0; j < pilha_tabela_simbolos[i].size(); j++){
			if(a1.label == pilha_tabela_simbolos[i][j].nome_variavel_temporaria){
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