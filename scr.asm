;	implementeaza screen-ul
;
;
%define _scr_entry 0


[bits 32]
[section .text]

%include "cfg.inc"
%include "scr.inc"
%include "memory.inc"
%include "kbd.inc"

global	scr_create_screen
global	scr_load_screen
global	scr_save_screen
global	scr_cls
global	scr_set_cursor
global	scr_put_char
global	scr_put_string
global	scr_move_cursor_forward
global	scr_move_cursor_back
global	scr_move_cursor_up
global	scr_move_cursor_down
global	scr_line_scroll_down
global	scr_line_scroll_up

;	scr_create_screen - creeaza un ecran virtual
;	IN	:	ebx		pointer catre structura scr		
;	OUT	:	eax		1 - OK, 0 - ERROR
scr_create_screen:
	push ecx	

	;scr lastx, lasty
	mov word [ebx+scr.lastx], 0		; pozitia ultimului chr este la X si Y
	mov word [ebx+scr.lasty], 0
	
	;dimensiuni ecran
	mov ax, [max_x]
	mov [ebx+scr.maxx], ax
	mov ax, [max_y]
	mov [ebx+scr.maxy], ax
	
	;cursor init
	mov word [ebx+scr.crsx], 0
	mov word [ebx+scr.crsy], 0
	
	;setare atribut fundal
	mov byte [ebx+scr.attr],0x07
	
	;activ ? - 0 - nu
	mov byte [ebx+scr.activ],0
	
	;alocam memorie pt acest screen
	mov eax, [max_x]
	mov ecx, [max_y]
	imul ecx 					; eax=eax*ecx
	call mmaloc
	or esi, esi
	jz .fail
	mov [ebx+scr.mm], esi
	call scr_cls 				; sa stergem screenu' :)	
	mov eax, 1							; all OK

.back:
	pop ecx
	ret

.fail:
	xor eax, eax
	jmp .back

;	scr_load_screen		-	incarca din ecranul virtual in cel real
;	IN	:	ebx - pointer catre structura scr
;
scr_load_screen:
	push esi
	push edi
	push ecx
	push eax
	xor eax, eax
	xor ecx, ecx
	
	cmp byte [ebx+scr.activ],0
	je .bye

	mov edi, 0x0B8000		; destinatie
	mov esi, [ebx+scr.mm]	; sursa
	mov  ax, [ebx+scr.lastx] 
	mov  cx, [ebx+scr.lasty]
	imul ecx
	mov ecx, eax	

	rep movsw
	
.bye:
	pop eax
	pop ecx
	pop edi
	pop esi
	ret

;	scr_save_screen - salveaza acest ecran 
;	IN	:	ebx pointer catre structura scr
;
scr_save_screen:
	push esi
	push edi
	push ecx
	push eax
	xor eax, eax
	xor ecx, ecx

	mov esi, 0x0B8000		; sursa
	mov edi, [ebx+scr.mm]	; destinatia
	mov  ax, [ebx+scr.lastx] 
	mov  cx, [ebx+scr.lasty]
	imul ecx
	mov ecx, eax	

	rep movsw
	
	pop eax
	pop ecx
	pop edi
	pop esi
	ret

;	scr_cls	-	clear screen
;	IN	:	ebx	pointer catre struc scr
;
scr_cls:
	push edi
	push ecx
	push eax
	
	movzx eax, word [ebx+scr.maxx]
	movzx ecx, word [ebx+scr.maxy]
	imul ecx
	mov ecx, eax

	mov edi, [ebx+scr.mm]	; set destination
	mov ah,  [ebx+scr.attr]	; attribut
	xor al, al				; spatiu

	rep stosw				; umplem
	
	mov al, [scr.activ]
	cmp al, 0				; este ecran activ?
	jnz	.fillscr			; dap , sari
	
.back:
	pop eax
	pop ecx
	pop edi
	ret
.fillscr:
	call scr_load_screen	; reafisam ecranul
	jmp .back



;	scr_set_cursor	-	seteaza hardware cursorul apeland portul 0x03d4
;	IN	:	ebx - pointer to Vscreen struct
;
scr_set_cursor:
	push eax
	push edx
	push ecx
	xor ecx, ecx
	xor eax, eax
	
	cmp byte [ebx+scr.activ], 0
	je .bye 

	mov ax, [ebx+scr.crsy]
	mov dx, 80
	imul dx
	mov cx, [ebx+scr.crsx]
	add eax, ecx
	mov ecx, eax
	
	mov dx, 0x03d4

	mov al, 0x0e
	mov ah, ch					; high byte from pos
	out dx,ax
	
	mov al, 0x0F
	mov ah, cl					; low byte from pos
	out dx, ax
	
.bye:	
	pop ecx
	pop edx
	pop eax
	ret

;	scr_put_char	- pune un caracter pe ecranul virtual
;	IN	:	ebx	ptr 2 scr
;			dl	character
scr_put_char:
	push eax
	push ecx

	xor eax, eax
	xor ecx, ecx	
	
	cmp dl, 0x0d						; \n new line ?
	jz	.cr
	
	cmp dl, 0x08						; \b backspace?
	jz .bspace
	
	cmp dl, 0x09						; \t tab?
	jz .tab
	
	cmp dl, K_DOWN						; implements cursor 
	jz .kdown
	cmp dl, K_UP
	jz .kup
	cmp dl, K_LEFT
	jz .kleft
	cmp dl, K_RIGHT
	jz .kright							; end cursor
	
			
.l0:
	push edx
.l1:
	mov ax, [ebx+scr.crsy]
	mov cx, 80
	imul cx
	mov cx,	[ebx+scr.crsx]
	add eax, ecx 
	shl eax, 1							;	pentru ca avem cate 2 bytes pt un chr
	
	mov edi, [ebx+scr.mm]
	add edi, eax

	pop edx
	mov al, dl							; chr
	mov ah, [ebx+scr.attr]				; atribut
	mov word [edi], ax
	call scr_move_cursor_forward

	cmp byte [ebx+scr.activ], 0			;e activ?
	jnz .refresh

.back:	
	pop ecx
	pop eax
	ret
.refresh:
	call scr_load_screen
	jmp .back	
.cr:	
	call scr_move_cursor_down
	jmp .back
.bspace:
	call scr_move_cursor_back
	xor dl, dl						;	mov dl, ' '
	call scr_put_char
	call scr_move_cursor_back
	jmp .back
.tab:
	mov ecx, kbd_tab_spaces			; cate spatii pt tab (def in cfg.inc)
	mov dl, ' '
.ltab:
	call scr_put_char
	loop .ltab
	jmp .back
.kdown:
	call scr_move_cursor_down
	jmp .back
.kup:
	call scr_move_cursor_up
	jmp .back	
.kleft:
	call scr_move_cursor_back
	jmp .back
.kright:
	call scr_move_cursor_forward
	jmp .back
			
;	scr_put_string	- pune un string in ecranul virtual
;	IN	:	ebx		pointer catre structura scr
;			esi		pointer catre string-ul terminat in 0
scr_put_string:
	push eax
	push edx

	; is active?
	mov al, byte [ebx+scr.activ]
	push eax
	mov byte [ebx+scr.activ], 0

.chrloop:
	lodsb
	or al, al
	jz .gata
	mov dl, al
	call scr_put_char
	jmp .chrloop

.gata:
	pop eax
	mov [ebx+scr.activ],al
	call scr_load_screen

	pop edx
	pop eax
	ret
	
	
;	scr_move_cursor_forward	- muta cursorul cu o pozitie inainte si trece la urm linie daca e nevoie
;	IN	:	ebx	ptr catre scr
;
scr_move_cursor_forward:
	cmp word[ebx+scr.crsx], 79		; e max?
	jz .scrlline					; e la capat de linie, sari
		
	inc word [ebx+scr.crsx]			;x=x+1
	
	call scr_set_cursor
.back:
	ret
	
.scrlline:
	call scr_move_cursor_down
	jmp .back
	
	
	
;	scr_move_cursor_down	-	muta cursorul pe linia urmatoare
;	IN	:	ebx	ptr scr
;
scr_move_cursor_down:
	cmp word[ebx+scr.crsy], 24
	jz	.scrldn					; eo screen?

	inc word [ebx+scr.crsy]		; y=y+1
	mov word [ebx+scr.crsx], 0

	call scr_set_cursor
	
.back:	
	ret

.scrldn:
	call scr_line_scroll_down
	jmp .back	

;	scr_move_cursor_back	-	muta o pozitie inapoi cursorul
;	IN	:	ebx ptr scr
;
scr_move_cursor_back:
	cmp word[ebx+scr.crsx],0
	jz .upline 
	
	dec word [ebx+scr.crsx]
	call scr_set_cursor

.back:
	ret
.upline:
	mov word [ebx+scr.crsx], 79
	call scr_move_cursor_up
	jmp .back


;	scr_move_cursor_up	- muta un rand mai sus cursorul
;	IN	:	bx scr ptr
;
scr_move_cursor_up:
	cmp word [ebx+scr.crsy], 0
	jz .scrlup
	
	dec word [ebx+scr.crsy]
	call scr_set_cursor
.back:
	ret
.scrlup:
	call scr_line_scroll_up
	jmp .back

;	scr_scroll_down	-	scroll down
;	IN	:	ebx - ptr 2 scr struct
;
scr_line_scroll_down:
	push edi
	push esi
	
;	movzx eax, word[ebx+scr.maxy]
;	movzx ecx, word[ebx+scr.maxx]
;	imul ecx							; size of screen
	mov ecx,(80*25)	

	mov edi, [ebx+scr.mm]	
	mov esi, edi
	movzx eax,word [ebx+scr.maxx]
	shl eax, 1
	add esi, eax
	rep movsw

	mov word [ebx+scr.crsy], 24				; ioi ce najpet aici
	mov word [ebx+scr.crsx], 0				; cah cah cah
	call scr_set_cursor	
	call scr_load_screen	

	pop esi
	pop edi
	ret

;	scr_scroll_up	-	scroll up
;	unimplemented :)
;
scr_line_scroll_up:
ret
	
[section .data]	

max_x		dd 	80						; double pt ca sunt pointeri
max_y		dd	25						; -----------//-------------
is_active	db	0
