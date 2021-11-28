/* CEI222: Project Step[1] ID: [Sotiris Vasiliadis-ID19613]_[Michael-Aggelos Demou-ID19753]_[Konstantinos Konstantinou-ID20284]_[Giorgos Tsovilis-ID19971] */

%{ 
#include <iostream>
#include "symtable.h"
#include "lex.yy.c"
#include <string>
#include <vector>
#include "step4.tab.h"
using namespace std;
extern int yylex();
extern int yyparse();
void yyerror(char const *s);
extern char *yytext;
extern int yylineno;
static int temp;
static int cnttemp;
static int level=0;
static int tempcnt=0;
static int vartemp=0;
static int looptemp=0;
static int iftemp=0;
unsigned int ptr;
static bool firsttimerun=1;
char filename[80];
vector<string> parameters;
vector<int> arguments;
vector<string> code;
vector<string> varhelper;
symtable ProgramSymtable;
%}
%define parse.error verbose

%union {
    char* str;
    int num;
}
%type<num> program declaration_list declaration var_declaration type_specifier 
%type<num> fun_declaration local_declarations stmt_list statement 
%type<num> expression_stmt red_selection_stmt selection_stmt compound_stmt
%type<num> iteration_stmt return_stmt expression assign_stmt 
%type<num> simple_expression additive_expression term factor call
%type<str> var mulop addop relop
%token<num> NUM
%token<str> ID
%token IF WHILE ELSE INT RETURN VOID SOE GOE EQV NEV
%%
program: declaration_list	{for (auto i = code.begin(); i != code.end(); i++) cout<<*i;};						
					
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
			else
				code.push_back(to_string(tempcnt++)); code.push_back(": VARDECL "); code.push_back($2); code.push_back(" 4\n");

		}
		else
			yyerror("Invalid type specifier (did you mean int?)");	
                }
			       		
	       | type_specifier ID '[' NUM ']' ';'
	       {
		if($1==1)
      			if(ProgramSymtable.insertvtable($2, level, 0, $4))
				yyerror("Redefined variable declaration");
			else{
				temp=4*$4;
				 code.push_back(to_string(tempcnt++)); code.push_back(": VARDECL "); code.push_back($2); code.push_back(" "); code.push_back(to_string(temp));  code.push_back("\n");
			}

		else
			yyerror("Invalid type specifier (did you mean int?)");	
               }
	       | error ';' {yyerror("Invalid type specifier (did you mean int?)");}
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
                    if(ProgramSymtable.insertftable($2, level, $1, parameters, yylineno, filename, vartemp ))
		    	yyerror("Redefined function declaration");
		    
		    if(firsttimerun){
		    	 code.push_back(to_string(tempcnt++)); code.push_back(": GOTO main\n");
			firsttimerun=0;
		    }
		     code.push_back(to_string(tempcnt++)); code.push_back(": LABEL "); code.push_back($2); code.push_back("\n"); 
		    for(auto i=0;i<parameters.size();i++){
			 code.push_back(to_string(tempcnt++)); code.push_back(": PARAMOUT"); code.push_back(" _t"); code.push_back(to_string(vartemp++)); code.push_back("\n");
		    }
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

selection_stmt: IF '(' expression ')' {code.push_back(" _l"); code.push_back(to_string(vartemp)); ptr=code.size(); code.push_back("\n"); code.push_back( to_string(tempcnt++)); code.push_back("\n"); code.push_back( to_string(tempcnt++)); iftemp=vartemp; } red_selection_stmt {$$=$3;};

red_selection_stmt: statement {$$=0;
			
			if(iftemp!=vartemp){	
				iftemp=vartemp++;
				unsigned int temp=code.size()-ptr;
				auto loc=code.end()-temp-1;
				*loc=to_string(iftemp);
				loc+=2;
				code.insert(++loc,": GOTO "); code.insert(++loc,"_l"); code.insert(++loc,to_string(vartemp));
				loc+=2;
				code.insert(++loc,": LABEL "); code.insert(++loc,"_l"); code.insert(++loc,to_string(--vartemp)); code.insert(++loc,"\n"); vartemp++;
				code.push_back( to_string(tempcnt++)); code.push_back(": LABEL "); code.push_back("_l"); code.push_back(to_string(vartemp++)); code.push_back("\n");
				}
			}
             	  | statement ELSE  statement {
		      $$=0;
		      if(iftemp!=vartemp){	
				iftemp=vartemp++;
				unsigned int temp=code.size()-ptr;
				auto loc=code.end()-temp-1;
				*loc=to_string(iftemp);
				loc+=2;
				code.insert(++loc,": GOTO "); code.insert(++loc,"_l"); code.insert(++loc,to_string(vartemp));
				loc+=2;
				code.insert(++loc,": LABEL "); code.insert(++loc,"_l"); code.insert(++loc,to_string(--vartemp)); code.insert(++loc,"\n"); vartemp++;
				code.push_back( to_string(tempcnt++)); code.push_back(": LABEL "); code.push_back("_l"); code.push_back(to_string(vartemp++)); code.push_back("\n");
				}
		      }
              ;

iteration_stmt: WHILE {code.push_back(to_string(tempcnt++)); code.push_back(": LABEL _l"); code.push_back(to_string(vartemp)); code.push_back("\n"); looptemp=vartemp++; } '(' expression ')' {code.push_back(" _l"); code.push_back(to_string(vartemp)); iftemp=vartemp++; ptr=code.size(); code.push_back("\n"); code.push_back( to_string(tempcnt++));cnttemp=tempcnt++;}
		 statement {$$=0;
				 if(iftemp!=vartemp){	
					iftemp=vartemp++;
					unsigned int temp=code.size()-ptr;
					auto loc=code.end()-temp-1;
					*loc=to_string(iftemp);
					loc+=2;
					code.insert(++loc,": GOTO "); code.insert(++loc,"_l"); code.insert(++loc,to_string(vartemp)); code.insert(++loc,"\n");
					code.insert(++loc,to_string(cnttemp));code.insert(++loc,": LABEL "); code.insert(++loc,"_l"); code.insert(++loc,to_string(--vartemp)); code.insert(++loc,"\n"); vartemp++; 
					code.push_back( to_string(tempcnt++)); code.push_back(": GOTO "); code.push_back("_l"); code.push_back(to_string(looptemp)); code.push_back("\n");
					code.push_back( to_string(tempcnt++)); code.push_back(": LABEL "); code.push_back("_l"); code.push_back(to_string(vartemp++)); code.push_back("\n");
				}
			}
			
              ;

return_stmt: RETURN  ';' 
	   {
		$$=0;
		code.push_back(to_string(tempcnt++)); code.push_back(": RETURN\n");
	   }
           | RETURN expression ';' 
	   {
		if(ProgramSymtable.returnftype(level))
			ProgramSymtable.assignfunval(level, $2); 
		else
			yyerror("Return type of a function");
		$$=$2;
		 code.push_back(to_string(tempcnt++)); code.push_back(": RETURN "); code.push_back("_t");code.push_back(to_string(--vartemp)); code.push_back("\n"); vartemp++;
	   }
           ;

expression: simple_expression {$$ = $1;}
          ;

assign_stmt: var '=' expression_stmt 
           {
		if(!ProgramSymtable.modifyvtable($1, level, $3))
			yyerror("Undefined variable");
		code.push_back(to_string(tempcnt++)); code.push_back(": A0 "); code.push_back(ProgramSymtable.getvarlabel($1,level));
		code.insert(code.end(), varhelper.begin(), varhelper.end()); code.push_back("\n"); 
		varhelper.clear();
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
                 if($2=="<="){
			$$=$1<=$3;
			 code.push_back(to_string(tempcnt++)); code.push_back(": IFST "); code.insert(code.end(), varhelper.begin(), varhelper.end());
			varhelper.clear();
		 }
		 else if($2=="<"){
			$$=$1<$3;
			code.push_back(to_string(tempcnt++)); code.push_back(": IFSE "); code.insert(code.end(), varhelper.begin(), varhelper.end()); 
			varhelper.clear();
		 }
		 else if($2==">"){
			$$=$1>$3;
			code.push_back(to_string(tempcnt++)); code.push_back(": IFGT"); code.insert(code.end(), varhelper.begin(), varhelper.end()); 
			varhelper.clear();
		 }
		 else if($2==">="){
			$$=$1>=$3;
			code.push_back(to_string(tempcnt++)); code.push_back(": IFGE "); code.insert(code.end(), varhelper.begin(), varhelper.end()); 
			varhelper.clear();
		}
		 else if($2=="=="){
			$$=$1==$3;
			code.push_back(to_string(tempcnt++)); code.push_back(": IFEQ "); code.insert(code.end(), varhelper.begin(), varhelper.end()); 
			varhelper.clear();
		}
		 else if($2=="!="){
			$$=$1!=$3;
			code.push_back(to_string(tempcnt++)); code.push_back(": IFNE "); code.insert(code.end(), varhelper.begin(), varhelper.end());
			varhelper.clear();
		 }
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
                   | additive_expression  addop term
                   { 
			
			if($2=="+"){
			 	$$=$1+$3;			    
			    	code.push_back(to_string(tempcnt++)); code.push_back(": A2PLUS "); code.push_back("_t"); code.push_back(to_string(vartemp++));
				code.insert(code.end(), varhelper.begin(), varhelper.end()); code.push_back("\n"); 
				varhelper.clear(); 
				varhelper.push_back(" _t");varhelper.push_back(to_string(--vartemp));vartemp++;
			}
			else if($2=="-"){
			   	$$=$1-$3;
			   	code.push_back(to_string(tempcnt++)); code.push_back(": A2MINUS "); code.push_back("_t");code.push_back(to_string(vartemp++));
				code.insert(code.end(), varhelper.begin(), varhelper.end()); code.push_back("\n"); 
				varhelper.clear(); 
				varhelper.push_back(" _t");varhelper.push_back(to_string(--vartemp));vartemp++;
			}
			 
		   }
                   ;

addop: '+' {$$ = "+";}
     | '-' {$$ = "-";}
     ;

term: factor {$$ = $1;}
    | term mulop factor
    {  
	if($2=="*"){
		$$=$1*$3;
		code.push_back(to_string(tempcnt++)); code.push_back(": A2MULT "); code.push_back("_t");code.push_back(to_string(vartemp++));
		code.insert(code.end(), varhelper.begin(), varhelper.end()); code.push_back("\n"); 
		varhelper.clear(); 
	}
	else if($2=="/"){
		$$=$1/$3;
		code.push_back(to_string(tempcnt++)); code.push_back(": A2DIV "); code.push_back("_t");code.push_back(to_string(vartemp++));
		code.insert(code.end(), varhelper.begin(), varhelper.end()); code.push_back("\n"); 
		varhelper.clear(); 
	}
	else if($2=="%"){
		$$=$1%$3;
		code.push_back(to_string(tempcnt++)); code.push_back(": A2MOD "); code.push_back("_t");code.push_back(to_string(vartemp++));
		code.insert(code.end(), varhelper.begin(), varhelper.end()); code.push_back("\n"); 
		varhelper.clear();
	}
	else
	    yyerror("Type mismatch or void in term/factor exp");        
    };

mulop: '*'  {$$ = "*";}
     | '/'  {$$ = "/";}
     | '%'  {$$ = "%";}
     ;

factor: '(' expression ')' {$$ = $2;}
      | NUM  {$$=$1; varhelper.push_back(" ");varhelper.push_back(to_string($1)); }
      | var  {$$=ProgramSymtable.valuevtablesearch($1, level); varhelper.push_back(" "); varhelper.push_back(ProgramSymtable.getvarlabel($1,level));}
      | call {$$ = $1; }
      ;

call: ID '(' args ')'
    {	
	unsigned int size=arguments.size();
        if(ProgramSymtable.vtablesearch($1, level))
		yyerror("Is a variable, but was called as function");
        
	else if(ProgramSymtable.ftablesearch($1)){
		if (!ProgramSymtable.ftableargsearch($1, size))
			yyerror("Wrong num of arguments");
		else{
                	for(auto it=arguments.rbegin();it!=arguments.rend();++it){
				ProgramSymtable.modifyparamvtable(level, *it, size);
				code.push_back(to_string(tempcnt++)); code.push_back(": PARAMIN "); code.push_back(to_string(*it)); code.push_back("\n");
			}
		}				
		code.push_back(to_string(tempcnt++)); code.push_back(": CALL "); code.push_back($1); code.push_back(" "); code.push_back(to_string(arguments.size())); code.push_back("\n");
		$$=ProgramSymtable.returnfunvalue($1, size);
		code.push_back(to_string(tempcnt++)); code.push_back(": RETURNOUT _t"); code.push_back(to_string(vartemp)); code.push_back("\n"); 
		varhelper.clear();
		varhelper.push_back(" _t"); varhelper.push_back(to_string(vartemp++));
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