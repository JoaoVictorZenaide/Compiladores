%{
#include <string>
%}

digit [0-9]
letter [a-zA-Z]
espaco [ \t]

ID {letter}({letter}|{digit})*

%%

{espaco}+                           ; // ignora espaços e tabs

"\n"                                ; // ignora o /n

"main"                              { return TOKEN_MAIN; }

"int"                               { yylval.label = "int"; return TOKEN_TIPO_INT; }

{digit}+                            { yylval.label = yytext; return TOKEN_NUMERO_INT; }

{ID}                                { yylval.label = yytext; return TOKEN_ID; }

[(){}[\];,]                         { return *yytext; }

[+\-*/=]                            { return *yytext; }

.                                   { *yytext; }
                                
%%