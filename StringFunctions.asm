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
    je ReturnSize
    inc rsi
    inc r10
PrintTheString:
    ; actually print the string
    mov rax, 1
    mov rbx, 1
    mov rsi, rcx
    mov rdx, 10
    syscall
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
    je Exit
    inc rsi
Exit:
    pop rbp
    ret


strlen:
    push rbp 
    mov rbp, rsp

    ; the string adress must be contained in rcx
    mov rsi, 0
    xor r10, r10
LenLoop:
    mov r10b, Byte [rcx + rsi]
    cmp r10b, 0
    je Quit
    inc rsi
    inc rax
Quit:
    ; len is in rax
    pop rbp
    ret


strcmp:
    push rbp
    mov rbp, rsp

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
    jne Return
    inc rsi
Exit:
    cmp al, bl
    je ReturnEqual
    ja ReturnBigger
    jb ReturnSmaller
ReturnBigger:
    mov rax, 1
    pop ebp
    ret
ReturnSmaller:
    mov rax, -1
    pop ebp
    ret
ReturnEqual:
    mov rax, 0
    pop ebp
    ret


UP:
    push rbp
    mov rbp, rsp

    ; rcx must contain the adress of the string
    mov rsi, 0
UpLoop:
    mov al, Byte [rcx + rsi]
    cmp al, 'a'
    jae SecondConditionUp
    jmp ContinueUp
SecondConditionUp:
    cmp al, 'z'
    jbe incrementValue
    jmp ContinueUp
incrementValue:
    add al, 32
    mov Byte [rcx + rsi], al
ContinueUp:
    cmp al, 0
    jne UpLoop
    inc rsi

    pop rbp
    ret


DOWN:
    push rbp
    mov rbp, rsp

    ; rcx must contain the adress of the string
    mov rsi, 0
DownLoop:
    mov al, Byte [rcx + rsi]
    cmp al, 'A'
    jae SecondConditionDown
    jmp ContinueDown
SecondConditionDown:
    cmp al, 'Z'
    jbe decrementValue
    jmp ContinueDown
decrementValue:
    dec al, 32
    mov Byte [rcx + rsi], al
ContinueDown:
    cmp al, 0
    jne UpLoop
    inc rsi

    pop rbp
    ret


