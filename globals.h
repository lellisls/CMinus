#ifndef _GLOBALS_H_
#define _GLOBALS_H_


#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

#ifndef TRUE
#define TRUE 1
#endif

#ifndef FALSE
#define FALSE 0
#endif

#define MAXTOKENLEN 64

typedef enum
    /* book-keeping tokens */
   {
    ENDFILE,ERROR,
    /* reserved words */
    IF,ELSE,INT,FLOAT,VOID,RETURN,WHILE,
    /* multicharacter tokens */
    ID,NUM,FNUM,
    /* special symbols */
    ASSIGN,EQ,NEQ,LT,LE,GT,GE,PLUS,MINUS,
    TIMES,OVER,LPAREN,RPAREN,SEMI,COLON,
    LBOX,RBOX,LKEY,RKEY,LCOMM,RCOMM,
   } TokenType;

#endif
