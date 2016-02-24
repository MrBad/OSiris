; pic.asm
; functii utile pentru controlul intreruperilor - mascare de intreruperi/demascare
; setare lucrul cu controlerul 8259  (pic)


%include	"cfg.inc"
%define		pic_entry 0
%include	"pic.inc"


[bits 32]
[section .text]

global pic_reprogram
global pic_irq_get_mask
global pic_irq_set_mask


;______________________________________________________________________________________________
;	pic_reprogram - remapeaza intreruperile 0x0-0x15 catre 0x20-0x2f
;	
;
;______________________________________________________________________________________________
pic_reprogram:
	push eax
  
	mov al, 0x11						
	out port_8259M, al					; initializarea masterului
	out port_8259S, al					; initializarea sclavului

	mov al,0x20							; intreruperea hardware de baza a masterului - 0x20
	out (port_8259M+1), al
	
	mov al, 0x28						; intreruperea hardware de baza a sclavului - 0x28
	out (port_8259S+1), al
	
	mov al, 0x04						; primul 8259 e master	
	out (port_8259M+1), al			
	
	mov al, 0x02						; al doilea 8259 e sclav
	out (port_8259S+1), al
	
	mov al, 0x01
	out (port_8259M+1), al				; mod 8086 pentru amandoua
	out (port_8259S+1), al
	
	mov al, 0xFF
	out (port_8259M+1), al				; mascam toate intreruperile pt moment
	out (port_8259S+1), al				; pe ambele picuri
	
	pop eax
	ret		

;______________________________________________________________________________________________
;	pic_irq_set_mask	seteaza mask-ul pentru master si slave
;	in 	: 	ax			- ah - master
;	out	: none			- al - slave	
;______________________________________________________________________________________________
pic_irq_set_mask:
	out (port_8259M+1), al			; LSB
	mov al, ah
	out (port_8259S+1), al			; MSB
	ret

;______________________________________________________________________________________________
;	pic_irq_get_mask		intoarce in ax mask-ul atat pt master cat si pt sclav
;	in	: none				//reversul functiei de mai sus :)
;	out	:	ax				mask
;______________________________________________________________________________________________
pic_irq_get_mask:
	in al, (port_8259S+1)			; MSB
	mov ah, al
	in al, (port_8259M+1)			; LSB
	ret	
	