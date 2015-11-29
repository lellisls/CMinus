
debug ?= 0
ifeq ($(debug), 1)
	CFLAGS=-g -DDEBUGFLAG -Wwrite-strings
	BFLAGS=-v -g
endif

bison:
	@bison -d $(BFLAGS) calc.y
	@flex calc.l
	@gcc $(CFLAGS) -std=gnu99 -c lex.yy.c
	@g++ $(CFLAGS) -std=c++11 -o bin/calc lex.yy.o calc.tab.c -ly -lfl
	@bin/calc

view:
	dot -Tps calc.dot -o graph.ps; evince graph.ps
