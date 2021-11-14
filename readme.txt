G++ IS NEEDED TO COMPILE, C++ COMMANDS WERE USED

Commands FOR LINUX/MAC

bison -d step3.y

flex step3.fl

g++ step3.tab.c symtable.cpp -w

./a.out input.txt    OR    ./a.out


Commands used FOR WINDOWS:

bison -dv step3.y

flex step3.fl

g++ -o main step3.tab.c symtable.cpp -L"C:\GnuWin32\lib" -lfl -w

main (to enter input through command)

main input.txt (to enter through text file)

