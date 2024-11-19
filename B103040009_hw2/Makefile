all:	clean y.tab.c lex.yy.c
	gcc lex.yy.c y.tab.c -lfl

y.tab.c:
	bison -y -d B103040009.y

lex.yy.c:
	flex B103040009.l

clean:
	rm -f a.out lex.yy.c y.tab.c y.tab.h
