bits 16

;;;;;
; Converts decimal string to integer number.
; Arguments:
;     DS:SI   Pointer to string.
; Return:
;     CX      The value parsed.
;     SI      Pointer to end of the number.
;;;;;
atoi:
  mov di, si ; Start address
  .lp: ; Searching the end of the number
    mov bl, [si]
    cmp bl, '9'
    jg .lpe
    cmp bl, '0'
    jl  .lpe

    add si, 1
    jmp .lp
  .lpe:


  xor cx, cx
  std
  push si
  sub si, 1
  mov bx, 1
  .cnt:
    cmp si, di
    jl .cnte

    lodsb
    sub al, '0'
    mul bl
    add cx, ax

    mov ax, bx
    mov bl, 10
    mul bl
    mov bx, ax
    jmp .cnt
  .cnte:

  cld
  pop si
  ret