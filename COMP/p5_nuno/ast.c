#include <stdlib.h>
#include <stdio.h>
#include "ast.h"

// create a node of a given category with a given lexical symbol
struct node *newnode(enum category category, char *token) {
    struct node *new = malloc(sizeof(struct node));
    new->category = category;
    new->token = token;
    new->type = no_type;
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

// get a pointer to a specific child, numbered 0, 1, 2, ...
struct node *getchild(struct node *parent, int position) {
    struct node_list *children = parent->children;
    while((children = children->next) != NULL)
        if(position-- == 0)
            return children->node;
    return NULL;
}

// category names #defined in ast.h
char *category_name[] = names;

// print the AST
void show(struct node *node, int depth) {
    int i;
    for(i = 0; i < depth; i++)
        printf("__");
    if(node->token == NULL)
        printf("%s\n", category_name[node->category]);
    else
        printf("%s(%s)\n", category_name[node->category], node->token);
    struct node_list *child = node->children;
    while((child = child->next) != NULL)
        show(child->node, depth+1);
}

void show_annotated(struct node *node, int depth){
    for(int i = 0; i < depth; i++){
        printf("__");
    }
    if(node->token == NULL){
        printf("%s", category_name[node->category]);
    }
    else{
        printf("%s(%s)", category_name[node->category], node->token);
    }

    if(node->type != no_type){
        printf(" - %s", type_name(node->type));
    }
    printf("\n");
    
    struct node_list *child = node->children;

    while((child = child->next) != NULL){
        show_annotated(child->node, depth+1);
    }
}

int count_children(struct node *parent){
    if(parent == NULL){
        return -1; 
    }
    int cnt = 0;
    struct node_list *cur_child = parent->children;

    while((cur_child = cur_child->next) != NULL){
        cnt++;
    }
         
    return cnt;
}