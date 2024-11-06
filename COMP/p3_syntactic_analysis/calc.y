%{
#include <stdio.h>
extern int yylex(void);
void yyerror(char *);
extern char *yytext;
%}

%token NATURAL
%token IF 
%token THEN
%token ELSE

%left IF THEN ELSE
%left '+' '-'
%left '*' '/'
%left '(' ')'
%nonassoc ','


%nonassoc LOWER_THAN_ELSE



%%

calculator: expression                  { printf("%d", $1); }
          | calculator ',' expression  {printf(", %d", $3);}
          ;
expression: NATURAL                     { $$ = $1; }
          | expression '+' expression   { $$ = $1 + $3; }
          | expression '-' expression   { $$ = $1 - $3; }
          | expression '*' expression   { $$ = $1 * $3; }
          | expression '/' expression   { $$ = $1 / $3; }
          |    '(' expression ')'       { $$ = $2; }
          | IF expression THEN expression ELSE expression { $$ = $2 ? $4 : $6; } %prec LOWER_THAN_ELSE
          ;

%%

void yyerror(char *error) {
    printf("%s '%s'\n", error, yytext);
}
