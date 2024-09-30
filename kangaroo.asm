section .data
    Snippet db "KANGAROO"
section .text
    global main

main: 
    mov rbp, rsp; save stack pointer for debuger 
    nop

    mov rbx, Snippet
    mov rax, 8
DoMore: 
    add byte [rbx], 32
    inc rbx
    dec rax
    jnz DoMore
    nop