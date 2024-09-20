#include <stdio.h>
#ifdef _WIN32
#include <windows.h>
typedef long long off_t;
#define MAP_FAILED ((void *) -1)
#else
#include <sys/mman.h>
#endif
void* mymmap(void *addr, size_t length, int prot, int flags, int fd, off_t offset) {
#ifdef _WIN32
    fprintf(stderr, "MyMap, addr = %p, length = %zu, prot = %d, flags = %d, fd = %d, offset = %lld\n", addr, length, prot, flags, fd, (long long)offset);
#else
    fprintf(stderr, "MyMap, addr = %p, length = %ld, prot = %d, flags = %d, fd = %d, offset = %ld\n", addr, length, prot, flags, fd, offset);
#endif 
    void* answer = mmap(addr, length, prot, flags, fd, offset);
    fprintf(stderr, "[JVDBG] MYMMAP answer = %p\n", answer);
    if (answer == MAP_FAILED) {
        fprintf(stderr, "Failed!\n");
#ifdef _WIN32
        fprintf(stderr, "try again\n");
        answer = VirtualAlloc(NULL, length, MEM_COMMIT | MEM_RESERVE, PAGE_READWRITE);
#else
        perror("mmap");
        fprintf(stderr, "try again\n");
        // void* answer = mmap(NULL, length, prot, flags, fd, offset);
        // answer = mmap(addr, length, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0); 
        // answer = mmap(addr, length, prot, flags, -1, 0); 
        answer = mmap(addr, length, prot, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
#endif
        fprintf(stderr, "[JVDBG] MYMMAP answer2 = %p\n", answer);
    }
    return answer; 
}
void* myprint(void *addr) {
    fprintf(stderr, "PRINT: %p\n", addr);
}
void* myprinti(int val) {
    fprintf(stderr, "PRINT intval: %d\n", val);
}
