#include <iostream>
using namespace std;

int main()
{
    int a[5] = {1,2,3,4,5};
    int *ptr;
    ptr = a;
    void *ptr1 = (void *)ptr;
    cout<< ptr << endl;
    cout<< ++ptr << endl;
    cout<< ptr1 << endl;
}