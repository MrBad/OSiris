; cateva variabile globale pt ajustarea fina a kernelului
;
;
%define _cfg_entry 0

; STRING
%ifndef _string_entry
  VMEM	EQU	0B8000h
%endif

; GDT
%ifndef _gdt_entry
  Cseg	EQU	0x08		; 4 GB data segment starting from 0x0
  Dseg	EQU 0x10		; 4 GB code segment
%endif

;
; - MEMORY - 

  mm_start	 			EQU	0x100000	; de la 1 mega in sus; de aici folosim memoria
  mm_end	 			EQU	0x400000	; pana la 4 mega, ca sa mearga si pe laptopul izei :)
  mm_table_size			EQU	0x10000		; 64 de k pentru tabela

;
; - IDT - 
  idt_nr				EQU	0x64		; definim primele 100 de intreruperi, restul nu ne trebuiesc (pana la 256)


;	
; - SCREEN - implementeaza virtual screen-ul
  def_scr_maxx 			EQU	80		; - latimea ecranului virtual [nr coloane] egala cu latimea ecranului
  def_scr_maxy 			EQU 1000	; - inaltimea [nr de linii] - 1000 sper sa ne ajunga adeca 40 de ecrane
  def_scr_startx		EQU 0		; - la ce coloana din ecranul real incepe cel virtual? max 80
  def_scr_starty		EQU 0		; - la ce linie din ecranul real incepe cel virtual? max 25
  def_scr_color			EQU 0x07	; coloarea default fundal
  
;
; - KEYBOARD -
  kbd_buf_size			EQU	1024	; - cat de mare este bufferul(e) care tin tastele apasate (stdin)
  kbd_howmany_buffers	EQU 0x1		; - 1 bufere corespunzatoare celor 1 virtual screenuri(pt moment)
  kbd_tab_spaces		EQU 4		; - cate spatii pt tab?
screen0		dd 0