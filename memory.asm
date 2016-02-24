;	functii utile de alocare/ dealocare de memorie
;	agentul de memorie
;	cream o tabela(de memorie), in care vom tine informatii referitoare la startul(deplasamentul fatza de 0)
;	portiunii de memorie, dimensiunea acestei portiuni, si informatie referitoare la atributul ei
;	(adeca daca este utilizata sau nu, daca a mai fost utilizata[asta pt viitor cand o sa aiba un 
;	sistem de defragmentare a ei - done :) ])	
;	Tabela va arata asa [start_adress1][size1][stat1][start_adress2][size2][stat2]...
;	in mod normal ne trebuie 32 de biti pt start_adress, 32 pt size (4GB, flat), 2 biti pt stat
; 	dar pt simplificare folosim 1 byte pt stat
;
;link1 - eax points here after mm_init->
;	start_address of allocated memory1	[dword]			pointer to beggining of mem alocated		
;	size of allocated memory			[dword]			what size do we want (eax remember)
;	status of allocated memory			[byte]			stat_free or stat_used
;link2
;	start_address of allocated memory2	[dword]
;	.
;	.
;	[fute] points here ->				000000000000
;	multe sticle de bere ->
;

%include "cfg.inc"
%define _mm_entry 0
%include "string.inc"
%include "memory.inc"

stat_free	EQU 0
stat_used	EQU	1

[bits 32]
[section .text]

global mm_init
global mmaloc
global mmfree
global mmdefrag
;_____________________________________________________________________________________
;	memory_init	 -  initializeaza tabela de memorie
;					eax, returneaza pointer catre inceputul tabelei;;;; pt debug :)
;_____________________________________________________________________________________

mm_init:
	push ecx
	push esi
	push edi
	
	mov edi, mm_table					; incarc unde incepe memoria,  edi - destination 4 bzero
	mov ecx, mm_table_size				; lungimea tabelei in memorie
	call bzero							; initializam (fill zero)
	mov dword [fute], mm_table			; mare buba o fost aici, pt ea a trebuit sa fac rutina de dump la memorie
										; adeca suntem la inceput in tabela !!!! NU INCEPUTUL MEMORIEI, :)
	mov esi,  [fute]					; initializam tabela si bagam primul entry (toata memoria libera)
	mov dword [esi], mm_start			; pointand spre o zona care incepe la mm_start
	mov dword [esi+4], (mm_end - mm_start)	; cu lungimea de
	mov dword [esi+8], stat_free			; si statutul free
											
	add dword [fute], 9						; first unnalocated table entry creste ;

	mov eax, mm_table						; intoarcem un pointer catre inceputul tabelei in memorie
	pop edi
	pop esi
	pop ecx
	ret	
; end of mem_init

;_____________________________________________________________________________________
;	mmaloc 	-	aloca un segment de memorie de
;	in		-	eax numar de bytes de alocat 
;	out		-	esi returnez in esi pointer catre zona alocata 
;				sau zero daca nu este alocata
;_____________________________________________________________________________________
mmaloc:
	push ebx
	push ecx
	mov esi, mm_table
	
.is_free:	
	mov byte bl,[esi+8]				; mutam statusul
	cmp bl, stat_free				; e free?
	jne .next_block					; nu -> incercam urmatorul bloc
									; da, continue
	mov ebx,[esi+4]					; mutam ce size avem in acest segment >ebx
	cmp ebx, eax					; comparam cu size-ul ce ne trebe
	jb	.next_block					; sari daca acest bloc este prea mic (below) si cauta urmatorul
	jg  .resize_block				; sari daca e prea mare
	
.all_OK:							; scriu noul segment care e egal cu ce vreau :) putin probabil
	; entry-ul ramane acelasi si size-ul, doar marchez ca bloc ocupat
	mov [esi+4], eax				; lungimea
	mov byte [esi+8], stat_used
.bye:
	mov dword ecx, [esi]					; intorc pointerul nu pointerul pointerului :)
	mov esi, ecx
	pop ecx
	pop ebx
	ret			

.next_block:
	add esi, 9						; magic number, 9 bytes = lungimea unui bloc descriptor
	cmp esi, (mm_table_end)
	jg .fail
	jmp .is_free

.resize_block:						; acel bloc mare il splituim in 2	
	sub ebx, eax					; ebx = ebx - eax
	mov ecx, [fute]					; 
	cmp ecx, (mm_table_end)
	jg  .fail
	mov [ecx+4], ebx				; scriu in tabela noua lungime
	mov byte [ecx+8], stat_free		; cat a mai ramas
	mov ebx, [esi]					; unde incepe ast de ii dau split
	add ebx, eax					; unde se termina
	mov [ecx], ebx					; scriu in tabela
	add dword [fute], 9
	jmp .all_OK	
	
.fail:
	xor esi, esi
	jmp .bye	
; end of mmaloc	

;_____________________________________________________________________________________
;	mmfree	-	elibereaza un bloc de memorie
;	in		-	edi (destination) pointeaza catre zona de memorie de eliberat
;	out		-	eax - numbytes freed, or 0 if fail
;_____________________________________________________________________________________
mmfree:
	push esi
	mov esi, mm_table

.try_again:
	mov eax, [esi]							; [esi] contine pointerul alocat deja si care noi il mentinem in tabela;  sa mori tu ca ai dat cu cursorul pana aici si nu ai word wrap :)
	cmp eax, edi							; il comparam cu ce cere baiatu'
	jne .next_block							; jmp if not equal
	
	mov byte [esi+8], stat_free						; am gasit in tabela entry-ul, il marcam ca liber
											; free your mind, we continue to hack
											; free bill
	mov eax, [esi+4]						; o sa returnam numarul de bytes eliberati
;;;;call mmdefrag							; sa defragmentam memoria, ca sa fie destula sa nu dea ca in alte so ca nu are memorie :) cand noi avem 128 de rami poate

.bye:
	pop esi									;)
	ret	
.fail:
	xor eax, eax							; eax e zero, eroare 
	jmp .bye
.next_block:
	add esi, 9
	cmp esi, (mm_table_end)					; este sfarsitul tabelei ?
	jg .fail								; daca esi e mai mare da, fail
	jmp .try_again							; nu, repeta, gasim entry-ul in tabela?

;end of mmfree

;_____________________________________________________________________________________
;	mmdefrag	-	va cauta in tabela 2 locatii de memorie apropiate libere
;					si le va "lipi" intr-un singur bloc mare
;					de cate ori gaseste astfel de 2 blocuri, procesul se reia (recursiv)
;					TO BE DONE! este foarte imp cand vom avea nevoie de mai multa mem
;					DOS-ul de ex nu avea astfel de proces si de aia crapa repede
;_____________________________________________________________________________________
mmdefrag:
;	push eax
.try_again:	
  	mov esi, mm_table

.is_free:						; caut primul entry care e liber
	mov byte bl, [esi+8]		
	cmp bl, stat_free
	jne .next_block
	
	mov eax, [esi]				; entry-ul primului segment liber
	add eax, [esi+4]			; se termina la adresa de memorie data de eax
	mov edi, mm_table
.is_any:						; caut daca exista vre-un segment care incepe la sfarsitul 	
								; primului segment si daca e liber
	mov ebx, [edi]
	cmp edi, [fute]
	jg .done	

	cmp ebx, eax				; sunt egale? cele 2 entry-uri?
	jne .s_is_any				; nu, cauta din nou
	
	mov byte cl, [edi+8]
	cmp cl, stat_free
	jne .next_entry_a
	; dap
	; lipim cele 2 segmente, mutam toata tabela mai jos cu 9 bytes si scadem fute cu 9
	; esi - inceputul 1 seg in tab edi - inceputul la al 2-lea seg in tab
	
	mov eax, [edi +4]				; lung la al 2-lea
	add [esi+4], eax				; 1 seg il marim cu lung la al 2-lea


	mov ecx, [fute]					; 1st unnalocated
	mov eax, edi
;add eax, 9
	sub ecx, eax
	mov esi, edi					; sf la al doilea
	add esi, 9

	mov edi, esi
	sub edi, 9
	call	memcpy
	jmp .try_again					; recursivitatea,daca a lipit, pai sa mai incerce poate mai gaseste segmente
								
.s_is_any:
	add edi, 9
	cmp edi, [fute]
	jg .done
	jmp .is_any	

.done:	
;	pop eax							; wonderful
									; wow, i did it :) it really sux:)
	nop								; asta e ca sa imi trag sufletul micro :))))	
	ret								; ar trebui sa beau o bere, nu credeam ca fac defraggerul

.next_block:
	add dword [esi], 9					; urmatorul entry
	cmp esi, mm_table_end
	jg  .done
	jmp .is_free						; back


.dump:
	jmp .done

.next_entry_a: 
	jmp .done							; aici ar trebui sa incercam cu alt entry
[section .data]
fute		dd	0					; first unnalocated table entry :)) cat de urata e limba romana

[section .bss]
mm_table			resb	(mm_table_size)			; spatiu rezervat tabelei
mm_table_end	EQU mm_table + mm_table_size		; unde se termina tabela de memorie
													; sau mm_table_end EQU $-mm_table :) the same
													
;//EOF