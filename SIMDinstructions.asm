; this is a program to test a large amount of native CPU simd instructions
section .data
    float32List dd 0.2, -3.33, 4.85, 9.11, 47.01, -94.58
    float64List dq 85512.511, -884.111, 0.555, 6.874, -54.322, -1.1
    x32Number dd 0.512
    x64Number dq 6458.222
section .bss
section .text
    global _start:
_start:
    ; first, loop to process 32 bit values
    mov rcx, 6
    mov rsi, 0
x32Loop:
    movss xmm0, [float32List + rsi]
    ; convert it in x64 float
    cvtss2sd xmm1, xmm0
    ; convert it in integer
    ; cvtss2si perfrorms rounding, cvttss2si does not.
    ; 32 or 64 bit distination register
    cvtss2si rax, xmm0
    cvttss2si ebx, xmm0
    ; now, convert an integer to a x32 float
    ; 32 bit value
    cvtsi2ss xmm2, ebx
    ; move the x32 number in xmm3
    movss xmm3, [x32Number]section .text
    ; now, do addition
    movss xmm4, xmm0
    addss xmm4, xmm3
    ; do substraction
    movss xmm4, xmm0
    subss xmm4, xmm3
    ; do multiplication
    movss xmm4, xmm0
    mulss xmm4, xmm3
    ; do division
    movss xmm4, xmm0
    divss xmm4, xmm3
    ; finally, x32 float square root
    sqrtss xmm4, xmm4
    ; now, do a couple of control instructions over xmm0
    ucomiss xmm0, 0
    je 0 ; -> crash : won't happen because xmm0 NEVER equals 0
    ; and all the other operations are juset as they are in traditional assembly (ja, jb, jbe, jne, jae...)
    add rsi, 4
    loop x32Loop