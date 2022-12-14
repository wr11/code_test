#include <iostream>

using namespace std;

class Box
{
    public:
        string boxname;
        static int objectCount;
        static Box objectList[];
        // 构造函数定义
        Box(double l=2.0, double b=2.0, double h=2.0, string s="box")
        {
            cout <<"Constructor called." << s << endl;
            length = l;
            breadth = b;
            height = h;
            if (s != "box"){
                objectList[objectCount] = *(this);
                objectCount++;
            }
            cout<< &(objectList[objectCount].boxname) << " " << &(this->boxname) << endl;
            this->boxname = s;
        }
        Box(const Box &obj)
        {
            cout<<"================================";
            boxname = obj.boxname;
            length = obj.length;
            breadth = obj.breadth;
            height = obj.height;

        }
        double Volume()
        {
            return length * breadth * height;
        }
        string getName()
        {
            return boxname;
        }
        static int getCount()
        {
            return objectCount;
        }
        static Box& getObjectByIndex(int index)
        {
            return objectList[index];
        }
    private:
        double length;
        double breadth;
        double height;
};

int Box::objectCount = 0;
Box Box::objectList[2];

int main(void)
{

cout << "Inital Stage Count: " << Box::getCount() << endl;
cout << "box 1: " << (Box::getObjectByIndex(0)).boxname <<endl;
cout << "box 2: " << (Box::getObjectByIndex(1)).boxname <<endl;

Box Box1(3.3, 1.2, 1.5, "box1");
Box Box2(8.5, 6.0, 2.0, "box2");

cout << "Final Stager Count: " << Box::getCount() << endl;
cout << "box 1: " << (Box::getObjectByIndex(0)).boxname <<endl;
cout << "box 2: " << (Box::getObjectByIndex(1)).boxname <<endl;

return 0;
}