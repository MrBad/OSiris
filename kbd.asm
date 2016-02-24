;	implements - keyboard driver
;	
;
;
%define _kbd_entry 0

[bits 32]
[section .text]

%include "cfg.inc"
%include "kbd.inc"
%include "memory.inc"
%include "string.inc"
%include "scr.inc"
%include "pic.inc"
%include "idt.inc"

global kbd_init
global kbd_convert
global kbd_int

;pointer to kbd buffer, global var
global kbd_ptr_buf
;pointer catre ultimul element din buffer, global var
global kbd_ptr_buf_last		

;	kbd_init - initializeaza tastatura si bufferele
;	
;
kbd_init:
	push eax
	push esi

	mov ax, 0xFFFD
	call pic_irq_set_mask					; demascam int kbd
	
	mov eax, 0x21							; int 21 - 
	mov ebx, kbd_int						; handlerul kbd
	call set_interupt_vector				; setez intreruperea

	mov eax, kbd_buf_size					; definit in cfg.inc
	call mmaloc
	or esi, esi
	jz .fail
	
	mov [kbd_ptr_buf], esi					; salvez pointerul
	mov [kbd_ptr_buf_last], esi				; ultimul element e = cu primul
	
.bye:
	pop esi
	pop eax
	ret

.fail:
	xor eax, eax
	jmp .bye	
	
;	converteste scancodul :)
;	IN	:	eax	- scancode
;	OUT	:	eax - ascii ret
kbd_convert:
	add eax, kbd_table
	mov al, [eax]
	movzx eax, al
	ret
	
;	int 0x1 hardware remapped to  int 0x21				
;	
;
kbd_int:
	push eax
	push esi 
	push ebx
	push edx
	cli
	
	xor eax, eax
		
	in al, 0x60
	cmp eax, 0x080				; vrem doar codul cand se apasa tasta nu cand se elibereaza
	jg .end						; ex - ESC - la apasare genereaza 0x1b la ridicare - 0x9b
	
	call kbd_convert

	cmp al ,0
	jz .end							; iesi daca tasta nu e implementata (0 in tabela tastaturii)
	
	mov esi, [kbd_ptr_buf_last]
	mov ebx, [kbd_ptr_buf]
	add ebx, kbd_buf_size-1
	cmp esi, ebx					; buf overflow?
	jz .end							; dap, jump
	xor ah, ah						; put a zero after last char, our buf it will be an null terminated string
	mov [esi], ax					; salvez caracterul

	inc dword [kbd_ptr_buf_last]	; incrementez ptr catre ultimul element

.end:	
	mov al, 0x20
	out 0x20, al

	sti
	pop edx
	pop ebx
	pop esi
	pop eax
	iret
.special:
	jmp .end


[section .data]
kbd_table:
db		0, 0x1B, '1', '2', '3', '4', '5', '6'		; 0x1b - escape
db		'7', '8', '9', '0', '-','=', 0x08, 0x09		; 0x08 - backspace, 0x09 - tab
db		'q', 'w', 'e', 'r', 't', 'y', 'u', 'i'		; 0x0a - CR
db		'o', 'p', '[', ']', 0xd, 0, 'a', 's'
db		'd','f','g','h','j','k','l', ";"
db		"'", "`", 0, '\', 'z', 'x', 'c', 'v'
db		'b', 'n', 'm', ',', '.', '/',  0, 0
db		 0, ' ', 0, K_F1, K_F2, K_F3, K_F4, K_F5
db		 K_F6, K_F7, K_F8, K_F9, K_F10, 0, 0, K_HOME
db		 K_UP, K_PGUP, '-', K_LEFT, '5', K_RIGHT, '+', K_END
db		 K_DOWN, K_PGDOWN, K_INS, K_DEL,0,0,0, K_F12  

tmp	db 0,0,0
kbd_ptr_buf	dd	0
kbd_ptr_buf_last	dd 0