section .data
    ; constants
    Sys_read equ 0
    Sys_write equ 1
    Sys_open equ 2
    Sys_close equ 3
    Sys_lseek equ 8
    Sys_exit equ 60
    Sys_ftruncate equ 77
    STDIN equ 0
    STDOUT equ 1
    SEEKSET equ 0
    SEEKEND equ 2
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
                db "   delete <--number|-N x>|<--name|-n name_of_the_password> : erase a password entry.", 10
                db "   add <--password|-p max_size_20_Bytes> <-n|--name max_size_40_Bytes> : add a new password entry.", 10
                db "   clear : clears all previously defined passwords.", 10
                db "   set </path/to/file>|<file> : defines the output file.", 10  
                db "   date : display creation date.", 10
                db "   q|quit : quit this program.", 10
                db "Thank's for supporting my work!", 10, 0
    listCommand db "list", 0
    listText db "The number of passwords stored is : ", 0
    deleteCommand db "delete", 0
    deleteCommandErrorMessage db "error : invalid arguments.", 10, 0
    nameDeletedCommand db "--name", 0
    nDeletedCommand db "-n", 0
    numberDeletedCommand db "--number", 0
    numDeletedCommand db "-N", 0
    addCommand db "add", 0
    addCommandErrorMessage db "error : invalid arguments.", 10, 0
    addCommandOverflowError db "error : exceeded max number of passwords '100'.", 10, 0
    passwordAdd db "--password", 0
    pAdd db "-p", 0
    nameAdd db "--name", 0
    nAdd db "-n", 0
    clearCommand db "clear", 0
    setCommand db "set", 0
    qCommand db "q", 0
    quitCommand db "quit", 0
    dateCommand db "date", 0 
    dateMessage db "creation date : ", 0
    errorOverflow db "error : user input max size overflow.", 10, 0
    BeginningYear dq 1970
    Years dq 0
    Months dq 0
    Days dq 0
    Hours dq 0
    Minutes dq 0
    Seconds dq 0
    MonthsOfTheYear db 31,28,31,30,31,30,31,31,30,31,30,31
    headerBuffer db "number of passwords set: 0", 0, "                  at [    /  /     :  :  ]", 10
    PasswdBuffer db "passwd<                                        >:                    ", 10
    errorFileOpening db "error opening password log file. Aborting...", 10, 0
    errorUnknown db "unknown command.", 10, 0
section .bss
    command resb 1024
    fileName resb 512
    fileBuffer resb 7071
    numberOfEntries resq 1
    Password resb 21
    namePassword resb 41
    arg resb 50
    maxNumberSize resb 20
    maxNumberSizeDelete resb 20
    dateBuffer resb 22
    name resb 41
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
    mov rdx, 644
    syscall
    ; check for any errors
    cmp rax, 0
    jb CriticalError
    mov qWord [FileDescriptor], rax
    ; get file size
    mov rax, Sys_lseek
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
    mov rax, Sys_lseek
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
    ; command add  
    mov rdx, addCommand
    call strcmp_spc
    cmp rax, 0 
    je addPassword
    ; command delete
    mov rdx, deleteCommand
    call strcmp_spc
    cmp rax, 0
    je deletePassword
    ; command clear
    mov rdx, clearCommand
    call strcmp_spc
    cmp rax, 0
    je clearAllPasswords
    ; command set
    mov rdx, setCommand
    call strcmp_spc
    cmp rax, 0
    je setLogFilePath
    ; command date
    mov rdx, dateCommand
    call strcmp_spc
    cmp rax, 0
    je displayCreationDate
    jmp UnknownCommand
helpUtility:
    mov rcx, helpMessage
    call printf
    jmp BigLoop
listPasswords:
    ; seek to adress 25
    mov rax, Sys_lseek
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
    mov rcx, newLine
    call printf
    ; seek to adress 70
    mov rax, Sys_lseek
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
    mov Byte [fileBuffer + r13], 0
    ; finally, output everything
    mov rcx, fileBuffer
    call printf
    jmp BigLoop
addPassword:
    ; reset both Password and namePassword
    mov rdi, Password
    mov rcx, 20
    mov al, ' '
    rep stosb
    mov rdi, namePassword
    mov rcx, 40
    mov al, ' '
    rep stosb
    ; r13 will contain the index in arg or password or name
    mov r13, 0
    ; r12 will contain the value password(0)/name(1)/arg(-1)
    mov r12, -2
    mov rsi, 3
    cmp Byte [command + 3], 0
    je addCommandError
    push rsi
loopadd:
    pop rsi
    mov al, Byte [command + rsi]
    inc rsi
    push rsi
    cmp al, 0
    je AddToPasswordFile
    cmp al, ' '
    je DoNotAddCharToString
    cmp al, 9
    je DoNotAddCharToString
    cmp r12, -1
    je AddCharToArg
    cmp r12, 1
    je AddCharToName
    cmp r12, 0
    je AddCharToPassword
    jmp addCommandError
AddCharToArg:
    cmp r13, 49
    je addCommandError
    mov Byte [arg + r13], al
    inc r13
    jmp loopadd
AddCharToName:
    cmp r13, 40
    je addCommandError
    mov Byte [namePassword + r13], al
    inc r13
    jmp loopadd
AddCharToPassword:
    cmp r13, 20
    je addCommandError
    mov Byte [Password + r13], al
    inc r13
    jmp loopadd
DoNotAddCharToString:
    cmp r12, -2
    je ReturnToAddLoop
    cmp r13, 0
    je addCommandError
    mov Byte [arg + r13], 0
    cmp r12, -1
    je CheckArg
    cmp r12, 0
    je ArgSet
    cmp r12, 1
    je ArgSet
    jmp addCommandError
CheckArg:
    mov rcx, arg
    mov rdx, passwordAdd
    call strcmp
    cmp rax, 0
    je PasswordSet
    mov rcx, arg
    mov rdx, pAdd
    call strcmp
    cmp rax, 0
    je PasswordSet
    mov rcx, arg
    mov rdx, nameAdd
    call strcmp
    cmp rax, 0
    je NameSet
    mov rcx, arg
    mov rdx, nAdd
    call strcmp
    cmp rax, 0
    je NameSet
    jmp addCommandError
PasswordSet:
    mov r12, 0
    jmp ContinueAddCommandLoop
NameSet:
    mov r12, 1
ContinueAddCommandLoop:
    mov r13, 0
    jmp loopadd 
ArgSet:
    mov r12, -1
    mov r13, 0
    jmp loopadd
ReturnToAddLoop:
    mov r12, -1
    jmp loopadd
AddToPasswordFile:
    cmp byte [Password], 0
    je addCommandError
    cmp byte [namePassword], 0
    je addCommandError
    mov rcx, namePassword
    lea rdx, Byte [PasswdBuffer + 7]
    call strcpy_raw
    mov rcx, Password
    lea rdx, Byte [PasswdBuffer + 49]
    call strcpy_raw
    ; now, lseek to the end 
    mov rax, Sys_lseek
    mov rdi, qWord [FileDescriptor]
    mov rsi, 0
    mov rdx, SEEKEND
    syscall
    ; check that size =< 7000
    cmp rax, 7000
    jnbe overflowError
    ; write it
    mov rax, Sys_write
    mov rdi, qWord [FileDescriptor]
    mov rsi, PasswdBuffer
    mov rdx, 70
    syscall
    ; and finally, increment the number of passwords
    ; seek to adress 25
    mov rax, Sys_lseek
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
    ; increment rax
    inc rax
    ; convert back and write back
    mov r8, rax
    mov r9, maxNumberSize
    call sprintf
    mov rcx, maxNumberSize
    call strlen
    ; seek to adress 25
    mov rax, Sys_lseek
    mov rdi, qWord [FileDescriptor]
    mov rsi, 25
    mov rdx, SEEKSET
    syscall
    mov rax, Sys_write
    mov rdi, qWord [FileDescriptor]
    mov rsi, maxNumberSize
    mov rdx, 20
    syscall
    jmp BigLoop
addCommandError:
    mov rcx, addCommandErrorMessage
    call printf
    jmp BigLoop
overflowError:
    mov rcx, addCommandOverflowError
    call printf
    jmp BigLoop
deletePassword:
    ; r15 will contain the index in arg/name/maxnumbersize
    mov r15, 0
    ; r14 will contain the index in the command string
    mov r14, 6
    ; r13 will contain the state : -2=>initial, -1=>arg, 0=>name, 1=>maxnumbersize, 2=>error, 3=>error
    mov r13, -2
loopDelete:
    mov al, Byte [command + r14]
    inc r14
    cmp al, 0
    je ExitDeleteLoop
    cmp al, ' '
    je ChangeState
    cmp al, 9
    je ChangeState
    cmp r13, -2
    je deleteCommandError
    cmp r13, -1
    je IncrementCharToArg
    cmp r13, 0
    je IncrementCharToName
    cmp r13, 1
    je IncrementCharToMaxNumberSize
    jmp deleteCommandError
IncrementCharToArg:
    cmp r15, 49
    je deleteCommandError
    mov Byte [arg + r15], al
    inc r15
    jmp loopDelete
IncrementCharToName:
    cmp r15, 40
    je deleteCommandError
    mov Byte [name + r15], al
    inc r15
    jmp loopDelete
IncrementCharToMaxNumberSize:
    cmp r15, 20
    je deleteCommandError
    mov Byte [maxNumberSizeDelete + r15], al
    inc r15
    jmp loopDelete
ChangeState:
    cmp r13, 2
    je loopDelete
    cmp r13, 3
    je loopDelete
    cmp r13, 1
    je ChangeToErrorState1
    cmp r13, 0
    je ChangeToErrorState0
    cmp r13, -1
    je checkArgDeleteCommand
    cmp r13, -2
    je SetArg
    jmp deleteCommandError
checkArgDeleteCommand:
    mov Byte [arg + r15], 0
    mov rcx, arg
    mov rdx, nameDeletedCommand
    call strcmp
    cmp rax, 0
    je SetName
    mov rcx, arg
    mov rdx, nDeletedCommand
    call strcmp
    cmp rax, 0
    je SetName
    mov rcx, arg
    mov rdx, numberDeletedCommand
    call strcmp
    cmp rax, 0
    je SetNumber
    mov rcx, arg
    mov rdx, numDeletedCommand
    call strcmp
    cmp rax, 0
    je SetNumber
    jmp deleteCommandError
SetArg:
    mov r13, -1
    xor r15, r15
    jmp loopDelete
SetName:
    mov r13, 0
    xor r15, r15
    jmp loopDelete
SetNumber:
    mov r13, 1
    xor r15, r15
    jmp loopDelete
ChangeToErrorState0:
    mov Byte [name + r15], 0
    add r13, 2
    jmp loopDelete
ChangeToErrorState1:
    mov Byte [maxNumberSizeDelete + r15], 0
    add r13, 2
    jmp loopDelete
ExitDeleteLoop:
    cmp r13, -2
    je ContinueDeleteLoop
    ; incremnt r13 if necessary
    cmp r13, 1
    jbe IncR13
    jmp ContinueFunction
IncR13:
    add r13, 2
ContinueFunction:
    ; find out the number of passwords
    mov rax, Sys_lseek
    mov rdi, qWord [FileDescriptor]
    mov rsi, 25
    mov rdx, SEEKSET
    syscall
    mov rax, Sys_read
    mov rdi, qWord [FileDescriptor]
    mov rsi, maxNumberSize
    mov rdx, 20
    syscall 
    mov rcx, maxNumberSize
    call strtol
    mov r12, rax
    mov rbx, 70
    mul rbx
    ; now, rax contain the total size of all passwords
    ; save it for later
    mov r14, rax
    ; save it for later
    add r14, 70
    ; lseek the offset 70
    mov rax, Sys_lseek
    mov rdi, qWord [FileDescriptor]
    mov rsi, 70
    mov rdx, SEEKSET
    syscall
    ; now, read EVERYTHING
    mov rax, Sys_read
    mov rdi, qWord [FileDescriptor]
    mov rsi, fileBuffer
    mov rdx, r14
    syscall
    ; write a final 0
    mov Byte [fileBuffer + r14], 0
    ; find out if the password exists, il yes, delete it and update.
    mov r15, fileBuffer
    cmp r13, 2
    je FindName
    cmp r13, 3
    je FindNumber
    jmp deleteCommandError
FindName:
    ; r15 will contain the index in the buffer
    mov rcx, r12
loopReadFileToFindName:
    ; read the name
    push rcx
    lea rcx, Byte [r15 + 7]
    mov rdx, name
    call strcmp_spc
    pop rcx
    cmp rax, 0
    je deletePasswordFinally
    add r15, 70
    loop loopReadFileToFindName
    jmp deleteCommandError
FindNumber:
    ; first : convert the maxNumberSizeDelete variable
    mov rcx, maxNumberSizeDelete
    call strtol
    ; check if it is bigger than r13
    cmp rax, r12
    ja deleteCommandError
    ; now, dec rax to get the absolute loaclisation (a list starts with 0)
    dec rax
    mov rbx, 70
    mul rbx
    add r15, rax
    jmp deletePasswordFinally
deletePasswordFinally:
    lea rcx, Byte [r15]
    lea rdx, Byte [r15 + 70]
    mov rsi, r14
    call memcpy
    ; now, update the counter at the beginning
    dec r12
    mov r8, r12
    mov r9, maxNumberSize
    call sprintf
    ; lseek the the correct adress (25)
    mov rax, Sys_lseek
    mov rdi, qWord [FileDescriptor]
    mov rsi, 25
    mov rdx, SEEKSET
    syscall
    ; and write !
    mov rax, Sys_write
    mov rdi, qWord [FileDescriptor]
    mov rsi, maxNumberSize
    mov rdx, 20
    syscall
    ; calculate the new size 
    mov rax, r12
    mov rbx, 70
    mul rbx
    mov r12, rax
    mov rax, Sys_lseek
    mov rdi, qWord [FileDescriptor]
    mov rsi, 70
    mov rdx, SEEKSET
    mov rax, Sys_write
    mov rdi, qWord [FileDescriptor]
    mov rsi, fileBuffer
    mov rdx, r12
    syscall
    ; truncate the file
    add r12, 70
    mov rax, Sys_ftruncate
    mov rdi, qWord [FileDescriptor]
    mov rsi, r12
    syscall
    ; finally, return to the main loop
    jmp BigLoop
ContinueDeleteLoop:
    mov r13, -1
    inc rsi
    jmp loopDelete
deleteCommandError:
    mov rcx, deleteCommandErrorMessage
    call printf
    jmp BigLoop
clearAllPasswords:
    ; this command completly clears the password file and resets it.
    ; in order to do that, we first set it's size to 0
    mov rax, Sys_ftruncate
    mov rdi, qWord [FileDescriptor]
    mov rsi, 0
    syscall
    ; we lseek to adress 0
    mov rax, Sys_lseek
    mov rdi, qWord [FileDescriptor]
    mov rsi, 0
    mov rdx, SEEKSET
    syscall
    ; now, we regenerate a minimal header
    call GenerateHeader
    ; and we write it
    mov rax, Sys_write
    mov rdi, qWord [FileDescriptor]
    mov rsi, headerBuffer
    mov rdx, 70
    syscall
    ; finally, jmp back
    jmp BigLoop
setLogFilePath:
    ; first : read the user input
    mov r15, 3
    mov r14, 0
readLoop:
    mov al, Byte [command + r15]
    inc r15
    cmp al, 0
    je TryToOpenTheFile
    cmp al, ' '
    je readLoop
    cmp al, 9
    je readLoop
    cmp r14, 513
    je CriticalError
    mov Byte [fileName + r14], al
    inc r14
    jmp readLoop
TryToOpenTheFile:
    mov Byte [fileName + r14], 0
    ; try to open the file
    mov rax, Sys_open
    mov rdi, fileName
    mov rsi, O_CREAT | O_RDWR
    mov rdx, 644
    syscall
    ; check for any errors
    cmp rax, 0
    jb CriticalError
    mov qWord [FileDescriptor], rax
    call GenerateHeader
    ; seek to position 0
    mov rax, Sys_lseek
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
    jmp BigLoop
displayCreationDate:
    ; seek to adress 48
    mov rax, Sys_lseek
    mov rdi, qWord [FileDescriptor]
    mov rsi, 48
    mov rdx, SEEKSET
    syscall
    ; read date 
    mov rax, Sys_read
    mov rdi, qWord [FileDescriptor]
    mov rsi, dateBuffer
    mov rdx, 21
    syscall
    ; output everything
    mov rcx, dateMessage
    call printf
    mov rcx, dateBuffer
    call printf
    mov rcx, newLine
    call printf
    jmp BigLoop
UnknownCommand:
    mov rcx, errorUnknown
    call printf
    jmp BigLoop
CriticalError:
    mov rcx, errorFileOpening
    call printf
ExitProgram:
    ; close the file
    mov rax, Sys_close
    mov rdi, qWord [FileDescriptor]
    syscall
    ; exit the program
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
    mov rsi, 49
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
    mov rdi, 54
    call insertFunction
    mov r8, [Days]
    mov r9, maxNumberSize
    call sprintf
    mov rdi, 57
    call insertFunction
    mov r8, [Hours]
    mov r9, maxNumberSize
    call sprintf
    mov rdi,  60
    call insertFunction
    mov r8, [Minutes]
    mov r9, maxNumberSize
    call sprintf
    mov rdi, 63
    call insertFunction
    mov r8, [Seconds]
    mov r9, maxNumberSize
    call sprintf
    mov rdi, 66
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