%option noyywrap nodefault yylineno case-insensitive 

%{
	struct symbol{
		char* name; 
		struct ref* reflist; 
		struct ref* tail;
	}; 
	
	struct ref{
		struct ref* next; 
		char* filename; 
		int flags; 
		int lineno; 
	};

#define MHASH 9997
struct symbol symtab[MHASH]; 

struct symbol* lookup(char* ); 
void addref(int, char*, char*, int); 

char* curfilename; 
void printrefs();
void test_print();
%}

%%

a | 
an | 
and | 
are | 
as | 
at | 
be | 
but | 
for | 
in | 
is | 
it | 
of | 
on | 
or | 
that | 
the | 
this | 
to  /* ignore */

[a-z]+(\'(s|t))? { 
	addref(yylineno, curfilename, yytext, 0); 	
}
.|\n /* ignore everything else */
%%

int main(int argc, char** argv){
	if(argc < 2){
		curfilename = "(stdin)"; 
		yylineno = 1; 
		yylex(); 
	} else {
		for(int i=1;i<argc;i++){
			FILE* f = fopen(argv[i], "r");
			if(!f){
				perror(argv[i]);
				return 1;
			}
			curfilename = argv[i]; 

			yyrestart(f); 
			yylineno = 1; 
			yylex(); 
			fclose(f); 
		}
		test_print();
		//printrefs(); 
	}
}

/* hash a symbol */
static unsigned symhash(char* sym){
	unsigned int hash = 0; 
	unsigned c; 

	while(c = *sym++) hash = hash*9 ^ c; 
	return hash; 
}

/* 찾아보고 없다면  빈공간을 return 한다.  있으면 그거 return  */
struct symbol* lookup(char* sym){
	struct symbol* sp = &symtab[symhash(sym) % MHASH];
	int scount = MHASH;  //how many have we looked at
	
	while(--scount >= 0){
		//이미 존재한다면
		if(sp->name && !strcmp(sp->name, sym)){
			//printf("alreay entry\n");
			return sp; 
		}
		//없다면 reflist 0으로 한다음 return
		if(!sp->name){
			//printf("make new entry\n");
			sp->name = strdup(sym); 
			sp->reflist = 0; 
			return sp; 
		}
		/* try the next entry */ //만약 sp 가 배열의 크기보다 크다면 다시 처음배열로  
		if(++sp >= symtab+MHASH){
			sp = symtab; 
		}
	}
	fputs("symbol table overflow\n", stderr); 
	abort(); 
}

void addref(int lineno, char* filename, char* word, int flags){
	//printf("addreff\n");
	struct ref* r; 
	struct symbol* sp = lookup(word);  //new entry or aleary entry 

	/* don't do dups of same line and file */
	if(sp->reflist && 
		sp->reflist->lineno == lineno && 
		sp->reflist->filename == filename){
		return;
	}

	r = (struct ref*)malloc(sizeof(struct ref)); 
	if(!r) {
		fputs("out of space\n", stderr);
		abort(); 
	}
	//r->next = sp->reflist; 
	r->next = NULL;
	r->filename = filename; 
	r->lineno = lineno;  //lineno ? 
	r->flags = flags;  //flags?
	if(sp->reflist == NULL){
		sp->reflist = r;
		sp->tail = r;  
	} else {
		sp->tail->next = r; 
		sp->tail = r; 
	}
}

static int symcompare(const void* xa, const void *xb){
	const struct symbol* a = xa; 
	const struct symbol* b = xb; 

	if(!a->name){
		if(!b->name) return 0; 
		return 1; 
	}	
	if(!b->name) return -1; 
	return strcmp(a->name, b->name); 
}

void test_print(){
	struct symbol* sp;
	qsort(symtab, MHASH, sizeof(struct symbol), symcompare);
	for(sp=symtab;sp->name && sp < symtab+MHASH; sp++){
		struct ref* rp = sp->reflist;
		printf("symbol name : %s\n", sp->name); 
		while(rp != NULL){
			printf("filename : %s\n", rp->filename);
			printf("lineno : %d, flags : %d\n", rp->lineno, rp->flags);
			rp = rp->next; 
		}
		printf("\n");
	}
}

void printrefs(){
	printf("printrefs\n");
	struct symbol* sp; 
	qsort(symtab, MHASH, sizeof(struct symbol), symcompare); 

	for(sp=symtab; sp->name && sp < symtab+MHASH; sp++){
		/* last printed filename, to skip dups */
		char* prevfn = NULL; 
		/* reverse the list of references */
		struct ref* rp = sp->reflist; 
		/* previous ref */
		struct ref* rpp = 0;
		/* next ref */ 
		struct ref* rpn; 

		do{
			rpn = rp->next; 
			rp->next = rpp; 
			rpp = rp; 
			rp = rpp; 
		} while(rp);
 
		printf("[symbol]\n");
		printf("%10s", sp->name);
		for(rp=rpp; rp; rp = rp->next){
			if(rp->filename == prevfn){
				printf(" %d", rp->lineno);
			} else {
				printf(" %s:%d", rp->filename, rp->lineno);
				prevfn = rp->filename; 
			}
		}
		printf("\n");
	}
}






















