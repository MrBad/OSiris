[BITS 32]
%define _gdt_entry 0
;************************/ Sectiunea Tabelei Globale a Descriptorilor /************************;
; 0x0
GDT:									; null desc 
			dw GDT_Lg					; limita GDT
			dd GDT						; unde e in memorie , o sa rescriu ca sa fie relocatabil
			dw 0
; 0x08			
.cseg:	dw	0xFFFF			; limita
		dw	0x0				; baza low 24 bits	--|
		db	0x0				; baza hi 24 bits	  |--> adresa pe 24 de biti a inceputului segmentului de memorie
							; le voi rescrie	--|
		db	REseg			; atributul segmentului - read and execute
		dw	0x00CF			; se refera la faptul daca e tabela locala sau globala(0), nivelul de privilegiu (0 = max)

; 0x10							
.dseg:	dw	0xFFFF			; un mare segment de 4 giga de date,
		dw	0x0				; incep la 0x0 - bhi --|
		db	0x0				; blow				 --|--> raman 0 ca sa imi fie mai usor
		db	RWseg			; Read/Write
		dw	0x00CF			; granulatie
		
GDT_Lg	EQU	$-GDT-1			; lungimea tabelei
ROseg	EQU	10011000b		; atribut segment Read Only
REseg	EQU	10011010b		; atribut segment Read/Execute		
RWseg	EQU 10010010b		; atribut segment Read/Write
							
Cseg	EQU GDT.cseg-GDT	; unde e localizat seg de cod in tabela globala (te asigur ca e 0x08, dar e mai clar asa)
Dseg	EQU GDT.dseg-GDT	; unde e localizat seg de date ala mare si frumos
