bits 16

;;;;;
; Converts hexadecimal digit to byte.
;   Format: 0~F or 0~f
; Arguments:
;     DS:SI   Pointer to string.
; Return:
;     AL      Value converted. (0 if not valid hexadecimal digit)
;     SI      End of the hexadecimal value.
;;;;;
xtob:
  lodsb
  cmp al, '9'
  jg .is_letter
  cmp al, '0'
  jl .not_valid

  sub al, '0'
  jmp .stop

.is_letter:
  cmp al, 'F'
  jg .is_lower
  cmp al, 'A'
  jl .not_valid

  sub al, 'A' - 10
  jmp .stop

.is_lower:
  cmp al, 'f'
  jg .not_valid
  cmp al, 'a'
  jl .not_valid

  sub al, 'a' - 10
  jmp .stop

.not_valid:
  xor al, al
.stop:
  ret