section .data
    Numbers dq 8956, -99985, 665, 5112, 0
    len db 5
    AsciiNumbers db '+1321', 0, '-744', 0, '+2633', 0, '+744', 0, '-877', 0
    
section .bss
    numbersResultsBuffer resb 100
    AsciiNumbersResultsList resq 5 
section .text
    default rel

    global _start
_start:
    ; first part : convert an INT in ASCII
    ; first, divide the number
    mov cl, byte [len]
    dec cl
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
    ; now, convert a bunch of ASCII numbers into Integers
    mov cl, Byte [len]
    ; r8 will contain the index in 'AsciiNumbers'
    mov r8, 0
    ; r9 will contain the number we're in 
    mov r9, 0
    ; r10b will contain the sign of the number
    mov r10, 0
ConvertionLoop:
    mov r10b, byte [AsciiNumbers + r8]
    inc r8
    xor rax, rax
    mov rbx, 1
    xor r11, r11
    mov r12, rcx
    xor rcx, rcx
PushLoop:
    mov al, byte [AsciiNumbers + r8]
    inc r8
    cmp al, 0
    je PopLoop
    push rax
    inc rcx
    jmp PushLoop
PopLoop:
    pop rax
    sub rax, '0'
    mul rbx
    add r11, rax
    mov rax, 10
    mul rbx
    mov rbx, rax
    loop PopLoop
    ; now, inverse the numbre if negative
    cmp r10b, '-'
    je Negative
    jmp End
Negative:
    neg r11
    jmp End 
End:
    ; now, write the number
    mov qWord [AsciiNumbersResultsList + r9*8], r11
    inc r9
    ; restore rcx
    mov rcx, r12
    loop ConvertionLoop
    ; finally, proprely exit the program
    mov rax, 60
    xor rdi, rdi
    syscall