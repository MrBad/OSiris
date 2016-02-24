;; ---[ string.asm
;; asta include cateva functii absolut necesare pt inceput de manipulare a stringurilor 
;; si a memoriei

%include "cfg.inc"

%define _string_entry 0

[BITS 32]
[SECTION .text]

global memcpy
global strlen
global pprint
global bin2hex
global bzero
global bin2hexall

;___________________________________________________________________
;	memcpy 	-	copy from source to destination n bytes of data	
;
;	ds:esi	-	sursa
;	es:edi	-	destinatie
;	ecx		-	numar de biti de copiat
;___________________________________________________________________
memcpy:
	pusha
	pushf

.chrcpy:
	lodsb						;   al <- [ds:esi], inc esi
	stosb						;	al ->[es:edi], inc edi
	loop .chrcpy				; dec ecx jmp chrcpy
		
	popf
	popa
	
	ret						;	else return
	
;___________________________________________________________________
;
;	strlen	-	calculate the length of a null terminated string
;	ds:esi	-	source	of null terminated string
;	return  -	ecx	= number of bytes read
;				use it in debug
;___________________________________________________________________
strlen:
	push esi				; this was a bug
	
	xor ecx, ecx			; ecx=0
	push eax

.cntbt:
	inc ecx					; ecx++
	lodsb					;	al <- [ds:esi]; inc esi
	or al, al				; al=0?
	jnz .cntbt				; if al != 0 goto cntbt
	dec ecx					; the length is without zero

	pop eax
	
	pop esi
	ret						; else return the value
;___________________________________________________________________
;
;	pprint	-	print an null terminated string onto screen
;	ds:esi	-	source	of null terminated string
;	
;				use it in debug
;___________________________________________________________________
pprint:
	push eax

	mov eax, Dseg				; 4 giga seg base to zero
	mov es, eax
	mov edi, VMEM				;	VMEM is ponter to video memory

.charrp:
	lodsb						;	al <- [ds:esi], inc esi
	stosb						;	[es:edi] <- al, inc edi
	mov byte [es:edi], 0x02		;   culoare verde pe fundal negru 
	inc edi
	or al,al
	jnz .charrp

	pop eax
	ret							; 15 min sa imi dau seama ca am uitat un ret :)
	
;___________________________________________________________________
;
;	bin2hex	: converteste din binar in hexa ... folosit in debug
; 			  un byte
;	ds:esi	-	bin 2 convert
;	returneaza in bx XXh, inc esi
;___________________________________________________________________
bin2hex:
	push eax
										; in functia asta cam citesti de la dreapta la stanga
	xor ebx, ebx						; ca arabii, da' las' ca o sa facem noi una mai dajteapta
	xor eax, eax
	lodsb								; al <- [ds:esi], inc esi
	push eax
	and al, 0xF0						; decupam primii 4 biti
	shr al, 4							; msb
	add eax, hextable
	mov bh, [eax]						; vezi cu little endian

	pop eax
	and	al, 0x0F						; lsb
	add eax, hextable
	mov bl, [eax]						; cl = lsb - two little endian
	  
	pop eax
	ret
	hextable	db	"0123456789ABCDEF"

;___________________________________________________________________
;
;	bzero	- sterge (pune 0) o portiune de memorie
;	es:edi	- destinatia in memorie
;	ecx		- cati bytes?
;
;___________________________________________________________________  
bzero:
  push eax
  xor eax,eax

.nextbyte:
  stosb					; [es:edi] <- al, inc edi
  loop .nextbyte

  pop eax  
  ret	

;___________________________________________________________________  
;	bin2hexall - afiseaza pe ecran un dump hexa a unei zone de mem
;				 atentie ca byte-sii vin invers :)
;	esi < zona de memorie de dumpat
;	ecx < numarul de bytes, mai mic decat un ecran (80*24)
;___________________________________________________________________  
bin2hexall:
	push eax	
	push ebx
	
	mov eax, buff	;dest
	cmp ecx, buff_size
	jb .exit
.b1
	call bin2hex
	mov word [eax], bx
	add eax,2
	loop .b1
	
	mov byte [eax], 0
	mov esi, buff
	call pprint

	pop ebx
	pop eax
.exit:
	ret
	
buff db (80*4)
db 0
buff_size EQU ($ - buff - 1)
