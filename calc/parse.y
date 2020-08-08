%{

#include <stdio.h>
void yyerror(char *s);
int yylex();
%}

%token NUMBER
%token ADD SUB MUL DIV 
%token EOL 

%left ADD SUB
%left MUL DIV
%left AND OR 
%%

program : 
		| program statement EOL 
		; 

statement : expr 
		  {
			printf("calc result : %d\n", $1);
		  }
		  ; 

expr : expr ADD expr 
	 {
 		$$ = $1 + $3;
     }
	 | expr SUB expr
	 {
		$$ = $1 - $3; 
	 } 
	 | expr MUL expr
	 {
		$$ = $1 * $3; 
     }
     | expr DIV expr 
	 {
		$$ = $1 / $3; 
	 }
	 | expr AND expr 
	 {
		$$ = $1 & $3; 
     }
	 | expr OR expr 
	 {
		$$ = $1 | $3;
	 }
	 | NUMBER 
	 {
		$$ = $1; 
	 } 
     ; 

%%

int main(int argc, char** argv){
	yyparse(); 
}

void yyerror(char *s){
	fprintf(stderr, "error : %s\n", s);
}
