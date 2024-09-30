; Excutable name: eatsyscall
; Version       : 1.0
; Create date   : 9/23/2024
; Last update   : 9/23/2024
; Author        : Sen Meann
; Architecture  : x64
; From          : x64 Assembly Language Step by Step, 4th Edition
; Description   : A simple program in assymbly for x64 linux using NASM
;                Build using command:
;                 nasm -felf64 eatsyscall.asm
;                 gcc -no-pie eatsyscall.o

section .data  ; Section containing initialized data
    EatMsg: db "Eat at Joe's!", 10
    EatLen: equ $-EatMsg
section .bss

section .text
global main

main: 
    push rbp
    mov rbp, rsp

    mov rax, 1
    mov rdi, 1

    mov rsi, EatMsg
    mov rdx, EatLen
    syscall

    mov rax, 60
    mov rdi, 0
    syscall