%{
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"
#define TABLE_SIZE 100
char identifierTable[TABLE_SIZE][127];
char identifierType[TABLE_SIZE][127];
char undefinedID[127];
int undefinedMsg=0;
int expStart = 0,count = 0;
char firstType[127];
char secondType[127];
int typeconflictMsg=0;
int assignVal=0;
char previousIdType[127];
unsigned int charCount = 0, tokenCount = 0, lineCount = 1 ,position = 1, afterVar = 0, identifierCount = 0;
void insert_identifier(char *name);
int find_identifier(char *name);
%}

whitespace	[\ \t]*
eol	([\r][\n])|[\n]

sign	[+-]
scale_factor	[Ee]{sign}?{digit_sequence}
digit	[0-9]
digit_sequence	{digit}+

integer	{digit_sequence}
real	{digit_sequence}"."{digit_sequence}({scale_factor}|[Ff])?

symbol	[.,:;()\[\]]

operator "+"|"-"|"*"|"/"|"="|":="|">"|"<"|"<="|">="|"<>"|"mod"

PROGRAM     [Pp][Rr][Oo][Gg][Rr][Aa][Mm]
INTEGER     [Ii][Nn][Tt][Ee][Gg][Ee][Rr]
REAL	    [Rr][Ee][Aa][Ll]
VAR         [Vv][Aa][Rr]
IF          [Ii][Ff]
THEN        [Tt][Hh][Ee][Nn]
ELSE        [Ee][Ll][Ss][Ee]
BEGIN       [Bb][Ee][Gg][Ii][Nn]
END         [Ee][Nn][Dd]
WHILE       [Ww][Hh][Ii][Ll][Ee]
FOR         [Ff][Oo][Rr]
DO          [Dd][Oo]
TO          [Tt][Oo]
FUNCTION    [Ff][Uu][Nn][Cc][Tt][Ii][Oo][Nn]
PROCEDURE   [Pp][Rr][Oo][Cc][Ee][Dd][Uu][Rr][Ee]
FLOAT	    [Ff][Ll][Oo][Aa][Tt]
STRING      [Ss][Tt][Rr][Ii][Nn][Gg]
OF	    [Oo][Ff]
ARRAY	    [Aa][Rr][Rr][Aa][Yy]
READ	    [Rr][Ee][Aa][Dd]
WRITE       [Ww][Rr][Ii][Tt][Ee]
WRITELN     [Ww][Rr][Ii][Tt][Ee][Ll][Nn]



letter	[A-Za-z]
identifier	({letter}|"_")({letter}|{digit}|"_")*

string_character	[^'\r\n]|\"
quoted_string	\'{string_character}*\'
string	{quoted_string}+

comment	\/\/[^\r\n]*|"{"[^}]*"}"|"(*"([^\*]|[\*]+[^\*)])*[\*]+")"
%%
{whitespace} {
	printf("%s", yytext);
	position++;
}
{eol} {
	if(undefinedMsg){printf("\tsyntax error: %s undefined.",undefinedID);undefinedMsg=0;}
	if(count==1){expStart=0;typeconflictMsg=0;}
	if(typeconflictMsg){printf("\tsyntax error: %s and %s are conflicted.",firstType, secondType);typeconflictMsg=0;}
	if(assignVal){
		if(strcmp(firstType,previousIdType)!=0)	{printf("\tsyntax error: %s and %s are conflicted.",previousIdType, firstType);assignVal=0;}
	}
	printf("\nLine%2d: ", ++lineCount);
	position=1;
}
{integer} {
	if(expStart==1&&count==0){
		strcpy(firstType,"integer");
		count++;
	}
	tokenCount++;
	charCount += yyleng;
	position += yyleng;
	printf("%s", yytext);
	return INTNUM;
}
{real} {
	if(expStart==1&&count==0){
		strcpy(firstType,"real");
		count++;
	}
	tokenCount++;
	charCount += yyleng;
	position += yyleng;
	printf("%s", yytext);
	return REALNUM;
}
{symbol} {
	tokenCount++;
	charCount += yyleng;
	position += yyleng;
	printf("%s", yytext);
	if(strcmp(yytext, ".") == 0)	return '.';
	if(strcmp(yytext, ",") == 0)	return ',';
	if(strcmp(yytext, ":") == 0)	return ':';
	if(strcmp(yytext, ";") == 0)	return ';';
	if(strcmp(yytext, "(") == 0)	return '(';
	if(strcmp(yytext, ")") == 0)	return ')';
	if(strcmp(yytext, "[") == 0)	return '[';
	if(strcmp(yytext, "]") == 0)	return ']';
}
{operator} {
	tokenCount++;
	charCount += yyleng;
	position += yyleng;
	printf("%s", yytext);
	if(strcmp(yytext, "+") == 0)	{assignVal=0;return '+';}
	if(strcmp(yytext, "-") == 0)	{assignVal=0;return '-';}
	if(strcmp(yytext, "*") == 0)	{assignVal=0;return '*';}
	if(strcmp(yytext, "/") == 0)	{assignVal=0;return '/';}
	if(strcmp(yytext, "=") == 0)	{assignVal=0;return '=';}
	if(strcmp(yytext, ":=") == 0)	{assignVal=1;expStart=1;count=0;return ASSIGN;}
	if(strcmp(yytext, ">") == 0)	{assignVal=0;return '<';}
	if(strcmp(yytext, "<") == 0)	{assignVal=0;return '>';}
	if(strcmp(yytext, ">=") == 0)	{assignVal=0;return GEQ;}
	if(strcmp(yytext, "<=") == 0)	{assignVal=0;return LEQ;}
	if(strcmp(yytext, "<>") == 0)	{assignVal=0;return NQ;}
	if(strcmp(yytext, "mod") == 0)	{assignVal=0;return MOD;}
}

{PROGRAM}	{tokenCount++;charCount += yyleng;position += yyleng;printf("%s", yytext);return(PROGRAM);}
{INTEGER}	{tokenCount++;charCount += yyleng;position += yyleng;printf("%s", yytext);if(!afterVar){int i;for(i=0;i<=identifierCount-1;i++){if(strcmp(identifierType[i],"")==0) strcpy(identifierType[i],"integer");}}return(INTEGER);}
{REAL}		{tokenCount++;charCount += yyleng;position += yyleng;printf("%s", yytext);if(!afterVar){int i;for(i=0;i<=identifierCount-1;i++){if(strcmp(identifierType[i],"")==0) strcpy(identifierType[i],"real");}}return(REAL);}
{VAR}		{tokenCount++;charCount += yyleng;position += yyleng;printf("%s", yytext);return(VAR);}
{IF}		{tokenCount++;charCount += yyleng;position += yyleng;printf("%s", yytext);return(IF);}
{THEN} 		{tokenCount++;charCount += yyleng;position += yyleng;printf("%s", yytext);return(THEN);}
{ELSE} 		{tokenCount++;charCount += yyleng;position += yyleng;printf("%s", yytext);return(ELSE);}
{BEGIN}		{tokenCount++;charCount += yyleng;position += yyleng;printf("%s", yytext);afterVar=1;return(BEGINTOKEN);}
{END}		{tokenCount++;charCount += yyleng;position += yyleng;printf("%s", yytext);return(END);}
{WHILE}		{tokenCount++;charCount += yyleng;position += yyleng;printf("%s", yytext);return(WHILE);}
{FOR}		{tokenCount++;charCount += yyleng;position += yyleng;printf("%s", yytext);return(FOR);}
{DO} 		{tokenCount++;charCount += yyleng;position += yyleng;printf("%s", yytext);return(DO);}
{TO}		{tokenCount++;charCount += yyleng;position += yyleng;printf("%s", yytext);return(TO);}
{FUNCTION}	{tokenCount++;charCount += yyleng;position += yyleng;printf("%s", yytext);return(FUNCTION);}
{PROCEDURE}	{tokenCount++;charCount += yyleng;position += yyleng;printf("%s", yytext);return(PROCEDURE);}
{FLOAT}		{tokenCount++;charCount += yyleng;position += yyleng;printf("%s", yytext);if(!afterVar){int i;for(i=0;i<=identifierCount-1;i++){if(strcmp(identifierType[i],"")==0) strcpy(identifierType[i],"real");}}return(FLOAT);}
{STRING}	{tokenCount++;charCount += yyleng;position += yyleng;printf("%s", yytext);if(!afterVar){int i;for(i=0;i<=identifierCount-1;i++){if(strcmp(identifierType[i],"")==0) strcpy(identifierType[i],"string");}}return(STRING);}
{OF}		{tokenCount++;charCount += yyleng;position += yyleng;printf("%s", yytext);return(OF);}
{ARRAY}		{tokenCount++;charCount += yyleng;position += yyleng;printf("%s", yytext);return(ARRAY);}
{READ} 		{tokenCount++;charCount += yyleng;position += yyleng;printf("%s", yytext);return(READ);}
{WRITE} 	{tokenCount++;charCount += yyleng;position += yyleng;printf("%s", yytext);return(WRITE);}
{WRITELN} 	{tokenCount++;charCount += yyleng;position += yyleng;printf("%s", yytext);return(WRITELN);}

{identifier} {
	int i=0;
	for(i=0;i<identifierCount;i++){
		if(strcmp(yytext,identifierTable[i])==0){
			break;
		}
	}
	strcpy(previousIdType,identifierType[i]);
	
	if(expStart==1&&count==0){
		strcpy(firstType,identifierType[i]);
		count++;
	}
	else if(expStart==1&&count==1){
		strcpy(secondType,identifierType[i]);
		if(strcmp(firstType,secondType)!=0){
			typeconflictMsg=1;
		}
		expStart=0; count++;
	}
	
	if(afterVar&&!find_identifier(yytext)){
		tokenCount++;
		charCount += yyleng;
		position += yyleng;
		strcpy(undefinedID, yytext);
		undefinedMsg=1;
		printf("%s", yytext);
		return ID;
	}
	else{
		insert_identifier(yytext);
		tokenCount++;
		charCount += yyleng;
		position += yyleng;
		printf("%s", yytext);
		return ID;
	}
}
{string} {
	if(expStart==1&&count==0){
		strcpy(firstType,"string");
		count++;
	}
	tokenCount++;
	charCount += yyleng;
	position += yyleng;
	printf("%s", yytext);
	return STRINGNUM;
}
{comment} {
	printf("A comment starts");
	tokenCount++;
	charCount += yyleng;	
	position += yyleng;
	int i=0;
	for(i=0;i<yyleng;i++){
		if(yytext[i] == '\n')	lineCount++;
	}
}
. {
	printf("%s (in char: %d, undefined.)", yytext, charCount);
	charCount += yyleng;
}
%%
int yywrap(void) {
    return 1;
}
void insert_identifier(char *name) {
    // Check for duplicates
    int i;
    for (i=0; i < identifierCount; i++) {
        if (strcmp(identifierTable[i], name) == 0) {
            return;
        }
    }
    // Insert new identifier
    if (identifierCount < TABLE_SIZE) {
        strcpy(identifierTable[identifierCount], name);
        identifierCount++;
    } else {
        fprintf(stderr, "Error: Symbol table overflow\n");
        return;
    }
}
int find_identifier(char *name) {
    int i;
    for (i=0; i < identifierCount; i++) {
        if (strcmp(identifierTable[i], name) == 0) {
            return 1;
        }
    }
    return 0;
}
