#ifndef _SCAN_H_
#define _SCAN_H_

#include "globals.h"
/* MAXTOKENLEN is the maximum size of a token */
#define MAXTOKENLEN 40

/* tokenString array stores the lexeme of each token */
extern char tokenString[MAXTOKENLEN+1];
extern char lastIDName[MAXTOKENLEN+1];
#endif
