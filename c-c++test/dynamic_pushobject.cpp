#include <iostream>
#include <cstdlib>
#include <cstring>
#include <malloc.h>
using namespace std;

class Box
{
    public:
        string boxname;
        static int objectCount;
        static Box** objectList;
        // 构造函数定义
        Box(double l=2.0, double b=2.0, double h=2.0, string s="box")
        {
            Box::_pushObject(this);
            this->length = l;
            this->breadth = b;
            this->height = h;
            this->boxname = s;
        }
        Box(const Box &obj)
        {
            cout<<"================================";
            this->boxname = obj.boxname;
            this->length = obj.length;
            this->breadth = obj.breadth;
            this->height = obj.height;

        }
        static void _pushObject(Box* box);
        double Volume()
        {
            return this->length * this->breadth * this->height;
        }
        string getName()
        {
            return this->boxname;
        }
        static int getCount()
        {
            return Box::objectCount;
        }
        static Box* getObjectByIndex(int index)
        {
            if (Box::objectCount != 0)
            {
                return *(Box::objectList + index);
            }
            else{
                return NULL;
            }
        }
    private:
        double length;
        double breadth;
        double height;
};

int Box::objectCount = 0;
Box** Box::objectList = (Box **)malloc(24);
void Box::_pushObject(Box* box)
{
    *(Box::objectList + Box::objectCount) = box;
    Box::objectCount++;
    int malloc_usable = malloc_usable_size(Box::objectList);
    if (Box::objectCount >= malloc_usable/sizeof(unsigned long int))
    {
        size_t new_size = malloc_usable * 2;
        Box** new_list = (Box**)malloc(new_size);
        mempcpy(new_list, Box::objectList, malloc_usable);
        free(Box::objectList);
        objectList = new_list;
        cout<< "expand malloc " << malloc_usable_size(Box::objectList) << endl;
    }

}

string getBoxname(int index)
{
    Box* box = Box::getObjectByIndex(index);
    if (!box)
    {
        return "no such box";
    }
    else
    {
        return box->boxname;
    }
}

void box_info()
{
    int count = Box::getCount();
    if (count == 0){
        cout<<"there is no box"<<endl;
        return;
    }
    for (int i = 0; i < count; i++)
    {
        cout<< getBoxname(i) << endl;
    }
}

int main(void)
{
    cout<< malloc_usable_size(Box::objectList) <<endl;
    cout << "Inital Stage Count: " << Box::getCount() << endl;
    box_info();

    Box Box1(3.3, 1.2, 1.5, "box1");
    Box Box2(8.5, 6.0, 2.0, "box2");
    Box Box3(8.5, 6.0, 2.0, "box3");
    Box Box4(8.5, 6.0, 2.0, "box4");
    Box Box5(8.5, 6.0, 2.0, "box5");
    Box Box6(8.5, 6.0, 2.0, "box6");
    Box Box7(8.5, 6.0, 2.0, "box7");

    cout << "Final Stager Count: " << Box::getCount() << endl;
    box_info();
    free(Box::objectList);

    return 0;
}