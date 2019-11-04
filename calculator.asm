format ELF executable 3
entry start
segment readable executable

macro read_str str_ptr, len
{
    pusha
    xor edx, edx
    mov eax, 3 ; #define __NR_read 3
    mov ebx, 0 ; fd
    mov ecx, str_ptr ; buffer_ptr
    mov dx, len ; length
    int 0x80 ; sys_cal
    popa
}

macro put_str str_ptr, len
{
    pusha
    xor edx, edx
    mov eax, 4 ; #define __NR_write 4
    mov ebx, 1 ; fd
    mov ecx, str_ptr ; buffer_ptr
    mov dx, len ; length
    int 0x80 ; sys_call
    popa
}

macro str_len str_ptr, len_ptr {
    pusha
    local .continue1
    local .loop1
    xor eax, eax ; length = 0
    lea edx, [str_ptr] ; point to first element
    jmp .continue1 ; skip iterator
    .loop1:
        inc edx ; next element
        inc eax ; increment length
    .continue1:
        cmp byte[edx], 0 ; check if pointed element is \0
        jnz .loop1 ; if not eq go to next
    mov [len_ptr], ax ; store len
    popa
}


macro zero_str str_ptr, len {
    pusha
    local .continue1
    local .loop1
    xor ecx, ecx
    lea edi, [str_ptr] ; point to first element
    jmp .continue1 ; skip iterator
    .loop1:
        inc edi ; next symbol
        inc ecx ; increment counter
    .continue1:
        mov byte[edi], 0 ; put zero
        cmp cx, len ; compsre counters 
        jnz .loop1 ; next symbol, until counter != length
    popa
}

macro exit code
{
    pusha
    mov eax, 1 ; #define __NR_exit 1
    mov ebx, code ; code
    int 0x80 ; sys_call
    popa
}

macro itoa num, str_ptr
{
    pusha
    local .push_chars
    local .pop_chars
    local .less
    local .continue
    xor   eax, eax
    xor   ebx, ebx
    xor   ecx, ecx
    mov ax, num ; copy value
    mov bx, 10 ; store snum base
    lea edi, [str_ptr] ; point to first element 

    test ax, ax ; check sign
    jns .push_chars ; if positive go to chars representation; test SF
    neg ax ; else switcch sign

    .push_chars:
        xor edx, edx ; clear dividend; note: num = [s1][s2][s3][s4] thus num / base = [s1][s2][s3] (r. [s4])
        div bx ; DX = 0, AX = num, BX = 10 => DX:AX / BX => AX = [s1][s2][s3], DX = [s4], BX = 10
        add dx, "0" ; convert number to symbol 

    .continue:
        push dx ; store in stack
        inc cx ; increment counter 
        test ax, ax ; logical and
        jnz .push_chars ; if all bits of number are not zeros, read next symbol; test ZF 

        mov ax, num ; copy value
        test ax, ax ; logical and 
        jns .pop_chars ; if number is  not negative, extract it's string value; test SF
    
    mov dx, '-' ; else store sign
    push dx ; push sign to stack
    inc cx ; increment counter

    cld ; reset DF

    .pop_chars:
        pop ax ; get symbol
        stosb ; load AL to ES:EDI; increment EDI
        dec cx ; increment counter
        test cx, cx ; logical and
        jnz .pop_chars ; if all bits of number are not zeros, read next symbol; test ZF
    
    mov ax, 0x0a ; add \n 
    stosb ; load AL to ES:EDI; increment EDI
    popa
}

macro atoi str_ptr, num_ptr
{
    pusha
    local .get_decimal
    local .continue1
    local .store_num
    local .ret_error
    local .continue2
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    cld ; set DF = 0
    mov esi, str_ptr ; point to first symbol
    cmp byte [esi], '-' ; check if negative
    jne .get_decimal ; if ZF = 0 start read string
    inc esi ; else skip one symbol
    .get_decimal:
        lodsb ; load DS:ESI to AL; increment ESI
        cmp al, 48 ; check if symbol is number
        jl .continue1 ; else stop reading num
        cmp al, 57 ; check if symbol is number
        jg .continue1 ; else stop reading num
        sub al, 48 ; convert to number
        imul bx, 10 ; shift <-
        jo .ret_error ; if OF = 1 throw error
        add bx, ax ; add extracted symbol
        jo .ret_error ; if OF = 1 throw error
        xor eax, eax
        jmp .get_decimal ; go to next symbol
    .continue1:
        xchg bx, ax ; exchnge registre's interiors
        mov esi, str_ptr ; point to first symbol
        cmp byte [esi] , '-' ; check if num is negative
        jnz .store_num ; continue if ZF=0
        neg ax ; else switch sign
    .store_num:
        mov [num_ptr], ax ; store num
        jmp .continue2 ; go to end
    .ret_error: 
        str_len overflow_str, len ; get string length
        put_str overflow_str, [len] ; print string
        exit 1 ; reserved for error
    .continue2:
        popa
}

macro print_num element {
    pusha
    zero_str element_str, 6 ; clear string
    zero_str element_str_out, 6 ; clear string
    itoa element, element_str_out ; convert number to string
    str_len element_str_out, len ; calculate string length 
    put_str element_str_out, [len] ; write string to fd=1
    zero_str element_str, 6 ; clear string
    zero_str element_str_out, 6 ; clear string
    popa
}

read_op:
    mov eax, 4
    mov ebx, 1
    mov ecx, input_op_prompt
    mov edx, input_op_prompt_len
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, input_str
    mov edx, 0x1
    int 0x80
    ret


start:
    str_len input_prompt, len ; get string length
    put_str input_prompt, [len] ; print string

    zero_str input_str, 6 ; clean string
    read_str input_str, 7 ; read element
    atoi input_str, number1 ; convert to number

    str_len input_prompt, len ; get string length
    put_str input_prompt, [len] ; print string

    zero_str input_str, 6 ; clean string
    read_str input_str, 7 ; read element
    atoi input_str, number2 ; convert to number


    str_len input_op_prompt, len ; get string length
    put_str input_op_prompt, [len] ; print string

    zero_str input_str, 6 ; clean string
    read_str input_str, 7 ; read element

    xor eax, eax
    xor ebx, ebx
    xor edx, edx
    xor ecx, ecx

    jmp math

    op_add:
        mov ax, [number1]
        add ax, [number2]
        jmp start_continue1
    op_sub:
        mov ax, [number1]
        sub ax, [number2]
        jmp start_continue1
    op_div:
        mov ax, [number1]
        cmp ax, 0
        js change_sign1
        jmp start_continue2
        change_sign1:
            neg ax
        start_continue2:
        mov bx, [number2]
        idiv bx
        cmp [number1], 0
        js change_sign2
        jmp start_continue1
        change_sign2:
            neg ax
        jmp start_continue1
    op_mul:
        mov ax, [number1]
        imul ax, [number2]
        jmp start_continue1

    math:
        cmp byte[input_str], '+'
        je op_add
        cmp byte[input_str], '-'
        je op_sub
        cmp byte[input_str], '/'
        je op_div
        cmp byte[input_str], '*'
        je op_mul

    start_continue1:
        mov [number], ax
        print_num [number] ; print result
        exit 0
        ret


segment readable writeable

n db 0
symbol dw 0
number dw 0
number1 dw 0
number2 dw 0
number_str dw 0
input_prompt db 'enter number: ', 0x0a, 0x00
input_len = $-input_prompt
input_op_prompt db 'enter op: ', 0x0a, 0x00
input_op_prompt_len = $-input_op_prompt
input_str dw 0x100
overflow_str db "Number overflow.", 0x0a, 0x00
element_str rb 6
element_str_out rb 6
len dw 0
el dw 0