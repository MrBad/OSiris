[bits 32]
%ifndef _idt_entry
	extern idt_setup
	extern load_idt
	extern set_interupt_vector
	extern get_interupt_vector
%endif
