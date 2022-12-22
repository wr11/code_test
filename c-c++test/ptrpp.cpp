#include <iostream>
using namespace std;

int main()
{
    int a = 10;
    int *ptr;
    ptr = &a;
    printf("%p %d \n", ptr, *ptr);
    ptr++;
    *ptr = 100;
    printf("%p %p \n", ptr, *ptr);
}