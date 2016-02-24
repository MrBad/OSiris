[bits 32]
%ifndef _kbd_entry
  extern kbd_init
  extern kbd_convert
  extern kbd_int

  extern kbd_ptr_buf				; pointer catre bufferul tastaturii
  extern kbd_ptr_buf_last			; pointer catre ultimul element in buffer

  ; var globale
%endif
  
  
; 
;
;defineste tastele speciale 

%define  K_F1		0x80
%define  K_F2		(K_F1+1)
%define  K_F3		(K_F2+1)
%define  K_F4		(K_F3+1)
%define  K_F5		(K_F4+1)
%define  K_F6		(K_F5+1)
%define  K_F7		(K_F6+1)
%define  K_F8		(K_F7+1)
%define  K_F9		(K_F8+1)
%define  K_F10		(K_F9+1)
%define  K_F11		(K_F10+1)
%define  K_F12  	(K_F11+1)

%define  K_INS		0x90
%define  K_DEL		(K_INS+1)
%define  K_HOME		(K_DEL+1)
%define  K_END		(K_HOME+1)
%define  K_PGUP		(K_END+1)
%define  K_PGDOWN	(K_PGUP+1)
%define  K_LEFT		(K_PGDOWN+1)
%define  K_UP		(K_LEFT+1)
%define  K_DOWN		(K_UP+1)
%define  K_RIGHT	(K_DOWN+1)
    
  