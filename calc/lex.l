%{
#include <stdio.h>
#include "parse.tab.h"
%}

%%

"+" { return ADD; } 
"-" { return SUB; }
"*" { return MUL; }
"/" { return DIV; }
"&" { return AND; }
"|" { return OR; }
[0-9]+ { yylval = atoi(yytext); return NUMBER; }
"\n" return EOL; 
[  \t] {  }
. {
		printf("Error char : %c", *yytext);
	}
%%

int yywrap(){
	return 1;
}
