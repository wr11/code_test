
#include <iostream>
#include <thread>
#include <vector>
using namespace std;
 
struct test
{
	int a;
};
 
int main() {
 
	struct test t;
	vector<struct test*> vt;
	vt.push_back(&t);
	for (int i = 0; i < vt.size() ; i++ )
	{
		cout << vt[i] << endl;
	}
 
	return 0;
}