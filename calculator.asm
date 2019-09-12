format ELF executable 3
entry start
segment readable executable

start:
    mov eax, 1 ; __NR_exit
    xor ebx, ebx ; first argument
    int 0x80 ; system_call
    ret

segment readable writeable

n db 1 ; data