#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"
#include "semantics.h"
#include "codegen.h"

int temporary;   // sequence of temporary registers in a function

extern struct symbol_list *symbol_table;

int codegen_natural(struct node *natural) {
    printf("  %%%d = add i32 %s, 0\n", temporary, natural->token);
    return temporary++;
}

int codegen_identifier(struct node *identifier){
    printf("  %%%d = add i32* %%%s\n", temporary, identifier->token);
    return temporary++;
}

int codegen_mul(struct node *mul) {
    int t1 = codegen_expression(getchild(mul, 0));
    int t2 = codegen_expression(getchild(mul, 1));
    printf("  %%%d = mul i32 %%%d, %%%d\n", temporary, t1, t2);
    return temporary++;
}

int codegen_add(struct node *add) {
    int t1 = codegen_expression(getchild(add, 0));
    int t2 = codegen_expression(getchild(add, 1));
    printf("  %%%d = add i32 %%%d, %%%d\n", temporary, t1, t2);
    return temporary++;
}

int codegen_div(struct node *div) {
    int t1 = codegen_expression(getchild(div, 0));
    int t2 = codegen_expression(getchild(div, 1));
    printf("  %%%d = sdiv i32 %%%d, %%%d\n", temporary, t1, t2);
    return temporary++;
}


int codegen_sub(struct node *sub) {
    int t1 = codegen_expression(getchild(sub, 0));
    int t2 = codegen_expression(getchild(sub, 1));
    printf("  %%%d = sub i32 %%%d, %%%d\n", temporary, t1, t2);
    return temporary++;
}

int codegen_expression(struct node *expression) {
    int tmp = -1;
    switch(expression->category) {
        case Natural:
            tmp = codegen_natural(expression);
            break;
        case Identifier:
            tmp = codegen_identifier(expression);
            break;
        case Mul:
            tmp = codegen_mul(expression);
            break;
        case Add:
            tmp = codegen_add(expression);
            break;
        case Div:
            tmp = codegen_div(expression);
            break;
        case Sub:
            tmp = codegen_sub(expression);
            break;
        default:
            break;
    }
    return tmp;
}

void codegen_parameters(struct node *parameters) {
    struct node *parameter;
    int curr = 0;
    while((parameter = getchild(parameters, curr++)) != NULL) {
        if(curr > 1)
            printf(", ");
        printf("i32 %%%s", getchild(parameter, 1)->token);
    }
}

void codegen_function(struct node *function) {
    temporary = 1;
    printf("define i32 @_%s(", getchild(function, 0)->token);
    codegen_parameters(getchild(function, 1));
    printf(") {\n");
    int tmp = codegen_expression(getchild(function, 2));
    printf("  ret i32 %%%d\n", tmp);
    printf("}\n\n");
}

// code generation begins here, with the AST root node
void codegen_program(struct node *program) {
    // predeclared I/O functions
    printf("declare i32 @_read(i32)\n");
    printf("declare i32 @_write(i32)\n\n");

    // generate code for each function
    struct node_list *function = program->children;
    while((function = function->next) != NULL)
        codegen_function(function->node);

    // generate the entry point which calls main(integer) if it exists
    struct symbol_list *entry = search_symbol(symbol_table, "main");
    if(entry != NULL && entry->node->category == Function)
        printf("define i32 @main() {\n"
               "  %%1 = call i32 @_main(i32 0)\n"
               "  ret i32 %%1\n"
               "}\n");
}
