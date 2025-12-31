; this contains a bunch of functions used in the StringParser program
default rel
section .text

global help
help:
    ; print the string
    mov rax, Sys_write
    mov rdi, STDOUT
    mov rsi, helpString
    mov rdx, 95
    syscall
    ; return 
    ret

global eraseSpaces
eraseSpaces:
    ; rdi must contain the adress of the input buffer
    ; r8 will contain the read adress in the buffer, and r9 the write adress
    mov r8, 0
    mov r9, 0
LoopEraseSpaces:
    mov al, Byte [rdi + r8]
    cmp al, ' '
    je IgnoreSpace
    cmp al, 9
    je IgnoreSpace
    cmp al, 0
    je Exit
    jmp IncludeCaracter
IgnoreSpace:
    inc r8
    jmp LoopEraseSpaces
IncludeCaracter:
    mov Byte [rdi + r9], al
    inc r8
    inc r9
    jmp LoopEraseSpaces
Exit:
    mov Byte [rdi + r9], 0
    ret

global down
down:
    ; this function make a string non-case sensitive
    ; rdi must contain the adress of the input string
    mov rsi, 0
downLoop:
    mov al, Byte [rdi + rsi]
    cmp al, 'A'
    jae MaybeModifyLetter
    cmp al, 0
    je ExitDown
    inc rsi
    jmp downLoop
MaybeModifyLetter:
    cmp al, 'Z'
    jbe ModifyLetter
    inc rsi
    jmp downLoop
ModifyLetter:
    add al, 32
    mov Byte [rdi + rsi], al
    inc rsi
    jmp downLoop
ExitDown:
    ret 

section .rodata
    ; constants
    Sys_write equ 1
    STDOUT equ 1
    ; variables
    helpString db "String parser program, v1.0.0, by @AnisDjerrab. GNU general public lisence v3.0, 2025.", 10
               db "Usage :", 10