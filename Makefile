
debug ?= 0

ifeq ($(debug), 1)
	CFLAGS=-g -DDEBUGFLAG
endif

scanner:
	@flex lex/cminus.l
	@gcc $(CFLAGS) -std=gnu99 -o bin/scanner lex.yy.c  -lfl

scanner-tests: scanner-test1 scanner-test2 scanner-test3 scanner-test4

scanner-test1: scanner
	@bin/scanner tests/test1.c

scanner-test2: scanner
	@bin/scanner tests/test2.c

scanner-test3: scanner
	@bin/scanner tests/test3.c

scanner-test4: scanner
	@bin/scanner tests/test4.c

tabela:
	@flex -o ${@}.c lex/cmenostabela.l
	@gcc $(CFLAGS) -std=gnu99 -o bin/${@} ${@}.c  -lfl

tabela-tests: tabela-test1 tabela-test2 tabela-test3 tabela-test4

tabela-test1: tabela
	@bin/tabela tests/test1.c

tabela-test2: tabela
	@bin/tabela tests/test2.c

tabela-test3: tabela
	@bin/tabela tests/test3.c

tabela-test4: tabela
	@bin/tabela tests/test4.c
