
debug ?= 0
ifeq ($(debug), 1)
	CFLAGS=-g -DDEBUGFLAG -Wwrite-strings
	BFLAGS=-v -g
endif

bison: scanner.o
	@g++ $(CFLAGS) -std=c++11 -o bin/calc objs/* main.cpp -ly -lfl
	@bin/calc

scanner.o:
	@flex -o scanner.c lex/scanner.l
	@gcc $(CFLAGS) -std=gnu99 -c scanner.c -o objs/lex.yy.o

parser.o:
	@bison -d $(BFLAGS) yacc/paser.y
	@g++ $(CFLAGS) -std=c++11 -c parser.c -o objs/parser.o

view:
	dot -Tps calc.dot -o graph.ps; evince graph.ps
