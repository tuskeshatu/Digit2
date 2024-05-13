.include "p24FJ256GA705.inc"  ;Processzor t�pus kiv�laszt�sa

;config bitek    
config __FOSCSEL, FNOSC_FRCPLL & PLLMODE_PLL4X & IESO_OFF
config __FOSC, POSCMD_NONE & OSCIOFCN_ON & SOSCSEL_OFF & PLLSS_PLL_FRC & IOL1WAY_OFF
config __FWDT, FWDTEN_OFF
config __FICD, ICS_PGD2 & JTAGEN_OFF

    
.global __reset ; k�telezoen export�land� c�mke, ettol ker�l a reset vektor 
		; hely�re a k�dunk �s nem lesz semmi m�s a mem�ri�ban
.extern Disp_init   ; M�shol meg�rt szubrutin a hardver inicializ�l�s�ra
.extern Disp_conv   ; M�shol meg�rt szubrutin
		    ; Be: w0 - 0 ... 99 k�z�tti �rt�k
		    ; Ki: w0 - a = seg kijelz?r kiviend? bitminta
    
.bss 
    szam: .space 2	; itt sz�mol 10ms-k�nt az IT
    kijelez: .space 2	; itt sz�moljuk, amit ki kell jelezni
 
.text 
__reset:
;k�telezo startup k�d, ha stack hivatkoz�s t�rt�nik ezelott, az reset
    mov #__SP_init,w15 ; Stack pointer inicializalas
    mov #__SPLIM_init,w0 ;
    mov w0,_SPLIM ; stack limit inicializalas

    call Disp_init

;----------------------------------------------------
; 1. feladat - Inicializ�l�s
;   call Init_SPI
;   ...    

;----------------------------------------------------
; 2. feladat - Inicializ�l�s
;   call Init_Timer
; IT enged�lyez�s
; ...    
    
;----------------------------------------------------
; 4. feladat - Inicializ�l�s
;    call Init_PWM
; ...    
    
main:
;----------------------------------------------------
; 1. feladat
; BTN2 figyel�s (Button2_press)
; kijelez n�vel�s
; kijelz�s: Disp_conv, Send_SPI 
;
    
    bra main

;----------------------------------------------------
; 2. feladat
; Sz�ml�l�s Timerrel
; 
    
    bra main
    
;----------------------------------------------------
; 3. - 4. feladat
; Reakci�ido m�r�s
;
    
    bra main
;----------------------------------------------------

;A m�r�sen k�szitendo szubrutinok helye:

;----------------------------------------------------
.global __T1Interrupt
;2. feladat: Timer Interrupt rutin
__T1Interrupt:

;ide j�n, amit sz�zadm�sodpercenk�nt csin�lni kell

retfie

;----------------------------------------------------
;1. feladat: SPI1 inicializ�l�s
;SCK: RB15, MOSI:RB14
;Master, 16 bit m�d, 4 Mhz �rajel
;Ront: w0
Init_SPI:

return

;----------------------------------------------------
;1. feladat: SPI k�ld�s
;CS# �ll�t�s! (LATC,#9)
;BE: w0
;Ront: -
Send_SPI:
    
return
;----------------------------------------------------
;1. feladat: BTN2 (PORTA,#12) lenyom�s�ra v�rakoz�s
;BE: -
;KI: -
;Ront: -
Button2_press:

return

;----------------------------------------------------
;2. feladat: Timer1 inicializ�l�s
;IT k�r�s 10 ms
;Ront: w0
Init_Timer:

return
;----------------------------------------------------
;2. feladat: DelayN10ms  N*10 ms v�rakoz�s
;BE: w1 - N
;KI: -
;Ront: -
DelayN10ms:

return
;----------------------------------------------------
;4. feladat: PWM inicializ�l�s
;OC1 kimenet PORTA 1-re (z�ld LED)
;Kezdetben a LED nem vil�git
;Ront: w0
Init_PWM:

return    
;----------------------------------------------------
    
.end
    





