[org 0x7c00]

bits 16

start: 
    mov ax 0x07C0
    mov ds, ax
    mov es, ax
    mov ss, ax

    mov sp, 0x7C00

    cli   ; Disable Interuption.
    cld   ; Clear direction flags