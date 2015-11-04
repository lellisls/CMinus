cminus:
	flex cminus.l
	gcc -o alcminus lex.yy.c  -lfl
 
