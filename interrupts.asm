; implements exceptions
; int0x2 - intel reserved - unimplemented

;int0x0 - divide by zero - fault
;int0x1 - debug - trap
;int0x3 - breakpoint - trap
;int0x4 - overflow - trap
;int0x5 - bounds check - fault
;int0x6 - bad opcode - fault
;int0x7 - no coprocesor - fault
;int0x8 - double fault - abort
;int0x9 - coprocessor overrun - abort
;int0xA - invalid TSS segment - fault
;int0xB - segment not present - fault
;int0xC - stack fault - fault
;int0xD - general protection fault - fault 
;int0xE - page fault - fault
;int0x10 - coprocesor error - fault

%define interrupts_entry 0
%include "idt.inc"
%include "string.inc"

global setupfaults


; setupfaults - seteaza intreruperile de la 0x0 la 0x10
;
;
setupfaults:
	push eax
	push ebx

	mov eax, 0x0
	mov ebx, int0x0
	call set_interupt_vector
	mov eax, 0x0
	mov ebx, int0x0
	call set_interupt_vector
	mov eax, 0x0
	mov ebx, int0x0
	call set_interupt_vector
	mov eax, 0x01
	mov ebx, int0x1
	call set_interupt_vector
	mov eax, 0x03
	mov ebx, int0x3
	call set_interupt_vector
	mov eax, 0x04
	mov ebx, int0x4
	call set_interupt_vector
	mov eax, 0x05
	mov ebx, int0x5
	call set_interupt_vector
	mov eax, 0x06
	mov ebx, int0x6
	call set_interupt_vector
	mov eax, 0x07
	mov ebx, int0x7
	call set_interupt_vector
	mov eax, 0x08
	mov ebx, int0x8
	call set_interupt_vector
	mov eax, 0x09
	mov ebx, int0x9
	call set_interupt_vector
	mov eax, 0x0A
	mov ebx, int0xA
	call set_interupt_vector
	mov eax, 0x0B
	mov ebx, int0xB
	call set_interupt_vector
	mov eax, 0x0C
	mov ebx, int0xC
	call set_interupt_vector
	mov eax, 0x0D
	mov ebx, int0xD
	call set_interupt_vector
	mov eax, 0x10
	mov ebx, int0x10
	call set_interupt_vector
	;call 911
	
	pop ebx
	pop eax
	ret

; dumpallregs - dumpeaza toti registrii procesorului
; in none ret none :)
;
;
dumpallregs:
	push esi
	push edi

	mov edi, msg_dmp+4					; campul eax
	call hexeax
	
	mov eax, ebx
	add edi, 12
	call hexeax
	
	mov eax, ecx
	add edi, 12
	call hexeax
	
	mov eax, edx
	add edi, 12
	call hexeax
	
	mov eax, [esp+12]	; esi - salvat in intrerupere inainte de afishare mesaj
	add edi, 12
	call hexeax
	
	pop eax				; edi :)
	add edi, 12
	call hexeax
	
	mov eax, ds
	add edi, 12
	call hexeax
	
	mov eax, es
	add edi, 12
	call hexeax

	mov eax, gs
	add edi, 12
	call hexeax

	mov eax, fs
	add edi, 12
	call hexeax

	mov eax, ss
	add edi, 12
	call hexeax

	mov eax, esp
	add edi, 12
	call hexeax

	mov eax, ebp
	add edi, 12
	call hexeax
	
	mov eax, [esp]
	add edi, 12
	call hexeax
	
	mov eax, [esp+4]
	add edi, 12
	call hexeax
	
	mov eax, [esp+8]
	add edi, 12
	call hexeax
	
	pop esi
	call strlen				; ret in ecx strlen of msg @ esi	
	mov edi, blue_screen
	call memcpy				; copiez mesajul in screen

	mov esi, blue_screen
	call pprint

	ret
; hexeax - locala ia un registru si scrie in hexa continutul lui la adresa pointata de 
;			edi 
; in:	eax - 4 bytes :)	
; out:  [edi]...[edi+9] - hexascii
hexeax:
	push ebx
	push ecx
	
	add edi, 7						; ca sa nu scriem incepand cu LSB	
	mov [tmp], eax					; temp store
	mov bh, 8
.l1:	
	and eax, 0x0F					; am ramas cu ultimii 4 biti :)
	add eax, .hextable
	mov bl, [eax]					; bl is .hextable[eax]
	mov byte [edi], bl				; se poate cu xlat = traduce al din o tabela situata la bx...
	
	dec edi							; destination
	mov eax, [tmp]					; re-store :)
	shr eax, 4						; eax=eax/16
	mov [tmp], eax					; il salvez pt urmatoarea tura
	dec bh							; scad forul :)
	cmp bh, 0x0						; am ajuns la 0 ?
	jnz .l1							; de 8 ori ...
	
	add edi,9						; do not ask to explain this :) it is sucz
	
	pop ecx
	pop ebx
	ret	


.hextable	db "0123456789ABCDEF"


	
;
; all the rest bullshit, i know there was a shorter way to do this... but....
;

;int0x0 - divide by zero - fault
;
;
int0x0:
	push esi
	mov esi, msg_0x0
	call dumpallregs
	pop esi
	jmp $
	
;int0x1	- debug - trap
;
;
int0x1:
	push esi
	mov esi, msg_0x1
	call dumpallregs
	pop esi
	jmp $

;int0x3 - breakpoint - trap
;
;
int0x3:
	push esi
	mov esi, msg_0x3
	call dumpallregs
	pop esi
	jmp $
	
;int0x4 - overflow - trap
;
;
int0x4:
	push esi
	mov esi, msg_0x4
	call dumpallregs
	pop esi
	jmp $

;int0x5 - bounds check - fault
;
;
int0x5:
	push esi
	mov esi, msg_0x5
	call dumpallregs
	pop esi
	jmp $

;int0x6 - bad opcode - fault
;
;
int0x6:
	push esi
	mov esi, msg_0x6
	call dumpallregs
	pop esi
	jmp $

;int0x7 - no coprocesor - fault
;
;
int0x7:
	push esi
	mov esi, msg_0x7
	call dumpallregs
	pop esi
	jmp $

;int0x8 - double fault - abort
;
;
int0x8:
	push esi
	mov esi, msg_0x8
	call dumpallregs
	pop esi
	jmp $

;int0x9 - coprocessor overrun - abort
;
;
int0x9:
	push esi
	mov esi, msg_0x9
	call dumpallregs
	pop esi
	jmp $

;int0xA - invalid TSS segment - fault
;
;
int0xA:
	push esi
	mov esi, msg_0xA
	call dumpallregs
	pop esi
	jmp $

;int0xB - segment not present - fault
;
;
int0xB:
	push esi
	mov esi, msg_0xB
	call dumpallregs
	pop esi
	jmp $

;int0xC - stack fault - fault
;
;
int0xC:
	push esi
	mov esi, msg_0xC
	call dumpallregs
	pop esi
	jmp $

;int0xD - general protection fault - fault 
;
;
int0xD:
	push esi
	mov esi, msg_0xD
	call dumpallregs
	pop esi
	jmp $

;int0xE - page fault - fault
;
;
int0xE:
	push esi
	mov esi, msg_0xE
	call dumpallregs
	pop esi
	jmp $

;int0x10 - coprocesor error - fault
;
;
int0x10:
	push esi
	mov esi, msg_0x10
	call dumpallregs
	pop esi
	jmp $
;this code really sucks
[section .data]
  msg_0x0		db		"There was an divide by zero error (fault)             ",0
  msg_0x1 		db		"This is a debug - trap                                ",0
  msg_0x3 		db		"This is a breakpoint - trap                           ",0
  msg_0x4 		db		"This is a overflow - trap                             ",0
  msg_0x5 		db		"There was a bounds check error (fault)                ",0
  msg_0x6 		db		"There was a bad opcode error (fault)                  ",0
  msg_0x7 		db		"There was a no coprocesor error (fault)               ",0
  msg_0x8 		db		"Whois General Failure? - double fault error (abort)   ",0
  msg_0x9		db		"Whois General Failure? - coprocessor overrun (abort)  ",0
  msg_0xA 		db		"There was a invalid TSS segment error (fault)         ",0
  msg_0xB 		db		"There was a segment not present error (fault)         ",0
  msg_0xC 		db		"There was a stack fault error (fault) :)              ",0
  msg_0xD 		db		"There was a general protection fault error            ",0 
  msg_0xE		db		"There was a page fault error (fault)                  ",0
  msg_0x10		db		"There was a coprocesor error (fault)                  ",0

  blue_screen db	"                                                                                "
  msg_dmp			
		  db		"eax=00000000        ebx=00000000        ecx=00000000        edx=00000000        "
		  db		"esi=00000000        edi=00000000        ds =00000000        es =00000000        "
		  db		"gs =00000000        fs =00000000        ss =00000000        esp=00000000        "
		  db		"ebp=00000000        xx =00000000        xx =00000000        xx =00000000",0
  tmp				db 0,0,0,0,0,0,0,0,0