#include <stdio.h>

#ifdef _WIN32
#include <windows.h>
typedef long long off_t; // Define off_t as long long for Windows
#define PROT_READ  1
#define PROT_WRITE 2
#define MAP_FAILED ((void *) -1)
#else
#include <sys/mman.h>
#include <unistd.h>
#endif

void* mymmap(void* addr, size_t length, int prot, int flags, int fd, off_t offset) {
    // Use %zu for size_t and %lld for off_t (long long in Windows)
    fprintf(stderr, "MyMap, addr = %p, length = %zu, prot = %d, flags = %d, fd = %d, offset = %lld\n", addr, length, prot, flags, fd, (long long)offset);

#ifdef _WIN32
    HANDLE hMap;
    void* answer = NULL;

    DWORD protect = 0;
    if (prot & PROT_READ) {
        protect |= PAGE_READONLY;
    }
    if (prot & PROT_WRITE) {
        protect |= PAGE_READWRITE;
    }

    hMap = CreateFileMappingA(INVALID_HANDLE_VALUE, NULL, protect, (DWORD)(length >> 32), (DWORD)(length & 0xFFFFFFFF), NULL);
    if (hMap) {
        answer = MapViewOfFile(hMap, FILE_MAP_WRITE, (DWORD)(offset >> 32), (DWORD)(offset & 0xFFFFFFFF), length);
    }
    if (!answer) {
        answer = MAP_FAILED;
    }
#else
    void* answer = mmap(addr, length, prot, flags, fd, offset);
#endif

    fprintf(stderr, "[JVDBG] MYMMAP answer = %p\n", answer);
    if (answer == MAP_FAILED) {
        fprintf(stderr, "Failed!\n");
#ifdef _WIN32
        fprintf(stderr, "try again\n");
        // Retry with a different approach on Windows (optional, can depend on specific needs)
        answer = VirtualAlloc(NULL, length, MEM_COMMIT | MEM_RESERVE, PAGE_READWRITE);
#else
        perror("mmap");
        fprintf(stderr, "try again\n");
        answer = mmap(addr, length, prot, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
#endif
        fprintf(stderr, "[JVDBG] MYMMAP answer2 = %p\n", answer);
    }
    return answer;
}

void* myprint(void* addr) {
    fprintf(stderr, "PRINT: %p\n", addr);
    return NULL;
}

void* myprinti(int val) {
    fprintf(stderr, "PRINT intval: %d\n", val);
    return NULL;
}
