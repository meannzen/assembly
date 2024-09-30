section .data

section .bss
    Buff resb 1      ; Reserve 1 byte for Buff

section .text
    global main

main:
    ; Compare rax and rbx
    mov rax, 1        ; Load 1 into rax
    mov rbx, 1        ; Load 2 into rbx
    sub rax, rbx      ; Compare rax with rbx
    je True           ; Jump to True if they are equal (ZF=1)

False:
    mov byte [Buff], 0x30     ; Store ASCII '0' in Buff (0x30 is '0')
    jmp Print

True:
    mov byte [Buff], 0x31     ; Store ASCII '1' in Buff (0x31 is '1')
    
Print:
    mov rax, 1             ; sys_write system call
    mov rdi, 1             ; stdout (file descriptor 1)
    mov rsi, Buff          ; Pointer to Buff (the buffer to print)
    mov rdx, 1             ; Length (1 byte)
    syscall                ; Call kernel to write 1 byte

End:
    mov rax, 60            ; sys_exit system call
    xor rdi, rdi           ; Return 0 (exit code)
    syscall                ; Call kernel to exit
