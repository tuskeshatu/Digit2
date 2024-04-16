.include "p24FJ256GA705.inc"  ;Processzor típus kiválasztása

.global Disp_init,Disp_conv;
    
.text
    
    ; Elore elkészitett szubrutinok:

; Portlábak inicializálása
Disp_init:   
    clr  ANSELA
    mov #0x1000,w0
    mov w0,ANSELB ;poti az AN8=RB12-n analóg
    clr  ANSELC
    bset LATC,#9; kijelzo cs alapból 1;
    bclr TRISC,#9 ;kijelzo CS kimenet
    bclr TRISC,#3 ;kijelzo PWM kimenet
    bclr TRISB,#15 ;kijelzo SCK
    bclr TRISB,#14 ;kijelzo adat
    bset LATC,#3 ;kijelzo fényero fel
    
    bclr TRISA,#8 ;LED1
    bclr TRISA,#9 ;LED2
    
    return   
       
; Be: w0 - szám 0 ... 99
; Ki: w0 - 2 db 7seg data    
Disp_conv:	
	push w1	;mentsük el w1,w2-t mert elrontjuk
	push w2
     	mov 	#99,w2
	cp	w0, w2
    	bra	LE, kifer	
    	retlw  #0,w0	  ;nem fér ki, legyen sötét a kijelzo
kifer:	
	mov #10,w2
	repeat #17	;osztani fogunk
	div.u	w0,w2 ;w0/10, hányados w0-ba, maradék w1-be
	call NumTo7SEG ;a hányados a felso helyiérték, az kész
	sl w0,#8,w2	;toljuk fel a helyére és tegyük el w0-ból
	mov w1,w0  ;az alsó helyiértékre is ugyanez
	call NumTo7SEG
	mov.b w0,w2	;w0 alsó bájtját w2 alsó bájtjára
	mov w2,w0	;az eredmény kész, tegyük w0-ba
	swap w0		;a kijelzon igazából fordítva kell
	pop w2
	pop w1
	return
	
NumTo7SEG:		;W0-ban szám, visszatéréskor 7seg data
			;ront: W0, STATUS
    	cp	    w0, #9
    	bra	    LE, mehet	
    	retlw   #0,w0	    ;nagyobb 15
mehet:
    	bra	    W0         ;eloreugrunk az ugrótáblában
segtable: 
	retlw  #0x7E,w0	;'0'
 	retlw  #0x0A,w0	; '1'    _a_
 	retlw  #0xB6,w0	; '2'  f|   |b
	retlw 	#0x9E,w0	; '3'   |_g_|
 	retlw 	#0xCA,w0	; '4'  e|   |c
	retlw  #0xDC,w0	; '5'   |_d_|.dp
	retlw 	#0xFC,w0	; '6'
	retlw 	#0x0E,w0	; '7'
 	retlw  #0xFE,w0	; '8'
	retlw 	#0xDE,w0	; '9'

.end


