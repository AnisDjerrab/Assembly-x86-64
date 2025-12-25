section .data   
    GenericText db "Type anything. enter <Q> or <q> to exit : ", 0
    QuitProgram db "Q", 0
    quitProgram db "q", 0
    SizePrompt db " - size => ", 0
    newLine db 10,0
    SplitPrompt db " - Split => {'", 0
    SplitPromptMiddle db "','", 0
    SplitPromptEnd db "'}", 0
    UpPrompt db " - UP => ", 0
    DownPrompt db " - DOWN => ", 0
section .bss
    readBuffer resb 128
    OutputString resb 10
    ElementBuffer resb 128
section .text
    default rel

    global _start
_start:
BigLoop:
    ; print the Prompt
    mov rcx, GenericText
    call printf
    ; read the user input
    mov rax, 0
    mov rdi, 0
    mov rsi, readBuffer
    mov rdx, 128
    syscall

    mov rsi, 0
ConvertInClikeChar:
    mov al, Byte [readBuffer + rsi]
    cmp al, 10
    je ConvertInC
    inc rsi
    jmp ConvertInClikeChar
ConvertInC:
    mov Byte [readBuffer + rsi], 0
    ; check if the user prompt equals "Q" or "q"
    mov rcx, readBuffer
    mov rdx, QuitProgram
    call strcmp
    cmp rax, 0
    je QuitProcess
    mov rcx, readBuffer
    mov rdx, quitProgram
    call strcmp
    cmp rax, 0
    je QuitProcess
    ; now, calculate the size
    mov rcx, readBuffer
    call strlen
    mov r8, rax
    mov r9, OutputString
    call sprintf
    mov rcx, SizePrompt
    call printf
    mov rcx, OutputString
    call printf
    mov rcx, newLine
    call printf
    ; split the number
    mov rcx, SplitPrompt
    call printf
    mov r12, 0
    mov r13, 0
SplitLoop:
    mov al, Byte [readBuffer + r12]
    cmp al, 0
    je ExitSplit
    inc r12
    cmp al, ' '
    je SplitElement
    cmp al, 9
    je SplitElement
    mov Byte [ElementBuffer + r13], al
    inc r13
    jmp SplitLoop
SplitElement:
    mov Byte [ElementBuffer + r13], 0
    mov rcx, ElementBuffer
    call printf
    mov rcx, SplitPromptMiddle
    call printf
    mov r13, 0
    jmp SplitLoop
ExitSplit: 
    mov Byte [ElementBuffer + r13], 0
    mov rcx, ElementBuffer
    call printf
    mov rcx, SplitPromptEnd
    call printf
    mov rcx, newLine
    call printf
    ; now, print the UP of the number
    mov rcx, readBuffer
    call UP
    mov rcx, UpPrompt
    call printf
    mov rcx, readBuffer
    call printf
    mov rcx, newLine
    call printf
    ; and the DOWN
    mov rcx, readBuffer
    call DOWN
    mov rcx, DownPrompt
    call printf
    mov rcx, readBuffer
    call printf
    mov rcx, newLine
    call printf
    jmp BigLoop
QuitProcess:
    mov rax, 60
    xor rdi, rdi
    syscall

%include "StringFunctions.asm"
