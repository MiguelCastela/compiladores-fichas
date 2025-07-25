#ifndef _AST_H
#define _AST_H

enum category { Program, Function, Parameters, Parameter, Arguments, Integer, Double, Identifier, Natural, Decimal, Call, If, Add, Sub, Mul, Div };
#define names { "Program", "Function", "Parameters", "Parameter", "Arguments", "Integer", "Double", "Identifier", "Natural", "Decimal", "Call", "If", "Add", "Sub", "Mul", "Div" }

struct node {
    enum category category;
    char *token;
    struct node_list *children;
};

struct node_list {
    struct node *node;
    struct node_list *next;
};

struct node *newnode(enum category category, char *token);
void addchild(struct node *parent, struct node *child);
void dfs(struct node *cur_node, int depth);
#endif



/*

#ifndef _AST_H
#define _AST_H

enum category { Program, Function, Parameters, Parameter, Arguments, Integer, Double, Identifier, Natural, Decimal, Call, If, Add, Sub, Mul, Div, Expression };
struct node {
    enum category category;
    char *token;
    struct node_list *children;
};

struct node_list {
    struct node *node;
    struct node_list *next;
};

struct node *newnode(enum category category, char *token);
void addchild(struct node *parent, struct node *child);
const char* category_to_string(enum category cat); 
void show(struct node *node, int depth); // Add this line


#endif


*/