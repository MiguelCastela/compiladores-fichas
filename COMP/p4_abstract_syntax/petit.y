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
                                    { $$ = program = newnode(Program, NULL);
                                      struct node *function = newnode(Function, NULL);
                                      addchild(function, newnode(Identifier, $1));
                                      addchild(function, $3);
                                      addchild(function, $6);
                                      addchild($$, function); /*reorder this for readability?*/}
    ;

parameters: parameter               { 
                                        $$ = newnode(Parameters, NULL);
                                        addchild($$,$1)

}
    | parameters ',' parameter      {$$ = $1
                                    addchild($$, $3)
                                    }
    ;

parameter: INTEGER IDENTIFIER       {   $$ = newnode(Parameter, NULL) 
                                        addchild($$, newnode(Integer, $1))
                                        addchild($$, newnode(Identifier, $2))
                                    }
    | DOUBLE IDENTIFIER             { $$ = newnode(Parameter, NULL);
                                      addchild($$, newnode(Double,$1 ))
                                      addchild($$, newnode(Interger,$2)) }
    ;

arguments: expression               { $$ = newnode(Arguments, NULL);
                                      addchild($$, $1); }
    | arguments ',' expression      { $$ = $1
                                      addchild($$, $3); }
    ;

expression: IDENTIFIER              { $$ = newnode(Expression, NULL);
                                      addchild($$, newnode(Identifier, $1)); 
                                      }

    | NATURAL                       { $$ = newnode(Expression, NULL);
                                      addchild($$, newnode(Natural, $1)); }
    | DECIMAL                       { 
                                        $$ = newnode(Expression, NULL);
                                        addchild($$, newnode(Decimal, $1)); }
    | IDENTIFIER '(' arguments ')'  { }
    | IF expression THEN expression ELSE expression  %prec LOW
                                    { /* ... */ }
    | expression '+' expression     { /* ... */ }
    | expression '-' expression     { /* ... */ }
    | expression '*' expression     { /* ... */ }
    | expression '/' expression     { /* ... */ }
    | '(' expression ')'            { $$ = $2; }  
    ;

%%

/* START subroutines section */

// all needed functions are collected in the .l and ast.* files
