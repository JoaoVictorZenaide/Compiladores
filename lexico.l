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

"int"                               { return TOKEN_TIPO_INT; }

{digit}+                            { yylval.label = yytext; return TOKEN_DIGIT; }

{ID}                                { yylval.label = yytext; return TOKEN_ID; }

[(){}[\];,]                         { return *yytext; }

[+\-*/]                             { return *yytext; }

.                                   { *yytext; }
                                
%%