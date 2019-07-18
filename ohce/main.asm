;;;;;
; Developed by Luiz Felipe (2019)
;   https://github.com/Silva97
;   felipe.silva337@yahoo.com
;
; Tool for echo advanced text construction developed in Assembly for MS-DOS
;;;;;

org  0x100
bits 16
jmp main

ATTR_DEFAULT equ 0x07

%include "str/inc.asm"
%include "key/inc.asm"

main:
  xor bx, bx
  mov bl, [0x80]  ; Argument size
  cmp bl, 1
  jle .show_help

  sub bl, 1
  mov si, 0x82
  lea di, [si + bx] ; End of the argument line
  mov bl, ATTR_DEFAULT

  cmp byte [si], '"'
  jne .parse
  sub di, 1
  add si, 1
  .parse:
    push di
    call stresc
    cmp al, 0
    je .no_print

    call putc

    call getkey
    cmp ax, CTRL_C
    je .abort
  .no_print:
    pop di
    cmp si, di
    jl .parse

  ret

.abort:
  mov si, abort_msg
  call echo
  ret

.show_help:
  mov si, help
  call echo
  ret

abort_msg: db "^C aborted.", 0x00
help:
db `Tool for echo advanced text construction.\r\n`
db `Developed by Luiz Felipe. (2019)\r\n`
db `  https://github.com/Silva97\r\n`
db `  felipe.silva337@yahoo.com\r\n\r\n`

db `Usage: ohce "text"\r\n`
db `You can use escape sequences to determine the echoed text.\r\n`
db `    \\r      Carriage return. (0x0D / 13)\r\n`
db `    \\n      Line feed.       (0x0A / 10)\r\n`
db `    \\xHH    ASCII character HH in hexadecimal value.\r\n`
db `    \\@HH    Sets the attribute to HH hexadecimal value.\r\n`
db `    \\@n     Sets the attribute to default value. (07)\r\n`
db `    \\~      Inverts the background and foreground attributes.\r\n`
db `    \\*N,C   Repeats the C character N times.\r\n`
db `    \\s      Saves the current cursor position.\r\n`
db `    \\p      Restores previous saved cursor position.\r\n`
db `    \\gR,C   Sets the cursor position to R row and C column.\r\n`
db `            If R or C is '#', the value not is modified.\r\n`
db `    \\:N     Sets the variable to N value.\r\n`
db `    \\+      Increments the variable value.\r\n`
db `    \\-      Decrements the variable value.\r\n`
db `    \\$      Expand to value of the variable.\r\n`
db `    \\j      Jump to last \\: escape sequence.\r\n`
db `    \\!N     Jump to last \\: if variable NOT is equal N.\r\n`
db `    \\=N     Jump to last \\: if variable is equal N.\r\n`
db `Any other character escaped is just returned.\r\n\r\n`

db `EXAMPLES\r\n`
db `    ohce "One\\s\\g#,12\\~simple\\p\\@n example"\r\n`
db `    ohce "Your name is \\@0A%USER%\\@n?"\r\n`
db `    ohce "\\:1Item \\$\\r\\n\\+\\!6"`
db 0x00