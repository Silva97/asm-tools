bits 16

;;;;;
; Verifies if a character is a valid hexadecimal digit.
; Argument:
;     AL    The hexadecimal character.
; Return:
;     AL    Zero if not is valid, nonzero otherwise.
;;;;;
ishex:
  cmp al, '9'
  jg .is_letter
  cmp al, '0'
  jl  .no
  jmp .yes

.is_letter:
  cmp al, 'F'
  jg .is_lower
  cmp al, 'A'
  jl  .no
  jmp .yes

.is_lower:
  cmp al, 'f'
  jg .no
  cmp al, 'a'
  jl .no

.yes:
  mov al, 1
  ret
.no:
  xor al, al
  ret
