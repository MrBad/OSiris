; file idt.asm
; contine functii referitoare la tabela de intreruperi a sistemului
;idt:
;	word	offset_low catre functie
;	word	selector
;	word	settings
;	word	offset high
;
;idtr:
;	word	limit
;	dword	*idt


%define _idt_entry	0

[bits 32]
[section .text]

%include "idt.inc"
%include "cfg.inc"
%include "memory.inc"
%include "string.inc"

global idt_setup
global load_idt
global set_interupt_vector
global get_interupt_vector


;	load_idt - incarca tabela globala de intreruperi
;
;
load_idt:
;  push eax
;  mov eax, [idt_ptr]
;  lidt[eax]
;  pop eax
  ret


;	idt_setup	-	aloca o zona de memorie pentru tabela de intreruperi si 
;					salveaza in idt_ptr inceputul ei
;				-	se stie: un descriptor de intr are 8 bytes
;
idt_setup:
	push eax
	push esi
	
	mov eax, idt_nr				; numarul de intreruperi care le vrem, definit 
	imul eax, 8					; in cfg.inc (100)
	call mmaloc
	or esi, esi
	jz .fail
  	
	mov [idt_ptr], esi
	mov [idtr+2], esi				; scriu in idtr belea ca scriam la idtr+4 <- aici era buba
	lidt [idtr]

	pop esi
	pop eax	
	ret

.fail:							; fatal -  nu pot sa initializez intreruperile
    mov esi, msg_cannot_mmaloc
    call pprint
    jmp $



;	set_interupt_vector 	-	seteaza o intrerupere 
;	in:
;		eax	- numarul intreruperii
;		ebx - pointer catre inceputul functiei de tratare a intreruperii
set_interupt_vector:
	push esi

	cmp eax, idt_nr
	jg .err

	mov esi, [idt_ptr]			; pointer catre inceputul tabelului de intr
	imul eax, 8					; inmultesc intreruperea cu 8 bytes
	add esi, eax				; adun, esi acum pointeaza catre inceputul descriptorului intreruperii eax :)
	mov word [esi], bx			; LSB offset selector
	mov word [esi+2], Cseg		; segmentul
	mov word [esi+4], 0x8e00	; flagul
	shr ebx, 16					; in ebx acum MSB
	mov word [esi+6], bx
jmp .debug
	mov eax, 1
.back:
	pop esi
	ret
.err:
	xor eax, eax
	jmp .back
.debug:
	mov eax, esi	; intorc zona de mem unde e tabela de intr
	jmp .back


;	get_interupt_vector		-	intoarce pointerul catre functia de tratare a intreruperii X
;	in:
;		eax - numarul intreruperii
;	out:
;		esi - pointer catre inceputul zonei de memorie unde se afla functia (suna ca draq)
;		eax - selectorul implicit
get_interupt_vector:
	push edi
	
	xor esi, esi
	
	mov edi, [idt_ptr]
	imul eax, 8
	add edi, eax
	
	mov word ax,[edi+6]		; offs MSB
	shl eax, 16				
	mov word ax, [edi]		; offs LSB
	mov esi, eax
	mov word ax, [edi+2]	; selectorul 

	pop edi
ret


[section .data]
idt_ptr		dd	0
msg_cannot_mmaloc		db	"+ Fatal, cannot alloc memory for interrupt descriptor table! halt",0

idtr:
	dw	(800) - 1			; limita idt
	dd	0					; unde incepe tabelul cu intreruperi in memorie? - o sa rescriu asta in mem


;//EOF
