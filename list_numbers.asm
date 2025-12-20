section .data
    list db 13, 7, 55, 68, 1, 0, -11, 17, -89, -121, 85, 23
    numberOfElements db 12
section .bss
    AverageValue resb 1
    HighestValue resb 1
    LowestValue resb 1
    MostAverageValue resb 1
section .text
    default rel

    global _start
_start:
    ; calculate the average value
    movzx rcx, byte [numberOfElements]
    xor rsi, rsi
    mov ax, 0 
AverageLoop:
    movsx r10w, byte [list + rsi]
    add ax, r10w
    inc rsi
    loop AverageLoop
    ; end of loop
    cwd
    movzx bx, byte [numberOfElements]
    idiv bx
    mov byte [AverageValue], al 
    ; now find the highest value
    movzx rcx, byte [numberOfElements]
    xor rsi, rsi
    mov al, -128
TopValueLoop:
    mov bl, byte [list + rsi]
    inc rsi
    cmp bl, al
    jg Above 
    loop TopValueLoop
    jmp Continue1
Above:
    mov al, bl
    dec rcx
    cmp rcx, 0
    je Continue1
    jmp TopValueLoop
Continue1:
    mov byte [HighestValue], al
    ; now calculate the lowest value
    movzx rcx, byte [numberOfElements]
    xor rsi, rsi
    mov al, 127
BottomValueLoop:
    mov bl, byte [list + rsi]
    inc rsi
    cmp bl, al
    jl Below 
    loop BottomValueLoop
    jmp Continue2
Below:
    mov al, bl
    dec rcx
    cmp rcx, 0
    je Continue2
    jmp BottomValueLoop
Continue2:
    mov byte [HighestValue], al
    ; finally, find out the closest value to the middle
    movzx rcx, byte [numberOfElements]
    xor rsi, rsi
    mov al, 0
    mov bl, 127
    mov r8b, -127
    xor r10, r10
    mov r10b, 0
MiddleLoop:
    mov dl, byte [list + rsi]
    inc rsi
    cmp dl, byte [AverageValue]
    jle FirstCase
    jmp SecondCase
FirstCase:
    sub dl, byte [AverageValue]
    cmp dl, bl
    jg Confirmed1
    jmp ContinueLoop
Confirmed1:
    mov bl, dl
    neg dl
    mov r8b, bl
    mov r10, rsi
    jmp ContinueLoop
SecondCase:
    sub dl, byte [AverageValue]
    cmp dl, bl
    jl Confirmed2
    jmp ContinueLoop
Confirmed2:
    mov r8b, dl
    neg dl
    mov bl, bl
    mov r10, rsi
    jmp ContinueLoop
ContinueLoop:
    loop MiddleLoop
    mov r11b, byte [list + r10]
    mov byte [MostAverageValue], r11b
    ; finally, exit the program
    mov rax, 60
    xor rdi, rdi
    syscall 
