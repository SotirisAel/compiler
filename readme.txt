G++ IS NEEDED TO COMPILE, C++ COMMANDS WERE USED

Commands FOR LINUX/MAC

bison -d step4.y

flex step4.fl

g++ step4.tab.c symtable.cpp -w

./a.out input.txt    OR    ./a.out


Commands used FOR WINDOWS:

bison -dv step4.y

flex step4.fl

g++ -o main step4.tab.c symtable.cpp -L"C:\GnuWin32\lib" -lfl -w

main (to enter input through command)

main input.txt (to enter through text file)

