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

int codegen_id(struct node *id){
    printf("  %%%d = add i32 %%%s, 0\n", temporary, id->token);
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

int codegen_sub(struct node *sub) {
    int t1 = codegen_expression(getchild(sub, 0));
    int t2 = codegen_expression(getchild(sub, 1));
    printf("  %%%d = sub i32 %%%d, %%%d\n", temporary, t1, t2);
    return temporary++;
}

int codegen_div(struct node *div) {
    int t1 = codegen_expression(getchild(div, 0));
    int t2 = codegen_expression(getchild(div, 1));
    printf("  %%%d = sdiv i32 %%%d, %%%d\n", temporary, t1, t2);
    return temporary++;
}

int codegen_call(struct node *call) {
    struct node *args = getchild(call, 1);

    // MIGHT BE TO SHORT, REVISE LATER (MAYBE REALLOC)
    char args_str[4096];
    args_str[0] = '\0';

    int cur = 0;
    struct node *arg;
    while((arg = getchild(args, cur++)) != NULL){
        int t = codegen_expression(arg);
        char str[128];
        if(cur > 1)
            sprintf(str, ", i32 %%%d", t);
        else
            sprintf(str, "i32 %%%d", t);    
        strcat(args_str, str);        
    }
    printf("  %%%d = call i32 @_%s(%s)\n", temporary, getchild(call, 0)->token, args_str);

    return temporary++;
}

int codegen_if(struct node *ifnode){
    int label_id = temporary++;
    printf("  %%%d = alloca i32\n", label_id);

    int t = codegen_expression(getchild(ifnode, 0));
    printf("  %%%d = icmp ne i32 %%%d, 0\n", temporary, t);
    int cmp = temporary++;
    printf("  br i1 %%%d, label %%L%dthen, label %%L%delse\n", cmp, label_id, label_id);
    printf("L%dthen:\n", label_id);
    
    int t1 = codegen_expression(getchild(ifnode, 1));
    printf("  store i32 %%%d, i32* %%%d\n", t1, label_id);
    printf("  br label %%L%dend\n", label_id);
    printf("L%delse:\n", label_id);

    int t2 = codegen_expression(getchild(ifnode, 2));   
    printf("  store i32 %%%d, i32* %%%d\n", t2, label_id);
    printf("  br label %%L%dend\n", label_id);
    printf("L%dend:\n", label_id);
    printf("  %%%d = load i32, i32* %%%d\n", temporary, label_id);
    
    return temporary++;
}

int codegen_expression(struct node *expression) {
    int tmp = -1;
    switch(expression->category) {
        case Natural:
            tmp = codegen_natural(expression);
            break;
        case Identifier:
            tmp = codegen_id(expression);
            break;
        case Mul:
            tmp = codegen_mul(expression);
            break;  
        case Add:
            tmp = codegen_add(expression);
            break;
        case Sub:
            tmp = codegen_sub(expression);
            break;
        case Div:
            tmp = codegen_div(expression);
            break;
        case Call:
            tmp = codegen_call(expression);
            break;
        case If:
            tmp = codegen_if(expression);
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
