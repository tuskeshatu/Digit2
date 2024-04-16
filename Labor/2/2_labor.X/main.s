.include "p24FJ256GA705.inc"  ;Processzor t�pus kiv�laszt�sa

;config bitek    
config __FOSCSEL, FNOSC_FRCPLL & PLLMODE_PLL4X & IESO_OFF
config __FOSC, POSCMD_NONE & OSCIOFCN_ON & SOSCSEL_OFF & PLLSS_PLL_FRC & IOL1WAY_OFF
config __FWDT, FWDTEN_OFF
config __FICD, ICS_PGD2 & JTAGEN_OFF

    
.global __reset ;k�telezoen export�land� c�mke, ettol ker�l a reset vektor hely�re a k�dunk �s nem lesz semmi m�s a mem�ri�ban
.extern Disp_init   ; M�shol meg�rt szubrutin a hardver inicializ�l�s�ra
.extern Disp_conv   ; M�shol meg�rt szubrutin
		    ; Be: w0 - 0 ... 99 k�z�tti �rt�k
		    ; Ki: w0 - a = seg kijelz�r kiviend� bitminta
    
.bss 
    szam: .space 2
    adatsor: .space 400
 
.text 
__reset:
    ;k�telezo startup k�d, ha stack hivatkoz�s t�rt�nik ezelott, az reset
    mov #__SP_init,w15 ; Stack pointer inicializalas
    mov #__SPLIM_init,w0 ;
    mov w0,_SPLIM ; stack limit inicializalas

main:
;---------------------------------------
;1. feladat
;---------------------------------------    
;   1ms k�sleltet�s kipr�b�l�sa, ellen�rz�se
    call Delay1ms
    bra  main

;---------------------------------------
;2. feladat
;---------------------------------------    
;   N ms k�sleltet�s kipr�b�l�sa
    mov  #100,w0
    call DelayNms
    bra  main

    
;---------------------------------------
;3. feladat
;---------------------------------------    
;   Pontosan 1sec k�sletet�s kipr�b�l�sa a fejleszt� panelen
;   A pr�ba el�tt ne felejtse el a konfigur�ci�t szimul�torr�l panelre �t�ll�tani
    call Delay1sec
;   LED1 (LATA,#8) - LED2 (LATA,#9) felv�ltva le-fel kapcsol
    
    bra main

;---------------------------------------
;4. feladat
;---------------------------------------    
;   Disp_send elk�sz�t�se �s kiprob�l�sa - a jelalak megjelen�t�se a Logic Analyzer ablakban
;   Ne felejtse el a konfigur�ci�t panelr�l szimul�torra vissza�ll�tani
    mov #0xB91A,w0	
    call Disp_send
    bra main
    
;---------------------------------------
;5. feladat
;---------------------------------------    
;   0 ... 99 k�z�tti sz�ml�l� - szimul�ci� ut�n kipr�b�l�s a panelen
;   Szimul�ci� alatt az 1ms k�sleltet�st haszn�lja, Panel eset�n az 1sec-et
;   A kijelzend� �rt�khez haszn�lja a szam v�ltoz�t
    mov szam,w0
    call Disp_conv  ;a 0 �s 99 kozti szamokat kijelz�re kiirhato formatumra hozza
    call Disp_send  

    call Delay1ms   ; vagy call Delay1sec
; ....
; ....

    bra main

;---------------------------------------
;6. feladat
;---------------------------------------    
;   N ... M k�z�tti sz�ml�l� 
;   A sz�ml�l� a BTN1 gomb megnyom�s�nak hat�s�ra l�p 
    mov  szam,w0
    call Disp_conv  ; A 0 �s 99 k�zti sz�mokat 
                    ; kijelz�re kiirhat� form�tumra hozza
    call Disp_send  ; Elk�ldi a kijelz�re a w0-ban tal�lhat� �rt�ket

; ....
; Gomb figyel�se, sz�ml�l� �rt�k�nek megv�ltoztat�sa
; ....

    bra  main

;A m�r�sen k�szitendo szubrutinok helye:   

;---------------------------------------
;1. feladat
;---------------------------------------    
; 1 ms k�sleltet�s
; Be: -
; Ki: -
; Ront: -
Delay1ms:  
; ....  
; ....
    return

;---------------------------------------
;2. feladat
;---------------------------------------    
; N msec k�slelte�s
; Be: w0 - N
; Ki: -
; Ront: w0
DelayNms:
; ....
; ....
    return

;---------------------------------------
;3. feladat
;---------------------------------------    
; Pontosan 1 sec k�sleltet�s
; Be: -
; Ki: -
; Ront: -

Delay1sec:         
; ....
; ....
    return
    
;---------------------------------------
;4. feladat
;---------------------------------------    
; 16 bites �rt�k kik�ld�se a kijelz?re
; Be: w0 - a kik�ldend� �rt�k
; Ki: -
; Ront: w0
Disp_send:
; ....
; ....
    return

;-------------------------------    	
    
.end
    





