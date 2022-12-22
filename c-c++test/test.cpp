#include <iostream>
using namespace std;

class A
{
	public:
    	explicit A(int p):p(p){cout << "construct" << p << " " << this << endl;}
		~A(){cout << "delete" << p << endl;}
		A (const A &obj) {cout << "copy" << endl;}
        int p = 10;
};
 
A GetA()
{
    return A(1);
}
 
int main()
{
    // A a1 = GetA();   // a1是左值
    // //A&& a2 = GetA(); // a2是右值引用
    // cout<< a1.p << endl;
    // cout<<GetA().p << endl;
    A a1 = GetA();
    cout << &a1 << endl;
    return 0;
}