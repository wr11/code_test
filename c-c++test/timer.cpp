#include <vector>
#include <map>
#include <cstdint>
#include <unistd.h>
#include <time.h>
#include <iostream>
using namespace std;

typedef void (*TimerHandler)(struct TimerNode *node);
//获取系统时间，单位是毫秒
static uint32_t current_time()
{
    uint32_t t;
    struct timespec ti;
    clock_gettime(CLOCK_MONOTONIC, &ti);
    t = (uint32_t)ti.tv_sec * 1000;
    t += ti.tv_nsec / 1000000;
    return t;
}

struct TimerNode
{
    //该任务在最小堆中的下标位置
    int idx = 0;
    //该任务是第几号任务
    int id = 0;
    unsigned int expire = 0;
    //回调函数
    TimerHandler cb = NULL;
};

class MinHeapTimer
{
public:
    MinHeapTimer()
    {
        _heap.clear();
        _map.clear();
    }
    int Count()
    {
        return ++_count;
    }
    //加入任务，expire为该任务的失效时间，expire过后就要执行回调函数cb
    int AddTimer(uint32_t expire, TimerHandler cb)
    {

        int64_t timeout = current_time() + expire;
        TimerNode *node = new TimerNode;
        int id = Count();
        node->id = id;
        node->expire = timeout;
        node->cb = cb;
        node->idx = (int)_heap.size();
        _heap.push_back(node);
        _shiftUp((int)_heap.size() - 1);
        _map.insert(make_pair(id, node));
        return id;
    }
    //删除一个任务
    bool DelTimer(int id)
    {
        auto iter = _map.find(id);
        if (iter == _map.end())
            return false;
        _delNode(iter->second);
        return true;
    }
    //获取一个任务
    void ExpireTimer()
    {
        if (_heap.empty())
        {
            return;
        }
        //获取当前时间
        uint32_t now = current_time();
        while (!_heap.empty())
        {
            //获取最近的一个任务
            TimerNode *node = _heap.front();
            //当最近一个任务的时间大于当前时间，说明没有任务要执行
            if (now < node->expire)
            {
                break;
            }
            //遍历一下堆，这一步可以不加
            for (int i = 0; i < _heap.size(); i++)
            {
                cout << "touch    idx: " << _heap[i]->idx
                          << " id: " << _heap[i]->id << " expire: "
                          << _heap[i]->expire << std::endl;
            }
            //执行最近任务的回调函数
            if (node->cb)
            {
                node->cb(node);
            }
            //执行完就删掉这个任务
            _delNode(node);
        }
    }

private:
    //用于比较两个任务的过期时间
    bool _compare(int lhs, int rhs)
    {
        return _heap[lhs]->expire < _heap[rhs]->expire;
    }
    //向下调整算法，每次删除一个节点就要向下调整
    void _shiftDown(int parent)
    {
        int child = parent * 2 + 1;
        while (child < _heap.size() - 1)
        {
            if (child + 1 < _heap.size() - 1 && !_compare(child, child + 1))
            {
                child++;
            }
            if (!_compare(parent, child))
            {
                std::swap(_heap[parent], _heap[child]);
                _heap[parent]->idx = parent;
                _heap[child]->idx = child;
                parent = child;
                child = parent * 2 + 1;
            }
            else
            {
                break;
            }
        }
    }
    //向上调整算法，每添加一个数都要调用向上调整算法，保证根节点为最小节点
    void _shiftUp(int child)
    {
        int parent = (child - 1) / 2;
        while (child > 0)
        {
            if (!_compare(parent, child))
            {
                std::swap(_heap[parent], _heap[child]);
                _heap[parent]->idx = parent;
                _heap[child]->idx = child;
                child = parent;
                parent = (child - 1) / 2;
            }
            else
            {
                break;
            }
        }
    }
    //删除的子函数
    void _delNode(TimerNode *node)
    {
        int last = (int)_heap.size() - 1;
        int idx = node->idx;
        if (idx != last)
        {
            std::swap(_heap[idx], _heap[last]);
            _heap[idx]->idx = idx;
            resign(idx);
        }
        _heap.pop_back();
        _map.erase(node->id);
        delete node;
    }
    void resign(int pos)
    {
        //向上调整和向下调整只会发生一个
        _shiftDown(pos);
        _shiftUp(pos);
    }

private:
    //数组中存储任务节点
    vector<TimerNode *> _heap;
    //存储值和响应节点的映射关系
    map<int, TimerNode *> _map;
    //任务的个数，注意不是_heap的size
    int _count = 0;
};

void print_hello(TimerNode *te)
{
    std::cout << "hello world time = " << te->idx << "\t" << te->id << "\t" << current_time() << std::endl;
}

int main()
{
    MinHeapTimer mht;
    //一号任务，立刻执行
    mht.AddTimer(0, print_hello);
    //二号任务，一秒后执行
    mht.AddTimer(1000, print_hello);
    mht.AddTimer(7000, print_hello);
    mht.AddTimer(2000, print_hello);
    mht.AddTimer(9000, print_hello);
    mht.AddTimer(10000, print_hello);
    mht.AddTimer(6000, print_hello);
    mht.AddTimer(3000, print_hello);
    // while (1)
    // {
    //     mht.ExpireTimer();
    //     // usleep(10000);
    //     sleep(1);
    // }
    return 0;
}