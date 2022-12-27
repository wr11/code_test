#include <iostream>
#include <string.h>
#include <string>
#include <memory>
#include <unistd.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <sys/epoll.h>
#include <errno.h>
#include <time.h>
#include <fcntl.h>
#include <thread>
#include <vector>

#define EPOLL_OS __linux__ || __unix__

#if EPOLL_OS
#include <linux/version.h>
#define VERSION_MIN = KERNEL_VERSION(4,5,0)
#endif

using namespace std;

// region conf
static const bool _DEBUG = true;
static const bool _NONBLOCK = true;
static const bool _REUSEPORT = true;
static const bool _ALLOW_THREAD_INCOMPLETE = true;
static const int _MAX_EPOLL_WAIT_EVENT_SIZE = 1024;
// end region conf

struct NetParam
{
    in_addr_t ip;
    unsigned short port;
    unsigned short thread_num;

    string raw_ip;
    string raw_port;
    string raw_thread_num;
};

#if EPOLL_OS
struct NetThread_Linux
{
    bool writable;
    int fd_socket;
    int fd_epoll;
};
#else
struct NetThread_Other {};
#endif

// region print
#define TIMESTRSIZE 80

char* GetTimeStr()
{
    time_t raw_time;
    struct tm *info;
    static char buffer[TIMESTRSIZE];
    time(&raw_time);
    info = localtime(&raw_time);
    strftime(buffer, TIMESTRSIZE, "%Y-%m-%d %H:%M:%S", info);
    return buffer;
}

namespace Print{
    void Warn(string file, string function, int line, string msg){
        char *time = GetTimeStr();
        cout << "[" << this_thread::get_id() << "]" << "[" << time << "]" \
            << "[" << file << ":" << line << " in " << function << "]" << "[WARN]" << msg << endl;
    }

    void Error(string file, string function, int line, string msg){
        char *time = GetTimeStr();
        cout << "[" << this_thread::get_id() << "]" << "[" << time << "]" \
            << "[" << file << ":" << line << " in " << function << "]" << "[ERROR]" << msg << endl;
    }

    void Notify(string file, string function, int line, string msg){
        char *time = GetTimeStr();
        cout << "[" << this_thread::get_id() << "]" << "[" << time << "]" \
            << "[" << file << ":" << line << " in " << function << "]" << "[NOTE]" << msg << endl;
    }

    void Debug(string file, string function, int line, string msg){
        char *time = GetTimeStr();
        if (_DEBUG)
        {
            cout << "[" << this_thread::get_id() << "]" << "[" << time << "]" \
                << "[" << file << ":" << line << " in " << function << "]" << "[DEBUG]" << msg << endl;
        }
    }
}

#define GPRINTW(MSG) ({Print::Warn(__FILE__, __FUNCTION__,__LINE__,MSG);})
#define GPRINTE(MSG) ({Print::Error(__FILE__,__FUNCTION__,__LINE__,MSG);})
#define GPRINTN(MSG) ({Print::Notify(__FILE__,__FUNCTION__,__LINE__,MSG);})
#define GPRINTD(MSG) ({Print::Debug(__FILE__,__FUNCTION__,__LINE__,MSG);})
// end region print

// region os
class COSHandler
{
    public:
        virtual void CheckOS(struct NetParam* np) = 0;
        virtual int CreateSocket(struct NetParam* np) = 0;
        virtual int SetSocketNonBlocking(int socket) = 0;
        virtual bool Bind(int socket, struct NetParam* np) = 0;
        virtual bool Listen(int socket, int backlog_len) = 0;
        virtual bool GenerateSocketEvent(int socket, struct NetThread_Linux* nt) = 0;
        virtual void EventLoop(struct NetThread_Linux* nt) = 0;
        virtual bool AddListener(struct NetThread_Linux* nt) = 0;
        virtual void Accept(int socket, struct sockaddr_in* client_addr, socklen_t* addr_len, int epoll_fd) = 0;
        virtual void Receive(int socket, char* buffer) = 0;
        virtual void Send(int socket) = 0;
    protected:
        void _WrongOS(){GPRINTE("Unsupport operate system!");exit(EXIT_FAILURE);};
};

class CLinuxHandler : public COSHandler
{
    public:
        virtual void CheckOS(struct NetParam* np);
        virtual int CreateSocket(struct NetParam* np);
        virtual int SetSocketNonBlocking(int socket);
        virtual bool Bind(int socket, struct NetParam* np);
        virtual bool Listen(int socket, int backlog_len);
        virtual bool GenerateSocketEvent(int socket, struct NetThread_Linux* nt);
        virtual void EventLoop(struct NetThread_Linux* nt);
        virtual bool AddListener(struct NetThread_Linux* nt);
        virtual void Accept(int socket, struct sockaddr_in* client_addr, socklen_t* addr_len, int epoll_fd);
        virtual void Receive(int socket, char* buffer);
        virtual void Send(int socket){};
        int SetSocketReusePort(int socket);
};

class COtherOSHandler : public COSHandler
{
    public:
        virtual void CheckOS(struct NetParam* np){this->_WrongOS();};
};

void CLinuxHandler::CheckOS(struct NetParam* np)
{
    uint32_t cpu_num = thread::hardware_concurrency();
    int os_version = LINUX_VERSION_CODE;

#if LINUX_VERSION_CODE < KERNEL_VERSION(4,5,0)
    GPRINTE("your kernel version is not satisfied, please update!");
    exit(EXIT_FAILURE);
#endif

    if ((np->thread_num == 0 || np->thread_num > 2 * cpu_num) && !_DEBUG)
    {
        np->thread_num = cpu_num;
    }
    string thread_num_change = np->raw_thread_num + "->" + to_string(np->thread_num);

    string os_info = "current os info\nos:\t\t linux\nversion code:\t";
    os_info = os_info + to_string(os_version) + "\ncpu num:\t" + to_string(cpu_num) + \
        "\nip:\t\t" + np->raw_ip + "\nport:\t\t" + np->raw_port + "\nthread num:\t" + thread_num_change + \
        "\nos check finish, the server process is ready ...";
    GPRINTN(os_info);
}

int CLinuxHandler::CreateSocket(struct NetParam* np)
{
    int socket_fd = socket(AF_INET, SOCK_STREAM, 0);
    if (socket_fd < 0)
    {
        GPRINTE("create socket error");
        perror("create socket");
        return -1;
    }
    if (_NONBLOCK)
    {
        this->SetSocketNonBlocking(socket_fd);
    }
    if (_REUSEPORT)
    {
        this->SetSocketReusePort(socket_fd);
    }
    return socket_fd;
}

int CLinuxHandler::SetSocketNonBlocking(int socket)
{
    int old_option = fcntl(socket, F_GETFL);
    if (old_option < 0)
    {
        GPRINTE("get fcntl flag error");
        perror("get fcnt");
        return -1;
    }
    int new_option = old_option | O_NONBLOCK;
    if (fcntl(socket, F_SETFL, new_option) < 0)
    {
        GPRINTE("set fcntl non blocking error");
        perror("set fcnt");
        return -1;
    }
    return old_option;
}

int CLinuxHandler::SetSocketReusePort(int socket) {
    int opt = 1;
    int ret = setsockopt(socket, SOL_SOCKET, SO_REUSEPORT,
        &opt, static_cast<socklen_t>(sizeof(opt)));
    return ret;
}

bool CLinuxHandler::Bind(int socket, struct NetParam* np)
{
    struct sockaddr_in *server_addr = (struct sockaddr_in *)malloc(sizeof(struct sockaddr_in));
    memset(server_addr, 0, sizeof(struct sockaddr_in));

    server_addr->sin_family = AF_INET;
    server_addr->sin_addr.s_addr = np->ip;
    server_addr->sin_port = htons(np->port);

    if (bind(socket, (const struct sockaddr *)server_addr, sizeof(*server_addr)) < 0)
    {
        GPRINTE("socket bind failed!");
        perror("bind");
        free(server_addr);
        close(socket);
        return false;
    }
    free(server_addr);
    return true;
}

bool CLinuxHandler::Listen(int socket, int backlog_len)
{
    if (backlog_len < 1)
    {
        backlog_len = SOMAXCONN;
    }
    int ret = listen(socket, backlog_len);
    if (ret < 0)
    {
        GPRINTE("socket listen failed!");
        perror("listen");
        close(socket);
        return false;
    }
    return true;
}

bool CLinuxHandler::GenerateSocketEvent(int socket, struct NetThread_Linux* nt)
{
    int epoll_fd = epoll_create(2);
    if (epoll_fd < 0)
    {
        GPRINTE("epoll_create failed!");
        perror("epoll_create");
        close(socket);
        return false;
    }
    nt->fd_socket = socket;
    nt->fd_epoll = epoll_fd;
    nt->writable = false;
    return true;
}

bool CLinuxHandler::AddListener(struct NetThread_Linux* nt)
{
    struct epoll_event ev;
    ev.events = EPOLLIN|EPOLLOUT|EPOLLRDHUP|EPOLLET;
    ev.data.ptr = nt;
    int ret = epoll_ctl(nt->fd_epoll, EPOLL_CTL_ADD, nt->fd_socket, &ev);
    if (ret < 0)
    {
        GPRINTE("epollctl add failed! closing ...");
        perror("epollctl add failed");
        close(nt->fd_epoll);
        close(nt->fd_socket);
        return false;
    }
    return true;
}

void CLinuxHandler::EventLoop(struct NetThread_Linux* nt)
{
    GPRINTD("Loop Start");
    struct epoll_event *ev = (struct epoll_event *)malloc(sizeof(struct epoll_event)*_MAX_EPOLL_WAIT_EVENT_SIZE);
    struct sockaddr_in *client_addr = (struct sockaddr_in *)malloc(sizeof(struct sockaddr_in));
    socklen_t sock_len = sizeof(struct sockaddr_in);
    char *buffer = (char *)malloc(sizeof(char)*4096);
    while(true)
    {
        memset(ev, 0, sizeof(*ev));
        int num_fds = epoll_wait(nt->fd_epoll, ev, _MAX_EPOLL_WAIT_EVENT_SIZE, -1);
        switch(num_fds)
        {
            case -1:
                if (errno == EINTR) continue;
                else{
                    GPRINTE("epoll wait error!");
                    perror("epoll wait");
                    return;
                }
            case 0:
                continue;
            default:
                for (int i = 0; i < num_fds; i++)
                {
                    struct NetThread_Linux* nt_new = (struct NetThread_Linux*)ev[i].data.ptr;
                    if (nt_new->fd_socket == nt->fd_socket)
                    {
                        GPRINTD("wake up");
                        memset(client_addr, 0, sizeof(*client_addr));
                        this->Accept(nt->fd_socket, client_addr, &sock_len, nt->fd_epoll);
                    }
                    else if (ev[i].events & EPOLLIN)
                    {
                        memset(buffer, 0, sizeof(*buffer));
                        this->Receive(nt->fd_socket, buffer);
                    }
                }
        }
    }
    free(ev);
    free(client_addr);
}

void CLinuxHandler::Accept(int socket, struct sockaddr_in* client_addr, socklen_t* addr_len, int epoll_fd)
{
    while(true)
    {
        int client_fd = accept(socket, (struct sockaddr *)client_addr, addr_len);
        if (client_fd < 0)
        {
            if (errno == EAGAIN) break;
            GPRINTE("accept failed!");
            perror("accept failed");
            break;
        }
        this->SetSocketNonBlocking(client_fd);

        struct NetThread_Linux nt;
        nt.fd_epoll = epoll_fd;
        nt.fd_socket = client_fd;
        nt.writable = true;
        this->AddListener(&nt);
        GPRINTD("accept success");
    }
}

void CLinuxHandler::Receive(int socket, char* buffer)
{
    GPRINTD("Receive");
}
//end region os

// region net
class CNetBase
{
    public:
        CNetBase(struct NetParam* np);
        ~CNetBase(){
            free(_net_param);
            _net_param = NULL;
            for (int i = 0; i < this->vec_event.size(); i++)
            {
                close(vec_event[i].fd_socket);
                close(vec_event[i].fd_epoll);
            }
        };
        void PrintNetParam(){cout << this->_net_param->ip << " " << this->_net_param->port << " " << this->_net_param->thread_num << endl;};
        struct NetParam* GetPeer(){return this->_net_param;};
        void Run();
        static void ThreadBoot(CNetBase* net_base, struct NetThread_Linux* nt);
    private:
        struct NetParam* _net_param;
        shared_ptr<COSHandler> _os_handler;
#if EPOLL_OS
        vector<struct NetThread_Linux> vec_event;
#else
        vector<struct NetThread_Other> vec_event;
#endif
};

CNetBase::CNetBase(struct NetParam* np)
{
    this->_net_param = np;
    np = NULL;
#if EPOLL_OS
    this->_os_handler = make_shared<CLinuxHandler>();
#else
    this->_os_handler = make_shared<COtherOSHandler>();
#endif
    this->_os_handler->CheckOS(this->_net_param);
}

void CNetBase::Run()
{
    int socket;
    for (int i = 0; i < this->_net_param->thread_num; i++)
    {
        socket = this->_os_handler->CreateSocket(this->_net_param);
        if (socket < 0)
        {
            exit(EXIT_FAILURE);
        }
        if (!this->_os_handler->Bind(socket, this->_net_param))
        {
            exit(EXIT_FAILURE);
        }
        if (!this->_os_handler->Listen(socket, 0))
        {
            exit(EXIT_FAILURE);
        }
        struct NetThread_Linux nt;
        if (this->_os_handler->GenerateSocketEvent(socket, &nt))
        {
            this->vec_event.push_back(nt);
        }
        else
        {
            exit(EXIT_FAILURE);
        }
    }

    if (this->_net_param->thread_num != this->vec_event.size() && !_ALLOW_THREAD_INCOMPLETE)
    {
        string notify = "plan to start thread num is ";
        notify = notify + to_string(this->_net_param->thread_num) + ", ";
        notify = notify + "but in fact start thread num is " + to_string(this->vec_event.size());
        GPRINTN(notify);
        GPRINTE("because of _ALLOW_THREAD_INCOMPLETE(false), server will quit ...");
        exit(EXIT_FAILURE);
    }

    vector<shared_ptr<thread>> _thread_vec;
    for (int i = 0; i < this->vec_event.size(); i++)
    {
        shared_ptr<thread> thd(new thread(CNetBase::ThreadBoot, this, &(this->vec_event[i])));
        _thread_vec.push_back(thd);
    }
    for (size_t i = 0; i < _thread_vec.size(); i++) {
        _thread_vec[i]->join();
    }
}

void CNetBase::ThreadBoot(CNetBase* net_base, struct NetThread_Linux* nt)
{
    if (!net_base->_os_handler->AddListener(nt))
    {
        GPRINTE("epoll add listener error!");
        perror("epoll add listener");
        return;
    }
    net_base->_os_handler->EventLoop(nt);
}

class CNet
{
    public:
        CNet(){};
        ~CNet(){};

        void CheckNetParam(char* ip, char* port, char* thread_num, struct NetParam* np);
        void Init(char* ip, char* port, char* thread_num);
        void PrintNetParam(){this->_net_base->PrintNetParam();};
        void Run();

    private:
        shared_ptr<CNetBase> _net_base;
};

void CNet::CheckNetParam(char* ip, char* port, char* thread_num, struct NetParam* np)
{
    np->raw_ip = ip;
    np->raw_port = port;
    np->raw_thread_num = thread_num;
    in_addr_t addr = inet_addr(ip);
    if (addr == INADDR_NONE)
    {
        GPRINTE("invalid ip");
        exit(EXIT_FAILURE);
    }

    short nport = atoi(port);
    if ((nport <= 0) || (nport >= 65535))
    {
        GPRINTE("invalid port");
        exit(EXIT_FAILURE);
    }

    short nthread_num = atoi(thread_num);

    np->ip = addr;
    np->port = nport;
    np->thread_num = nthread_num;
}

void CNet::Init(char* ip, char* port, char* thread_num){
    struct NetParam* np = (struct NetParam*)malloc(sizeof(struct NetParam));
    if (np == NULL)
    {
        free(np);
        GPRINTE("memory malloc netparam failed");
        exit(EXIT_FAILURE);
    }
    memset(np, 0, sizeof(struct NetParam));
    this->CheckNetParam(ip, port, thread_num, np);
    if (!this->_net_base)
    {
        this->_net_base = make_shared<CNetBase>(np);
    }
    else{
        GPRINTW("repeat init net!");
    }
}

void CNet::Run()
{
    this->_net_base->Run();
}
// end region net

int main(int argc, char* argv[])
{
    // parameters check
    if(argc != 4)
    {
        cout<< "usage: ./" << basename(argv[0]) << " [ip] [port] [thread_num]\n";
        exit(EXIT_FAILURE);
    }

    CNet net;
    net.Init(argv[1], argv[2], argv[3]);

    // net.SetCallBack();

    net.Run();
    return 0;
}