%{
    #include "y.tab.h"
    int yyparse(void);

    #define YY_USER_ACTION { col += yyleng; }
    
    int line = 1; 
    int col = 0; 
%}

digit   [0-9]
IF      "if"
THEN    "then"
ELSE    "else"

%%

{IF}                    { return IF; col += yyleng; }
{THEN}                  { return THEN; col += yyleng; }
{ELSE}                  { return ELSE; col += yyleng; }
{digit}+                { yylval = atoi(yytext); return NATURAL; col += yyleng; }
[()=,*/+-]              { return yytext[0]; col += yyleng; }
\n                      { col = 0; line++; }
[ \t]+                  { col += yyleng; }
.                       { printf("Unrecognized character\n"); }


%%


int main() {
    yyparse();
    return 0;
}
int yywrap() {
    return 1;
}
