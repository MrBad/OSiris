[BITS 32]
[section .text]

global debugu
global _start
_start:

  cli

  ;init memory
  call mm_init

  ;init interrupts
  call idt_setup

  ;init hardware interrupts
  call pic_reprogram
  
  ;init faults
  call setupfaults

  ;kbd init
  call kbd_init
    
  sti


  mov eax, scr_size
  call mmaloc
  or esi, esi
  jz	end 

  mov [screen0], esi
  mov ebx, esi
  call scr_create_screen
  or eax, eax
  jz end

  mov ebx, [screen0]
  mov byte [ebx+scr.activ],1
  mov word [ebx+scr.lastx],80
  mov word [ebx+scr.lasty],25
  mov byte [ebx+scr.attr], 0x02

;  mov word [ebx+scr.maxx], 3
;  mov word [ebx+scr.maxy], 10
  mov word [ebx+scr.crsx],0
  mov word [ebx+scr.crsy],0

  mov esi, msg1
  call scr_put_string

end:  
  mov eax, [kbd_ptr_buf]		; debug kbd
  cmp eax, [kbd_ptr_buf_last]
  jz end						; daca bufferul e gol nu afisha nik

  mov esi, [kbd_ptr_buf]
  mov dl, [esi]
  mov ebx, [screen0]
  call scr_put_char
  
;  mov esi, [kbd_ptr_buf+1]
;  mov edi, [kbd_ptr_buf]
;  mov ecx, [kbd_ptr_buf_last]
;  sub ecx, kbd_buf_size
;  call memcpy

  dec dword [kbd_ptr_buf_last]
  jmp end



; 'include' section  
%include "idt.inc"
%include "string.inc"
%include "memory.inc"
%include "cfg.inc"
%include "pic.inc"
%include "interrupts.inc"
%include "kbd.inc"
%include "scr.inc"

[section .data]

adrx	dd 0x55
ptr_kbd			dd	0		; pointer catre bufferul alocat tastaturii
hi_ptr_kbd		dd	0		; unde a ajuns acest pointer
msg1			db	"[+] This is OSiris Virtual Screen, enjoy!", 0x0d
msg				db	"[+] Wellcome to OSiris", 0x0d
				db	"[+] Keyboard installed OK", 0x0d,0
				