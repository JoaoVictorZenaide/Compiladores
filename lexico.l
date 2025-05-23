%{
#include <string>
%}

digit [0-9]
letter [a-zA-Z]
espaco [ \t]

relacional ("!="|"=="|"<="|">=")

string \"(({letter}|{digit}|{espaco})*?)\"
ID {letter}({letter}|{digit})*

%%

{espaco}+                           ; // ignora espaços e tabs

(\n)                                { yylineno++; return TOKEN_NOVA_LINHA;}

"main"                              { return TOKEN_MAIN; }

"fun"                               { return TOKEN_FUNC; }

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

[+\-]                               { yylval.label = yytext; return TOKEN_OPERADOR_MAIS_MENOS; }

[*/]                                { yylval.label = yytext; return TOKEN_OPERADOR_VEZES_DIVIDIDO; }

.                                   { *yytext; }
                                
%%