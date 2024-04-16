.include "p24FJ256GA705.inc"  ;Processzor típus kiválasztása

;config bitek    
config __FOSCSEL, FNOSC_FRCPLL & PLLMODE_PLL4X & IESO_OFF
config __FOSC, POSCMD_NONE & OSCIOFCN_ON & SOSCSEL_OFF & PLLSS_PLL_FRC & IOL1WAY_OFF
config __FWDT, FWDTEN_OFF
config __FICD, ICS_PGD2 & JTAGEN_OFF

    
.global __reset ;kötelezoen exportálandó címke, ettol kerül a reset vektor helyére a kódunk és nem lesz semmi más a memóriában
.extern Disp_init   ; Máshol megírt szubrutin a hardver inicializálására
.extern Disp_conv   ; Máshol megírt szubrutin
		    ; Be: w0 - 0 ... 99 közötti érték
		    ; Ki: w0 - a = seg kijelzör kiviendö bitminta
    
.bss 
    szam: .space 2
    adatsor: .space 400
 
.text 
__reset:
    ;kötelezo startup kód, ha stack hivatkozás történik ezelott, az reset
    mov #__SP_init,w15 ; Stack pointer inicializalas
    mov #__SPLIM_init,w0 ;
    mov w0,_SPLIM ; stack limit inicializalas

main:
;---------------------------------------
;1. feladat
;---------------------------------------    
;   1ms késleltetés kipróbálása, ellenörzése
    call Delay1ms
    bra  main

;---------------------------------------
;2. feladat
;---------------------------------------    
;   N ms késleltetés kipróbálása
    mov  #100,w0
    call DelayNms
    bra  main

    
;---------------------------------------
;3. feladat
;---------------------------------------    
;   Pontosan 1sec késletetés kipróbálása a fejlesztö panelen
;   A próba elött ne felejtse el a konfigurációt szimulátorról panelre átállítani
    call Delay1sec
;   LED1 (LATA,#8) - LED2 (LATA,#9) felváltva le-fel kapcsol
    
    bra main

;---------------------------------------
;4. feladat
;---------------------------------------    
;   Disp_send elkészítése és kiprobálása - a jelalak megjelenítése a Logic Analyzer ablakban
;   Ne felejtse el a konfigurációt panelröl szimulátorra visszaállítani
    mov #0xB91A,w0	
    call Disp_send
    bra main
    
;---------------------------------------
;5. feladat
;---------------------------------------    
;   0 ... 99 közötti számláló - szimuláció után kipróbálás a panelen
;   Szimuláció alatt az 1ms késleltetést használja, Panel esetén az 1sec-et
;   A kijelzendö értékhez használja a szam változót
    mov szam,w0
    call Disp_conv  ;a 0 és 99 kozti szamokat kijelzöre kiirhato formatumra hozza
    call Disp_send  

    call Delay1ms   ; vagy call Delay1sec
; ....
; ....

    bra main

;---------------------------------------
;6. feladat
;---------------------------------------    
;   N ... M közötti számláló 
;   A számláló a BTN1 gomb megnyomásának hatására lép 
    mov  szam,w0
    call Disp_conv  ; A 0 és 99 közti számokat 
                    ; kijelzöre kiirható formátumra hozza
    call Disp_send  ; Elküldi a kijelzöre a w0-ban található értéket

; ....
; Gomb figyelése, számláló értékének megváltoztatása
; ....

    bra  main

;A mérésen készitendo szubrutinok helye:   

;---------------------------------------
;1. feladat
;---------------------------------------    
; 1 ms késleltetés
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
; N msec késlelteés
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
; Pontosan 1 sec késleltetés
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
; 16 bites érték kiküldése a kijelz?re
; Be: w0 - a kiküldendö érték
; Ki: -
; Ront: w0
Disp_send:
; ....
; ....
    return

;-------------------------------    	
    
.end
    





