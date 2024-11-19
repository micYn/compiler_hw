%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern unsigned int charCount, tokenCount, lineCount, position;
extern int expStart;
void yyerror(const char *s);
int yylex();
int yyparse();

%}
%define parse.error verbose
%token PROGRAM INTEGER REAL VAR IF THEN ELSE BEGINTOKEN END WHILE FOR DO TO FUNCTION PROCEDURE FLOAT STRING OF ARRAY READ WRITE WRITELN
%token ID INTNUM REALNUM STRINGNUM
%token ASSIGN LEQ GEQ NQ MOD
%left '+' '-'
%left '*' '/'

%%
prog 		: PROGRAM ID ';' VAR dec_list BEGINTOKEN stmt_list END '.' | error '.' {yyerrok;}
dec_list	: dec | dec_list dec
dec 		: id_list ':' type ';' | error ';' {yyerrok;}
standtype	: INTEGER | REAL | STRING
type 		: INTEGER | REAL | STRING | ARRAY '['INTNUM '.''.' INTNUM']' OF standtype
id_list 	: varid | STRINGNUM | id_list ',' varid | id_list ',' STRINGNUM
varid		: ID | ID '[' simpexp ']'
stmt_list	: stmt | stmt_list stmt
stmt		: assign ';'| read ';'| write ';'| for | ifstmt | writeln ';'| error ';' {yyerrok;}
assign		: varid ASSIGN simpexp
read		: READ '(' id_list ')'
write		: WRITE '(' id_list ')' | WRITE
writeln		: WRITELN '(' id_list ')' | WRITELN
ifstmt		: IF '(' exp ')' THEN body
exp		: simpexp | exp relop simpexp
relop		: '>' | '<' | GEQ | LEQ | NQ | '=' | MOD
simpexp		: term | simpexp '+' term | simpexp '-' term    
term		: factor | term '*' factor | term '/' factor | '-' INTNUM | '+' INTNUM
factor		: varid | INTNUM | REALNUM | STRINGNUM | '(' simpexp ')'
for		: FOR index_exp DO body 
index_exp	: varid ASSIGN simpexp TO exp
body		: stmt | BEGINTOKEN stmt_list END ';'
%%
/*我如何處理statement: statement list 由多個 statement組成 ，而statement可以是line29的那些*/
int main() {
    printf("Line %d: ",lineCount);
    yyparse();
    printf("\n");
    return 0;
}
void yyerror(const char *str){
	fprintf(stderr, "Line%2d: 1st char: %d, %s\n", lineCount, position , str);
	expStart=0;
}
