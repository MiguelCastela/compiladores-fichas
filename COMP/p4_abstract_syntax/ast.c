#include <stdlib.h>
#include <stdio.h>
#include "ast.h"

// create a node of a given category with a given lexical symbol
struct node *newnode(enum category category, char *token) {
    struct node *new = malloc(sizeof(struct node));
    new->category = category;
    new->token = token;
    new->children = malloc(sizeof(struct node_list));
    new->children->node = NULL;
    new->children->next = NULL;
    return new;
}

// append a node to the list of children of the parent node
void addchild(struct node *parent, struct node *child) {
    struct node_list *new = malloc(sizeof(struct node_list));
    new->node = child;
    new->next = NULL;
    struct node_list *children = parent->children;
    while(children->next != NULL)
        children = children->next;
    children->next = new;
}

// Names defined in ast.h
const char *category_name[] = names;
void dfs(struct node *cur_node, int depth){
    for(int i = 0; i < depth; i++){
        printf("__");
    }    
    if(cur_node->token == NULL){
        printf("%s\n", category_name[cur_node->category]);
    }
    else{
        printf("%s(%s)\n", category_name[cur_node->category], cur_node->token);
    }
    
    struct node_list *child = cur_node->children;
    while((child = child->next) != NULL){
        dfs(child->node, depth+1);
    }
}


/*
void print_indent(int depth) {
    for (int i = 0; i < depth; i++) {
        printf("__");
    }
}

void show(struct node *node, int depth) {
    if (node == NULL) return;

    // Print the current node's category and token
    print_indent(depth);
    printf("%s", category_to_string(node->category));
    if (node->token != NULL) {
        printf("(%s)", node->token);
    }
    printf("\n");

    // Traverse each child node in the children list
    struct node_list *child = node->children;
    while (child != NULL) {
        if (child->node != NULL) {
            show(child->node, depth + 1);
        }
        child = child->next; // Advance to the next child
    }
}

const char* category_to_string(enum category cat) {
    switch (cat) {
        case Program: return "Program";
        case Function: return "Function";
        case Parameters: return "Parameters";
        case Parameter: return "Parameter";
        case Arguments: return "Arguments";
        case Integer: return "Integer";
        case Double: return "Double";
        case Identifier: return "Identifier";
        case Natural: return "Natural";
        case Decimal: return "Decimal";
        case Call: return "Call";
        case If: return "If";
        case Add: return "Add";
        case Sub: return "Sub";
        case Mul: return "Mul";
        case Div: return "Div";
        default: return "Unknown";
    }
}*/