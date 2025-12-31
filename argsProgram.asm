section .data
    ; constants
    Sys_write equ 1
    Sys_exit equ 60
    STDOUT equ 1 
    ; variables
    errorMessage db "not the right number of args provided. provide exacty three unsigned numbers.", 10, 0
    errorMessageInvalidArgument db "invalid argument. remember args must be unsigned numbers.", 10, 0
    numberFirstPart db "number ", 0
    numberSecondPart db " : ", 0
    sumOfNumber db "The sum of the numbers is : ", 0
    number db 49, 0
    newLine db 10, 0
section .bss
    sumNumbers resb 21
section .text
    default rel

    global _start:
_start:

    mov r12, [rsp]
    lea r13, [rsp + 8]
    mov r14, 0
    ; check if the number of args is right
    cmp r12, 4
    jne numberOfArgsError
    ; now, convert in string
    add r13, 8
    mov rbx, 3
readLoop:
    mov rcx, [r13]
    call strtol
    cmp rax, -1
    je ErrorInvalidArg
    add r14, rax
    ; print the arg
    mov rcx, numberFirstPart
    call printf
    mov rcx, number
    call printf
    mov rcx, numberSecondPart
    call printf
    mov rcx, [r13]
    call printf
    mov rcx, newLine
    call printf
    add r13, 8
    inc r15
    inc Byte [number]
    dec rbx
    cmp rbx, 0
    jne readLoop
    ; now convert in string
    mov r8, r14
    mov r9, sumNumbers
    call sprintf
    mov rcx, sumOfNumber
    call printf
    mov rcx, sumNumbers 
    call printf
    mov rcx, newLine
    call printf
    jmp ExitProgram
numberOfArgsError:
    mov rcx, errorMessage
    call printf
    jmp ExitProgram
ErrorInvalidArg:
    mov rcx, errorMessageInvalidArgument
    call printf
ExitProgram:
    mov rax, Sys_exit
    xor rdi, rdi
    syscall

%include "StringFunctions.asm"