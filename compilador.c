%{
#define ID 65
#define NUM 66
#define E 67
%}
digit [0-9]
letter [a-zA-Z]
%%
{digit}+                            { return NUM; }
{letter}({letter}|{digit})*         { return ID; }
<<EOF>>							    { return E; }
%%

int main(){
    int valDigit = 0;
    int valID = 0;
    int token;

    while((token = yylex()) != E){
        if(token == ID){
            valID++;
        }
        else if(token == NUM){
            valDigit++;
        }
    }
    printf("quantidade de ID's: %d\nquantidade de numeros: %d\n", valID, valDigit);

    return 0;
}