%{ 
#include <stdio.h>
#include <string.h>
#include "step2.tab.h"
#include "lex.yy.c"
#include <string.h>
int yylex();
void yyerror(char const *s);
%}
%option noyywrap
%union {
    string ident;
    int num; 
}

%token<num> NUM
%token<ident> ID

%token IF
%token WHILE
%token ELSE
%token INT
%token RETURN
%token VOID
%token COM
%token SOE
%token GOE
%token EQV
%token NEV
%token<num> NEWLINE

%%
program:  declaration_list { printf("program\ndeclaration_list\n"); };							
					
declaration_list: declaration_list declaration  { printf("declaration_list\n"); }
				| declaration   					
				;
					
declaration: var_declaration 					
		   | fun_declaration
           ;
					
var_declaration: type_specifier ID ';'  	{ printf("val_declaration\n");} 		
			   | type_specifier ID '[' NUM ']' ';'  
			   ;
	

				
type_specifier: INT   { printf("type_specifier(INT)\n"); }
			  | VOID  { printf("type_specifier(VOID)\n"); }
			  ;
					
fun_declaration: type_specifier ID fun1 
			   ;
					
fun1: '(' params ')' compound_stmt {printf("Fun_definition_params-compound\n");};	 			
					
params: param_list	{printf("Params-INT\n");}					 
	  | VOID 		{printf("Params-Void\n");}
	  ;
					
param_list: param_list ',' param 
		  | param 
		  ;
 
param: type_specifier ID 
	 | type_specifier ID '[' NUM ']' 
	 ;

compound_stmt: '{' local_declarations statement_list '}' { printf("compound_stmt\nDeclaration\n"); };			
					
local_declarations: local_declarations var_declaration 
			      | {printf("empty\n"); }		
				  ;
					
statement_list: statement_list statement 	{printf("statement_list\n");}
			  | {printf("statement_list(empty)\n");}
			  ;
					
statement: expression_stmt 				
		 | compound_stmt 
		 | selection_stmt 
		 | iteration_stmt 
		 | return_stmt 
		 ;
					
expression_stmt: expression ';' 	{printf("expression_stmt\n");}
			   | ';' 		   
			   ;
						
selection_stmt: IF '(' expression ')' statement {printf("IF_without_else");}
			  | IF '(' expression ')' statement ELSE statement {printf("IF_with_else");}
              ;

iteration_stmt:	WHILE '(' expression ')' statement {printf("WHILE\n");};

return_stmt: RETURN ';' 
           | RETURN expression ';' ;

expression:	var '=' expression  {printf("expression\n");} 	
		  | simple_expression ;
 
var: ID 	{printf("var\n");}
   | ID '[' expression ']'  	{printf("var_array\n");} 
   ; 

simple_expression: additive_expression relop additive_expression {printf("simple_expression\n");}
			     | additive_expression 	{printf("additive_expression\n");}
			     ;

relop: '<' 
     | SOE 
     | '>'  
     | GOE
     | EQV
     | NEV
     ;

additive_expression: additive_expression addop term 
                   | term ;
 
addop: '+' {printf("addop\n");}
	 | '-' {printf("minusop\n");}
	 ; 

term: term mulop factor  {printf("term\n");} 
	| factor		     {printf("term\n");} 
	;
 
mulop: '*' {printf("mulop\n");}
	 | '/' {printf("divop\n");}
	 ;   	

factor:	'(' expression ')' {printf("factor\n");}
	  | var                {printf("factor\n");}
	  | call               {printf("factor\n");}
	  | NUM                {printf("factor\n");}
	  ;
call: ID '(' args ')' {printf("call input\n");};
					
args: arg_list 
	| {printf("args(empty)\n");}
	;


arg_list : arg_list ',' expression 
		 | expression 
		 ;
			
%%

int main(int argc, char *argv[])
{
    if (argc==1){
		printf("Enter numbers manually and press enter to finish:\n");
        yyin=stdin;
    }
	if (argc==2){
		yyin=fopen(argv[1],"r");
	}
    yyparse();
    return 0;
}

void yyerror (char const *s) {
   fprintf (stderr, "%s\n", s);
}