#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <sys/epoll.h>
#include <signal.h>
#include <errno.h>
#include <time.h>
#include <libgen.h>
#include <fcntl.h>
 
#define MAX_EPOLL_EVENTS    1024
#define MAX_BUFFER_SIZE     4096
 
typedef int (*NCALLBACK)(int, int, void*);
 
struct  Revent {
    int fd;              // 事件对应的fd
    int events;       // 事件类型（  本代码中我们只处理EPOLL_IN和EPOLL_OUT）
    void *arg;        // 实际传入的是一个struct Reactor结构体指针
    int (*callback)(int fd, int evtype,void *arg); //事件回调函数
    int status;       // 当前事件是否在epoll集合中: 1表示在, 0表示不在
    char buffer[MAX_BUFFER_SIZE]; // 读写缓冲区
    int length;       //缓冲区数据的长度
    long last_active; // 最后一次活跃的时间
    struct Revent* prev;
    struct Revent* next;
};
 
// Reactor主体
struct Reactor {
    //epoll 的fd
    int epoll_fd; 
    // reactor事件集，是二维结构，因为每个fd可能有多个事件
    // 第一维下标即为对应的文件描述符, 共有MAX_EPOLL_EVENTS-5个可以用来存放客户端的fd
    // 因为剩余的5个都有其他用处了。0: 标准输入  1: 标准输出 2:标准错误 3:监听socket
    // 4:epool专用fd
    struct Revent *events[MAX_EPOLL_EVENTS]; 
};
 
// 创建一个Tcp Server
int init_server(char *ip, short port);
// 向reactor中添加一个服务器监听事件
int reactor_addlistener(struct Reactor *reactor, int fd, NCALLBACK callback);
 
/***下面这3个函数是用来对reactor操作的***/
struct Reactor *reactor_init();
int reactor_destroy(struct Reactor *reactor);
int reactor_run(struct Reactor *reactor);
 
 
/***下面这3个函数是用来对Revent事件结构操作的***/
int revent_set(struct Revent *ev, int fd, int event, int length, int status, NCALLBACK callback, void *arg);
int revent_add(int epoll_fd, struct Revent* ev);
int revent_del(int epoll_fd, struct Revent* event);
 
/***下面这3个函数是Revent事件可以使用的回调函数***/
// fd:  事件对应的文件描述符  events: 事件的类型(EPOLLIN,EPOLLOUT,...组合)  arg: 事件自身句柄  
int accept_callback(int fd, int events, void *arg);
int recv_callback(int fd, int events, void *arg);
int send_callback(int fd, int events, void *arg);
 
 
int init_server(char *ip, short port)
{
    // 1.创建套接字
    int sock_fd = socket(AF_INET, SOCK_STREAM, 0);
    if(sock_fd == -1)
    {
        printf("Error in %s(), socket: %s\n", __func__, strerror(errno));
        return -1;
    }
 
    // 2.初始化服务器地址
    struct sockaddr_in server_addr;
    memset(&server_addr, 0, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    if(inet_pton(AF_INET, ip, (void*)&server_addr.sin_addr.s_addr) == -1)
    {
        printf("Error in %s(), inet_pton: %s\n", __func__, strerror(errno));
        return -1;
    }
    server_addr.sin_port = htons(port);
 
    // 3.绑定服务器地址
    if(bind(sock_fd, (const struct sockaddr*)&server_addr, sizeof(server_addr)) == -1)
    {
        printf("Error in %s(), bind: %s\n", __func__, strerror(errno));
        return -1;
    }
 
    // 3.监听
    if(listen(sock_fd, 20) == -1)
    {
        printf("Error in %s(), listen: %s\n", __func__, strerror(errno));
        return -1;
    }
 
    printf("Listen start [%s:%d]...\n", inet_ntoa(server_addr.sin_addr), ntohs(server_addr.sin_port));
    
    return sock_fd;
}
 
struct Reactor *reactor_init()
{
    // 1.创建一个reactor
    struct Reactor *reactor = (struct Reactor*)malloc(sizeof(struct Reactor));
    if(reactor == NULL)
        return NULL;
    memset(reactor, 0, sizeof(struct Reactor));
 
    // 2.创建reacotr的epoll_fd
    reactor->epoll_fd = epoll_create(1);
    if(reactor->epoll_fd == -1)
    {
        printf("Error in %s(), epoll_create: %s\n", __func__, strerror(errno));
        free(reactor);
        return NULL;
    }
    return reactor;
}
 
int reactor_destroy(struct Reactor *reactor)
{
    if(reactor == NULL)
    {
        printf("Error in %s(): %s\n", __func__, "reactor arg is NULL");
        return -1;
    }
    // 关闭epoll_fd、销毁事件集、释放结构
    close(reactor->epoll_fd);
    free(reactor);
    return 0;
}
 
int reactor_run(struct Reactor *reactor)
{
    // 1.判断参数
    if(reactor == NULL || reactor->epoll_fd < 0 || reactor->events == NULL)
    {
        printf("Error in %s(): %s\n", __func__, "reactor arg is error");
        return -1;
    }
    struct epoll_event ep_events[MAX_EPOLL_EVENTS + 1];
 
    // 2.进行epoll_wait()
    int nready;
    while(1)
    {
        nready = epoll_wait(reactor->epoll_fd, ep_events, MAX_EPOLL_EVENTS, 1000);
        // 3.函数出错
        if(nready == -1)
        {
            // 如果epoll_wait函数在阻塞过程中接收到外部信号, 那么继续进行epoll_wait()
            if(errno == EAGAIN || errno == EWOULDBLOCK)
                continue;
            printf("Error in %s(), epoll_wait: %s\n", __func__, strerror(errno));
            return -1;
        }
        // 4.epoll_wait函数超时
        else if(nready == 0)
            continue;
        // 5.有事件准备好
        else
        {
            // 遍历处理已就绪的事件
            for(int i = 0; i < nready; ++i)
            {
		        struct Revent* ev = (struct Revent*)ep_events[i].data.ptr;
		   
		        int res;
	            int fd = ev->fd;
		        // 如果是可读事件
		        if((ep_events[i].events & EPOLLIN)){
			        struct Revent* evhead = reactor->events[fd];
			        for(ev=evhead;ev!=NULL;ev=ev->next)
				    if(ev->events&EPOLLIN)break;
			        if(ev!=NULL){
				        printf("readable events prepare to handling.\n");
				        res = ev->callback(ev->fd,ev->events, ev);//ev在callback内部可能被释放，因此调用之后不要再访问它了
				        printf("readable result: %d\n",res);
			        }
		        }
		
                // 如果是可写事件
                if((ep_events[i].events & EPOLLOUT)){
                    struct Revent* evhead = reactor->events[fd];
                    for(ev=evhead;ev!=NULL;ev=ev->next)
                        if(ev->events&EPOLLOUT)break;
                    if(ev!=NULL){
                        printf("writable events prepare to handling.\n");
                        res = ev->callback(ev->fd, ev->events,ev);
                        printf("writable result: %d\n",res);//同理，不应再访问ev
                    }
		        }
            }//end for
        }
    }//end while
    return 0;
}
 
int reactor_addlistener(struct Reactor *reactor, int fd, NCALLBACK callback)
{
    if(reactor == NULL || fd <0 || callback == NULL)
    {
        printf("Error in %s(): %s\n", __func__, "arg error");
        return -1;
    }
    // 初始化监听socket的可读事件, 并将该事件添加到reactor的事件集合中
    struct Revent *ev = (struct Revent*)malloc(sizeof(struct Revent));
    memset(ev,0,sizeof(struct Revent));
    revent_set(ev, fd, EPOLLIN, 0, 0, callback, reactor);
    printf("listening fd=%d\n",fd);
    int ret = revent_add(reactor->epoll_fd, ev);
    if(ret<0){
        free(ev);
        printf("warning add listenner read event falided.\n");
    }
    return 0;
}
 
int revent_set(struct Revent *ev, int fd, int event, int length, int status, NCALLBACK callback, void *arg)
{
    if(ev == NULL || fd <0 || event <0 || length < 0 || callback == NULL || arg == NULL || status < 0)
    {
        printf("Error in %s(): %s\n", __func__, "arg error");
        return -1;
    }
    // 初始化Revent结构的相关内容即可
    ev->fd = fd;
    ev->events = event;
    ev->arg = arg;
    ev->callback = callback;
    ev->status = status;
    ev->length = length;
    ev->last_active = time(NULL);
    ev->next = NULL;
    ev->prev = NULL;
    return 0;
}
 
int revent_add(int epoll_fd, struct Revent* ev)
{
    if(ev == NULL)
        return -1;
    struct Reactor *reactor=(struct Reactor *)ev->arg;
    if(reactor == NULL || reactor->epoll_fd <0||ev->status!=0)
        return -1;
    
    // 0.将事件加入reactor的事件集合
    int fd = ev->fd;
    struct Revent *head = reactor->events[fd];
    if(head==NULL){
        reactor->events[fd] = ev;
    }
    else{
        head->prev = ev;
        ev->next = head;
        ev->prev = NULL;
        reactor->events[fd] = ev;
    }
    ev->status=1;
    // 1.将事件注册到epoll事件集合中
    struct epoll_event ep_event;
    memset(&ep_event, 0, sizeof(ep_event));
    ep_event.events = ev->events;
    ep_event.data.ptr = ev;
    //ep_event.data.fd = ev->fd; data成员是一个联合体, 不能同时使用fd和ptr成员
    // 如果当前ev已经在epoll事件表中, 就修改; 否则就把ev新加入到epoll事件表中
    int op=EPOLL_CTL_ADD;
    int evtype = 0;
    int res = epoll_ctl(epoll_fd, op, fd, &ep_event);
    if( res != 0){
        if(errno==EEXIST){
            //printf("this fd is already in epoll set\n");
            op = EPOLL_CTL_MOD;
            memset(&ep_event, 0, sizeof(ep_event));
            ep_event.data.ptr = ev;
            for(struct Revent *e=ev; e!=NULL; e=e->next)
                ep_event.events |= e->events;
            res = epoll_ctl(epoll_fd, op, fd, &ep_event);
        }
    }
    if(res !=0)
    {
        reactor->events[fd]=reactor->events[fd]->next;
        ev->status=0;
        printf("update event for fd=%d falided, epoll_ctl: %s, operator type: %d, error:%d\n",fd, strerror(errno),op,errno);
        return -1;
    }
    printf("update event type for fd=%d success. with type is: %d\n",fd,ep_event.events);
    return 0;
}
 
int revent_del(int epoll_fd,  struct Revent* ev)
{
    if(ev == NULL)
        return -1;
    
    printf("prepare to del event from reactor events set\n");
    struct Reactor *reactor=(struct Reactor *)ev->arg;
    if(reactor == NULL || reactor->epoll_fd <0 ||ev->status != 1)
    {
        printf("Error in %s(), ev->status=%d\n", __func__, ev->status);
        return -1;
    }
    //把ev从reactor中取出
    int fd = ev->fd;
    if(ev == reactor->events[fd])
        reactor->events[fd] = ev->next;
    if(ev->prev!=NULL)
        ev->prev->next = ev->next;
    if(ev->next!=NULL)
        ev->next->prev = ev->prev;
        
    ev->status = 0;
    struct epoll_event ep_event;
    memset(&ep_event, 0, sizeof(ep_event));
    ep_event.data.ptr = ev;
    struct Revent* ev_this_fd = reactor->events[fd];
 
    int EVENTSTYPE=0;
    for(;ev_this_fd!=NULL;ev_this_fd=ev_this_fd->next)
        EVENTSTYPE |= ev_this_fd->events;
 
    int op;
    if(EVENTSTYPE != 0){
        memset(&ep_event, 0, sizeof(ep_event));
        ep_event.data.ptr=reactor->events[fd];
        ep_event.events = EVENTSTYPE;
        op=EPOLL_CTL_MOD; 
    }
    else{
        op=EPOLL_CTL_DEL;
    } 
    if(epoll_ctl(epoll_fd, op , fd, &ep_event) == -1)
    {
        printf("Error in %s(), epoll_ctl: %s\n", __func__, strerror(errno));
        return -1;
    }
    return 0;
}
 
int accept_callback(int fd, int what, void* ntyev)
{
    // 1.获取该fd对应的事件结构
    struct Revent *ev = (struct Revent*)ntyev;
    // 2.获得reactor结构
    struct Reactor *reactor =(struct Reactor*)(ev->arg);
    // 3.初始化客户端地址结构
    struct sockaddr_in cli_addr;
    memset(&cli_addr, 0 , sizeof(cli_addr));
    socklen_t len = sizeof(cli_addr);
 
    // 4.接收客户端
    int cli_fd;
    cli_fd = accept(fd, (struct sockaddr*)&cli_addr, &len);
    if(cli_fd == -1)
    {
        //fd耗尽了,太多的客户端同时在线，还没有释放。
        //所以服务端增加超时机制及时关掉超时的客户端，回收fd是尤其必要的
        if(errno==EMFILE)
            printf("Error in %s(), accept: %s\n", __func__, strerror(errno));
        return -1;
    }
    
    // fd 的0、1、2、3、4 都被占用了
    // 0: 标准输入  1: 标准输出 2:标准错误 3:监听socket 4:epool专用fd
    // 5.将套接字设置为非阻塞
    fcntl(cli_fd, F_SETFL, O_NONBLOCK);
    // setsockopt(sockfd, SOL_SOCKET, SO_SNDTIMEO, &timeout, len)
    // 如果设置了SO_SNDTIMEO超时, 即便是阻塞的套接字，在recv 和 accept 的时候也会非阻塞
    // 6.将新事件添加到reactor事件表中
    struct Revent *cliev_read = (struct Revent*)malloc(sizeof(struct Revent));
    memset(cliev_read,0,sizeof(struct Revent));
    
    revent_set(cliev_read, cli_fd, EPOLLIN, 0, 0, recv_callback, reactor);
    int ret = revent_add(reactor->epoll_fd, cliev_read);
    if(ret<0){
        free(cliev_read);
        close(cli_fd);
        printf("Add new client reading event falided.\n");
        return -1;
    }
    printf("New connect: [%s:%d] [client fd=%d] [evtype:%d] [time:%ld]\n", \
        inet_ntoa(cli_addr.sin_addr), ntohs(cli_addr.sin_port),cli_fd,cliev_read->events,cliev_read->last_active);
    return cli_fd;
}
 
int recv_callback(int fd,  int what, void* ntyev)
{
    // 1.获取该fd对应的事件结构
    struct Revent *ev = (struct Revent*)ntyev;
    // 2.获得reactor结构
    struct Reactor *reactor =(struct Reactor*)(ev->arg);
    // 3.接收数据
    int rc = recv(fd, ev->buffer, MAX_BUFFER_SIZE, 0);
    if(rc <= 0)//recv出错
    {
        // EAGAIN 表示读缓冲区暂时没有可读的数据
        if(errno == EAGAIN || errno == EWOULDBLOCK)
            return rc;
        //ECONNRESET 表示收到了对端内核发送的RST信号,表明对端socket已
        //经关闭(网络不通的话，将收不到该信号)
        if(errno==ECONNRESET)
            printf("Counter part socket has been closed.\n");
        printf("Error in %s(),  %s\n", __func__, strerror(errno));
        // 把该fd相关的事件全部移除
        for(struct Revent *tmpev = reactor->events[fd];tmpev!=NULL;){
            revent_del(reactor->epoll_fd, tmpev);
            free(tmpev);
            tmpev = reactor->events[fd];
        }
        //close调用时,如果该fd的读缓冲区还剩有数据没取完,将会向对方发送RST包而不是FIN包
        close(fd);
        printf("[Close fd=%d]\n",fd);
        reactor->events[fd]=NULL;
    } 
    else
    {
        ev->buffer[rc] = '\0';
        printf("Recv[fd = %d]: %s\n", fd, ev->buffer);
        // 这里应该是解析接收到的数据，并进行处理，根据需求决定是否要写回数据。
        // 考虑到直接调用send有可能不成功，比如当前时刻写缓冲区满了，不能确定何
        // 时有空闲，所以也要把可写事件也注册到reactor
        struct Revent *ev_write = (struct Revent*)malloc(sizeof(struct Revent));
        memset(ev_write,0,sizeof(struct Revent));
        strcpy(ev_write->buffer,ev->buffer);//将收到的数据再发送回去
        revent_set(ev_write, fd, EPOLLOUT, rc, 0, send_callback, reactor);
        int ret = revent_add(reactor->epoll_fd, ev_write);
        if(ret<0){
            printf("Add client writable event falided.\n");
            free(ev_write);
        }
    }
    return rc;
}
 
int send_callback(int fd,  int what, void* ntyev)
{   
    // 1.获取该fd对应的事件结构
    struct Revent *ev = (struct Revent*)ntyev;
    // 2.获得reactor结构
    struct Reactor *reactor =(struct Reactor*)(ev->arg);
    // 3.向发送缓冲区中写入数据
    int rc = send(ev->fd, ev->buffer, ev->length, 0);//对方可能回复RST
    //  有可能要发送的内容太多，不能一次性放入发送缓冲区，可以循环发送
    //  过程中要注意发送缓冲区中待发数据的长度变化，如果长度线性增加且，
    //说明对方接收异常，可以提前终止，不必等发送缓冲区满填满。
    /*
    int value;//socket发送队列中等待发送的数据长度
    unsigned int sendBufferLen;//socket 发送队列总长度，固定不变
    size_t optlen = sizeof(sendBufferLen);
    getsockopt(ev->fd, SOL_SOCKET, SO_SNDBUF, &sendBufferLen, &optlen);
    ioctl(ev->fd,TIOCOUTQ,&value);
    //如果发送缓冲区剩余空间不足，调用send会失败
    while(sendBufferLen-value>ev->length&& rc>0 ){
        rc = send(ev->fd, ev->buffer, ev->length, 0);
        ioctl(ev->fd,TIOCOUTQ,&value);
        //如果数据发完了，可以break出来
    }
    */
    if(rc > 0) //写入缓冲区成功，且当前时刻还未检测到对方socket异常
    {
        printf("Send[fd = %d]: %s\n", ev->fd, ev->buffer);
        // 如果数据发完，移除可写事件, 避免水平触发方式下的重复触发写事件
        revent_del(reactor->epoll_fd, ev);
        free(ev);
    }
    else //send写入缓冲区失败(rc<0)，检测到对方socket异常
    {
        printf("Error in %s(), %s\n", __func__, strerror(errno));
        if(errno==EPIPE)//处理可以预见的错误，其他的错误暂不处理。EPIPE表示对方异常关闭，等价于recv时收到ECONNRESET信号
        {
            printf("EPIPE. Counter part disconnected Unusually.\n");
            for(struct Revent *tmpev = reactor->events[fd];tmpev!=NULL;){
                revent_del(reactor->epoll_fd, tmpev);
                free(tmpev);
                tmpev = reactor->events[fd];
            }
        }
        else{
            revent_del(reactor->epoll_fd, ev);
            free(ev);
        }
    }
    //调用close时如果写缓冲区还有数据没发完，则根据该fd的SO_LINGER策略决定是直接丢弃还是尝试发送直到
    //SO_LINGER策略超时，超时和直接丢弃都会向对方发送RST报文。
    if(reactor->events[fd]==NULL) {close(fd);printf("[Close fd=%d]\n",fd);}
    return rc;
}
 
int main(int argc, char *argv[])
{
    if(argc != 3)
    {
        printf("usage: ./%s [ip] [port]\n", basename(argv[0]));
        exit(EXIT_FAILURE);
    }
    char *ip = argv[1];
    short port = atoi(argv[2]);
    int sock_fd;
 
    // 1.初始化一个用于监听的socket
    sock_fd = init_server(ip, port);
    // 2.初始化reactor
    struct Reactor *reactor = reactor_init();
    if( reactor == NULL)
    {
        printf("Error in %s(), Reactor_init: create reactor error\n", __func__);
        exit(1);
    }
    // 3.将监听socket添加到reactor事件集中,并指定handler 为accept_callback
    reactor_addlistener(reactor, sock_fd, accept_callback);
    // 4.运行reactor
    reactor_run(reactor);
    // 5.销毁
    reactor_destroy(reactor);
    //6.关闭监听socket
    close(sock_fd);
    return 0;
}