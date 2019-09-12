format ELF executable 3
entry start
segment readable executable

itoa:
    mov ax, [number]
    mov [number_str], ax
    jmp negres
    negreschange:
        mov ax, [number_str]
        neg ax
        mov [number_str], ax
    negres:
       cmp [number_str], 0
       js negreschange
    jmp loop1
    loop1end:
        xor eax, eax
        xor ebx, ebx
        xor edx, edx
        xor ecx, ecx
        mov ax, [number_str]
        mov bx, 10
        div bx
        push dx
        inc [len]
        mov [number_str], ax
    loop1:
        cmp ax, 0
        jnz loop1end

    jmp negnum
    negnumend:
        mov ax, [number]
        neg ax
        mov [number], ax
        mov [symbol], 45
	    mov	eax,4
	    mov	ebx,1
	    mov	ecx,symbol
	    mov	edx,1
        int	0x80
    negnum:
        cmp [number], 0
        js negnumend

    forloopstart:
        mov [n], 0
    forloop:
        xor eax, eax
        xor ebx, ebx
        xor edx, edx
        xor ecx, ecx
        pop [symbol]
        add [symbol], 48


	    mov	eax,4
	    mov	ebx,1
	    mov	ecx,symbol
	    mov	edx,1
        int	0x80

        inc [n]
        xor eax, eax
        mov al, [n]
        cmp [len], al
        jnz forloop
        ret

atoi:
    push esi
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    cmp byte [esi], '-'
    jnz negskip
    inc esi
    negskip:
        lodsb
        cmp al, 10
        je done
        sub al, 48
        imul bx, 10
        add ebx, eax
        xor eax, eax
        jmp short negskip
    done:
        xchg ebx,eax
        pop esi
        cmp byte [esi] , '-'
        jz negate
        ret
    negate:
        neg eax
    ret

read_number:
    mov eax, 4
    mov ebx, 1
    mov ecx, input_prompt
    mov edx, input_len
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, input_str
    mov edx, 0x100
    int 0x80
    ret

read_op:
    mov eax, 4
    mov ebx, 1
    mov ecx, input_op_prompt
    mov edx, input_op_prompt_len
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, input_str
    mov edx, 0x100
    int 0x80
    ret


start:
    call read_number
    mov esi, input_str
    call atoi
    mov [number1], ax
    mov [input_str], 0x100
    call read_number
    mov esi, input_str
    call atoi
    mov [number2], ax


    call read_op
    jmp math

    op_add:
        mov ax, [number1]
        add ax, [number2]
        jmp contin
    op_sub:
        mov ax, [number1]
        sub ax, [number2]
        jmp contin
    op_div:
        xor eax, eax
        xor ebx, ebx
        xor edx, edx
        xor ecx, ecx
        movsx eax, [number1]
        jmp cond
        negch:
            neg ax
        cond:
            cmp ax, 0
            js negch
        mov bx, [number2]
        idiv bx
        cmp [number1], 0
        js negch2
        jmp contin
        negch2:
            neg ax
        jmp contin
    op_mul:
        mov ax, [number1]
        imul ax, [number2]
        jmp contin

    math:
        cmp byte[input_str], '+'
        je op_add
        cmp byte[input_str], '-'
        je op_sub
        cmp byte[input_str], '/'
        je op_div
        cmp byte[input_str], '*'
        je op_mul

    contin:
        mov [number], ax
        call itoa

        mov eax, 1
        xor ebx, ebx
        int 0x80
        ret


segment readable writeable

n db 0
symbol dw 0
len db 0
number dw 0
number1 dw 0
number2 dw 0
number_str dw 0
input_promppt db 'enter number: '
input_len = $-input_prompt
input_op_prompt db 'enter op: '
input_op_prompt_len = $-input_op_prompt
input_str dw 0x100

