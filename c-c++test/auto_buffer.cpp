#include <iostream>
#include <malloc.h>
#include <memory>
#include <string.h>
using namespace std;

#define PRINTERRR(ERROR) ({printf("ERROR[%s-%s-%d]:%s\n",__FILE__,__FUNCTION__,__LINE__,ERROR);})

static int _BUFFER_SIZE = 24;

class CBufferPool
{
    public:
        CBufferPool(){};
};

class CBuffer
{
    public:
        CBuffer();
        ~CBuffer();
        void PrintPtr();
        void ResetRW();
        bool Write(char* content, int size);
        bool Read(char* content, int size);
        int GetReadSize();
        int GetWriteableSize();
        int GetReadableSize();
    private:
        char* _read_ptr;
        char* _write_ptr;
        char* _malloc_start_ptr;
        char* _malloc_end_ptr;
        int _malloc_real_size;
};

CBuffer::CBuffer()
{
    this->_malloc_start_ptr = (char *)malloc(sizeof(char) * _BUFFER_SIZE);
    this->_malloc_real_size = malloc_usable_size(this->_malloc_start_ptr);
    this->_read_ptr = this->_malloc_start_ptr;
    this->_write_ptr = this->_malloc_start_ptr;
    this->_malloc_end_ptr = this->_malloc_start_ptr + this->_malloc_real_size - 1;
}

CBuffer::~CBuffer()
{
    free(this->_malloc_start_ptr);
    this->_malloc_start_ptr = NULL;
    this->_malloc_end_ptr = NULL;
    this->_read_ptr = NULL;
    this->_write_ptr = NULL;
}

void CBuffer::PrintPtr()
{
    cout << "_malloc_start_ptr: " << (void *)this->_malloc_start_ptr << endl \
        << "_malloc_end_ptr: " << (void *)this->_malloc_end_ptr << endl \
        << "_read_ptr: " << (void *)this->_read_ptr << endl \
        << "_write_ptr: " << (void *)this->_write_ptr << endl;
}

void CBuffer::ResetRW()
{
    this->_read_ptr = this->_malloc_start_ptr;
    this->_write_ptr = this->_malloc_start_ptr;
}

int CBuffer::GetWriteableSize()
{
    if (this->_write_ptr > this->_read_ptr || this->_write_ptr == this->_read_ptr)
    {
        return (this->_malloc_end_ptr - this->_write_ptr + 1) + (this->_read_ptr - this->_malloc_start_ptr);
    }
    else
    {
        return (this->_read_ptr - this->_write_ptr);
    }
}

int CBuffer::GetReadableSize()
{
    if (this->_read_ptr < this->_write_ptr || this->_read_ptr == this->_write_ptr)
    {
        return (this->_write_ptr - this->_read_ptr);
    }
    else
    {
        return (this->_malloc_end_ptr - this->_read_ptr + 1) + (this->_write_ptr - this->_malloc_start_ptr);
    }
}

int CBuffer::GetReadSize()
{
    int readable_size = this->GetReadableSize();
    if (readable_size == 0) return 0;
    else{
        int size = 0;
        if (this->_read_ptr < this->_write_ptr)
        {
            for (int i = 0; i < readable_size; i++)
            {
                if (*(this->_read_ptr + i) == '\0'){
                    return size+1;
                }
                else{
                    size = size + 1;
                }
            }
            return size;
        }
        else
        {
            int to_end_size = this->_malloc_end_ptr - this->_read_ptr + 1;
            int start_to_size = this->_write_ptr - this->_malloc_start_ptr;
            for (int i = 0; i < to_end_size; i++)
            {
                if (*(this->_read_ptr + i) == '\0')
                {
                    return size+1;
                }
                else{
                    size = size + 1;
                }
            }
            for (int i = 0; i < start_to_size; i++)
            {
                if (*(this->_malloc_start_ptr + i) == '\0')
                {
                    return size+1;
                }
                else{
                    size = size + 1;
                }
            }
            return size;
        }
    }
}

bool CBuffer::Write(char* content, int size)
{
    if (this->GetWriteableSize() < size)
    {
        PRINTERRR("size tool large");
        return false;
    }
    if (this->_write_ptr + size > this->_malloc_end_ptr)
    {
        int to_end_size = this->_malloc_end_ptr - this->_write_ptr + 1;
        int start_to_size = size - to_end_size;
        void* ret1 = memmove(this->_write_ptr, content, to_end_size);
        void* ret2 = memmove(this->_malloc_start_ptr, content + to_end_size, start_to_size);
        if (ret1 && ret2){
            this->_write_ptr = this->_malloc_start_ptr + start_to_size;
            return true;
        }
        else{
            PRINTERRR("memmove failed");
            return false;
        }
    }
    else
    {
        void* ret3 = memmove(this->_write_ptr, content, size);
        if (ret3)
        {
            this->_write_ptr = this->_write_ptr + size;
            return true;
        }
        else{
            PRINTERRR("memmove failed");
            return false;
        }
    }
    return true;
}

bool CBuffer::Read(char *content, int size)
{
    int readable_size = this->GetReadableSize();
    if (readable_size == 0)
    {
        PRINTERRR("nothing to read");
        return false;
    }
    if (this->_read_ptr + size < this->_malloc_end_ptr || this->_read_ptr + size == this->_malloc_end_ptr)
    {
        void* ret = memmove(content, this->_read_ptr, size);
        if (ret)
        {
            this->_read_ptr = this->_read_ptr + size;
            return true;
        }
        else{
            PRINTERRR("memmove failed");
            return false;
        }
    }
    else
    {
        int to_end_size = this->_malloc_end_ptr - this->_read_ptr + 1;
        int start_to_size = size - to_end_size;
        void* ret1 = memmove(content, this->_read_ptr, to_end_size);
        void* ret2 = memmove(content+to_end_size, this->_malloc_start_ptr, start_to_size);
        if (ret1 && ret2)
        {
            this->_read_ptr = this->_malloc_start_ptr + (size - to_end_size);
            return true;
        }
        else{
            PRINTERRR("memmove failed");
            return false;
        }
    }
}

int main()
{
    shared_ptr<CBuffer> buffer = make_shared<CBuffer>();
    char content1[4] = {'w', 'h', 'w', '\0'};
    char content2[4] = {'k', 'l', 'k', '\0'};
    char content3[2] = {'m', '\0'};
    buffer -> Write(content1, 4);
    int size = buffer->GetReadSize();
    char *res = (char *)malloc(sizeof(char) * size);
    buffer -> Read(res, size);
    cout<< res << endl;
    cout<<buffer->GetReadableSize()<<endl;
    cout<<buffer->GetWriteableSize()<<endl;
    cout<<endl;

    buffer -> Write(content2, 4);
    buffer -> Write(content1, 4);
    buffer -> Write(content2, 4);
    buffer -> Write(content1, 4);
    buffer -> Write(content2, 4);
    buffer -> Write(content3, 2);
    cout<<buffer->GetReadableSize()<<endl;
    cout<<buffer->GetWriteableSize()<<endl;

    // int size1 = buffer->GetReadSize();
    // char *res1 = (char *)malloc(sizeof(char) * size1);
    // buffer -> Read(res1, size1);
    // cout<<res1 << endl;

    // int size2 = buffer->GetReadSize();
    // char *res2 = (char *)malloc(sizeof(char) * size2);
    // buffer -> Read(res2, size2);
    // cout<<res2 << endl;

    // int size3 = buffer->GetReadSize();
    // char *res3 = (char *)malloc(sizeof(char) * size3);
    // buffer -> Read(res3, size3);
    // cout<<res3 << endl;

    // int size4 = buffer->GetReadSize();
    // char *res4 = (char *)malloc(sizeof(char) * size4);
    // buffer -> Read(res4, size4);
    // cout<<res4 << endl;

    // int size5 = buffer->GetReadSize();
    // char *res5 = (char *)malloc(sizeof(char) * size5);
    // buffer -> Read(res5, size5);
    // cout<<res5 << endl;

    // int size6 = buffer->GetReadSize();
    // char *res6 = (char *)malloc(sizeof(char) * size6);
    // buffer -> Read(res6, size6);
    // cout<<res6 << endl;

    int size1 = buffer->GetReadableSize();
    char *res1 = (char *)malloc(sizeof(char) * size1);
    buffer -> Read(res1, size1);
    for (int i=0;i<size1;i++)
    {
        cout<<*(res1+i);
    }
    cout<<endl;
    return 0;
}