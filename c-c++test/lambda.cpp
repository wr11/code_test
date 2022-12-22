#include <iostream>
using namespace std;

// 函数声明
void swap(int &x, int &y);
 
int main ()
{
   // 局部变量声明
   int a = 100;
   int b = 200;
   int c = 300;
 
   cout << "交换前，a 的值：" << a << endl;
   cout << "交换前，b 的值：" << b << endl;
   cout << "c 的值：" << c << endl;
 
   /* 调用函数来交换值 */
   // swap(a, b);
   auto function = [&](int &x, int &y) mutable -> void {cout<< x << " " << &x;int temp = x; x = y; y = temp;c=500;};
   function(a,b);
 
   cout << "交换后，a 的值：" << a << endl;
   cout << "交换后，b 的值：" << b << endl;
   cout << "c 的值：" << c << endl;

   int m = 600;
   int &n = m;
   cout<<typeid(m).name() << endl;
   cout<<typeid(n).name() << endl;
   cout<<typeid(*(&m)).name() << endl;
 
   return 0;
}
 
// 函数定义
void swap(int &x, int &y)
{
   int temp;
   temp = x; /* 保存地址 x 的值 */
   x = y;    /* 把 y 赋值给 x */
   y = temp; /* 把 x 赋值给 y  */
  
   return;
}