bits 16

;;;;;
; Converts word value to string.
; Arguments:
;     ES:BP   Pointer to buffer to write
;     AX      Number to convert.
; Return:
;     Nothing.
;;;;;
itoa:
  xor dx, dx
  mov bx, 10
  div bx

  cmp ax, 0
  je .zero

  push dx
  call itoa
  pop dx

.zero:
  add dl, '0'
  mov [bp], dl
  add bp, 1
  mov byte [bp], 0
  ret