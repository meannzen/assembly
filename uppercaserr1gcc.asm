section .bss
    Buff resb 1

section .data
section .text
global main

main: 
    mov rbp, rsp

Read:
    mov rax, 0     ; sys_read call
    mov rdi, 0    ; file descriptor 1
    mov rdx, Buff ; Tell sys_read to read one char  from stdin
    syscall
    cmp rax, 0
    je Exit

    cmp byte [Buff], 61h ; test input char againt lowercase 'a'
    jb Write

    cmp byte [Buff], 7Ah
    ja Write
    
    sub byte [Buff], 20h

Write:
    mov rax, 1
    mov rdi, 1
    mov rsi, Buff
    mov rdx, 1
    syscall
    jmp Read
Exit: 
    ret
