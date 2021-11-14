#pragma once
#include<string>
#include<vector>

using namespace std;

struct vartable{
	string name;
	int scope,
            value,
	    size;
};

struct arguments{
		string names;
		int vals;		
};

struct funtable{
	string name;
	int scope,
	    type, //0 is void, 1 is int
	    value; 
	vector<string> args;

};

class symtable{
    public:
	symtable(){}
        void insertvtable(string varname, int sco, int val, int size);
	void insertftable(string funname, int sco, int ftype, vector<string> args);
	void assignfunval(int sco, int val);
        void deletevtable(int sco);
	void deleteftable(int sco);
        void modifyvtable(string varname, int sco, int val);
	void modifyparamvtable(int sco, int val, unsigned int params);
	void modifyfuntable(int sco, int val);
	bool isanArray(string varname, int sco);
	bool vtablesearch(string varname, int sco);
	int valuevtablesearch(string varname, int sco);
	bool ftablesearch(string funname);
	bool ftableargsearch(string funname, unsigned int size );
	int returnfunvalue(string funname, unsigned int size);
	void printeverything();

    private:
        vector<vartable> vtable;
        vector<funtable> ftable;
};