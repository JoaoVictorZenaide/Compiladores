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

"\n"                                ; // ignora o /n

"main"                              { return TOKEN_MAIN; }

"int"                               { yylval.label = "int"; return TOKEN_TIPO_INT; }

"float"                             { yylval.label = "float"; return TOKEN_TIPO_FLOAT; }

"string"                            { yylval.label = "string"; return TOKEN_TIPO_STRING; }

"bool"                              { yylval.label = "bool"; return TOKEN_TIPO_BOOL; }

{digit}+                            { yylval.label = yytext; return TOKEN_VARIAVEL_INT; }

{digit}+("."{digit}+)?              { yylval.label = yytext; return TOKEN_VARIAVEL_FLOAT; }

{ASCII}                             { yylval.label = yytext; return TOKEN_VARIAVEL_STRING; }

("true"|"false")                    { yylval.label = yytext; return TOKEN_VARIAVEL_BOOL; }

{ID}                                { yylval.label = yytext; return TOKEN_ID; }

[(){}[\];,]                         { return *yytext; }

[+\-*/=]                            { return *yytext; }

.                                   { *yytext; }
                                
%%