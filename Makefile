cminus:
	flex cminus.l
	gcc -o bin/alcminus lex.yy.c  -lfl

tests: test1 test2 test3 test4

test1: cminus
	bin/alcminus tests/${@}.c

test2: cminus
	bin/alcminus tests/${@}.c

test3: cminus
	bin/alcminus tests/${@}.c

test4: cminus
	bin/alcminus tests/${@}.c
