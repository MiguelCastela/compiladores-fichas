%{
    #include <stdio.h>
    extern int yylex(void);
    void yyerror(char *);
    extern char *yytext;
    extern int line, col;

    int last = 0;
%}

%token NATURAL
%token IF 
%token THEN
%token ELSE

%right IF
%left '+' '-'
%left '*' '/'
%nonassoc ','

%%


calculator: expression_list                                     { printf("\n"); }
          ;

expression_list: expression                                     { printf("%d", $1); }
               | expression_list ',' expression                 { printf(", %d", $3); }
               ;

expression: NATURAL                                             { $$ = $1; }
          | expression '+' expression                           { $$ = $1 + $3; }
          | expression '-' expression                           { $$ = $1 - $3; }
          | expression '*' expression                           { $$ = $1 * $3; }
          | expression '/' expression                           { $$ = $1 / $3; }
          | '(' expression ')'                                  { $$ = $2; }
          | IF expression THEN expression ELSE expression       { $$ = ($2 ? $4 : $6); } %prec IF
          ;


%%

void yyerror(char *error) {
    printf("\nline: %d\n col: %d\n", line, col);
    printf("%s '%s'\n", error, yytext);
}