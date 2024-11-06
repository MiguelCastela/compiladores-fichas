%{
#include <stdio.h>
extern int yylex(void);
void yyerror(char *);
extern char *yytext;
%}

%token NATURAL
%token IF THEN ELSE

%left IF THEN ELSE
%left '-' '+'
%left '*' '/'
%left '(' ')'
%left ','


%%

calculator: expression                                      { printf("%d\n", $1); }
          | calculator ',' calculator                       { ; }
          ;

expression: NATURAL                                         { $$ = $1; }
          | expression '+' expression                       { $$ = $1 + $3; }
          | expression '-' expression                       { $$ = $1 - $3; }
          | expression '*' expression                       { $$ = $1 * $3; }
          | expression '/' expression                       { $$ = $1 / $3; }
          | '(' expression ')'                              { $$ = $2; }
          | IF expression THEN expression ELSE expression   { $$ = $2 ? $4 : $6; }
          ;

%%

void yyerror(char *error) {
    printf("%s '%s'\n", error, yytext);
}
