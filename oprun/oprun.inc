; -----------------------------------
; Programmed by Luiz Felipe.
; GitHub: https://github.com/Silva97
; -----------------------------------
; Used NASM 2.13 for assembly the code.



; ------------------------ MACROS ------------------------ ;

%macro prints 2
	jmp %%txtEnd
	%%txt: DB %2, 0
	%%txtEnd:

	mov bl, %1
	mov cx, %%txtEnd - %%txt - 1
	mov bp, %%txt
	call _print
%endmacro

%macro print 2
	mov di, %2
	call strlen

	mov bl, %1
	mov cx, ax
	mov bp, %2
	call _print
%endmacro

%macro printnl 0
	mov ah, 0x0E
	mov al, 0x0D
	int 0x10
	
	mov al, 0x0A
	int 0x10
%endmacro

%macro putc 1
	mov ah, 0x0E
	mov al, %1
	int 0x10
%endmacro

; ------------------------ PROCESSOS ------------------------ ;
jmp _procsEnd


; BP = String, CX = Characters, BL = Attribute    
_print:
	push cx
	mov ah, 3
	int 0x10

	pop cx    
	mov al, 1

	mov ah, 0x13
	int 0x10
	ret

; DI = String | EXIT: AX = length
strlen:
	mov cx, 0xFFFF
	mov al, 0
	repne scasb

	mov ax, 0xFFFE
	sub ax, cx
	ret

; AL = Character
toupper:
	cmp al, 97
	jl _tuEnd
	cmp al, 102
	jg _tuEnd

	sub al, 32

	_tuEnd:
	ret

; AL = Character
tonumber:
	cmp al, 48
	jl _tnEnd
	cmp al, 57
	jg _tnNaN
	
	sub al, 48
	jmp _tnEnd
	
	_tnNaN:
	cmp al, 65
	jl _tnEnd
	cmp al, 70
	jg _tnEnd
	
	sub al, 55
	
	_tnEnd:
	ret

; AL = Character
isnumber:
	cmp al, 48
	jl _isnNaN
	
	cmp al, 57
	jg _isnChar
	
	ret
	
	_isnChar:
		cmp al, 65
		jl _isnNaN
		cmp al, 70
		jg _isnNaN

		ret

	_isnNaN:
	mov al, 0
	ret

_procsEnd:
