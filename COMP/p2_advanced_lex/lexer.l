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
    char* to_uppercase(char* str) {
        for (int i = 0; str[i] != '\0'; i++) {
            str[i] = toupper(str[i]);
        }
        return str;
    }
    int curline = 1;
    int curcol = 0;
    int str_index =0;
    int str_error = 0;
    int ml_comment_start_line = 0;
    int ml_comment_start_col = 0;
    char str_buffer[1024];
%}
digit   [0-9]
character [a-zA-Z]
keyword "integer"|"double"|"if"|"then"|"else"
whitespace [ \t\n]
ponctuation [()=,*/+-]

str_char    [^\"\\\n]
invalid_escape_sequence \\[^fnrt\\\"]
escape_seq  \\[fnrt\\"]



%X MULTI_LINE_COMMENT
%X STRING

%%

\" {
BEGIN(STRING);

str_index = 0;
str_buffer[0] = '\0';
str_error = 0;
}

<STRING>{str_char} {
    strncpy(&str_buffer[str_index], yytext, yyleng);
    str_index += yyleng;
}

<STRING>{escape_seq} {
    strncpy(&str_buffer[str_index], yytext, yyleng);
    str_index += yyleng;
}

<STRING>{invalid_escape_sequence} {
    printf("line %d" " column %d" " invalid escape sequence (%s)\n", curline, curcol-yyleng , yytext);
    str_error = 1;       
    str_index += yyleng;       
}

<STRING>\" {
    strncpy(&str_buffer[str_index], yytext, yyleng);
    str_buffer[str_index] = '\0';  
    if(!str_error){
        printf("STRLIT(%s)\n", str_buffer); 
        }
        else{
        }

    str_index = 0;
    str_buffer[0] = '\0';
    str_error = 0;
    BEGIN(INITIAL); 
}       

	
"/*"                               {BEGIN(MULTI_LINE_COMMENT);}
<MULTI_LINE_COMMENT>"*/"           {BEGIN(INITIAL); }
<MULTI_LINE_COMMENT>.              { ; }

{ponctuation}           { printf("PONCTUATION(%s)\n", yytext); }
{keyword}              { printf("KEYWORD(%s)\n", to_uppercase(yytext)); }
{digit}+                { printf("NATURAL(%s)\n", yytext); }
{digit}*"."{digit}+     { printf("DECIMAL(%s)\n", yytext); }
{whitespace}          {;}


{character}+({digit}|{character})* { printf("IDENTIFIER(%s)\n", yytext); }




.                      { printf(
        "error...\n"
        "line: %d\n"
        "column: %d\n"
        "unrecognized character: (%s)\n",    
        curline, curcol - yyleng, yytext
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
