/* CEI222: Project Step[3] ID: [Sotiris Vasiliadis-ID19613]_[Michael-Aggelos Demou-ID19753]_[Konstantinos Konstantinou-ID20284]_[Giorgos Tsovilis-ID19971] */

%{ 
#include <iostream>
#include "symtable.h"
#include "lex.yy.c"
#include <string>
#include <vector>
#include "step3.tab.h"
using namespace std;
extern int yylex();
extern int yyparse();
void yyerror(char const *s);
extern char *yytext;
extern int yylineno;
static int level=0;
static int offset=0;
static int goffset=0;
static int maxoffset=0;
char filename[80];
vector<string> parameters;
vector<int> arguments;
symtable ProgramSymtable;
%}
%define parse.error verbose

%union {
    char* str;
    int num;
}
%type<num> program declaration_list declaration var_declaration type_specifier 
%type<num> fun_declaration local_declarations stmt_list statement 
%type<num> expression_stmt selection_stmt compound_stmt
%type<num> iteration_stmt return_stmt expression assign_stmt 
%type<num> simple_expression additive_expression term factor call
%type<str> var mulop addop relop
%token<num> NUM
%token<str> ID
%token IF WHILE ELSE INT RETURN VOID SOE GOE EQV NEV
%%
program: declaration_list						
					
declaration_list: declaration
		| declaration declaration_list 
		;

declaration: var_declaration
	   | fun_declaration
           ;

var_declaration: type_specifier ID ';' {
		if($1==1){
      			if(ProgramSymtable.insertvtable($2, level, 0, 0))
			      yyerror("Redefined variable declaration");
		}
		else
			yyerror("Invalid type specifier (did you mean int?)");	
                }
			       		
	       | type_specifier ID '[' NUM ']' ';'
	       {
		if($1==1)
      			ProgramSymtable.insertvtable($2, level, 0, $4);
		else
			yyerror("Invalid type specifier (did you mean int?)");	
               }
	       | error ';' {}
	       ;
	

				
type_specifier  : INT   	{ $$=1;	}
                | VOID  	{ $$=0;	}
		| error ';' {yyerror("Invalid type specifier (did you mean int?)");}
                ;

fun_declaration : type_specifier ID '('
                {   
			level++;
                }
                params
                { 	  
                    if(ProgramSymtable.insertftable($2, level, $1, parameters, yylineno, filename ))
		    	yyerror("Redefined function declaration");
		    parameters.clear();
                }
                ')' compound_stmt
                {
                   
                }
                ;

params: VOID
      | param_list
      ;

param_list: param
          | param ',' param_list
          ;

param: type_specifier ID
      {  
	if($1==1)
      		parameters.push_back($2);
	else
		yyerror("Incompatible types in parameter declaration (did you mean int?)");	
	
      }
      | type_specifier ID '[' ']'
      {
        if($1==1){
      		parameters.push_back($2);
	}
	else
		yyerror("Incompatible types in parameter declaration (did you mean int?)");
      }
      | error ')' {yyerror("Invalid Parameters");}

      ;

compound_stmt : '{'
                   local_declarations stmt_list '}'
                {
                    
                }
                ;

local_declarations: var_declaration
                  | var_declaration local_declarations
		  | {}
                  ;

stmt_list: statement
         | statement stmt_list
	 | {}
         ;

statement: expression_stmt { $$ = $1; }				
	 | compound_stmt
	 | selection_stmt { $$ = $1; }
	 | iteration_stmt { $$ = $1; }
	 | assign_stmt { $$ = $1; }
	 | return_stmt { $$ = $1; }
	 ;

expression_stmt: expression ';'
               | ';' {$$ = 0;}
               ;

selection_stmt: IF '(' expression ')' statement {$$=0;}
              | IF '(' expression ')' statement ELSE statement {$$=0;}
              ;

iteration_stmt: WHILE '(' expression ')' statement {$$=0;}
              ;

return_stmt: RETURN  ';' 
	   {
		$$=0;
	   }
           | RETURN expression ';' 
	   {
		if(ProgramSymtable.returnftype(level))
			ProgramSymtable.assignfunval(level, $2); 
		else
			yyerror("Return type of a function");
		$$=$2;
	   }
           ;

expression: simple_expression {$$ = $1;}
          ;

assign_stmt: var '=' expression_stmt 
           {
		if(!ProgramSymtable.modifyvtable($1, level, $3))
			yyerror("Undefined variable");
		$$=$3;
           }
           ;

var: ID
   {
        if(ProgramSymtable.isanArray($1, level))
		yyerror("Incompatible types in assignment (illegal assignment)");
	else{
		if(ProgramSymtable.vtablesearch($1,level))
			$$=$1;
		}
        }
   | ID '[' expression ']'
   {
        if(!ProgramSymtable.isanArray($1, level))
		$$=$1;            
        else
                yyerror("Undefined variable");
   }
   ;

simple_expression: additive_expression {$$ = $1;}
                 | simple_expression relop additive_expression
                 {
                 if($2=="<=")
			$$=$1<=$3;
			
		 else if($2=="<")
			$$=$1<$3;
			    
		 else if($2==">")
			$$=$1>$3;
			   
		 else if($2==">=")
			$$=$1>=$3;
			   
		 else if($2=="==")
			$$=$1==$3;
			    
		 else if($2=="!=")
			$$=$1!=$3;
		 else	    
			yyerror("Type mismatch or void in simple_expression");  
                 }
                 ;

relop: SOE    {$$="<=";}
     | '<'    {$$="<";}
     | '>'    {$$=">";}
     | GOE    {$$=">=";}
     | EQV    {$$="==";}
     | NEV    {$$="!=";}
     ;

additive_expression: term {$$ = $1;}
                   | additive_expression addop term
                   { 
			if($2=="+")
			    $$=$1+$3;
			else if($2=="-")
			    $$=$1-$3;
		   }
                   ;

addop: '+' {$$ = "+";}
     | '-' {$$ = "-";}
     ;

term: factor {$$ = $1;}
    | term mulop factor
    {  
	if($2=="*")
	    $$=$1*$3;
	else if($2=="/")
	    $$=$1/$3;
	else if($2=="%")
	    $$=$1%$3;
	else
	    yyerror("Type mismatch or void in term/factor exp");        
    };

mulop: '*'  {$$ = "*";}
     | '/'  {$$ = "/";}
     | '%'  {$$ = "%";}
     ;

factor: '(' expression ')' {$$ = $2;}
      | NUM  {$$=$1;}
      | var  {$$=ProgramSymtable.valuevtablesearch($1, level);}
      | call {$$ = $1;}
      ;

call: ID '(' args ')'
    {	
	unsigned int size=arguments.size();
        if(ProgramSymtable.vtablesearch($1, level))
		yyerror("Is a variable, but was called as function");
        
	else if(ProgramSymtable.ftablesearch($1)){
		if (!ProgramSymtable.ftableargsearch($1, size))
			yyerror("Wrong type of arguments");
		else 
                for(auto it=arguments.begin();it!=arguments.end();++it)
			ProgramSymtable.modifyparamvtable(level, *it, size);
		$$=ProgramSymtable.returnfunvalue($1, size);
	}
		
        else{
		yyerror("Call to undefined function");
		$$=0;
	}
	
   }
   ;

args: arg_list
    | {}
    ;

arg_list: expression
        {
                arguments.push_back($1);
        }
        | expression ',' arg_list
        {  
                arguments.push_back($1);
        }
;		
%%

int main(int argc, char *argv[])
{
    if (argc==1){
	printf("Enter code manually enter press enter to finish:");
	yyin=stdin;
    }
    if (argc==2){
	yyin=fopen(argv[1],"r");
	strcpy(filename, argv[1]);
    }
    yyparse();
    return 0;
}

void yyerror (char const *s) {
    fprintf (stderr, "%s-: %d %s\n", filename, yylineno, s);
}