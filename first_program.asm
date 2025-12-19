; first program in asm, mainly focused on basic ALU operations.
section .data
    ByteVariable1 db 11
    ByteVariable2 db -33
    WordVariable1 dw 5
    WordVariable2 dw 71
    dWordVariable1 dd -651
    dWordVariable2 dd 44
    qWordVariable1 dq 8112
    qWordVariable2 dq -9920
section .bss
    bAddResult resb 1
    wSubResult resw 1
    dDivResult resd 1
    qMulResult resq 1
    RegResult1 resq 1
    RegResult2 resq 1
    RegResult3 resq 1
    RegResult4 resq 1
    RegResult5 resq 1
section .text
    default rel

    global _start
_start:
    ; add two Bytes
    mov al, byte [ByteVariable1]
    add al, byte [ByteVariable2]
    mov byte [bAddResult], al
    ; sub two Words
    mov ax, word [WordVariable1]
    sub ax, word [WordVariable2]
    mov word [wSubResult], ax
    ; div two double words
    mov eax, dWord [dWordVariable1]
    cdq
    mov ebx, dWord [dWordVariable2]
    idiv ebx
    mov dWord [dDivResult], eax
    ; Multiply two quad words
    mov rax, qWord [qWordVariable1]
    mov rbx, qWord [qWordVariable2]
    imul rbx
    imul rax, rbx ; same
    mov qWord [qMulResult], rax
    ; mov different register's values between each other
    mov eax, -55
    mov rbx, 99
    mov dl, -3
    mov rcx, 5
    ; mov dl in rbx
    ; movsx signed, movzx unsigned
    movsx rbx, dl
    mov qWord [RegResult1], rbx
    ; mov eax in rbx
    movsxd  rbx, eax
    mov qWord [RegResult2], rbx
    ; shift to the left
    shl rcx, 1
    mov qWord [RegResult3], rcx
    ; sift to the right
    shr rcx, 1 
    mov qWord [RegResult4], rcx
    ; rotate
    ror rcx, 3
    mov qWord [RegResult5], rcx 

    mov rax, 60
    xor rdi, rdi
    syscall 