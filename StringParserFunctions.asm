; this contains a bunch of functions used in the StringParser program
default rel
section .text

global help
extern malloc
help:
    ; copy the string
    mov rdi, 2046
    call malloc
    ; returns adress in rax
    mov rcx, 2032
    mov rdi, 2046
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

global nwLine
nwLine:
    ; rax will contain the adress of the output char*
    mov rdi, 2
    call malloc
    mov Byte [rax], 10
    mov Byte [rax + 1], 0
    ret

global input
input:
    push r12
    push r13
    ; rdi must contain the adress of the input char*
    ; get it's len
    mov r12, rdi
    call strlen
    mov r13, rax
    ; print it
    mov rax, Sys_write
    mov rdi, STDOUT
    mov rsi, r12
    mov rdx, r13
    syscall
    ; new, get an input 
    mov rdi, 4096
    call malloc
    mov r8, rax
    mov rax, Sys_read
    mov rdi, STDIN
    mov rsi, r8
    mov rdx, 4096
    syscall
    cmp rax, 0
    jbe return
    ; now, erase the final \n
    dec rax
    mov Byte [r8 + rax], 0
    mov rax, r8
return:
    pop r13
    pop r12
    ret

global trim
trim:
    push r12
    push r13
    ; the input string adress must be contained in rdi
    mov r12, rdi
    mov r13, 0
readSpacesLoopBeginning:
    mov al, Byte [rdi + r13]
    cmp al, ' '
    jne ContinueSpacesAtTheEnd
    inc r13
    jmp readSpacesLoopBeginning
ContinueSpacesAtTheEnd:
    ; now, the size of the slip is contained in r13
    ; get it's size
    mov rdi, r12
    call strlen
    mov r9, rax
    cmp rax, 0
    je ExitTrim
    ; now, slip
    cmp r13, 0
    je BeforeSpacesLoopEnd
    mov r8, r12
    add r8, r13
    mov rsi, 0
SlipLoop:
    mov al, Byte [r8 + rsi]
    mov Byte [r12 + rsi], al
    inc rsi
    dec r9
    cmp r9, 0
    jbe BeforeSpacesLoopEnd
    jmp SlipLoop
BeforeSpacesLoopEnd:
    mov rdi, r12
    call strlen
    mov rcx, rax
    dec rcx
readSpacesLoopEnd:
    cmp Byte [rdi + rcx], ' '
    jne ExitTrim
    mov Byte [rdi + rcx], 0
    loop readSpacesLoopEnd
ExitTrim:
    pop r13
    pop r12
    ret

global checkNumber
checkNumber:
    push r12
    ; rdi must contain the adress of the input string
    mov r12, rdi
    call strlen
    mov rcx, rax
    mov rsi, 0
    mov rax, 0
    cmp rcx, 0
    je ExitCheck
    cmp Byte [r12 + rsi], '-'
    je IgnoreSign
    cmp Byte [r12 + rsi], '+'
    je IgnoreSign
loopCheck:
    mov dl, Byte [r12 + rsi]
    cmp dl, 0
    je ExitCheck
    cmp dl, '0'
    jb NotANumber
    cmp dl, '9'
    ja NotANumber
    inc rsi
    mov rax, 1
    loop loopCheck
    jmp ExitCheck
IgnoreSign:
    inc rsi
    dec rcx
    cmp rcx, 0
    je ExitCheck
    jmp loopCheck
NotANumber:
    mov rax, 0
ExitCheck:
    pop r12
    ret

global Addition
Addition:
    push r12
    push r13
    push r14
    ; rdi must contain the adress of the first number
    ; rsi must contain the adress of the second number
    mov r13, rsi
    call strtol
    mov r12, rax
    mov rdi, r13
    call strtol
    mov r13, rax
    mov r14, r12
    add r14, r13
    ; now, the result is contained in r14
    mov rdi, 32
    call malloc
    mov rdi, r14
    mov rsi, rax
    call sprintf
    mov rax, rsi
    ; now, return
    pop r14
    pop r13
    pop r12
    ret

global Subtraction
Subtraction:
    push r12
    push r13
    push r14
    ; rdi must contain the adress of the first number
    ; rsi must contain the adress of the second number
    mov r13, rsi
    call strtol
    mov r12, rax
    mov rdi, r13
    call strtol
    mov r13, rax
    mov r14, r12
    sub r14, r13
    ; now, the result is contained in r14
    mov rdi, 32
    call malloc
    mov rdi, r14
    mov rsi, rax
    call sprintf
    mov rax, rsi
    ; now, return
    pop r14
    pop r13
    pop r12
    ret

global Multiplication
Multiplication:
    push r12
    push r13
    push r14
    ; rdi must contain the adress of the first number
    ; rsi must contain the adress of the second number
    mov r13, rsi
    call strtol
    mov r12, rax
    mov rdi, r13
    call strtol
    mov r13, rax
    mov r14, r12
    imul r14, r13
    ; now, the result is contained in r14
    mov rdi, 32
    call malloc
    mov rdi, r14
    mov rsi, rax
    call sprintf
    mov rax, rsi
    ; now, return
    pop r14
    pop r13
    pop r12
    ret

global Division
Division:
    push r12
    push r14
    ; rdi must contain the adress of the first number
    ; rsi must contain the adress of the second number
    mov r13, rsi
    call strtol
    mov r12, rax
    mov rdi, r13
    call strtol
    mov r14, rax
    mov rax, r12
    cqo
    cmp r14, 0
    je MallocDiv
    idiv r14
    mov r14, rax
    ; now, the result is contained in r14
MallocDiv:
    mov rdi, 32
    call malloc
    mov rdi, r14
    mov rsi, rax
    call sprintf
    mov rax, rsi
    ; now, return
    pop r14
    pop r12
    ret 

global asm_strcmp
asm_strcmp:
    push rbx

    ; rdi must contain the adress of the first string
    ; rsi must contain the adress of the second string
    mov rcx, 0
CompareLoop:
    mov al, Byte [rdi + rcx]
    mov bl, Byte [rsi + rcx]
    cmp al, 0
    je ExitCompareLoop
    cmp bl, 0
    je ExitCompareLoop
    cmp al, bl
    jne ExitCompareLoop
    inc rcx
    jmp CompareLoop
ExitCompareLoop:
    cmp al, bl
    ja ReturnBigger
    cmp al, bl
    jb ReturnSmaller
    cmp al, bl
    je ReturnEqual
ReturnBigger:
    mov rdi, 7
    call malloc
    mov ebx, dWord [Bigger]
    mov dWord [rax], ebx
    mov bx, Word [Bigger + 4]
    mov Word [rax + 4], bx
    mov bl, Byte [Bigger + 6]
    mov Byte [rax + 6], bl
    pop rbx
    ret
ReturnSmaller:
    mov rdi, 8
    call malloc
    mov rbx, qWord [Smaller]
    mov qWord [rax], rbx 
    pop rbx
    ret
ReturnEqual:
    mov rdi, 6
    call malloc
    mov ebx, dWord [equal]
    mov dWord [rax], ebx
    mov bx, Word [equal + 4]
    mov Word [rax + 4], bx
    pop rbx
    ret



global eraseSpacesExceptApostrophies
eraseSpacesExceptApostrophies:
    push rbp
    mov rbp, rsp
    sub rsp, 8
    ; local variable [rbp - 8] will be a bool InParenthesisSimple
    mov Byte [rbp - 8], 0
    ; local variable [rbp - 7] will be a bool InParenthesisDouble
    mov Byte [rbp - 7], 0
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
    cmp Byte [rbp - 8], 1
    je IncludeCaracter
    cmp al, '"'
    je ChangeStatusDouble
    cmp Byte [rbp - 7], 1
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
    cmp Byte [rbp - 7], 1
    je IncludeCaracter
    xor Byte [rbp - 8], 1
    jmp IncludeCaracter
ChangeStatusDouble:
    cmp Byte [rbp - 8], 1
    je IncludeCaracter
    xor Byte [rbp - 7], 1
    jmp IncludeCaracter
Exit:
    mov Byte [rdi + r9], 0
    add rsp, 8
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



global up
up:
    ; this function make a string non-case sensitive
    ; rdi must contain the adress of the input string
    mov rsi, 0
upLoop:
    mov al, Byte [rdi + rsi]
    cmp al, 'a'
    jae MaybeModifyLetterUp
    inc rsi
    cmp al, 0
    je ExitUp
    jmp upLoop
MaybeModifyLetterUp:
    cmp al, 'z'
    jbe ModifyLetterUp
    inc rsi
    jmp upLoop
ModifyLetterUp:
    sub al, 32
    mov Byte [rdi + rsi], al
    inc rsi
    jmp upLoop
ExitUp:
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
    cmp rdi, 0
    je ExitPrint
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
ExitPrint:
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

global strlen_spc
strlen_spc:
    push r13
    push r12
    ; the string adress must be contained in rdi
    call strlen
    ; now, rax contains the len of the string
    ; it'll be converted in string by calling sprintf
    mov r12, rax
    mov rdi, 20
    call malloc
    mov r13, rax
    mov rdi, r12
    mov rsi, rax
    call sprintf
    mov rax, r13
    pop r12
    pop r13
    ret

sprintf:
    push rbp
    mov rbp, rsp
    push rbx

    ; rdi must contain the input number
    ; rsi must contain the adress of the output string 
    xor r10, r10
    xor r11, r11
    mov rax, rdi
    shr rax, 63
    cmp rax, 1
    je NegativeNumber
    jmp PositiveNumber
NegativeNumber:
    mov byte [rsi + r10], '-'
    inc r10
    mov rax, rdi
    neg rax
    jmp DivideLoop
PositiveNumber:
    mov rax, rdi
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
    ; now, Write the caracters one by one in the buffer
WriteInAsciiLoop:
    pop rdx
    add rdx, '0'
    mov byte [rsi + r10], dl
    inc r10
    loop WriteInAsciiLoop
    ; finally, write the final 0
    mov byte [rsi + r10], 0
    mov rax, rsi
    ; exit the function
    pop rbx
    pop rbp
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

strtol:
    push rbp
    mov rbp, rsp
    sub rsp, 8
    push rbx

    ; rdi must contain the input string adress
    ; r8 will contain the index in the rdi string
    mov r8, 0
    xor rax, rax
    xor rbx, rbx
    mov Byte [rbp - 8], 0
    cmp Byte [rdi], '+'
    je UpdatePositive
    cmp Byte [rdi], '-'
    je UpdateNegative
ConvertLoop:
    mov bl, Byte [rdi + r8]
    cmp bl, 0
    je WriteBinaryNumber
    sub bl, '0'
    imul rax, 10
    add rax, rbx
    inc r8
    jmp ConvertLoop
WriteBinaryNumber:
    ; now, write the number
    cmp Byte [rbp - 8], 1
    je NegateNumber

    add rsp, 8
    pop rbx
    pop rbp
    ret
UpdatePositive:
    inc rdi
    jmp ConvertLoop
UpdateNegative:
    inc rdi
    mov Byte [rbp - 8], 1
    jmp ConvertLoop
NegateNumber:
    neg rax
    add rsp, 8
    pop rbx
    pop rbp
    ret
ExitError:
    mov rax, -1
    add rsp, 8
    pop rbx
    pop rbp
    ret

section .rodata
    ; constants
    Sys_read equ 0
    Sys_write equ 1
    STDIN equ 0
    STDOUT equ 1
    ; variables
    helpString db "String parser program, v1.0.0, by @AnisDjerrab. GNU general public license v3.0, 2025.", 10
               db "This a quit advanced programming language prototype, with complete parsing, tokenisation, tree creation, and support for nested structures. it's also case-insensitive.", 10
               db "Here, evrything's a string. even numbers. so everything must be '' or ", 34, " ", 34, ", and both of them have exactly the same purpose.", 10
               db "Usage :", 10
               db "  * basic commands *", 10
               db "   q|quit : quit the program.", 10
               db "   h|help : display this help utility.", 10
               db "  * functions *", 10
               db "   help() => <helpUtility> : returns this help utility string.", 10
               db "   eraseSpaces(<arg>) => <argWithoutSpaces> : remove all spaces from a string.", 10
               db "   down(<arg>) => <argWithAllCaractersDown> : convert all characters to lowercase.", 10
               db "   up(<arg>) => <argWithAllCaractersUp> : convert all characters to uppercase.", 10
               db "   merge(<arg1>, <arg2>) => <mergeArgs> : concatenates two args.", 10
               db "   trim(<arg>) => <argWithoutSpacesAtTheBeginningOrEnd> : remove all spaces at the beginning and end.", 10
               db "   strcmp(<arg1>, <arg2>) => <result> : returns if arg1 is bigger, smaller, or equal, compared to arg2.", 10
               db "   print(<arg>) => <void> : outputs a message on the screen.", 10
               db "   input(<args>) => <enteredMessage> : outputs a message on the screen and gets user input.", 10
               db "   newLine() => <newLine> : returns a newline character.", 10
               db "   strlen(<arg>) => <lenOfTheArg> : returns the string-converted len of the arg.", 10
               db "   add(<num1>, <num2>) => <sumOfTheTwoNumber> : converts the two numbers in integer, do the addition, and converted the result back.", 10
               db "   sub(<num1>, <num2>) => <num1MinusNum2> : converts the two numbers in integer, do the subtraction, and converted the result back.", 10
               db "   mul(<num1>, <num2>) => <num1MultipliedByNum2> : converts the two numbers in integer, do the multiplication, and converted the result back.", 10
               db "   div(<num1>, <num2>) => <num1DividedByNum2> : converts the two numbers in integer, do the division, and converted the result back.", 10
               db "  * examples *", 10
               db "   >> up(merge('the message entered is : ', input('enter anything : ')))", 10
               db "   >> ADD(strlen ( 'a message' ), sub ( '-12', '14' ) ) ", 0
    newLine db 10
    Smaller db "smaller", 0
    Bigger db "bigger", 0
    equal db "equal", 0