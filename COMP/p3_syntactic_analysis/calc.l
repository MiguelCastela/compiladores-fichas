%{
#include "y.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

int yyparse(void);
    #define YY_USER_ACTION \
    if(yytext[0] == '\n') { \
        curline++; \
        curcol = 0; \
    } \
    else { \
        curcol += yyleng; \
    };
    char* to_uppercase(char* str) {
        for (int i = 0; str[i] != '\0'; i++) {
            str[i] = toupper(str[i]);
        }
        return str;
    }
    int curline = 1;
    int curcol = 0;
%}

digit   [0-9]
whitespace [ \t\n]

%%
"if"                    {  return IF; }
"then"                  {  return THEN; }
"else"                  {  return ELSE; }
{digit}+                { yylval = atoi(yytext); return NATURAL; }
[()=,*/+-]              { return yytext[0]; }
{whitespace}            {;}
.                      { printf(
        "error...\n"
        "line: %d\n"
        "column: %d\n"
        "unrecognized character: (%s)\n",    
        curline, curcol - yyleng, yytext
    ); }
%%
int main() {
    yyparse();
    return 0;
}
int yywrap() {
    return 1;
}
