; Everything that comes after a semicolon (;) is a comment
default rel

WEIGHT_OF_EMPTY_BOX equ 500
TRUCK_HEIGHT equ 300
PAY_PER_BOX equ 5
PAY_PER_TRUCK_TRIP equ 220

section .text

; You should implement functions in the .text section
; A skeleton is provided for the first function

; the global directive makes a function visible to the test files
global get_box_weight
get_box_weight:
    ; This function takes the following parameters:
    ; - The number of items for the first product in the box, as a 16-bit non-negative integer
    ; - The weight of each item of the first product, in grams, as a 16-bit non-negative integer
    ; - The number of items for the second product in the box, as a 16-bit non-negative integer
    ; - The weight of each item of the second product, in grams, as a 16-bit non-negative integer
    ; The function must return the total weight of a box, in grams, as a 32-bit non-negative integer
    ; total = (items1 * each_item) + (items2 * each_item2) +  WEIGHT_OF_EMPTY_BOX
    ; first wieith 
    movzx eax , di
    movzx esi, si
    imul eax, esi
    ; secornd wieith
    movzx edx, dx
    movzx ecx, cx
    imul edx, ecx
    ; total + WEIGHT_OF_EMPTY_BOX
    add eax, edx
    add eax, WEIGHT_OF_EMPTY_BOX
    ret

global max_number_of_boxes
max_number_of_boxes:
    ; TODO: define the 'max_number_of_boxes' function
    ; This function takes the following parameter:
    ; - The height of the box, in centimeters, as a 8-bit non-negative integer
    ; The function must return how many boxes can be stacked vertically, as a 8-bit non-negative integer
    movzx ecx, dil
    mov eax, TRUCK_HEIGHT 
    xor edx, edx
    div ecx
    ret

global items_to_be_moved
items_to_be_moved:
    ; TODO: define the 'items_to_be_moved' function
    ; This function takes the following parameters:
    ; - The number of items still unaccounted for a product, as a 32-bit non-negative integer
    ; - The number of items for the product in a box, as a 32-bit non-negative integer
    ; The function must return how many items remain to be moved, after counting those in the box, as a 32-bit integer
    ;unaccounted_items - box_items
    movzx rax, edi
    movzx rdx, esi
    sub rax, rdx
    ret

global calculate_payment
calculate_payment:
    movzx r9, r9b
    inc r9                      ; total_people

    ; Total earnings
    mov rax, rsi
    imul rax, PAY_PER_BOX
    mov r11, rax

    mov rax, rdx
    imul rax, PAY_PER_TRUCK_TRIP
    add r11, rax

    ; Penalty
    mov rax, rcx
    imul rax, r8
    sub r11, rax                ; net_work in r11

    ; Your full work share (quotient + remainder)
    mov rax, r11
    cqo
    idiv r9
    add rax, rdx                ; your_work = q + r
    mov r11, rax

    ; Upfront: subtract the FULL amount per person (q + remainder)
    mov rax, rdi
    cqo
    idiv r9                     ; rax = q, rdx = remainder
    add rax, rdx                ; rax = full upfront share (q + r)

    ; Final payout
    sub r11, rax
    mov rax, r11
    ret

%ifidn __OUTPUT_FORMAT__,elf64
section .note.GNU-stack noalloc noexec nowrite progbits
%endif
