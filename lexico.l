%{
#include <string>
%}

digit [0-9]
letter [a-zA-Z]
caracter_especial [!#$%&'()*+,\-./:;<>=?_{}|\[\]\\]
espaco [ \t]

relacional ("!="|"=="|"<="|">=")

string \"({digit}|{letter}|{caracter_especial}|" ")*\"
ID {letter}({letter}|{digit})*

%%

{espaco}+                           ; // ignora espaços e tabs

(\n)                                { yylineno++; return TOKEN_NOVA_LINHA;}

"main"                              { return TOKEN_MAIN; }

"fun"                               { return TOKEN_FUNC; }

"ret"                               { return TOKEN_RETURN; }

"input"                             { return TOKEN_INPUT; }

"output"                            { return TOKEN_OUTPUT; }

"if"                                { return TOKEN_IF; }

"else"                              { return TOKEN_ELSE; }

"while"                             { return TOKEN_WHILE; }

"do"                                { return TOKEN_DO; }

"for"                               { return TOKEN_FOR; }

"switch"                            { return TOKEN_SWITCH; }

"case"                              { return TOKEN_CASE; }

"default"                           { return TOKEN_DEFAULT; }

"break"                             { return TOKEN_BREAK; }

"continue"                          { return TOKEN_CONTINUE; }

"int"                               { yylval.label = "int"; return TOKEN_TIPO_INT; }

"float"                             { yylval.label = "float"; return TOKEN_TIPO_FLOAT; }

"string"                            { yylval.label = "string"; return TOKEN_TIPO_STRING; }

"bool"                              { yylval.label = "bool"; return TOKEN_TIPO_BOOL; }

{digit}+                            { yylval.label = yytext; yylval.tipo = "int"; return TOKEN_VARIAVEL_INT; }

{digit}+("."{digit}+)?              { yylval.label = yytext; return TOKEN_VARIAVEL_FLOAT; }

{string}                            { yylval.label = yytext; return TOKEN_VARIAVEL_STRING; }

("true"|"false")                    { yylval.label = yytext; return TOKEN_VARIAVEL_BOOL; }

{ID}                                { yylval.label = yytext; return TOKEN_ID; }

[(){}[\];,]                         { return *yytext; }

{relacional}                        { yylval.label = yytext; return TOKEN_OPERADOR_RELACIONAL; }

("&&"|"||")                         { yylval.label = yytext; return TOKEN_OPERADOR_E_OU; }

[<>]                                { yylval.label = yytext; return TOKEN_OPERADOR_MENOR_MAIOR; }

[!]                                 { yylval.label = yytext; return TOKEN_OPERADOR_NEGADO; }

[=]                                 { yylval.label = yytext; return TOKEN_OPERADOR_IGUAL; }

[%]                                 { yylval.label = yytext; return TOKEN_OPERADOR_RESTO; } 

"++"                                { yylval.label = yytext; return TOKEN_OPERADOR_MAIS_MAIS; }

"--"                                { yylval.label = yytext; return TOKEN_OPERADOR_MENOS_MENOS; }

[+\-]                               { yylval.label = yytext; return TOKEN_OPERADOR_MAIS_MENOS; }

[*/]                                { yylval.label = yytext; return TOKEN_OPERADOR_VEZES_DIVIDIDO; }

.                                   { *yytext; }
                                
%%