    ; Sets us in 16 bit mode
    BITS 16

start:
    ; 07C0h is where the BIOS loads the boot sector
    ; Basically a magic number but is industry standard so just trust it
    mov eax, 07C0h

    ; (512 + 4096) / 16 bytes per paragraph = 288
    ; 512 is the size of our boot sectior (code section)
    ; 4096 is the size of our disk buffer
    ; Thus, we have 288 paragraphs
    add eax, 288

    ; Thus, our stack segment is pointed at the end of our disk buffer
    ; This is actually a count of paragraphs (which is 16 bytes/paragraph)
    ; Also, ss is a count of paragraphs, not bytes
    mov ss, ax

    ; And our stack pointer is 4096 bytes
    ; This essentially allocates 4kb for the stack
    ; This means we count down our stack pointer
    ; and might overwrite our data segment if we do
    mov esp, 4096

    ; Our data segment is actually at the start of our boot sector
    mov eax, 07C0h
    mov ds, ax

    mov ax, 17764
    push ax
    call println_num
    pop ax
 
    ; Load the text string as the source register for the next call
    mov si, text_string

    ; Print the text string to the screen
    call print_string

    ; Dollar sign means the current location
    ; This is essentially an infinite loop that will
    ; stall instead of executing the next line
    jmp $

    ; Declares a null terminated string
    text_string db 'This is my cool new OS!', 13, 10, 0

println_num:
    push ebp
    mov ebp, esp
    push ax

    mov ax, [ebp + 6]
    push ax
    call print_num
    pop ax

    mov si, text_newline
    call print_string

    pop ax
    mov esp, ebp
    pop ebp
    ret

    text_newline db 13, 10, 0

; Start Function print_num
print_num:
    ; Subroutine prologue
    push ebp
    mov ebp, esp
    push ax
    push bx
    push dx
    
    ; Subroutine Body
    ; Load parameter as a register
    mov dx, [ebp + 6]

    ; Get first digit
    cwd ; extends eax into edx
    mov bx, 10
    div bx ; quotient in eax and remainder in edx

    ; If the dividend is zero, there's no more digits to print
    cmp ax, 0
    je .print_num_no_more_digits

    ; Recursively print the remaining digits
    ; Save lowest digit before recursively calling for higher digits
    push dx
    push ax
    call print_num
    pop ax
    pop dx

.print_num_no_more_digits:
    ; Convert digit to character
    add dx, 48

    ; Print lowest digit
    mov ah, 0Eh
    mov al, dl
    int 10h

    ; Subroutine Epilogue
    pop dx        ; Restore registers
    pop bx        ; Restore registers
    pop ax        ; Restore registers
    mov esp, ebp   ; Deallocate local variables
    pop ebp        ; Reset base pointer to caller
    ret
; End Function print_num

; Start Function print_string
print_string:
    mov ah, 0Eh

.repeat:
    ; Loads a byte from [ds:si/si] into al
    ; Here, we're using si but we can substitute with esi
    ; Then increments (or decrements depending on the direction flag) si
    ; We can also decrement depending on the direction flag
    lodsb

    ; If we are at the null terminating character (\0), finish
    cmp al, 0
    je .done

    ; If we fell through, this means we're not at the end yet
    ; Print this character and repeat
    int 10h
    jmp .repeat

.done:
    ; Return to the callee
    ret
; End Function print_string

    ; Pad the remaining of our boot sector with 0's up until 512 bytes - 2 bytes for our signature
    ; 512 bytes make this fit into a floppy drive
    ; 512 bytes - 2 bytes = 510 bytes
    ; $ is the current address, $$ is the start of the current sector
    ; ($ - $$) is the current size of the current sector
    ; Thus, we fill the rest of this sector (510 bytes total) with zeros
    times 510-($-$$) db 0

    ; The last two bytes need to be 0xAA and 0x55 which is the boot signature
    ; This is just some magic numbers that mark this sector as a valid boot sector
    dw 0xAA55
