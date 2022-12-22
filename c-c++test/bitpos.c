#include <stdio.h>
#include <string.h>
 
/* 定义位域结构 */
struct
{
    unsigned short a:1;
    unsigned short b:1;
} status2;
 
int main( )
{
   printf( "Memory size occupied by status2 : %lu\n", sizeof(status2));
   status2.a = 1;
   status2.b = 0;
   printf( "Memory size occupied by status2 : %lu\n", sizeof(status2));
   printf("status2 %d %d", status2.a, status2.b);
 
   return 0;
}