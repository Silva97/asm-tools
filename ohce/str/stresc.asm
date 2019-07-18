bits 16

;;;;;
; Escapes a string sequence. If the first character is not a '\',
; just return it.
;
; Arguments:
;     BL     The default attribute.
;     DS:SI  Pointer to string.
;
; Escapes:
;     \r     Carriage return. (0x0D/13)
;     \n     Line feed. (0x0A/10)
;     \@HH   Sets attribute to HH hexadecimal value.
;     \@n    Sets attribute to default.
;     \xHH   ASCII character in hexadecimal.
;     \~     Inverts the background and foreground attributes.
;     \gR,C  Sets the cursor position to R row and C column.
;     \s     Saves the current cursor position.
;     \p     Restores previous saved cursor position.
;     \*N,C  Repeats C character N times.
;     \:N    Sets variable to N value.
;     \+     Increments the variable.
;     \-     Decrements the variable.
;     \j     Jumps to last \: escape.
;     \=N    Jumps to last \: if variable is equal N.
;     \!N    Jumps to last \: if variable NOT is equal N.
;     \$     Expand to value of the variable in decimal.
; Any other character is just returned.
;
; Return:
;     AL    The character escaped. (0 if no character)
;     BL    The character attribute.
;     SI    The end of the escape sequence.
;;;;;
__stresc_dx:   dw 0x0000
__stresc_si:   dw 0x0000
__stresc_rep:  dw 0x0000
__stresc_var:  dw 0x0000
__stresc_str:  times 6 db 0
__stresc_ptr:  dw 0x0000
__stresc_show: db 0x00
stresc:
  cmp byte [__stresc_show], 0
  je .strrep
  mov bp, [__stresc_ptr]
  mov al, [bp]
  cmp al, 0
  jne .show
  mov byte [__stresc_show], 0
  jmp .start
.show:
  add word [__stresc_ptr], 1
  jmp .stop

.strrep:
  cmp word [__stresc_rep], 0
  je .start
  mov al, [si]
  sub word [__stresc_rep], 1
  ret

.start:
  lodsb
  cmp al, '\'
  jne .stop

  lodsb
  cmp al, '\'
  je .stop
  ; For optimize \\

  cmp al, 'r'
  je .carriage
  cmp al, 'n'
  je .feed
  cmp al, '@'
  je .attr
  cmp al, 'x'
  je .hex
  cmp al, '~'
  je .invert
  cmp al, 'g'
  je .goto
  cmp al, 's'
  je .save
  cmp al, 'p'
  je .previous
  cmp al, '*'
  je .repeat
  cmp al, ':'
  je .label
  cmp al, '+'
  je .increment
  cmp al, '-'
  je .decrement
  cmp al, 'j'
  je .jump
  cmp al, '!'
  je .if_notequal
  cmp al, '='
  je .if_equal
  cmp al, '$'
  je .variable

  jmp .stop

.carriage:
  mov al, 0x0D
  jmp .stop

.feed:
  mov al, 0x0A
  jmp .stop

.attr:
  cmp byte [si], 'n'
  je .atdef

  call xxtob
  mov bl, al
  xor al, al
  jmp .stop
.atdef:
  mov bl, ATTR_DEFAULT
  xor al, al
  add si, 1
  jmp .stop

.hex:
  call xxtob
  jmp .stop

.invert:
  mov al, bl
  shr bl, 4
  shl al, 4
  add bl, al

  xor al, al
  jmp .stop

.goto:
  push bx
  xor bh, bh
  mov ah, 0x03
  int 0x10

  cmp byte [si], '#'
  jne .row
  add si, 1
  jmp .col
.row:
  call atoi
  mov dh, cl
.col:
  add si, 1
  cmp byte [si], '#'
  jne .getcol

  add si, 1
  jmp .end
.getcol:
  call atoi
  mov dl, cl
.end:
  pop bx
  xor bh, bh
  mov ah, 0x02
  int 0x10
  xor al, al
  jmp .stop

.save:
  push bx
  mov ah, 0x03
  int     0x10
  pop bx
  mov [__stresc_dx], dx
  xor al, al
  jmp .stop

.previous:
  xor bh, bh
  mov dx, [__stresc_dx]
  mov ah, 0x02
  int     0x10
  xor al, al
  jmp .stop

.repeat:
  push bx
  call atoi
  cmp cx, 1
  jle .dont_repeat

  sub cx, 2
  mov [__stresc_rep], cx
.dont_repeat:
  add si, 1
  mov al, [si]
  pop bx
  jmp .stop

.label:
  push bx
  call atoi
  mov [__stresc_var], cx
  mov [__stresc_si],  si
  xor al, al
  pop bx
  jmp .stop

.increment:
  cmp word [__stresc_var], 0x7FFF
  je .dont_inc
  add word [__stresc_var], 1
.dont_inc:
  xor al, al
  jmp .stop

.decrement:
  cmp word [__stresc_var], 0
  je .dont_dec
  sub word [__stresc_var], 1
.dont_dec:
  xor al, al
  jmp .stop

.jump:
  mov si, [__stresc_si]
  xor al, al
  jmp .stop

.if_notequal:
  push bx
  call atoi
  cmp [__stresc_var], cx
  je .ifne_false
  mov si, [__stresc_si]
.ifne_false:
  xor al, al
  pop bx
  jmp .stop

.if_equal:
  push bx
  call atoi
  cmp [__stresc_var], cx
  jne .ife_false
  mov si, [__stresc_si]
.ife_false:
  xor al, al
  pop bx
  jmp .stop

.variable:
  push bx
  mov bp, __stresc_str
  mov ax, [__stresc_var]
  call itoa

  mov byte [__stresc_show], 1
  mov word [__stresc_ptr], __stresc_str + 1
  mov al,  [__stresc_str]
  pop bx
  jmp .stop

.stop:
  ret
