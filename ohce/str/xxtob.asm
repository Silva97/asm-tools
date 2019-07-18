bits 16

;;;;;
; Converts hexadecimal digits to byte.
; Format: XX - To hexadecimal characters.
; Argument:
;     DS:SI   Pointer to string.
; Return:
;     AL      Value converted. (0 if not valid hexadecimal value)
;     SI      End of the hexadecimal value.
;;;;;

xxtob:
  call xtob
  mov ah, al
  shl ah, 4

  call xtob
  add al, ah
  ret