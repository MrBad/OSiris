;
;
;
[bits 32]
%ifndef _scr_entry
  extern	scr_create_screen
  extern	scr_load_screen
  extern	scr_save_screen
  extern	scr_cls
  extern	scr_set_cursor
  extern	scr_put_char
  extern	scr_put_string
  extern	scr_move_cursor_forward
  extern	scr_move_cursor_back
  extern	scr_move_cursor_up
  extern	scr_move_cursor_down
  extern	scr_line_scroll_down
  extern	scr_line_scroll_up
%endif



; virtual screen
struc scr
.lastx	resw	1			; pozitia ultimului caracter din ecranul v este dat de linia X si
.lasty	resw	1			; coloana Y
.maxx	resw	1			; cate coloane are ecranul virtual max 2^16
.maxy	resw	1			; cate linii are ecranul virtual   max 2^16		
.crsx	resw	1			; pozitia cursor x 
.crsy	resw	1			; pozitie cursor y
.attr	resb	1			; atribut fundal
.activ  resb	1			; ecran activ? 0 nu 1 da
.mm		resd	1			; pointer catre zona de memorie alocata acestui ecran
endstruc
