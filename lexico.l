%{
#include "sintatico.tab.h"
%}

digit [0-9]
letter [a-zA-Z]
espaco [ \t]

%%

{digit}+                            { yylval = atoi(yytext); return INTEIRO; }
{letter}({letter}|{digit})*         { return ID; }
"+"                                 { return '+'; }
[ \t]                               ; // ignora espaços e tabs
"\n"                                { return FIM_DE_LINHA; }
                                
%%