%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define TABLE_SIZE 100

char identifierTable[TABLE_SIZE][127];
int identifierCount = 0;
int charCount = 0, tokenCount = 0, lineCount = 1, position = 1, operandPrecedes = 0;

void insert_identifier(char *name);
%}
a	[Aa]
b	[Bb]
c	[Cc]
d	[Dd]
e	[Ee]
f	[Ff]
g	[Gg]
h	[Hh]
i	[Ii]
j	[Jj]
k	[Kk]
l	[Ll]
m	[Mm]
n	[Nn]
o	[Oo]
p	[Pp]
q	[Qq]
r	[Rr]
s	[Ss]
t	[Tt]
u	[Uu]
v	[Vv]
w	[Ww]
x	[Xx]
y	[Yy]
z	[Zz]


whitespace	[\ \t]*
eol	([\r][\n])|[\n]

sign	[+-]
scale_factor	[Ee]{sign}?{digit_sequence}
digit	[0-9]
digit_sequence	{digit}+
hex_digit	[0-9A-Fa-f]
octal_digit [0-7]
octal_digit_sequence	{octal_digit}+
hex_digit_sequence	{hex_digit}+
binary_digit_sequence	(0|1)+

integer	{sign}?({digit_sequence}|"$"{hex_digit_sequence}|"&"{octal_digit_sequence}|"%"{binary_digit_sequence})
wrong_integer	{sign}{sign}+{digit_sequence}
float	{sign}?{digit_sequence}"."{digit_sequence}({scale_factor}|[Ff])?
wrong_float	({digit}+".")|("."{digit}+)|{sign}*{digit}*"."({digit}*[Ee][Ee]{sign}*{digit}*|[Ff][Ff])

punctuation_symbol	[.,:;()\[\]]
operator	"+"|"-"|"*"|"/"|"="|">"|"<"|"^"|"@"|"&"|"<="|">="|":="|"+="|"-="|"*="|"/="

reserved_word	absolute|and|array|asm|begin|case|const|constructor|destructor|div|do|downto|else|end|file|for|function|goto|if|implementation|in|inherited|inline|interface|label|mod|nil|not|object|of|on|operator|or|packed|procedure|program|record|reintroduce|repeat|self|set|shl|shr|string|then|to|type|unit|until|uses|var|while|with|xor|dispose|exit|false|new|true|as|class|dispinterface|except|exports|inalization|finally|initialization|inline|is|library|on|out|packed|property|raise|resourcestring|threadvar|try|abstract|alias|assembler|bitpacked|break|cdecl|continue|cppdecl|cvar|default|deprecated|dynamic|enumerator|experimental|export|external|far|far16|forward|generic|helper|implements|index|interrupt|iocheck|local|message|name|near|nodefault|noreturn|nostackframe|oldfpccall|otherwise|overload|override|pascal|platform|private|protected|public|published|read|register|reintroduce|result|safecall|saveregisters|softfloat|specialize|static|stdcall|stored|strict|unaligned|unimplemented|varargs|virtual|winapi|write|integer|float|real|char|boolean|byte


letter	[A-Za-z]
identifier	({letter}|"_")({letter}|{digit}|"_")*
wrong_identifier	[^{letter}"_"".""+*/=><^@&() ""-"\'\ \n\t\r]({letter}|"_")({letter}|{digit}|"_")*

string_character	[^'\r\n]|\"
quoted_string	\'{string_character}*\'
string	{quoted_string}+
wrong_string	(\'([^'\r\n;]|\")+)|{letter}+\'
comment	\/\/[^\r\n]*|"{"[^}]*"}"|"(*"([^\*]|[\*]+[^\*)])*[\*]+")"
wrong_comment "(*"([^\*]|[\*]+[^\*])*[\*]+")"
%%
{whitespace} {position+=yyleng;}
{eol} {lineCount++; position=1;}
{integer} {
	if(operandPrecedes){
		operandPrecedes = 0;
		REJECT;
	}
	else{
		tokenCount++;
		charCount += yyleng;
		printf("Line: %3d, starts at char. position: %2d, %s\t\"integer\" \n", lineCount, position , yytext);
		position += yyleng;
		operandPrecedes = 1;
	}
}
{wrong_integer} {
	if(operandPrecedes){
		operandPrecedes = 0;
		REJECT;
	}
	else{
		tokenCount++;
		charCount += yyleng;
		printf("Line: %3d, starts at char. position: %2d, %s\t\"wrong integer\" \n", lineCount, position , yytext);
		position += yyleng;
		operandPrecedes = 1;
	}
}
{float} {
	if(operandPrecedes){
		operandPrecedes = 0;
		REJECT;
	}
	else{
		tokenCount++;
		charCount += yyleng;
		printf("Line: %3d, starts at char. position: %2d, %s\t\"float\" \n", lineCount, position , yytext);
		position += yyleng;
		operandPrecedes = 1;
	}
}
{wrong_float} {
	if(operandPrecedes){
		operandPrecedes = 0;
		REJECT;
	}
	else{
		tokenCount++;
		charCount += yyleng;
		printf("Line: %3d, starts at char. position: %2d, %s\t\"wrong float\" \n", lineCount, position , yytext);
		position += yyleng;
		operandPrecedes = 1;
	}
}
{punctuation_symbol} {
	tokenCount++;
	charCount += yyleng;
	printf("Line: %3d, starts at char. position: %2d, %s\t\"punctuation symbol\" \n", lineCount, position , yytext);	
	position += yyleng;
}
{operator} {
	tokenCount++;
	charCount += yyleng;
	printf("Line: %3d, starts at char. position: %2d, %s\t\"operator\" \n", lineCount, position , yytext);	
	position += yyleng;
	operandPrecedes = 0;
}
({a}{b}{s}{o}{l}{u}{t}{e})|({a}{n}{d})|({a}{r}{r}{a}{y})|({a}{s}{m})|({b}{e}{g}{i}{n})|({c}{a}{s}{e})|({c}{o}{n}{s}{t})|({c}{o}{n}{s}{t}{r}{u}{c}{t}{o}{r})|({d}{e}{s}{t}{r}{u}{c}{t}{o}{r})|({d}{i}{v})|({d}{o})|({d}{o}{w}{n}{t}{o})|({e}{l}{s}{e})|({e}{n}{d})|({f}{i}{l}{e})|({f}{o}{r})|({f}{u}{n}{c}{t}{i}{o}{n})|({g}{o}{t}{o})|({i}{f})|({i}{m}{p}{l}{e}{m}{e}{n}{t}{a}{t}{i}{o}{n})|({i}{n})|({i}{n}{h}{e}{r}{i}{t}{e}{d})|({i}{n}{l}{i}{n}{e})|({i}{n}{t}{e}{r}{f}{a}{c}{e})|({l}{a}{b}{e}{l})|({m}{o}{d})|({n}{i}{l})|({n}{o}{t})|({o}{b}{j}{e}{c}{t})|({o}{f})|({o}{n})|({o}{p}{e}{r}{a}{t}{o}{r})|({o}{r})|({p}{a}{c}{k}{e}{d})|({p}{r}{o}{c}{e}{d}{u}{r}{e})|({p}{r}{o}{g}{r}{a}{m})|({r}{e}{c}{o}{r}{d})|({r}{e}{i}{n}{t}{r}{o}{d}{u}{c}{e})|({r}{e}{p}{e}{a}{t})|({s}{e}{l}{f})|({s}{e}{t})|({s}{h}{l})|({s}{h}{r})|({s}{t}{r}{i}{n}{g})|({t}{h}{e}{n})|({t}{o})|({t}{y}{p}{e})|({u}{n}{i}{t})|({u}{n}{t}{i}{l})|({u}{s}{e}{s})|({v}{a}{r})|({w}{h}{i}{l}{e})|({w}{i}{t}{h})|({x}{o}{r})|({d}{i}{s}{p}{o}{s}{e})|({e}{x}{i}{t})|({f}{a}{l}{s}{e})|({n}{e}{w})|({t}{r}{u}{e})|({a}{s})|({c}{l}{a}{s}{s})|({d}{i}{s}{p}{i}{n}{t}{e}{r}{f}{a}{c}{e})|({e}{x}{c}{e}{p}{t})|({e}{x}{p}{o}{r}{t}{s})|({i}{n}{a}{l}{i}{z}{a}{t}{i}{o}{n})|({f}{i}{n}{a}{l}{l}{y})|({i}{n}{i}{t}{i}{a}{l}{i}{z}{a}{t}{i}{o}{n})|({i}{n}{l}{i}{n}{e})|({i}{s})|({l}{i}{b}{r}{a}{r}{y})|({o}{n})|({o}{u}{t})|({p}{a}{c}{k}{e}{d})|({p}{r}{o}{p}{e}{r}{t}{y})|({r}{a}{i}{s}{e})|({r}{e}{s}{o}{u}{r}{c}{e}{s}{t}{r}{i}{n}{g})|({t}{h}{r}{e}{a}{d}{v}{a}{r})|({t}{r}{y})|({a}{b}{s}{t}{r}{a}{c}{t})|({a}{l}{i}{a}{s})|({a}{s}{s}{e}{m}{b}{l}{e}{r})|({b}{i}{t}{p}{a}{c}{k}{e}{d})|({b}{r}{e}{a}{k})|({c}{d}{e}{c}{l})|({c}{o}{n}{t}{i}{n}{u}{e})|({c}{p}{p}{d}{e}{c}{l})|({c}{v}{a}{r})|({d}{e}{f}{a}{u}{l}{t})|({d}{e}{p}{r}{e}{c}{a}{t}{e}{d})|({d}{y}{n}{a}{m}{i}{c})|({e}{n}{u}{m}{e}{r}{a}{t}{o}{r})|({e}{x}{p}{e}{r}{i}{m}{e}{n}{t}{a}{l})|({e}{x}{p}{o}{r}{t})|({e}{x}{t}{e}{r}{n}{a}{l})|({f}{a}{r})|({f}{a}{r}{1}{6})|({f}{o}{r}{w}{a}{r}{d})|({g}{e}{n}{e}{r}{i}{c})|({h}{e}{l}{p}{e}{r})|({i}{m}{p}{l}{e}{m}{e}{n}{t}{s})|({i}{n}{d}{e}{x})|({i}{n}{t}{e}{r}{r}{u}{p}{t})|({i}{o}{c}{h}{e}{c}{k})|({l}{o}{c}{a}{l})|({m}{e}{s}{s}{a}{g}{e})|({n}{a}{m}{e})|({n}{e}{a}{r})|({n}{o}{d}{e}{f}{a}{u}{l}{t})|({n}{o}{r}{e}{t}{u}{r}{n})|({n}{o}{s}{t}{a}{c}{k}{f}{r}{a}{m}{e})|({o}{l}{d}{f}{p}{c}{c}{a}{l}{l})|({o}{t}{h}{e}{r}{w}{i}{s}{e})|({o}{v}{e}{r}{l}{o}{a}{d})|({o}{v}{e}{r}{r}{i}{d}{e})|({p}{a}{s}{c}{a}{l})|({p}{l}{a}{t}{f}{o}{r}{m})|({p}{r}{i}{v}{a}{t}{e})|({p}{r}{o}{t}{e}{c}{t}{e}{d})|({p}{u}{b}{l}{i}{c})|({p}{u}{b}{l}{i}{s}{h}{e}{d})|({r}{e}{a}{d})|({r}{e}{a}{d}{l}{n})|({r}{e}{g}{i}{s}{t}{e}{r})|({r}{e}{i}{n}{t}{r}{o}{d}{u}{c}{e})|({r}{e}{s}{u}{l}{t})|({s}{a}{f}{e}{c}{a}{l}{l})|({s}{a}{v}{e}{r}{e}{g}{i}{s}{t}{e}{r}{s})|({s}{o}{f}{t}{f}{l}{o}{a}{t})|({s}{p}{e}{c}{i}{a}{l}{i}{z}{e})|({s}{t}{a}{t}{i}{c})|({s}{t}{d}{c}{a}{l}{l})|({s}{t}{o}{r}{e}{d})|({s}{t}{r}{i}{c}{t})|({u}{n}{a}{l}{i}{g}{n}{e}{d})|({u}{n}{i}{m}{p}{l}{e}{m}{e}{n}{t}{e}{d})|({v}{a}{r}{a}{r}{g}{s})|({v}{i}{r}{t}{u}{a}{l})|({w}{i}{n}{a}{p}{i})|({w}{r}{i}{t}{e})|({w}{r}{i}{t}{e}{l}{n})|({i}{n}{t}{e}{g}{e}{r})|({f}{l}{o}{a}{t})|({r}{e}{a}{l})|({c}{h}{a}{r})|({b}{o}{o}{l}{e}{a}{n})|({b}{y}{t}{e}) {
	tokenCount++;
	charCount += yyleng;
	printf("Line: %3d, starts at char. position: %2d, %s\t\"reserved word\" \n", lineCount, position , yytext);	
	position += yyleng;
}
{identifier} {
	if(yyleng>15){
		tokenCount++;
		charCount += yyleng;
		int i,j;
		printf("Line: %3d, starts at char. position: %2d, %s\t\"wrong identifier\" \n", lineCount, position , yytext);
		position += yyleng;
		operandPrecedes = 1;
	}
	else{
		tokenCount++;
		charCount += yyleng;
		printf("Line: %3d, starts at char. position: %2d, %s\t\"identifier\" \n", lineCount, position , yytext);
		position += yyleng;
		operandPrecedes = 1;
		insert_identifier(yytext);
	}
}
{wrong_identifier} {
	tokenCount++;
	charCount += yyleng;
	int i,j;
	printf("Line: %3d, starts at char. position: %2d, %s\t\"wrong identifier\" \n", lineCount, position , yytext);
	position += yyleng;
	operandPrecedes = 1;
}
{string} {
	int formerleng = yyleng;

	tokenCount++;
	charCount += yyleng;
	printf("Line: %3d, starts at char. position: %2d, ", lineCount, position);
	printf("\'");
	int i;
	for(i=1;i<=yyleng-2;i++){
		if(yytext[i]=='\''&&yytext[i+1]=='\''&&i+1!=yyleng-1){
			printf("%c", yytext[i]);
			i++;
			continue;
		}
		printf("%c", yytext[i]);
	}
	printf("\'\t\"character string\" \n");
	position += formerleng;
	operandPrecedes = 1;
}
{wrong_string} {
	tokenCount++;
	charCount += yyleng;
	printf("Line: %3d, starts at char. position: %2d, %s\t\"wrong character string\" \n", lineCount, position , yytext);	
	position += yyleng;
	operandPrecedes = 1;
}
{comment} {
	
	tokenCount++;
	charCount += yyleng;
	printf("Line: %3d, starts at char. position: %2d, \n%s\n\"comment\" \n", lineCount, position , yytext);	
	position += yyleng;
	int i=0;
	for(i=0;i<yyleng;i++){
		if(yytext[i] == '\n')	lineCount++;
	}
}
{wrong_comment} {
	tokenCount++;
	charCount += yyleng;
	printf("Line: %3d, starts at char. position: %2d, \n%s\n\"wrong comment\" \n", lineCount, position , yytext);	
	position += yyleng;
	int i=0;
	for(i=0;i<yyleng;i++){
		if(yytext[i] == '\n')	lineCount++;
	}
}		
. {
	tokenCount++;
	charCount += yyleng;
	printf("Line: %3d, starts at char. position: %2d, %s\t\"unrecognized character\" \n", lineCount, position, yytext);
	position += yyleng;
}
%%
int main() {

    printf("\n-----Scanner start-----\n");
	
    yylex();
	
    // Print identifier table
    printf("\nIdentifier Table:\n");
    for (int i = 0; i < identifierCount; i++) {
        printf("%s\n", identifierTable[i]);
    }
    
    printf("------Scanner end------\n");

    return 0;
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


