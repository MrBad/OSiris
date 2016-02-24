;Antionline OS
;(c)2004 MrBadNewS and Microbul concepts
;Boot sequence
;compilare nasm -f bin boot.asm
;scriere floapa dd if=boot of=/dev/fd0
;biosul ceteste ce epe sector 1 la adresa 0000:7c00h, adeca exact 512 bytes, bootloaderul
;booteaza, scrie mesaj, incarca la adresa 1000:0000 (cs:offset) ceea ce se afla pe sector 2 pe floapa
;sare la adresa 1000:0000 , acolo unde se afla programul incarcat, practic il executa

[BITS 16]
org 7c00h				; BIOS-ul incarca bootul in 0000:7c00 h

reset_fd:
	xor ax,ax			; ax=0
						; dl adeca device-ul de pe care bootez il seteaza biosul
	int 13h				; bios floapa, cu functia reset(ah=0)
	jc reset_fd			; jump if carry eroare, repeta

err_read:
	mov ax,1000h		; 1000h:0
	mov es,ax			; es:bx - unde incarc in memorie ce cetesc de pe floapa
	xor bx,bx			; inceputul ultimului seg de 64 de k din primii 4 MB

	mov ah,2			; functia read
	mov al, 65			; 512 * 18 = ? :)
	mov ch,0			; cilindrul 0
	mov cl,2			; sector 2 - pe primul se gaseste boot-ul - 512 bytes
	xor dx,dx			; dh-head0, dl-device-ul 0=fd0
	int 13h				; int bios floppy
	jc $				; repeta daca sunt erori

	mov ax, cs
	mov ds, ax	
	mov es, ax
	jmp mein
;*********************************************************************************************	
wait_A20:
	jmp $+2
	jmp $+2
	in al, 64h		;; citest status
	test al, 2		;; este bitul 2 ON?
	jnz wait_A20	;; da este 1 nu e in regula astept	
	ret

;*****	
mein:
	
	; stingem orice intrerupere
	
	cli
	; aici activam linia a 20 
	
	call wait_A20
	mov al, 0D1h
	out 64h, al
	call wait_A20
	mov al, 0DFh
	out 60h, al
	call wait_A20
	
	; testam daca a activat-o
	
	mov al, 0D0h			; comanda = read output port
	out 64h, al
	
	xor ax, ax
	in al, 60h				; cetesc status
	
	bt ax, 1				; e setata a 20 ? bit 1
	jc a20ok				; dap , afiseaza
	jmp $		;	ne oprim aici ca nu e ceva in regula
	
a20ok: sti
		
	; scriu bazele segmentelor, le puteam lasa zero daca se incarca de la 0x0000:xxxx, dar...
	; asta o sa fie corpul kernelului, sau functia main
	; intai descriptorul cseg. - incep la cs:0000 (te asigur ca cs e 1000h asa incarca loaderul)

	xor eax, eax					; eax = 0
	mov ax, cs						; eax = cs
	shl eax, 4						; eax = eax * 16

	mov dword [GDT.cseg+2], eax		; scriu baza dar rescriu atributul cu instructiunea asta
	mov byte  [GDT.cseg+5], REseg   ; asa ca scriu si atributul - read only
	
	; datele nu le relocatez ca vreau sa scriu de la 0 :))
	; adeca sa am un mare segment de 4G incepand cu offset 0 
	
	xor edx, edx					; edx = 0
	mov	dx, GDT						; edx <- ofs gdt
	add eax, edx					; eax <- seg+ofs GDT = baza GDT
	mov dword [GDT+2], eax
	
	; ok dupa atata munca incarc tabela
	lgdt [GDT]
	
	; trec in mod protejat
	mov eax, cr0
	or  al, 1
	mov cr0, eax
	
	; far jump ca cs sa fie incarcat din tabela :) (cacs)
	jmp dword	Cseg:pmode

[BITS 32]
pmode:
	mov eax, Dseg
	mov ds,  eax
	mov es,  eax
	mov fs,  eax
	mov gs,  eax

	jmp Cseg:0x010000			; salt la intrarea in kernel

%include 'gdt.inc'
times 510 - ($ - $$) db 0
dw 0x0AA55