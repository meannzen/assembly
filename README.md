# Most Useful Linux System Calls / APIs (2026 Edition)

A practical reference for systems programmers (C or Rust) on Linux.  
These cover the majority of real-world needs in servers, tools, daemons, embedded systems, and high-performance applications.

## 1. Core File I/O

| Syscall          | C Wrapper             | Description / Common Use Cases                              |
|------------------|-----------------------|-------------------------------------------------------------|
| read / readv     | `read()`, `readv()`   | Read data from files, sockets, pipes, or any file descriptor |
| write / writev   | `write()`, `writev()` | Write data to files, sockets, pipes, or any file descriptor |
| open / openat    | `open()`, `openat()`  | Open files or devices (use flags like O_CLOEXEC, O_NONBLOCK) |
| close            | `close()`             | Close a file descriptor to free resources                   |
| mmap / munmap    | `mmap()`, `munmap()`  | Map files or anonymous memory into process address space (zero-copy I/O, large allocations) |
| fstat / stat / fstatat | `fstat()`, `stat()` | Get file metadata: size, type, permissions, timestamps      |
| lseek            | `lseek()`             | Change the current file offset (seek)                       |
| fsync / fdatasync| `fsync()`, `fdatasync()` | Ensure data is written to disk for durability            |

## 2. Process and Thread Management

| Syscall          | C Wrapper             | Description / Common Use Cases                              |
|------------------|-----------------------|-------------------------------------------------------------|
| fork / clone     | `fork()`, `clone()`   | Create a new process or lightweight thread                  |
| execve           | `execve()`            | Replace the current process image with a new program        |
| waitpid          | `waitpid()`           | Wait for child process termination and get exit status      |
| exit             | `_exit()`             | Terminate the calling process                               |
| getpid / gettid  | `getpid()`, `gettid()`| Get current process or thread ID (useful for logging)       |

## 3. Networking (Sockets)

| Syscall          | C Wrapper                  | Description / Common Use Cases                              |
|------------------|----------------------------|-------------------------------------------------------------|
| socket           | `socket()`                 | Create a socket (TCP, UDP, Unix domain, etc.)               |
| bind             | `bind()`                   | Assign an address to a socket (server side)                 |
| listen           | `listen()`                 | Mark socket as passive and set backlog                      |
| accept / accept4 | `accept4()` (preferred)    | Accept incoming connection (use with SOCK_CLOEXEC)          |
| connect          | `connect()`                | Initiate connection to remote socket (client side)          |
| sendmsg / recvmsg| `sendmsg()`, `recvmsg()`   | Advanced send/receive with control messages and vectors     |

## 4. Modern Event & Async I/O (High-Performance)

| Syscall / API       | Library / Wrapper         | Description / Common Use Cases                              |
|---------------------|---------------------------|-------------------------------------------------------------|
| epoll_create1       | `epoll_create1()`         | Create an epoll instance for scalable I/O event notification |
| epoll_ctl           | `epoll_ctl()`             | Add, modify, or remove file descriptors from epoll set     |
| epoll_wait          | `epoll_wait()`            | Wait for I/O events (core of efficient servers like nginx)  |
| io_uring_setup      | liburing                  | Set up io_uring ring for high-performance async I/O         |
| io_uring_enter      | liburing                  | Submit requests and wait for completions                    |
| signalfd            | `signalfd()`              | Convert signals into readable file descriptors              |
| timerfd_create      | `timerfd_create()`        | Create timer as file descriptor (integrates with event loops) |

## Quick Reference: Top Syscalls to Know Well

1. `read()` / `write()`  
2. `open()` / `close()`  
3. `epoll_create1()` / `epoll_ctl()` / `epoll_wait()`  
4. `mmap()`  
5. `socket()` / `bind()` / `listen()` / `accept4()` / `connect()`  
6. `fork()` / `execve()` / `waitpid()`  
7. `fstat()` / `stat()`  
8. `sendmsg()` / `recvmsg()`  
9. io_uring family (for cutting-edge performance)  
10. `signalfd()` + `timerfd()` (modern helpers for clean event loops)

## Pro Tips

- Use `O_CLOEXEC` flag on open/accept/socket to avoid leaks across fork/exec  
- Prefer `accept4()` over plain `accept()` for better control  
- For maximum performance in 2026: Learn **io_uring** — it's becoming the standard for fast I/O  
- In Rust: Use safe wrappers via crates like `nix`, `mio`, `tokio`, `polling`, or `io-uring`

Happy low-level programming! 🐧🔧

Last updated: January 2026
