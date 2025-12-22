section .data
    Numbers dq 8956, -99985, 665, 5112, 0
    len db 5
section .bss
    numbersResultsBuffer resb 100
section .text
    default rel

    global _start
_start:
    ; first part : convert an INT in ASCII
    ; first, divide the number
    mov cl, byte [len]
    ; r8 will contain the index in the Result Buffer
    mov r8, 0
    ; r9 will contain the index in the Numbers list
    mov r9, 0
BigLoop:
    xor rsi, rsi
    ; first : get the sign of the number
    mov rax, qWord [Numbers + r9*8]
    shr rax, 63
    cmp rax, 1
    je NegativeNumber
    jmp PositiveNumber
NegativeNumber:
    mov byte [numbersResultsBuffer + r8], '-'
    inc r8
    mov rax, qWord [Numbers + r9*8]
    neg rax
    jmp DivideLoop
PositiveNumber:
    mov byte [numbersResultsBuffer + r8], '+'
    inc r8
    mov rax, qWord [Numbers + r9*8]
    jmp DivideLoop
DivideLoop:
    mov rbx, 10
    xor rdx, rdx
    div rbx
    push rdx
    inc rsi
    cmp rax, 0
    jne DivideLoop
Between:
    ; save rcx in r10 to be recovered later
    mov r10, rcx
    mov rcx, rsi
    ; now, Write the caracters one by one in the buffer
WriteInAsciiLoop:
    pop rdx
    add rdx, '0'
    mov byte [numbersResultsBuffer + r8], dl
    inc r8
    loop WriteInAsciiLoop
    ; finally, write the final \n
    mov byte [numbersResultsBuffer + r8], 10
    inc r8
    mov rcx, r10
    inc r9
    cmp rcx, 0
    je Continue
    dec rcx
    jmp BigLoop
Continue: