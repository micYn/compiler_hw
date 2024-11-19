CC = cc
LEX = flex

LEX_SOURCE = B103040009.l
C_SOURCE = lex.yy.c

all:	$(C_SOURCE)
	$(CC) $(C_SOURCE) -ll

$(C_SOURCE):	$(LEX_SOURCE)
	$(LEX) $(LEX_SOURCE)

clean:
	rm -f a.out $(C_SOURCE)
