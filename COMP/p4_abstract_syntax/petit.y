/* START definitions section -- C code delimited by %{ ... %} and token declarations */

%{

#include <stdio.h>
#include "ast.h"

int yylex(void);
void yyerror(char *);

struct node *program;
%}

%token INTEGER DOUBLE IF THEN ELSE
%token<lexeme> IDENTIFIER NATURAL DECIMAL
%type<node> program parameters parameter arguments expression

%left LOW
%left '+' '-'
%left '*' '/'

%union{
    char *lexeme;
    struct node *node;
}

/* START grammar rules section -- BNF grammar */

%%

program: IDENTIFIER '(' parameters ')' '=' expression
                                    { 
                                      $$ = program = newnode(Program, NULL);
                                      struct node *function = newnode(Function, NULL);
                                      addchild(function, newnode(Identifier, $1));
                                      addchild(function, $3);
                                      addchild(function, $6);
                                      addchild($$, function); /*reorder this for readability?*/
                                    }
          | program IDENTIFIER '(' parameters ')' '=' expression  
                                    {
                                        $$ = $1;
                                        struct node *function = newnode(Function, NULL);
                                        addchild(function, newnode(Identifier, $2));
                                        addchild(function, $4);
                                        addchild(function, $7);
                                        addchild($$, function);
                                    }
    ;

parameters: parameter               { 
                                        $$ = newnode(Parameters, NULL);
                                        addchild($$,$1);
                                    }
    | parameters ',' parameter      {
                                    $$ = $1;
                                    addchild($$, $3);
                                    }
    ;

parameter: INTEGER IDENTIFIER       {   
                                        $$ = newnode(Parameter, NULL);
                                        addchild($$, newnode(Integer,NULL));
                                        addchild($$, newnode(Identifier, $2));
                                    }
    | DOUBLE IDENTIFIER             { 
                                      $$ = newnode(Parameter, NULL);
                                      addchild($$, newnode(Double,NULL ));
                                      addchild($$, newnode(Identifier,$2)); }
    ;

arguments: expression               { $$ = newnode(Arguments, NULL);
                                      addchild($$, $1); }
    | arguments ',' expression      { 
                                      $$ = $1;
                                      addchild($$, $3); 
                                    }
    ;

expression: IDENTIFIER              { $$ = newnode(Identifier, $1); }
    | NATURAL                       { $$ = newnode(Natural, $1); }
    | DECIMAL                       { $$ = newnode(Decimal, $1); }
    | IDENTIFIER '(' arguments ')'  { 
                                      $$ = newnode(Call, NULL);
                                      addchild($$, newnode(Identifier, $1));
                                      //addchild($$, $1);
                                      addchild($$, $3); 
                                    }

    | IF expression THEN expression ELSE expression  %prec LOW
                                    { 
                                      $$ = newnode(If, NULL);
                                      addchild($$, $2);
                                      addchild($$, $4);
                                      addchild($$, $6);
                                    }
    ;

    | expression '+' expression     { 
                                      $$ = newnode(Add, NULL);
                                      addchild($$, $1);
                                      addchild($$, $3); 
                                    }
    | expression '-' expression     { 
                                      $$ = newnode(Sub, NULL);
                                      addchild($$, $1);
                                      addchild($$, $3); 
                                    }
    | expression '*' expression     { 
                                      $$ = newnode(Mul, NULL);
                                      addchild($$, $1);
                                      addchild($$, $3); 
                                    }
    | expression '/' expression     { 
                                      $$ = newnode(Div, NULL);
                                      addchild($$, $1);
                                      addchild($$, $3); 
                                    }
    | '(' expression ')'            {
                                      $$ = $2; 
                                    }  
    ;

%%

/* START subroutines section */

// all needed functions are collected in the .l and ast.* files
