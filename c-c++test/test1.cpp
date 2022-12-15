#include <iostream>
#include <cstdlib>
#include <cstring>
#include <malloc.h>
using namespace std;

int main()
{
	int a[6]={10,20,30,40,50,60};
	int *p = (int *)malloc(0);
	cout<< malloc_usable_size(p) <<endl;
	for (int i=0;i<6;i++)
	{
		*(p+i)=a[i];
	}
	for (int i=0;i<6;i++)
	{
		cout<<*(p+i)<<" "<<sizeof(p+i)<<endl;
	}
	cout<<"finish\n";
    return 0;
}