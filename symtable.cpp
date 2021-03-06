#include<iostream>
#include<vector>
#include<string>
#include "symtable.h"

using namespace std;

bool symtable::insertvtable(string varname, int sco, int val, int size){
	bool exists=false;
	for (auto it=vtable.begin(); it!=vtable.end(); ++it){
		if(it->name==varname && it->scope==sco)
			exists=true;
	}
	if(!exists){
		vtable.push_back({varname, sco, val,size,varname});
	}
	return exists;

}

string symtable::getvarlabel(string varname, int sco){
	bool exists=false;
	for (auto it=vtable.begin(); it!=vtable.end(); ++it){
		if(it->name==varname && it->scope==sco)
			return it->label;
		if(it->name==varname && it->scope==0)
			exists=true;		
	}
	if(exists)
		return varname;
	return "ERROR";
	
}

bool symtable::insertftable(string funname, int sco, int ftype, vector<string> args, int line, char filename[], int vartemp){
	bool exists=false;
	for (auto it=ftable.begin(); it!=ftable.end(); ++it)
		if(it->name==funname && it->type==ftype && it->args==args)
			exists=true;
	if(!exists){
		ftable.push_back({funname, sco, ftype, 0, args});
		for (auto it=args.begin(); it!=args.end(); ++it){
			if(!argvtablesearch(*it,sco)){				
				string temp="_t";
				temp.append(to_string(vartemp++));
				vtable.push_back({*it, sco, 0, 0, temp});
			}
			else
			 	printf("%c:- %d Redefined (duplicate) variable declaration in parameters list of a function",filename,line);
		}
	}
	return exists;
}

void symtable::assignfunval(int sco, int val){
	bool exists=false;
	for (auto it=ftable.begin(); it!=ftable.end(); ++it)
		if(it->scope==sco){
			it->value=val;
			break;
		}
}

void symtable::deletevtable(int sco){
	for (auto it=vtable.begin(); it!=vtable.end(); ++it)
		if(it->scope==sco)
			it=vtable.erase(it);
}

void symtable::deleteftable(int sco){
	for (auto it=ftable.begin(); it!=ftable.end(); ++it)
		if(it->scope==sco)
			it=ftable.erase(it);
	deletevtable(sco);
}

bool symtable::modifyvtable(string varname, int sco, int val){
	bool found=false;
	for (auto it=vtable.begin(); it!=vtable.end(); ++it){
		if(it->name==varname)
			if(it->scope==sco){
				it->value=val;
				found=true;
				break;
			}

	}
	for (auto it=vtable.begin(); it!=vtable.end(); ++it)
		if(it->name==varname)
			if (it->scope==0 && !found){
				it->value=val;
				found=true;
				break;
			}
	return found;
}

void symtable::modifyparamvtable(int sco, int val, unsigned int params){
	bool found=false;
	auto it=vtable.begin();
	for (auto i=0; i!=params; i++){
			if(it->scope==sco){
				it->value=val;
				found=true;
			}
			++it;
	}
	for (auto it=vtable.begin(); it!=vtable.end(); ++it)
		if (it->scope==0 && !found){
			it->value=val;
			found=true;
		}
}

void symtable::modifyfuntable(int sco, int val){
	for (auto it=ftable.begin(); it!=ftable.end(); ++it)
			if(it->scope==sco)
				it->value=val;
}

bool symtable::isanArray(string varname, int sco){
	bool found=false;
	for (auto it=vtable.begin(); it!=vtable.end(); ++it)
		if(it->name==varname)
			if(it->scope==sco)
				if(it->size>0)
					found=true;
				else
					return false;

	for (auto it=vtable.begin(); it!=vtable.end(); ++it)
		if(it->name==varname)
			if (it->scope==0 && !found)
				if(it->size>0)
					found=true;
	return found;
}

bool symtable::vtablesearch(string varname, int sco){
	bool found=false;
	for (auto it=vtable.begin(); it!=vtable.end(); ++it)
		if(it->name==varname)
			if(it->scope==sco)
				found=true;

	for (auto it=vtable.begin(); it!=vtable.end(); ++it)
		if(it->name==varname)
			if (it->scope==0 && !found)
				found=true;
	return found;
}

bool symtable::argvtablesearch(string varname, int sco){
	bool found=false;
	for (auto it=vtable.begin(); it!=vtable.end(); ++it)
		if(it->name==varname)
			if(it->scope==sco)
				found=true;
	return found;
}

int symtable::valuevtablesearch(string varname, int sco){
	int varvalue;
	bool found;
	for (auto it=vtable.begin(); it!=vtable.end(); ++it)
		if(it->name==varname)
			if(it->scope==sco){
					varvalue=it->value;
					found=true;
			}

	for (auto it=vtable.begin(); it!=vtable.end(); ++it)
		if(it->name==varname)
			if (it->scope==0 && !found)
					varvalue=it->value;
	return varvalue;
}

bool symtable::ftablesearch(string funname){
	bool found=false;
	for (auto it=ftable.begin(); it!=ftable.end(); ++it)
		if(it->name==funname)
			found=true;
	return found;
}

bool symtable::ftableargsearch(string funname, unsigned int size ){
	bool found=false;
	for (auto it=ftable.begin(); it!=ftable.end(); ++it)
		if(it->name==funname)
			if(it->args.size()==size)
				found=true;
	return found;
}

int symtable::returnfunvalue(string funname, unsigned int size){
	for (auto it=ftable.begin(); it!=ftable.end(); ++it)
		if(it->name==funname)
			if(it->args.size()==size)
				return it->value;
	return 0;
}

int symtable::returnftype(int sco){
	for (auto it=ftable.begin(); it!=ftable.end(); ++it)
		if(it->scope==sco)
			return it->type;
	return 0;
}

void symtable::printeverything(){
	cout<<endl<<"Functions: "<<endl;
	for (auto it=ftable.begin(); it!=ftable.end(); ++it)
		cout<<it->name<<" "<<it-> scope<<" "<<it->type<<" "<<it->value<<endl;
	cout<<endl<<"Variables: "<<endl;
	for (auto it=vtable.begin(); it!=vtable.end(); ++it)
		cout<<it->name<<" "<<it-> scope<<" "<<it->value<<" "<<it->label<<endl;
}