#include <stdio.h>
#include <stdlib.h>

void test(int (*p)[]);

int main()
{
   int p[2] = {10,20};
   printf("%p\n", p);
   int a = *(&p)[0];
   printf("%d\n", a);
}

void test(int (*p)[])
{
   printf("%p\n", &p);
}