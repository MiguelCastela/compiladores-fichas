%{
    #include <stdio.h>
    #include<stdlib.h>
    #include <string.h>
    #include<ctype.h>

    #define YY_USER_ACTION \
        if(yytext[0] == '\n') { \
            curline++; \
            curcol = 0; \
        } \
        else { \
            curcol += yyleng; \
        };
    int curline = 1;
    int curcol = 0;
%}
digit   [0-9]
character [a-zA-Z]
keyword "integer"|"double"|"if"|"then"|"else"
whitespace [ \t\n]
ponctuation [()=,*/+-]


%%
{ponctuation}           { printf("PONCTUATION(%s)\n", yytext); }
{keyword}              { printf("KEYWORD(%s)\n", yytext); }
{digit}+                { printf("NATURAL(%s)\n", yytext); }
{digit}*"."{digit}+     { printf("DECIMAL(%s)\n", yytext); }
{whitespace}          {;}


{character}+({digit}|{character})* { printf("IDENTIFIER(%s)\n", yytext); }

.                      { printf(
        "error...\n"
        "line: %d\n"
        "column: %d\n"
        "unrecognized character: (%s)\n",    
        curline, curcol, yytext
    ); }
%%
extern int yylex();
int main() {
    yylex();    /* run the lexical analysis automaton */
    return 0;
}
int yywrap() {  /* called on EOF, return 1 to terminate */
    return 1;
}
