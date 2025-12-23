; the goal of this program is to use macros to multiply all the elements of a list by two, then to inverse said list, and finally order it from biggest to smallest
; for unsigned numbers only

%macro DoubleAllList 2
    ; this marco supports qWord lists
    ; %1 contains the beginning index.
    ; %2 contains the len
    mov rcx, %2
    xor rsi, rsi
%%MulLoop:
    mov rax, qWord [%1 + rsi*8]
    shl rax, 1
    mov qWord [%1 + rsi*8], rax
    inc rsi
    loop %%MulLoop
%endmacro
    
%macro InverseList 2
    ; %1 contains the beginning of the list
    ; %2 contains the size of it
    mov rcx, %2
    xor rsi, rsi
%%PushLoop:
    push qWord [%1 + rsi*8]
    inc rsi
    loop %%PushLoop
    xor rsi, rsi
    mov rcx, %2
%%PopLoop:
    pop qWord [%1 + rsi*8]
    inc rsi
    loop %%PopLoop
%endmacro

%macro OrderList 2
    ; %1 contains the beginning adress of the list
    ; %2 contains it's len
    mov rcx, %2
%%outerLoop:
    mov rdi, %2
    xor rsi, rsi
%%innerLoop:
    cmp rsi, 0
    ja %%Proceed
    jmp %%Continue
%%Proceed:
    mov rdx, rsi
    dec rdx
    mov rax, qWord [%1 + rsi*8]
    cmp rax, qWord [%1 + rdx*8]
    ja %%InverseElements
    jmp %%Continue
%%InverseElements:
    mov rbx, qWord [%1 + rdx*8]
    mov [%1 + rdx*8], rax
    mov [%1 + rsi*8], rbx
%%Continue:
    dec rdi
    inc rsi
    cmp rdi, 0
    jne %%innerLoop
    loop %%outerLoop
%endmacro

section .data
    ListOne dq 66, 52, 0, 78, 951, 41
    ListOneLen dq 6
    ListTwo dq 87, 95, 12, 84, 0
    ListTwoLen dq 5
    ListThree dq 897, 61, 8, 6
    ListThreeLen dq 4
section .bss
section .text
    default rel

    global _start
_start:
    ; process all the lists
    DoubleAllList ListOne, [ListOneLen]
    InverseList ListOne, [ListOneLen]
    mov r11, 0
    OrderList ListOne, [ListOneLen]
    DoubleAllList ListTwo, [ListTwoLen]
    InverseList ListTwo, [ListTwoLen]
    OrderList ListTwo, [ListTwoLen]
    DoubleAllList ListThree, [ListThreeLen]
    InverseList ListThree, [ListThreeLen]
    OrderList ListThree, [ListThreeLen]

    ; exit the program
    mov rax, 60
    xor rdi, rdi
    syscall