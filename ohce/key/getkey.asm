bits 16

;;;;;
; Gets a key if it is pressed.
; Return:
;     AX   The code of the key. Zero if not have a pressed key.
;;;;;
getkey:
  mov ah, 0x01
  int 0x16
  jz .stop

  mov ah, 0x00
  int 0x16
.stop:
  ret