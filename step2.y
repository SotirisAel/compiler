/* CEI222: Project Step[1] ID: [Sotiris Vasiliadis-ID19613]_[Michael-Aggelos Demou-ID19753]_[Konstantinos Konstantinou-ID20284]_[Giorgos Tsovilis-ID19971] */

%{ 
#include <iostream>
#include "step2.tab.h"
#include "lex.yy.c"
#include <string>
#include <vector>
using namespace std;

int yylex();
void yyerror(char const *s);
extern char *yytext;
#define YYDEBUG_LEXER_TEXT yytext
vector<string> tree;
%}



%union {
    char* string;
    int num;  
}
%token<num> NUM
%token<string> ID
%type<string> type_specifier
%type<string> params
%type<string> param_list
%type<string> param
%token IF
%token WHILE
%token ELSE
%token INT
%token RETURN
%token VOID
%token SOE
%token GOE
%token EQV
%token NEV

%%
program: declaration_list {tree.push_back("program\n"); for (auto i = tree.rbegin(); i != tree.rend(); i++) cout<<*i;};							
					
declaration_list: declaration {tree.push_back("declaration_list\n"); }
		| declaration_list declaration 
		;
					
declaration: var_declaration
	   | fun_declaration {tree.push_back("declaration\n"); }
           ;
					
var_declaration: type_specifier ID ';'  	        {tree.push_back(")\n"); tree.push_back($2); tree.push_back("("); tree.push_back("var_declaration");} 		
	       | type_specifier ID '[' NUM ']' ';' 	{tree.push_back("])\n"); tree.push_back(to_string($4)); tree.push_back("["); tree.push_back($2); tree.push_back("("); tree.push_back("array_declaration");} 
	       ;
	

				
type_specifier: INT   { $$ = "INT"; }
	      | VOID  { $$ = "VOID"; }
	      ;
					
fun_declaration:  type_specifier ID fun1 {tree.push_back(")\n");tree.push_back($2);tree.push_back("-");tree.push_back($1); tree.push_back("("); tree.push_back("fun_definition");};	   
					
fun1:  '(' params ')' compound_stmt {tree.push_back(")\n");tree.push_back($2); tree.push_back("params("); tree.push_back("compound_stmt\n"); };
					
params: param_list	{$$=$1;}				 
      | VOID 		{$$="VOID";}
      ;
					
param_list: param 			{$$=$1}
	  | param_list ',' param 
	  ;
 
param: type_specifier ID 	
     | type_specifier ID '[' ']'
     ;

compound_stmt: '{' local_declarations statement_list '}' { tree.push_back("local_declarations\n"); };			
					
local_declarations: var_declaration
		  | local_declarations var_declaration
		  | {tree.push_back("empty"); }		
		  ;
					
statement_list: statement_list statement 	{tree.push_back("statement_list\n");}
	      | 				{tree.push_back("statement_list(empty)\n");}
	      ;
					
statement: expression_stmt 				
	 | compound_stmt 
	 | selection_stmt 
	 | iteration_stmt 
	 | return_stmt 
	 ;
					
expression_stmt: expression ';' 	{tree.push_back("expression_stmt\n");}
	       | ';' 		   
	       ;
						
selection_stmt: IF '(' expression ')' statement {tree.push_back("IF_without_else\n");}
	      | IF '(' expression ')' statement ELSE statement {tree.push_back("IF_with_else\n");}
              ;

iteration_stmt:	WHILE '(' expression ')' statement {tree.push_back("WHILE\n");};

return_stmt: RETURN ';' 
           | RETURN expression ';' 
	   ;

expression: var '=' expression  {tree.push_back("expression\n");} 	
	  | simple_expression 
	  ;
 
var: ID 			{tree.push_back(")\n");tree.push_back($1);tree.push_back("var(");}
   | ID '[' expression ']'  	{tree.push_back("array\n");} 
   ; 

simple_expression: additive_expression relop additive_expression {tree.push_back("simple_expression\n");}
		 | additive_expression 	{tree.push_back("additive_expression\n");}
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
 
addop: '+' {tree.push_back("addop(+)\n");}
     | '-' {tree.push_back("minusop\n");}
     ; 

term: term mulop factor  {tree.push_back("term\n");} 
    | factor		 {tree.push_back("term\n");} 
    ;
 
mulop: '*' {tree.push_back("mulop");}
     | '/' {tree.push_back("divop");}
     ;   	

factor:	'(' expression ')' {tree.push_back("factor\n");}
      | var                {tree.push_back("factor\n");}
      | call               {tree.push_back("factor\n");}
      | NUM                {tree.push_back("factor\n");}
      ;
call: ID '(' args ')' {tree.push_back("\n");tree.push_back($1);tree.push_back("call ");};
					
args: arg_list 
    | {tree.push_back("args(empty)\n");}
    ;


arg_list: arg_list ',' expression 
	| expression 
	;
			
%%

int main(int argc, char *argv[])
{
    if (argc==1){
	printf("Enter numbers manually and press enter to finish:");
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