#include <iostream>

using namespace std;

class Box
{
    public:
        static int objectCount;
        static Box objectList[];
        string boxname;
        int boxflag;
        // 构造函数定义
        Box(double l=2.0, double b=2.0, double h=2.0, string s="box", int flag=0)
        {
            cout <<"Constructor called." << s << endl;
            length = l;
            breadth = b;
            height = h;
            this->boxflag = flag;
            this->boxname = s;
            // boxname = "box"+to_string(objectCount);
            // 每次创建对象时增加 1
            // if (!objectList)
            // {
            //     objectList = this;
            // }
            // else
            // {
            //     *(objectList+objectCount) = *this;
            // }
            objectList[objectCount] = *(this);
            objectCount++;
        }
        double Volume()
        {
            return length * breadth * height;
        }
        static int getCount()
        {
            return objectCount;
        }
        static Box getObjectByIndex(int index)
        {
            return *(objectList + index);
        }
    private:
        double length;     // 长度
        double breadth;    // 宽度
        double height;     // 高度
};

// 初始化类 Box 的静态成员
int Box::objectCount = 0;
Box Box::objectList[2] = {};

int main(void)
{

// 在创建对象之前输出对象的总数
cout << "Inital Stage Count: " << Box::getCount() << endl;

Box Box1(3.3, 1.2, 1.5, "box1", 1);    // 声明 box1
Box Box2(8.5, 6.0, 2.0, "box2", 2);    // 声明 box2

// 在创建对象之后输出对象的总数
cout << "Final Stage Count: " << Box::getCount() << endl;
cout << "box 1: " << (Box::getObjectByIndex(0)).boxname <<endl;
cout << "box 2: " << (Box::getObjectByIndex(1)).boxname <<endl;

return 0;
}