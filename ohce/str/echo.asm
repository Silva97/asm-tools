bits 16

;;;;;
; Prints a ASCIIZ string in STDOUT
; Arguments:
;     DS:SI   Pointer to string.
; Return:
;     Nothing.
;;;;;
echo:
  mov ah, 0x02
  mov dl, [si]
  cmp dl, 0
  je .stop

  add si, 1
  int 0x21
  jmp echo

.stop:
  ret