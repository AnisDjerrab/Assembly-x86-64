section .data
    ; constants
    Width equ 1000
    Hight equ 1000
    BytesInPixel equ 3
    NumberOfThreads equ 5
    maxStackSize equ 65536
    CLONE_VM equ 0x00000100	
    CLONE_FS equ 0x00000200	
    CLONE_FILES equ 0x00000400	
    CLONE_SIGHAND equ 0x00000800	
    CLONE_THREAD equ 0x00010000	
    CLONE_SYSVSEM equ 0x00040000
    ; variables
    FinishedCounter db 0
section .bss
    combinedStacks resb maxStackSize*5
    ValuesBufferOld resq (Width+1)*(Hight+1)
    ValuesBufferNew resq (Width+1)*(Hight+1)
    PixelBuffer resq Width*Hight*BytesInPixel
section .text
    default rel

    global _main
_main:
MainCalculationLoop:
    ; launch the threads one by one 
    mov rcx, NumberOfThreads
    mov r10, 8
    mov r11, maxStackSize
loopLauchThreads:
    ; call linux to lauch a new fork
    mov rax, 56
    mov rdi, CLONE_FILES | CLONE_FS | CLONE_SIGHAND | CLONE_SYSVSEM | CLONE_THREAD | CLONE_VM
    lea rsi, [combinedStacks + r11 + maxStackSize]
    xor rdx, rdx
    xor r8, r8
    syscall
    cmp rax, 0
    je CalculationThread
    ; now, increment what must be incremented before the next syscall
    add r11, maxStackSize
    add r10, 1600
    dec rcx
    cmp rcx, 0
    jne loopLauchThreads
    jmp MainCalculationLoop
    ; exit the program
    mov rax, 60
    xor rdi, rdi
    syscall

CalculationThread:
    ; r10 contains the x value of the pixel
    ; we assume the material is iron -> α = 2.3e-5 m2/s
    ; we assume Δt = 1/60 s
    ; we assume Spixels = 1 cm²
    ; that gives us T_new​(x,y) = T_old​(x,y) + α * Δt * neighbours ∑​ T_neghbours − T_old​(x,y) / d2​
    ; rsi contains the value on X, rdi contains the value on Y
    mov rsi, r10
    mov rcx, 1600
    mov rax, qWord [FinishedCounter]
    inc rax
    mov qWord [FinishedCounter], rax
CalculationXLoop:
    xor rdi, rdi
    ; r11 will contain the loop register
    mov r11, 1001
    ; r12 & r13 will contain the adress keeper
    mov r12, ValuesBufferOld
    mov r13, ValuesBufferNew
CalculationYLoop:
    ; now, do the math
    ; first : calculate the cumulated value of neighbours
    mov rbx, r12
    add rbx, rsi
    ; direct neighbours -- we take them as they are
    movsd xmm0, qWord [rbx + 8]
    movsd xmm1, qWord [rbx - 8]
    movsd xmm2, qWord [rbx + 8016]
    movsd xmm3, qWord [rbx - 8016]
    movsd xmm4, qWord [r12 + rsi]
    addsd xmm0, xmm1
    addsd xmm0, xmm2
    addsd xmm0, xmm3
    movsd xmm2, 4
    mulsd xmm4, xmm2
    subsd xmm0, xmm4
    ; undirect neighbours -- add them * 1 / sqrt(2)
    movsd xmm3, qWord [rbx - 8008]
    movsd xmm5, qWord [rbx - 8024]
    movsd xmm6, qWord [rbx + 8008]
    movsd xmm7, qWord [rbx + 8024]
    addsd xmm3, xmm5
    addsd xmm3, xmm6
    addsd xmm3, xmm7
    subsd xmm3, xmm4
    movsd xmm2, 2
    movsd xmm1, 1
    sqrtsd xmm2, xmm2
    divsd xmm1, xmm2
    mulsd xmm3, xmm1
    ; add them all
    add xmm0, xmm3
    movsd xmm1, qWord  [r12 + rsi]
    movsd xmm2, 0.0166666666667
    movsd xmm3, 0.001
    movsd xmm4, 0.000023
    addsd xmm4, xmm2
    mulsd xmm3, xmm3
    divsd xmm4, xmm3
    mulsd xmm4, xmm0
    addsd xmm4, xmm0
    ; verify that it's not equal
    ucomisd xmm0, xmm4
    jne ModifyValue
BackInTheLoop:
    add r12, 1001
    add r13, 1001
    dec r11
    cmp r11, 0
    jne CalculationYLoop
    ; loop again
    add rsi, 8
    sub rcx, 8
    cmp rcx, 0
    je ExitThread
    jmp CalculationXLoop
ModifyValue:
    movsd qWord [r13 + rsi], xmm4
    movsd xmm0, 0
    movsd xmm1, 0
    ucomisd xmm4, 700
    ja IncrementBlue
BackBlue:
    movsd xmm2, 1
    addsd xmm2, 273
    divsd xmm2, 1273
    mov xmm3, 1
    subsd xmm3, xmm2
    movsd xmm4, xmm3
    mulsd xmm4, xmm3
    movsd xmm5, xmm4
    mulsd xmm4, xmm4
    mulsd xmm4, xmm5
    movsd xmm3, 1
    subsd xmm3, xmm4
    movsd xmm2, xmm3
    jmp IncrementGreen
BackGreen:
    mov rbx, r13
    add rbx, rsi
    imul rbx, 3
    movsd qWord [rbx], xmm2
    movsd qWord [rbx + 8], xmm1
    movsd qWord [rbx + 16], xmm0
    jmp BackInTheLoop
IncrementBlue:
    movsd xmm0, xmm4
    movsd xmm1, 700
    subsd xmm0, xmm1
    movsd xmm1, 300
    divsd xmm0, xmm1
    mulsd xmm0, xmm0
    jmp BackBlue
IncrementGreen:
    movsd xmm1, xmm0
    jmp BackGreen
ExitThread:
    mov rax, 60
    xor rdi, rdi
    syscall