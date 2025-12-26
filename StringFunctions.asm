; here is a reimplementation of some core C functions, in addition to custom ones.

printf:
    push rbp 
    mov rbp, rsp
    push rbx

    ; the string adress must be contained in rcx
    mov rsi, 0
    xor r10, r10
SizeLoop:
    mov al, Byte [rcx + rsi]
    cmp al, 0
    je PrintTheString
    inc rsi
    inc r10
    jmp SizeLoop
PrintTheString:
    ; actually print the string
    mov rbx, rsi
    mov rax, 1
    mov rdi, 1
    mov rsi, rcx
    mov rdx, rbx
    syscall
QuitPrint:
    ; exit the function
    pop rbx
    pop rbp
    ret


strcpy:
    push rbp
    mov rbp, rsp

    ; rcx must contain the input string adress
    ; rdx must contain the output string adress
    mov rsi, 0
CopyLoop:
    mov al, Byte [rcx + rsi]
    mov Byte [rdx + rsi], al
    cmp al, 0
    je Exitcpy
    inc rsi
Exitcpy:
    pop rbp
    ret


strlen:
    push rbp 
    mov rbp, rsp

    ; the string adress must be contained in rcx
    mov rax, 0
    xor r10, r10
LenLoop:
    mov r10b, Byte [rcx + rax]
    cmp r10b, 0
    je Quitlen
    inc rax
    jmp LenLoop
Quitlen:
    ; len is in rax
    pop rbp
    ret


strcmp:
    push rbp
    mov rbp, rsp
    push rbx

    ; rcx must contain the adress of the first string
    ; rdx must contain the adress of the second string
    mov rsi, 0
CompareLoop:
    mov al, Byte [rcx + rsi]
    mov bl, Byte [rdx + rsi]
    cmp al, 0
    je Exit
    cmp bl, 0
    je Exit
    cmp al, bl
    jne Exit
    inc rsi
    jmp CompareLoop
Exit:
    cmp al, bl
    ja ReturnBigger
    jb ReturnSmaller
    je ReturnEqual
ReturnBigger:
    mov rax, 1
    pop rbx
    pop rbp
    ret
ReturnSmaller:
    mov rax, -1
    pop rbx
    pop rbp
    ret
ReturnEqual:
    mov rax, 0
    pop rbx
    pop rbp
    ret

; a variant of strcmp which supports token comparison while keeping the original behavior of strcmp
strcmp_spc:
    push rbp
    mov rbp, rsp
    push rbx

    ; rcx must contain the adress of the first string
    ; rdx must contain the adress of the second string
    mov rsi, 0
CompareLoopToken:
    mov al, Byte [rcx + rsi]
    mov bl, Byte [rdx + rsi]
    cmp al, 0
    je ExitToken
    cmp al, ' '
    je InterAl
    cmp bl, 0
    je ExitToken
    cmp bl, ' '
    je InterBl
    cmp al, bl
    jne ExitToken
    inc rsi
    jmp CompareLoop
InterAl:
    mov al, 0
    jmp ExitToken
InterBl:
    mov bl, 0
    jmp ExitToken
ExitToken:
    cmp al, bl
    ja ReturnBiggerToken
    jb ReturnSmallerToken
    je ReturnEqualToken
ReturnBiggerToken:
    mov rax, 1
    pop rbx
    pop rbp
    ret
ReturnSmallerToken:
    mov rax, -1
    pop rbx
    pop rbp
    ret
ReturnEqualToken:
    mov rax, 0
    pop rbx
    pop rbp
    ret


UP:
    push rbp
    mov rbp, rsp

    ; rcx must contain the adress of the string
    mov rsi, 0
UpLoop:
    mov al, Byte [rcx + rsi]
    inc rsi
    cmp al, 'a'
    jae SecondConditionUp
    cmp al, 0
    je ContinueUp
    jmp UpLoop
SecondConditionUp:
    cmp al, 'z'
    jbe decrementValue
    jmp UpLoop
decrementValue:
    sub al, 32
    dec rsi
    mov Byte [rcx + rsi], al
    inc rsi
    jmp UpLoop
ContinueUp:

    pop rbp
    ret


DOWN:
    push rbp
    mov rbp, rsp

    ; rcx must contain the adress of the string
    mov rsi, 0
DownLoop:
    mov al, Byte [rcx + rsi]
    inc rsi
    cmp al, 'A'
    jae SecondConditionDown
    cmp al, 0
    je ContinueDown
    jmp DownLoop
SecondConditionDown:
    cmp al, 'z'
    jbe incrementValue
    jmp DownLoop
incrementValue:
    add al, 32
    dec rsi
    mov Byte [rcx + rsi], al
    inc rsi
    jmp DownLoop
ContinueDown:

    pop rbp
    ret


sprintf:
    push rbp
    mov rbp, rsp
    push rbx

    ; r8 must contain the input number
    ; r9 must contain the adress of the output string 
    ; r10 will contain the index in the result buffer
    xor r10, r10
    xor r11, r11
    mov rax, r8
    shr rax, 63
    cmp rax, 1
    je NegativeNumber
    jmp PositiveNumber
NegativeNumber:
    mov byte [r9 + r11], '-'
    inc r11
    mov rax, r8
    neg rax
    jmp DivideLoop
PositiveNumber:
    mov rax, r8
    jmp DivideLoop
DivideLoop:
    mov rbx, 10
    xor rdx, rdx
    div rbx
    push rdx
    inc r11
    cmp rax, 0
    jne DivideLoop
Between:
    mov rcx, r11
    xor r10, r10
    ; now, Write the caracters one by one in the buffer
WriteInAsciiLoop:
    pop rdx
    add rdx, '0'
    mov byte [r9 + r10], dl
    inc r10
    loop WriteInAsciiLoop
    ; finally, write the final 0
    mov byte [r9 + r10], 0
    ; exit the function
    pop rbx
    pop rbp
    ret