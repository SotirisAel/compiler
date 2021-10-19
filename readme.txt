Commands FOR LINUX/MAC

bison -d step2.y

flex step2.fl

gcc step2.tab.c -lm     OR    g++ step2.tab.c

./a.out input.txt    OR    ./a.out


Commands used FOR WINDOWS:

bison -dv step2.y

flex step2.fl

gcc -o main step2.tab.c -L"C:\GnuWin32\lib" -lfl

main (to enter input through command)

main input.txt (to enter through text file)

