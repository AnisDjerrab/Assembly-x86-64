section .data
    words db 'radar',0,'level',0,'rotor',0,'civic',0,'kayak',0,'table',0,'computer',0,'window',0,'elephant',0
    len dq 9
section .bss
    PalindromeWords resb 100
    NormalWord resb 20
    InversedWord resb 20
section .text
    default rel

    global _start
_start:
    mov rcx, qword [len]
    ; r8 will be the number of letter in a single word
    mov r8, 0
    ; r9 will be the index in the list
    mov r9, 0
    ; r11 will be the index in the Palinfrome words list
    mov r11, 0
BigLoop:   
    ; first find the word
InsideLoop:
    cmp byte [words + r9], 0
    je Continue
    mov al, byte [words + r9]
    mov byte [NormalWord + r8], al
    inc r8
    inc r9
    jmp InsideLoop
Continue:
    inc r9
    mov r10, rcx
    mov rcx, r8
    mov rsi, 0
LoopPush:
    movzx ax, byte [NormalWord + rsi]
    push ax
    inc rsi
    loop LoopPush
    ; end of loop
    mov rcx, r8
    mov rsi, 0
LoopPop:
    pop ax
    mov byte [InversedWord + rsi], al
    inc rsi
    loop LoopPop
    ; end of loop
    mov rcx, r8
    inc rcx
    mov rsi, 0
    ; now, compare
CompareLoop:
    mov al, byte [NormalWord + rsi]
    cmp al, byte [InversedWord + rsi]
    jne Return 
    inc rsi
    loop CompareLoop
    ; add the word to the Palindrome group 
    mov rcx, r8
    mov rsi, 0
PalindromeLoop:
    mov al, byte [NormalWord + rsi]
    mov byte [PalindromeWords + r11], al
    inc rsi
    inc r11
    loop PalindromeLoop
    ; add the final \0
    mov byte [PalindromeWords + r11], 0
    inc r11
Return:
    mov rcx, r10
    mov r8, 0
    cmp rcx, 0
    je Exit
    dec rcx 
    jmp BigLoop
Exit:
    mov rax, 60
    xor rdi, rdi
    syscall



