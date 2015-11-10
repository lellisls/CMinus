cminus:
	flex cminus.l
	gcc -o bin/alcminus lex.yy.c  -lfl
