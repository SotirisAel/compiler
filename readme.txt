G++ IS NEEDED TO COMPILE, C++ COMMANDS WERE USED

Commands FOR LINUX/MAC

bison -d step2.y

flex step2.fl

g++ step2.tab.c

./a.out input.txt    OR    ./a.out


Commands used FOR WINDOWS:

bison -dv step2.y

flex step2.fl

g++ -o main step2.tab.c -L"C:\GnuWin32\lib" -lfl

main (to enter input through command)

main input.txt (to enter through text file)

