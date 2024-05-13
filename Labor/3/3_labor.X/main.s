.include "p24FJ256GA705.inc"  ;Processzor típus kiválasztása

;config bitek    
config __FOSCSEL, FNOSC_FRCPLL & PLLMODE_PLL4X & IESO_OFF
config __FOSC, POSCMD_NONE & OSCIOFCN_ON & SOSCSEL_OFF & PLLSS_PLL_FRC & IOL1WAY_OFF
config __FWDT, FWDTEN_OFF
config __FICD, ICS_PGD2 & JTAGEN_OFF

    
.global __reset ; kötelezoen exportálandó címke, ettol kerül a reset vektor 
		; helyére a kódunk és nem lesz semmi más a memóriában
.extern Disp_init   ; Máshol megírt szubrutin a hardver inicializálására
.extern Disp_conv   ; Máshol megírt szubrutin
		    ; Be: w0 - 0 ... 99 közötti érték
		    ; Ki: w0 - a = seg kijelz?r kiviend? bitminta
    
.bss 
    szam: .space 2	; itt számol 10ms-ként az IT
    kijelez: .space 2	; itt számoljuk, amit ki kell jelezni
 
.text 
__reset:
;kötelezo startup kód, ha stack hivatkozás történik ezelott, az reset
    mov #__SP_init,w15 ; Stack pointer inicializalas
    mov #__SPLIM_init,w0 ;
    mov w0,_SPLIM ; stack limit inicializalas

    call Disp_init

;----------------------------------------------------
; 1. feladat - Inicializálás
;   call Init_SPI
;   ...    

;----------------------------------------------------
; 2. feladat - Inicializálás
;   call Init_Timer
; IT engedélyezés
; ...    
    
;----------------------------------------------------
; 4. feladat - Inicializálás
;    call Init_PWM
; ...    
    
main:
;----------------------------------------------------
; 1. feladat
; BTN2 figyelés (Button2_press)
; kijelez növelés
; kijelzés: Disp_conv, Send_SPI 
;
    
    bra main

;----------------------------------------------------
; 2. feladat
; Számlálás Timerrel
; 
    
    bra main
    
;----------------------------------------------------
; 3. - 4. feladat
; Reakcióido mérés
;
    
    bra main
;----------------------------------------------------

;A mérésen készitendo szubrutinok helye:

;----------------------------------------------------
.global __T1Interrupt
;2. feladat: Timer Interrupt rutin
__T1Interrupt:

;ide jön, amit századmásodpercenként csinálni kell

retfie

;----------------------------------------------------
;1. feladat: SPI1 inicializálás
;SCK: RB15, MOSI:RB14
;Master, 16 bit mód, 4 Mhz órajel
;Ront: w0
Init_SPI:

return

;----------------------------------------------------
;1. feladat: SPI küldés
;CS# állítás! (LATC,#9)
;BE: w0
;Ront: -
Send_SPI:
    
return
;----------------------------------------------------
;1. feladat: BTN2 (PORTA,#12) lenyomására várakozás
;BE: -
;KI: -
;Ront: -
Button2_press:

return

;----------------------------------------------------
;2. feladat: Timer1 inicializálás
;IT kérés 10 ms
;Ront: w0
Init_Timer:

return
;----------------------------------------------------
;2. feladat: DelayN10ms  N*10 ms várakozás
;BE: w1 - N
;KI: -
;Ront: -
DelayN10ms:

return
;----------------------------------------------------
;4. feladat: PWM inicializálás
;OC1 kimenet PORTA 1-re (zöld LED)
;Kezdetben a LED nem világit
;Ront: w0
Init_PWM:

return    
;----------------------------------------------------
    
.end
    





