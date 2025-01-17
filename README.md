# List of Common Linux System Calls

## File and Directory Operations
- `open` - Open a file.
- `close` - Close a file.
- `read` - Read data from a file.
- `write` - Write data to a file.
- `lseek` - Move the file pointer to a specified location.
- `stat` - Get file status.
- `fstat` - Get file status.
- `lstat` - Get file status.
- `mkdir` - Create a directory.
- `rmdir` - Remove a directory.
- `unlink` - Delete a file.

## Process Management
- `fork` - Create a new process.
- `execve` - Execute a program.
- `exit` - Terminate a process.
- `wait` - Wait for a process to change state.
- `waitpid` - Wait for a specific process to change state.
- `getpid` - Get the process ID.
- `getppid` - Get the parent process ID.

## Memory Management
- `brk` - Change data segment size.
- `mmap` - Map files or devices into memory.
- `munmap` - Unmap files or devices from memory.
- `mprotect` - Set memory protection.
- `msync` - Synchronize memory with physical storage.

## Inter-Process Communication (IPC)
- `pipe` - Create a pipe.
- `dup` - Duplicate a file descriptor.
- `dup2` - Duplicate a file descriptor to a specific value.
- `shmget` - Get shared memory segment.
- `shmat` - Attach shared memory segment.
- `shmctl` - Control shared memory segment.
- `semget` - Get a semaphore set.
- `semop` - Perform operations on a semaphore set.
- `semctl` - Control a semaphore set.

## Networking
- `socket` - Create a socket.
- `bind` - Bind a socket to an address.
- `listen` - Listen for socket connections.
- `accept` - Accept a socket connection.
- `connect` - Connect a socket.
- `send` - Send data through a socket.
- `recv` - Receive data from a socket.
- `getsockopt` - Get socket options.
- `setsockopt` - Set socket options.

## Time Management
- `time` - Get the current time.
- `gettimeofday` - Get the current time of day.
- `settimeofday` - Set the current time of day.
- `clock_gettime` - Get the time of a specified clock.
- `clock_settime` - Set the time of a specified clock.
- `nanosleep` - Suspend execution for a specified time.

## User and Group Management
- `getuid` - Get user ID.
- `geteuid` - Get effective user ID.
- `getgid` - Get group ID.
- `getegid` - Get effective group ID.
- `setuid` - Set user ID.
- `seteuid` - Set effective user ID.
- `setgid` - Set group ID.
- `setegid` - Set effective group ID.

## Miscellaneous
- `ioctl` - Control device.
- `fcntl` - File control operations.
- `kill` - Send a signal to a process.
- `sigaction` - Examine and change a signal action.
- `sigsuspend` - Wait for a signal.
- `sigpending` - Examine pending signals.
- `sigprocmask` - Change and examine the signal mask.
- `uname` - Get system information.
