bits 16

;;;;;
; Prints character and attribute in teletype mode.
; Arguments:
;     AL   The character to print.
;     BL   The attribute to character.
; Return:
;     Nothing.
;;;;;
__putc_char: db 0x00
putc:
  mov ah, 0x03
  xor bh, bh
  int 0x10

  mov [__putc_char], al
  mov al, 1
  mov cx, 1
  mov bp, __putc_char

  mov ah, 0x13
  int     0x10
  ret