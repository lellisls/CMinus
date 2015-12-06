#ifndef _GLOBALS_H_
#define _GLOBALS_H_


#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifndef YYPARSER

#include "parser.tab.h"

#endif

#ifndef TRUE
#define TRUE 1
#endif

#ifndef FALSE
#define FALSE 0
#endif

#define MAXTOKENLEN 64

#ifdef DEBUGFLAG
#define DEBUG( exp ) exp
#else
#define DEBUG( exp )
#endif

typedef int TokenType;

extern FILE* source; /* source code text file */
extern FILE* listing; /* listing output text file */
extern FILE* code; /* code text file for TM simulator */
extern int linenbr; /* source line number for listing */

/**************************************************/
/***********   Syntax tree for parsing ************/
/**************************************************/

typedef enum {StmtK,ExpK} NodeKind;
typedef enum {IfK,WhileK,AssignK,ReadK,WriteK} StmtKind;
typedef enum {OpK,ConstK,IdK} ExpKind;

/* ExpType is used for type checking */
typedef enum {Void,Integer,Boolean, FloatingPoint} ExpType;

#define MAXCHILDREN 3

typedef struct treeNode
   { struct treeNode * child[MAXCHILDREN];
     struct treeNode * sibling;
     int linenbr;
     NodeKind nodekind;
     union { StmtKind stmt; ExpKind exp;} kind;
     union { TokenType op;
             int val;
             float fval;
             char * name; } attr;
     ExpType type; /* for type checking of exps */
   } TreeNode;

#endif
