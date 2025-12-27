section .data
    ; constants
    Sys_read equ 0
    Sys_write equ 1
    Sys_open equ 2
    sys_lseek equ 8
    Sys_exit equ 60
    STDIN equ 0
    STDOUT equ 1
    SEEKSET equ 0
    SEEKEND equ 0
    O_RDWR equ 2
    O_CREAT equ 0x40
    ; variables
    WelcomeMessage db "Welcome to the password management program !", 10, "Type 'help' to list avalaible commands.", 10, 0
    Prompt db ">> ", 0
    newLine db 10, 0
    FileNameDefault db "password.txt", 0
    FileDescriptor dq 0
    helpCommand db "help", 0
    helpMessage db "Password Management program, v1.0.0, by @AnisDjerrab. GNU general public lisence version 3.0, 2025.", 10
                db "Usage :", 10
                db "   help : print the utility.", 10
                db "   list : list all passwords and their name.", 10
                db "   delete <--number x>|<name name_of_the_password> : erase a password entry.", 10
                db "   add <--password|-p max_size_20_Bytes> <-n|--name max_size_40_Bytes> : add a new password entry.", 10
                db "   clear : clears all previously defined passwords.", 10
                db "   set </path/to/file>|<file> : defines the output file.", 10  
                db "   q|quit : quit this program.", 10
                db "Thank's for supporting my work!", 10, 0
    listCommand db "list", 0
    listText db "The number of passwords stored is : ", 0
    eraseCommand db "delete", 0
    addCommand db "add", 0
    clearCommand db "clear", 0
    setCommand db "set", 0
    qCommand db "q", 0
    quitCommand db "quit", 0
    errorOverflow db "error : user input max size overflow.", 10, 0
    BeginningYear dq 1970
    Years dq 0
    Months dq 0
    Days dq 0
    Hours dq 0
    Minutes dq 0
    Seconds dq 0
    MonthsOfTheYear db 31,28,31,30,31,30,31,31,30,31,30,31
    headerBuffer db "number of passwords set: 0", 0, "                  ", 10, "at [    /  /     :  :  ]"
section .bss
    command resb 1024
    char resb 1
    fileName resb 512
    fileBuffer resb 7070
    numberOfEntries resq 1
    maxNumberSize resb 20
section .text
    default rel

    global _start
_start:
    ; print the Welcome message 
    mov rcx, WelcomeMessage
    call printf
    ; set file name to default
    mov rcx, FileNameDefault
    mov rdx, fileName
    call strcpy
    ; open the file
    mov rax, Sys_open
    mov rdi, fileName
    mov rsi, O_CREAT | O_RDWR
    syscall
    mov qWord [FileDescriptor], rax
    ; get file size
    mov rax, sys_lseek
    mov rdi, qWord [FileDescriptor]
    mov rsi, 0
    mov rdx, SEEKEND
    syscall
    ; create minimal structure if not present
    cmp rax, 70
    jb createFileStructure
    jmp BigLoop
createFileStructure:
    call GenerateHeader
    ; seek to position 0
    mov rax, sys_lseek
    mov rdi, qWord [FileDescriptor]
    mov rsi, 0
    mov rdx, SEEKSET
    syscall
    ; write the header buffer
    mov rax, Sys_write
    mov rdi, qWord [FileDescriptor]
    mov rsi, headerBuffer
    mov rdx, 70
    syscall 

BigLoop:
    ; print the prompt
    mov rcx, Prompt
    call printf
    mov r12, 0
    mov rax, Sys_read
    mov rdi, STDIN
    mov rsi, command
    mov rdx, 1024
    syscall
    mov r12, 0
    mov rcx, 1024
ConvertInClikeString:
    mov al, Byte [command + r12]
    cmp al, 10
    je ExecuteCommand
    inc r12
    loop ConvertInClikeString
    mov rcx, errorOverflow
    call printf
    jmp BigLoop
ExecuteCommand:
    mov Byte [command + r12], 0
    ; make the command non-case sensitive
    mov rcx, command
    call DOWN
    ; now, find out which command it is
    ; command help
    mov rcx, command
    mov rdx, helpCommand
    call strcmp_spc
    cmp rax, 0
    je helpUtility
    ; command quit
    mov rdx, qCommand
    call strcmp_spc
    cmp rax, 0
    je ExitProgram
    mov rdx, quitCommand
    call strcmp_spc
    cmp rax, 0
    je ExitProgram
    ; command list 
    mov rdx, listCommand
    call strcmp_spc
    cmp rax, 0
    je listPasswords
    jmp BigLoop
helpUtility:
    mov rcx, helpMessage
    call printf
    jmp BigLoop
listPasswords:
    ; seek to adress 0
    mov rax, sys_lseek
    mov rdi, qWord [FileDescriptor]
    mov rsi, 25
    mov rdx, SEEKSET
    syscall
    ; read ASCII number 
    mov rax, Sys_read
    mov rdi, qWord [FileDescriptor]
    mov rsi, maxNumberSize
    mov rdx, 20
    syscall
    ; convert in integer
    mov rcx, maxNumberSize
    call strtol
    ; the number of passwords is now stored in rax
    ; calculate the passwords total size
    mov r15, 70
    mul r15
    mov r13, rax
    mov rcx, listText
    call printf
    mov rcx, maxNumberSize
    call printf
    mov rcx, printf
    call printf
    ; seek to adress 70
    mov rax, sys_lseek
    mov rdi, qWord [FileDescriptor]
    mov rsi, 70
    mov rdx, SEEKSET
    syscall
    ; now, read everything 
    mov rax, Sys_read
    mov rdi, qWord [FileDescriptor]
    mov rsi, fileBuffer
    mov rdx, r13
    syscall
    ; finally, output everything
    mov rcx, fileBuffer
    syscall


ExitProgram:
    mov rax, Sys_exit
    xor rdi, rdi
    syscall







GenerateHeader:
    push rbp
    mov rbp, rsp
    push rbx
    push r14
    push r15
    
    
    mov rax, 201
    xor rdi, rdi
    syscall
    ; then : format it
    ; obtain the number of years
    mov r14, rax
    mov rdi, 0
    ; rsi contains a flag 'leap year' (0) or 'not a leap year' (1) for later Month operations
loopYears:
    mov rax, qWord [BeginningYear]
    cqo
    mov r15, 4
    div r15
    cmp rdx, 0
    jne MaybeLeapYear
    jmp NotALeapYear
MaybeLeapYear:
    mov rax, qWord [BeginningYear]
    cqo
    mov r15, 100
    div r15
    cmp rdx, 0
    je MayNotALeapYear
LeapYear:
    mov rbx, 31622400
    mov rsi, 0
    jmp ContinueCalculation
MayNotALeapYear:
    mov rax, qWord [BeginningYear]
    cqo
    mov r15, 400
    div r15
    cmp rdx, 0
    je LeapYear
NotALeapYear:
    mov rbx, 31536000
    mov rsi, 1
ContinueCalculation:
    sub r14, rbx
    cmp r14, 0
    jl FinalNumberOfYearsFound
    inc rdi
    inc qWord [BeginningYear]
    jmp loopYears
FinalNumberOfYearsFound:
    add r14, rbx
    add rdi, 1970
    mov qWord [Years], rdi
    ; no, it's time to calculate the month
    ; calculate the days of the current year 
    mov rax, r14
    cqo
    mov r15, 86400
    div r15
    cmp rsi, 0
    je MonthsLeapYear
    jmp ContinueCalculatingMonths
MonthsLeapYear:
    mov Byte [MonthsOfTheYear + 1], 29
ContinueCalculatingMonths:
    mov rcx, 12
    mov rsi, 0
    ; rdi contains the number of months
    mov rdi, 0
LoopMonths:
    xor r15, r15
    mov r15b, Byte [MonthsOfTheYear + rsi]
    sub rax, r15
    cmp rax, 0
    jl FinishedLoop
    inc rsi
    inc rdi
    loop LoopMonths
FinishedLoop:
    mov qWord [Months], rdi
    xor r15, r15
    mov r15b, Byte [MonthsOfTheYear + rsi]
    add rax, r15
    ; now : the number of days is directly contained in rax
    mov qWord [Days], rax
    ; and the rest in seconds is contained in rdx -- to find the number of hours, we just have to divide it by 3600
    mov rax, rdx
    cqo
    mov r15, 3600
    div r15
    mov qWord [Hours], rax
    ; rdx/60 -> minutes
    mov rax, rdx
    cqo
    mov r15, 60
    div r15
    mov qWord [Minutes], rax
    ; secondes are in rdx
    mov qWord [Seconds], rdx
    ; no, convert everything in ASCII and write in the buffer.
    mov r8, [Years]
    mov r9, maxNumberSize
    call sprintf
    mov rcx, 4
    mov rsi, 50
    mov rdi, 0
WriteLoop1:
    mov al, Byte [maxNumberSize + rdi]
    mov Byte [headerBuffer + rsi],  al
    inc rsi
    inc rdi
    loop WriteLoop1
    mov r8, [Months]
    mov r9, maxNumberSize
    call sprintf
    mov rdi, 55
    call insertFunction
    mov r8, [Days]
    mov r9, maxNumberSize
    call sprintf
    mov rdi, 58
    call insertFunction
    mov r8, [Hours]
    mov r9, maxNumberSize
    call sprintf
    mov rdi,  61
    call insertFunction
    mov r8, [Minutes]
    mov r9, maxNumberSize
    call sprintf
    mov rdi, 64
    call insertFunction
    mov r8, [Seconds]
    mov r9, maxNumberSize
    call sprintf
    mov rdi, 67
    call insertFunction

    pop r15
    pop r14
    pop rbx
    pop rbp
    ret

insertFunction:
    push r12
    mov r12, rdi
    inc r12
    cmp Byte [maxNumberSize + 1], 0
    je Possibility1
    jmp Possibility2
Possibility1:
    mov Byte [headerBuffer + rdi], '0'
    mov al, Byte [maxNumberSize]
    mov Byte [headerBuffer + r12], al
    jmp ExitInsertFunction
Possibility2:
    mov al, Byte [maxNumberSize]
    mov Byte [headerBuffer + rdi], al
    mov al, Byte [maxNumberSize + 1]
    mov Byte [headerBuffer + r12], al
ExitInsertFunction:
    pop r12
    ret


%include "StringFunctions.asm"