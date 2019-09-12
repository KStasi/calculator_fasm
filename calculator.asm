format ELF executable 3
entry start
segment readable executable

itoa:
    mov ax, [number] ; copy number to register
    mov [number_copy], ax ; copy number to number_copy
    cmp [number_copy], 0 ; check if need switch sign
    jl neg_num_change ; if negative, cast to unsigned value
    jmp continue_itoa1 ; skip the cast otherwise
    neg_num_change: ; block to change copy sign
        mov ax, [number_copy] ; copy value to register
        neg ax ; switch sign
        mov [number_copy], ax ; copy changed value to source
    continue_itoa1: ; main code stream

    jmp loop_push_symbols ; go to loop extracted symbols
    loop_push_symbols_body: ; block to initialise printed symbols
        xor eax, eax ; fresh register
        xor ebx, ebx ; fresh register
        xor edx, edx ; fresh register
        xor ecx, ecx ; fresh register
        mov ax, [number_copy] ; copy value to dividend
        mov bx, 10 ; initialise divisor
        div bx ; (dx:ax) / bx, quotient stored in ax and remainder in dx
        push dx ; save remainder in stack
        inc [len] ; increase length
        mov [number_copy], ax ; move quotient to number_copy; 'cut' the last symbol
    loop_push_symbols:
        cmp ax, 0 ; check if any symbol could be extracted
        jg loop_push_symbols_body ; if yes, extract symbol

    cmp [number], 0 ; check if need print sign
    jl print_minus ; if negative, print minus
    jmp continue_itoa2 ; skip print otherwise
    print_minus: ; block to print minus
        mov [symbol], 45 ; initiate symbol
	    mov	eax,4 ; __NR_write
	    mov	ebx,1 ; descriptor
	    mov	ecx,symbol ; buffer
	    mov	edx,1 ; length
        int	0x80 ; system_call
    continue_itoa2: ; main stream

    loop_pop_symbols_start: ; block to prepare printing loop
        mov [n], 0 ; zeroing counter
        cmp [len], 0 ; check if any pushed
        jne loop_pop_symbols ; if yes, start printing
        mov dx, 0 ; if no, then result symbol is 0
        push dx ; push it
        inc [len] ; increase output length
    loop_pop_symbols:
        xor eax, eax ; fresh register
        xor ebx, ebx ; fresh register
        xor edx, edx ; fresh register
        xor ecx, ecx ; fresh register
        pop [symbol] ; pop symbol
        add [symbol], 48 ; convert to ascii


	    mov	eax,4 ; __NR_write
	    mov	ebx,1 ; descriptor
	    mov	ecx,symbol ; buffer
	    mov	edx,1 ; length
        int	0x80 ; system_call

        inc [n] ; increment counter
        xor eax, eax ; fresh register
        mov al, [n] ; copy counter to register for comparison
        cmp [len], al ; check if all symbols printed
        jl loop_pop_symbols ; if no continue
        ret ; return otherwise

start:
    call itoa

    mov eax, 1 ; __NR_exit
    xor ebx, ebx ; first argument
    int 0x80 ; system_call
    ret

segment readable writeable

number dw 930 ; number to print
number_copy dw 0 ; space to number copy
len db 0 ; output string length
symbol dw 0 ; symbol to print
n db 0 ; counter
