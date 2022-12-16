#include <iostream>
#include <cstdlib>
#include <cstring>
#include <malloc.h>
using namespace std;

#define MAX 6

class A
{
	public:
		void M(){
			cout << "A M" << endl;
		}
};

class B
{
	public:
		void M(){
			cout << "B M" << endl;
		}
};

class C
{
	public:
		void M(){
			cout << "C M" << endl;
		}
};

class children: public A, public B, public C
{
	public:
		void M(){
			cout<< "ff" << endl;
		}
};

int main()
{
	children child;
	child.M();
    return 0;
}