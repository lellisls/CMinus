#ifndef _GLOBALS_H_
#define _GLOBALS_H_


#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

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

// char* tokenToString( int type ) {
//   switch( type ) {
//       case ENDFILE:
//       return( "ENDFILE" );
//       case ERROR:
//       return( "ERROR" );
//       case IF:
//       return( "IF" );
//       case ELSE:
//       return( "ELSE" );
//       case INT:
//       return( "INT" );
//       case FLOAT:
//       return( "FLOAT" );
//       case VOID:
//       return( "VOID" );
//       case RETURN:
//       return( "RETURN" );
//       case WHILE:
//       return( "WHILE" );
//       case ID:
//       return( "ID" );
//       case NUM:
//       return( "NUM" );
//       case FNUM:
//       return( "FNUM" );
//       case ASSIGN:
//       return( "ASSIGN" );
//       case EQ:
//       return( "EQ" );
//       case NEQ:
//       return( "NEQ" );
//       case LT:
//       return( "LT" );
//       case LE:
//       return( "LE" );
//       case GT:
//       return( "GT" );
//       case GE:
//       return( "GE" );
//       case PLUS:
//       return( "PLUS" );
//       case MINUS:
//       return( "MINUS" );
//       case TIMES:
//       return( "TIMES" );
//       case OVER:
//       return( "OVER" );
//       case LPAREN:
//       return( "LPAREN" );
//       case RPAREN:
//       return( "RPAREN" );
//       case SEMI:
//       return( "SEMI" );
//       case COLON:
//       return( "COLON" );
//       case LBOX:
//       return( "LBOX" );
//       case RBOX:
//       return( "RBOX" );
//       case LKEY:
//       return( "LKEY" );
//       case RKEY:
//       return( "RKEY" );
//       case LCOMM:
//       return( "LCOMM" );
//       case RCOMM:
//       return( "RCOMM" );
//   }
// }
#endif
