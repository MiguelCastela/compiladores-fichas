%{
    #include <ctype.h>
    #include <stdio.h>
    #include <string.h>

    #define YY_USER_ACTION \
        if(yytext[0] == '\n') { \
            curline++; \
            curcol = 1; \
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
    int curcol = 1;
    char str_buffer[1024];
    int str_index = 0;
%}

%X COMMENT
%X STRING

digit       [0-9]
x           [a-zA-Z_]
reserved    "integer"|"double"|"if"|"then"|"else"
ignore      [ \t\n]
ponctuation [()=,*/+-]


str_char    [^\"\n\\]
escape_seq  \\[fnrt\\"]
invalid_esc \\[^fnrt\\"]

%%

\" {
    BEGIN(STRING);
    str_index = 0;
}

<STRING>{str_char}+ {
    strncpy(&str_buffer[str_index], yytext, yyleng);
    str_index += yyleng;
    //ECHO;
}

<STRING>{escape_seq} {
    strncpy(&str_buffer[str_index], yytext, yyleng);
    str_index += yyleng;
    //ECHO;
}

<STRING>{invalid_esc} {
    printf("Line: %d, column %d: invalid escape sequence (%s)\n", curline, curcol, yytext);
    str_index += yyleng;
    BEGIN(INITIAL);
}

<STRING>\" {
    printf("STRLIT(\"%s\")\n", str_buffer);
    BEGIN(INITIAL);
}


<STRING>. {
    strncpy(&str_buffer[str_index], yytext, yyleng);
    str_index += yyleng;
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
