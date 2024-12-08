#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"
#include "semantics.h"

int semantic_errors = 0;

struct symbol_list *symbol_table;
struct symbol_list_queue *symbol_scopes;

void check_function(struct node *function) {
    struct node *id = getchild(function, 0);
    if(search_symbol(symbol_table, id->token) == NULL) {
        insert_symbol(symbol_table, id->token, no_type, function);
    } else {
        printf("Identifier %s already declared\n", id->token);
        semantic_errors++;
    }
    //Function's scope
    struct symbol_list *scope = (struct symbol_list *) malloc(sizeof(struct symbol_list));

    //The parameter list is the first child
    check_parameters(getchild(function, 1), scope);
    check_expression(getchild(function, 2), scope);

    //add scope to scope queue
    struct symbol_list_queue *new_scope = (struct symbol_list_queue *) malloc(sizeof(struct symbol_list_queue));
    new_scope->identifier = id->token;
    new_scope->table = scope;
    new_scope->next = symbol_scopes;
    symbol_scopes = new_scope;

}

void check_parameters(struct node *parameters, struct symbol_list *scope){
    struct node_list *parameter = parameters->children;
    while((parameter = parameter->next) != NULL){
        struct node *cur_parameter = parameter->node;

        // The identifier is the second child
        struct node *cur_parameter_id = getchild(cur_parameter, 1);
        if(search_symbol(symbol_table, cur_parameter_id->token) == NULL){
            enum type cur_type = category_type(getchild(cur_parameter, 0)->category);
            cur_parameter->type = cur_type;
            insert_symbol(scope, cur_parameter_id->token, cur_type, cur_parameter);
        }
        else{
            printf("Identifier %s (%d:%d) already declared\n", cur_parameter_id->token, cur_parameter_id->token_line, cur_parameter_id->token_column);
            semantic_errors++;
        }
    }
}

void check_expression(struct node *expression, struct symbol_list *scope){
    enum category cat = expression->category;
    switch(cat){
        case (Call):
            struct node *id = getchild(expression, 0);
            // if the function has already been declared
            if(search_symbol(symbol_table, id->token) != NULL){
                // Current call's arguments
                struct node *arguments = getchild(expression, 1);
                // Original function's declaration
                struct node *function = search_symbol(symbol_table, id->token)->node;
                // Original function's parameters                
                struct node *parameters = getchild(function, 1);

                // If the parameters exist and the call's argument count is different from the original declaration's parameter count 
                if((parameters != NULL) && (count_children(arguments) != count_children(parameters))){
                    printf("Calling %s (%d:%d) with incorrect arguments\n", id->token, id->token_line, id->token_column);
                    semantic_errors++;
                }
                // Correct number of arguments
                else{
                    struct node_list *argument = arguments->children;
                    while((argument = argument->next) != NULL){
                        check_expression(argument->node, scope);
                    }
                }
            }
            else{
                printf("Function %s (%d:%d) undeclared\n", id->token, id->token_line, id->token_column);
                semantic_errors++;
            }
            break;
            case (If):
                check_expression(getchild(expression, 0), scope);
                check_expression(getchild(expression, 1), scope);
                check_expression(getchild(expression, 2), scope);
            break;
        
            case (Add):
            case (Sub):
            case (Mul):
            case (Div):
                check_expression(getchild(expression, 0), scope);
                check_expression(getchild(expression, 1), scope);
                enum type left_type = getchild(expression, 0)->type;
                enum type right_type = getchild(expression, 1)->type;
                if(left_type != right_type){
                    printf("Incompatible types in expression %s (%d:%d)\n", category_names[cat], expression->token_line, expression->token_column);
                    semantic_errors++;
                }
                else{
                    expression->type = left_type;
                }

                break;
            case (Identifier):
                // Check in local scope first
                struct symbol_list *symbol = search_symbol(scope, expression->token);
                if(symbol == NULL) {
                    // If not found in local scope, check in global scope
                    symbol = search_symbol(symbol_table, expression->token);
                    if(symbol == NULL) {
                        printf("Identifier %s (%d:%d) undeclared\n", expression->token, expression->token_line, expression->token_column);
                        semantic_errors++;
                    } else {
                        expression->type = symbol->type;
                    }
                } else {
                    expression->type = symbol->type;
                    }
                break;
}





// semantic analysis begins here, with the AST root node
int check_program(struct node *program) {
    symbol_table = (struct symbol_list *) malloc(sizeof(struct symbol_list));
    symbol_scopes = (struct symbol_list_queue *) malloc(sizeof(struct symbol_list_queue));
    
    symbol_table->next = NULL;
    struct node_list *child = program->children;
    while((child = child->next) != NULL)
        check_function(child->node);
    return semantic_errors;
}

// insert a new symbol in the list, unless it is already there
struct symbol_list *insert_symbol(struct symbol_list *table, char *identifier, enum type type, struct node *node) {
    struct symbol_list *new = (struct symbol_list *) malloc(sizeof(struct symbol_list));
    new->identifier = strdup(identifier);
    new->type = type;
    new->node = node;
    new->next = NULL;
    struct symbol_list *symbol = table;
    while(symbol != NULL) {
        if(symbol->next == NULL) {
            symbol->next = new;    /* insert new symbol at the tail of the list */
            break;
        } else if(strcmp(symbol->next->identifier, identifier) == 0) {
            free(new);
            return NULL;           /* return NULL if symbol is already inserted */
        }
        symbol = symbol->next;
    }
    return new;
}

// look up a symbol by its identifier
struct symbol_list *search_symbol(struct symbol_list *table, char *identifier) {
    struct symbol_list *symbol;
    for(symbol = table->next; symbol != NULL; symbol = symbol->next)
        if(strcmp(symbol->identifier, identifier) == 0)
            return symbol;
    return NULL;
}

void show_symbol_table() {
    printf("\n== Global Scope ==\n");
    struct symbol_list *symbol;
    for(symbol = symbol_table->next; symbol != NULL; symbol = symbol->next)
        printf("Symbol %s : %s\n", symbol->identifier, type_name(symbol->type));
}

void show_symbol_scopes() {
    // Reverse the linked list to print in FIFO order
    struct symbol_list_queue *prev = NULL;
    struct symbol_list_queue *current = symbol_scopes;
    struct symbol_list_queue *next = NULL;

    while (current != NULL) {
        next = current->next;
        current->next = prev;
        prev = current;
        current = next;
    }
    symbol_scopes = prev;

    // Print the reversed list
    struct symbol_list_queue *cur_scope = symbol_scopes;
    while((cur_scope = cur_scope->next) != NULL){
        printf("\n== Scope %s ==\n", cur_scope->identifier);
        struct symbol_list *cur_symbol = cur_scope->table;
        
        while((cur_symbol = cur_symbol->next) != NULL){
            printf("Symbol %s : %s\n", cur_symbol->identifier, type_name(cur_symbol->type));
        }
        // cur_scope = cur_scope->next;
    }
}