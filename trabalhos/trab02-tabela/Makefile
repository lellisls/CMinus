
debug ?= 0

ifeq ($(debug), 1)
	CFLAGS=-g -DDEBUGFLAG
endif

tabela:
	@flex -o ${@}.c cmenostabela.l
	@gcc $(CFLAGS) -std=gnu99 -o bin/${@} ${@}.c  -lfl

tabela-tests: tabela-test1 tabela-test2 tabela-test3 tabela-test4

tabela-test1: tabela
	@bin/tabela ../../tests/test1.c

tabela-test2: tabela
	@bin/tabela ../../tests/test2.c

tabela-test3: tabela
	@bin/tabela ../../tests/test3.c

tabela-test4: tabela
	@bin/tabela ../../tests/test4.c
