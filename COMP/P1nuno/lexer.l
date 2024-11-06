%{
    #include <ctype.h>
    #include <stdio.h>
    #include <string.h>

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

digit       [0-9]
x           [a-zA-Z]
reserved    "integer"|"double"|"if"|"then"|"else"
ignore      [ \t\n]
ponctuation [()=,*/+-]

str_valid   \\[fnrt\\"]   /* Matches valid escape sequences: \f, \n, \r, \t, \\, and \" */
str_invalid \\[^fnrt\\"]  /* Matches invalid escape sequences: \ followed by any character except f, n, r, t, \, and " */
str_char    [^\n\t]       /* Matches any character except newline and tab */
%X COMMENT

%%
^\"({str_char}|{str_valid})*\"$ {
    printf("STRLIT(%s)\n", yytext);
}

^\"({str_char}|{str_invalid})*\"$ {
    printf("Line %d, column %d: invalid escape sequence (%s)\n", curline, curcol, yytext);
}

{reserved} { 
    printf("%s\n", to_uppercase(yytext)); 
}

{digit}+ { 
    printf("NATURAL(%s)\n", yytext); 
}

{digit}*"."{digit}+ {
    printf("DECIMAL(%s)\n", yytext); 
}

{x}+({digit}|{x})* {
    printf("IDENTIFIER(%s)\n", yytext); 
}

{ignore} {
    ; 
}

{ponctuation} { 
    printf("%s\n", yytext); 
}

"/*" {
    BEGIN(COMMENT);
}

<COMMENT>\n {
    printf(" ");
}

<COMMENT>. {
    ECHO;
}


<COMMENT>"*/" {
    BEGIN(INITIAL);
}

. { 
    printf(
        "error...\n"
        "line: %d\n"
        "column: %d\n", 
        curline, curcol
    ); 
}

%%

extern int yylex();
int main() {
    yylex();    /* run the lexical analysis automaton */
    return 0;
}
int yywrap() {  /* called on EOF, return 1 to terminate */
    return 1;
}
