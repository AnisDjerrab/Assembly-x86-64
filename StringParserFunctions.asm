; this contains a bunch of functions used in the StringParser program
default rel
section .text

global help
extern malloc
help:
    ; rdi must contain the adress of the input string
    ; copy the string
    mov rdi, 97
    call malloc
    ; returns adress in rax
    mov rcx, 96
    mov rdi, 96
    mov rsi, 0
copyLoopFast:
    movups xmm0, oword [helpString + rsi]
    movups oword [rax + rsi], xmm0
    add rsi, 16
    sub rcx, 16
    cmp rcx, 0
    ja copyLoopFast
    sub rdi, rsi
    mov rcx, rdi
    cmp rcx, 0
    jne copyLoopSlow
    ret
copyLoopSlow:
    mov dl, Byte [helpString + rsi]
    mov Byte [rax + rsi], dl
    inc rsi
    loop copyLoopSlow
    ret

global eraseSpacesExceptApostrophies
eraseSpacesExceptApostrophies:
    push rbp
    mov rbp, rsp
    sub rbp, 8
    ; local variable [rbp - 1] will be a bool InParenthesisSimple
    mov Byte [rbp - 1], 0
    ; local variable [rbp - 2] will be a bool InParenthesisDouble
    mov Byte [rbp - 2], 0
    ; rdi must contain the adress of the input buffer
    ; r8 will contain the read adress in the buffer, and r9 the write adress
    mov r8, 0
    mov r9, 0
LoopEraseSpaces:
    mov al, Byte [rdi + r8]
    cmp al, 0
    je Exit
    cmp al, 39
    je ChangeStatusSimple
    cmp [rbp - 1], 1
    je IncludeCaracter
    cmp al, '"'
    je ChangeStatusDouble
    cmp [rbp - 2], 1
    je IncludeCaracter
    cmp al, ' '
    je IgnoreSpace
    cmp al, 9
    je IgnoreSpace
    jmp IncludeCaracter
IgnoreSpace:
    inc r8
    jmp LoopEraseSpaces
IncludeCaracter:
    mov Byte [rdi + r9], al
    inc r8
    inc r9
    jmp LoopEraseSpaces
ChangeStatusSimple:
    cmp [rbp - 2], 1
    je IncludeCaracter
    xor [rbp - 1], 1
    jmp IncludeCaracter
ChangeStatusDouble:
    cmp [rbp - 1], 1
    je IncludeCaracter
    xor [rbp - 2], 1
    jmp IncludeCaracter
Exit:
    mov Byte [rdi + r9], 0
    pop rbp
    ret


global eraseSpaces
eraseSpaces:
    push rbp
    mov rbp, rsp
    sub rbp, 8
    ; rdi must contain the adress of the input buffer
    ; r8 will contain the read adress in the buffer, and r9 the write adress
    mov r8, 0
    mov r9, 0
LoopEraseSpacesRaw:
    mov al, Byte [rdi + r8]
    cmp al, 0
    je ExitSpace
    cmp al, ' '
    je IgnoreEverySpace
    cmp al, 9
    je IgnoreEverySpace
    jmp IncludeCaracterNotSpace
IgnoreEverySpace:
    inc r8
    jmp LoopEraseSpacesRaw
IncludeCaracterNotSpace:
    mov Byte [rdi + r9], al
    inc r8
    inc r9
    jmp LoopEraseSpacesRaw
ExitSpace:
    mov Byte [rdi + r9], 0
    pop rbp
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
    inc rsi
    cmp al, 0
    je ExitDown
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

global print
print:
    push rbx
    ; the string adress must be contained in rdi
    mov rsi, 0
SizeLoop:
    mov al, Byte [rdi + rsi]
    cmp al, 0
    je PrintTheString
    inc rsi
    jmp SizeLoop
PrintTheString:
    ; actually print the string
    mov r8, rdi
    mov rbx, rsi
    mov rax, Sys_write
    mov rdi, STDOUT
    mov rsi, r8
    mov rdx, rbx    
    syscall
    mov rax, Sys_write
    mov rdi, STDOUT
    mov rsi, newLine
    mov rdx, 1
    syscall
    ; exit the function
    pop rbx
    ret

global merge
merge:
    push r12
    push r13
    push r14
    ; rdi must contain the adress of the first input string
    ; rsi must contain the adress of the second input string
    mov r12, rdi
    mov r13, rsi
    mov r9, rsi
    call strlen
    ; r8 contains the len of the first string
    mov r8, rax
    mov rdi, r9
    call strlen
    ; r9 contains the len of the second string
    mov r9, rax
    ; now, call malloc
    mov rdi, r8
    add rdi, r9
    inc rdi
    call malloc
    mov r14, rax
    ; the output string ptr is contained in rax
    mov rdi, r12
    mov rsi, r14
    mov rdx, r8
    call memcpy
    mov rdi, r13
    lea rsi, [r14 + r8]
    mov rdx, r9
    call memcpy
    mov rax, r14
    add rax, r9
    add rax, r8
    mov Byte [rax], 0
    mov rax, r14
    ; now, return rax
    pop r14
    pop r13
    pop r12
    ret 

global strlen
strlen:
    ; the string adress must be contained in rdi
    mov rax, 0
    xor r10, r10
LenLoop:
    mov r10b, Byte [rdi + rax]
    cmp r10b, 0
    je Quitlen
    inc rax
    jmp LenLoop
Quitlen:
    ; len is in rax
    ret

memcpy:
    push r13
    push r12
    ; rdi will contain the input string
    ; rsi will contain the output string
    ; rdx will contain the copy size
    mov r13, 0
CopyLoopXMM:
    sub rdx, 16
    cmp rdx, 0
    jl ContinueSlowCopy
    movups xmm0, oword [rdi + r13]
    movups oword [rsi + r13], xmm0
    add r13, 16
    jmp CopyLoopXMM
ContinueSlowCopy:
    add rdx, 16
    cmp rdx, 8
    jae CopyQWord
    cmp rdx, 4
    jae CopyDWord
    cmp rdx, 2
    jae CopyWord
    cmp rdx, 1
    je CopyByte
    jmp ExitMEMCPY
CopyQWord: 
    mov r12, qWord [rdi + r13]
    mov qWord [rsi + r13], r12
    add r13, 8
    sub rdx, 8
    cmp rdx, 4
    jae CopyDWord
    cmp rdx, 2
    jae CopyWord
    cmp rdx, 1
    je CopyByte
    jmp ExitMEMCPY
CopyDWord:
    mov r12d, dWord [rdi + r13]
    mov dWord [rsi + r13], r12d
    add r13, 4
    sub rdx, 4
    cmp rdx, 2
    jae CopyWord
    cmp rdx, 1
    je CopyByte
    jmp ExitMEMCPY
CopyWord:
    mov r12w, Word [rdi + r13]
    mov Word [rsi + r13], r12w
    add r13, 2
    sub rdx, 2
    cmp rdx, 1
    je CopyByte
    jmp ExitMEMCPY
CopyByte:
    mov r12b, Byte [rdi + r13]
    mov Byte [rsi + r13], r12b
ExitMEMCPY:
    pop r12
    pop r13
    ret

section .rodata
    ; constants
    Sys_write equ 1
    STDOUT equ 1
    ; variables
    helpString db "String parser program, v1.0.0, by @AnisDjerrab. GNU general public lisence v3.0, 2025.", 10
               db "Usage :", 0
    newLine db 10