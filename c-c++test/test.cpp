#include <iostream>
#include <vector>
#include <string>
#include <string.h>
using namespace std;

int main() {
    string p = "hello world";
    const char* p1 = p.c_str();
    char* p2 = nullptr;
    p2 = const_cast<char *>(p1);
    cout << p.length() << " " << strlen(p1) << " " << strlen(p2) << endl;
    return 0;
}