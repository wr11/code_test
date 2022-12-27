
#include <time.h>
#include <stdio.h>
#include <iostream>
#include <unistd.h>
#include <thread>
using namespace std;
 
void Loop()
{
	cout<< "thread loop: " << this_thread::get_id() << endl;
	// while(true){}
	// int a;
	// cin >> a;
	cout<< "thread loop finish: " << this_thread::get_id() << endl;
}
 
int main() {

	thread thd1(Loop);
	thread thd2(Loop);

	thd1.join();
	cout << thd1.joinable() << endl;
	cout<< "yhd1 join" << endl;
	thd2.join();
	cout<< "yhd2 join" << endl;

	cout<< "main thread" << endl;
 
	return 0;
}