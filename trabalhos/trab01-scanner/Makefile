
debug ?= 0

ifeq ($(debug), 1)
	CFLAGS=-g -DDEBUGFLAG
endif

scanner:
	@flex cminus.l
	@gcc $(CFLAGS) -std=gnu99 -o bin/scanner lex.yy.c  -lfl

scanner-tests: scanner-test1 scanner-test2 scanner-test3 scanner-test4

scanner-test1: scanner
	@bin/scanner ../../tests/test1.c

scanner-test2: scanner
	@bin/scanner ../../tests/test2.c

scanner-test3: scanner
	@bin/scanner ../../tests/test3.c

scanner-test4: scanner
	@bin/scanner ../../tests/test4.c
