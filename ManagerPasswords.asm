section .data
    ; constants
    Sys_read equ 0
    STDIN equ 0
    STDOUT equ 1
    ; variables
    WelcomeMessage db "Welcome to the password management program !", 10, "Type 'help' to list avalaible commands", 0
    Prompt db ">> ", 0
    newLine db 10, 0
    FileName db "password.txt"
    FileDescriptor dq 0
    helpCommand db "help", 0
section .bss
    command resb 128
    char resb 1
section .text
    default rel

    global _start
_start:
    ; print the Welcome message 
    mov rcx, WelcomeMessage
    call printf
BigLoop:
    ; print the prompt
    mov rcx, Prompt
    call printf
    mov r12, 0
InputLoop:
    mov rax, Sys_read
    mov rdi, STDIN
    mov rsi, char
    mov rdx, 0
    syscall
    cmp Byte [char], 10
    je ExitLoop
    cmp r12, 127
    je ExitLoop
    ; write char in command
    mov al, Byte [char]
    mov Byte [command + r12], al
ExitLoop:
    ; convert in C like string
    mov Byte [command + r12], 10
    ; now, compare with the avalaible commands


%include "StringFunctions.asm"