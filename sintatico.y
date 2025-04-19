%{
    #include <stdio.h>

    void yyerror(char *msg); 
%}

%token INTEIRO
%token ID
%token FIM_DE_LINHA

%start linha

%%

linha: expressao FIM_DE_LINHA { printf("valor: %d\n", $1); };

expressao: expressao '+' termo { $$ = $1 + $3; }
    | termo { $$ = $1; }
    ;

termo: INTEIRO { $$ = $1; }
    ;

%%

int main(int argc, char **argv){
    return yyparse();
}

void yyerror(char *msg){
    fprintf(stderr, "erro: %s\n", msg);
}