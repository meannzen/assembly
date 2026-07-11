; Everything that comes after a semicolon (;) is a comment

; Assembler-time constants may be defined using 'equ'

PREPARATION_TIME equ 2
EXPECTED_MINUTES_IN_OVEN equ 40

section .text

; You should implement functions in the .text section

; the global directive makes a function visible to the test files

global expected_minutes_in_oven
expected_minutes_in_oven:
    ; TODO: This function has no arguments
    ; and must return a number
    mov rax ,EXPECTED_MINUTES_IN_OVEN
    ret

global remaining_minutes_in_oven
remaining_minutes_in_oven:
    ; TODO: define the 'remaining_minutes_in_oven' function
    ; This function takes one number as argument and must return a number
    mov rbx, rdi
    mov rax, EXPECTED_MINUTES_IN_OVEN 
    sub rax, rbx
    ret

global preparation_time_in_minutes
preparation_time_in_minutes:
    ; TODO: define the 'preparation_time_in_minutes' function
    ; This function takes one number as argument and must return a number
    mov rax, rdi
    mov rbx, PREPARATION_TIME
    mul rbx
    ret

global elapsed_time_in_minutes
elapsed_time_in_minutes:
    ; TODO: define the 'elapsed_time_in_minutes' function
    ; This function takes two numbers as arguments and must return a number
    call preparation_time_in_minutes
    add rax, rsi
    ret

%ifidn __OUTPUT_FORMAT__,elf64
section .note.GNU-stack noalloc noexec nowrite progbits
%endif