
debug ?= 0

ifeq ($(debug), 1)
	CFLAGS=-g -DDEBUGFLAG
	BFLAGS=-v -g
endif

bison:
	bison -d $(BFLAGS) calc.y
	flex calc.l
	gcc $(CFLAGS) -std=gnu99 -c lex.yy.c
	g++ $(CFLAGS) -std=gnu99 -o calc lex.yy.o calc.tab.c -ly -lfl
