default:
	bison -dv step3.y
	flex step3.fl
	g++ step3.tab.c symtable.cpp -w