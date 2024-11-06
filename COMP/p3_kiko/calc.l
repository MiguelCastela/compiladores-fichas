%{
    #include "y.tab.h"
    int yyparse(void);

    #define YY_USER_ACTION \
        token_begincolumn = token_endcolumn; \
        token_beginline = token_endline; \
        if (yytext[yyleng-1] == '\n') { \
            token_endline++; \
            token_endcolumn = 0; \
        } else { \
            token_endcolumn += yyleng; \
            token_begincolumn += 1; \
        }

    int token_begincolumn = 0;  // } indicates the beginning of the token
    int token_beginline = 1;    // }
    int token_endcolumn = 0;        // } indicates the end of the token
    int token_endline = 1;          // }

%}


digit   [0-9]

%%
{digit}+                { yylval = atoi(yytext); return NATURAL; }
[()=,*/+-]              { return yytext[0]; }
\n                      { return 0; }
"if"                    { return IF; }
"then"                  { return THEN; }
"else"                  { return ELSE; }
.                       { printf("Unrecognized character at line:%d column:%d\n", token_beginline, token_begincolumn); }
%%


int main() {
    yyparse();
    return 0;
}
int yywrap() {
    return 1;
}
