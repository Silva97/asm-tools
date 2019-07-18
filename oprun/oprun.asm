; Opcode Run - Programa para executar código de máquina.
; O mesmo funciona como um "console", você digita código de máquina em hexadecimal e pressiona enter para executar.
; O código é carregado no offset 0x100, mesmo endereço que o MS-DOS carrega os programas.

; Exemplo de programa olá mundo:
; 	B4 03 CD 10 B0 01 B3 0F B9 0B 00 BD 13 01 B4 13 CD 10 C3 4F 6C 61 20 6D 75 6E 64 6F 0D 0A

; -----------------------------------
; Programmed by Luiz Felipe.
; GitHub: https://github.com/Silva97
; -----------------------------------
; Used NASM 2.13 for assembly the code.

org 0x100

runLength EQU 512   ; Número maximo de Bytes
runOffset EQU 0x100 ; Endereço onde carregar o programa

jmp init
	times runLength DB 0x90
init:

%include "oprun.inc"


prints 0x0A, "Opcode Run v0.2"
printnl
print  0x0F, msg1
; ------------------------------------


getStart:
	prints 0x0C, "> "

	mov cx, runLength
	mov di, runOffset
	mov al, 0x90
	rep stosb ; Inserir NOP na área de execução
    
	mov byte [runOffset + runLength], 0xC3 ; RET no fim do programa


	mov di, opcode
	mov si, runOffset
	mov cx, 0 ; Número de Bytes


getInput:
	mov ah, 0
	int 0x16

	cmp al, "x"  ; Sair do programa
	je exit

	cmp al, 0x0D ; Executar o código
	je runCode

	cmp cx, runLength
	je getInput ; Se chegou ao limite, não insere mais nada


	call toupper  ; AL em caixa alta. (Se entre "a" e "f")


	call isnumber
	cmp al, 0
	je getInput   ; Verificando se é um caractere válido

	mov ah, 0x0E
	int 0x10      ; Mostrar o caractere na tela


	mov [di], al
	cmp di, opcode + 1
	je conOpcode

	inc di
jmp getInput


runCode:
	mov [size], cx

runRepeat:
	printnl
	prints 0x09, "----- Running the program -----"
	printnl

	call runOffset

	printnl
	prints 0x09, "----- The program's end -----"
	printnl

	print 0x0F, msg2

	mov ah, 0
	int 0x16

	cmp al, "r"
	je runRepeat

	cmp al, "s"
	je saveProgram

	jmp getStart



conOpcode: ; Convertendo em opcode
	inc cx
	mov di, opcode

	mov al, [di]
	call tonumber
	shl al, 4
	mov bl, al

	mov al, [di + 1]
	call tonumber
	add al, bl


	mov [si], al
	inc si

	putc " "
	jmp getInput


saveProgram:
	xor cx, cx
	mov dx, file

	mov ah, 0x3C
	int 0x21

	mov bx, ax
	mov cx, [size]
	mov dx, runOffset

	mov ah, 0x40
	int 0x21

	printnl
	print 0x0A, msg3

	jmp getStart

exit:

ret


; ------------------------------------
msg1: DB "A prompt to run machine code", 0x0D, 0x0A
	  DB "   * The program is loaded in 0x100 offset(Same as MS-DOS)", 0x0D, 0x0A
	  DB "   * Limit of 512 bytes", 0x0D, 0x0A
	  DB "   - Type X to exit.", 0x0D, 0x0A
	  DB "   - Press enter to run the code.", 0x0D, 0x0A, 0x0A
	  DB "---- Programmed by Luiz Felipe", 0x0D, 0x0A
	  DB "---- GitHub: https://github.com/Silva97", 0x0D, 0x0A, 0

msg2: DB "- Type S to save the program.", 0x0D, 0x0A
	  DB "- Type R to run the program again.", 0x0D, 0x0A
	  DB "- Press enter to continue.", 0x0D, 0x0A, 0

msg3: DB "Program saved with the name 'PROGRAM.COM'", 0x0D, 0x0A, 0

opcode: times 2 DB 0
size:	DW 0
file:	DB "program.com", 0
