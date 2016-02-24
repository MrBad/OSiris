%ifndef pic_entry
	extern pic_reprogram
	extern pic_irq_set_mask
	extern pic_irq_get_mask
%endif

port_8259M	EQU 0x20			; master pic port
port_8259S	EQU 0xA0			; slave pic port