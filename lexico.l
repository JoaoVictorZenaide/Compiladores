%{
#include <string>
%}

digit [0-9]
letter [a-zA-Z]
espaco [ \t]

ASCII \"(({letter}|{digit}|{espaco})*?)\"
ID {letter}({letter}|{digit})*

%%

{espaco}+                           ; // ignora espaços e tabs

(\n)                                { yylineno++; return TOKEN_NOVA_LINHA;}

"main"                              { return TOKEN_MAIN; }

"func"                              { return TOKEN_FUNC; }

"int"                               { yylval.label = "int"; return TOKEN_TIPO_INT; }

"float"                             { yylval.label = "float"; return TOKEN_TIPO_FLOAT; }

"string"                            { yylval.label = "string"; return TOKEN_TIPO_STRING; }

"bool"                              { yylval.label = "bool"; return TOKEN_TIPO_BOOL; }

{digit}+                            { yylval.label = yytext; yylval.tipo = "int"; return TOKEN_VARIAVEL_INT; }

{digit}+("."{digit}+)?              { yylval.label = yytext; return TOKEN_VARIAVEL_FLOAT; }

{ASCII}                             { yylval.label = yytext; return TOKEN_VARIAVEL_STRING; }

("true"|"false")                    { yylval.label = yytext; return TOKEN_VARIAVEL_BOOL; }

{ID}                                { yylval.label = yytext; return TOKEN_ID; }

[(){}[\];,]                         { return *yytext; }

"&&"                                { yylval.label = yytext; return TOKEN_E_LOGICO; }

"||"                                { yylval.label = yytext; return TOKEN_OU_LOGICO; }

"!="                                { yylval.label = yytext; return TOKEN_DIFERENTE; }

"=="                                { yylval.label = yytext; return TOKEN_IGUAL_IGUAL; }

"<="                                { yylval.label = yytext; return TOKEN_MENOR_IGUAL; }

">="                                { yylval.label = yytext; return TOKEN_MAIOR_IGUAL; }

[+\-*/=<>!]                         { return *yytext; }

.                                   { *yytext; }
                                
%%