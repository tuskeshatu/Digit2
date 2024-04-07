.include "p24FJ256GA705.inc"  ;Processzor típus kiválasztása

;config bitek    
config __FOSCSEL, FNOSC_FRCPLL & PLLMODE_PLL4X & IESO_OFF
config __FOSC, POSCMD_NONE & OSCIOFCN_ON & SOSCSEL_OFF & PLLSS_PLL_FRC & IOL1WAY_OFF
config __FWDT, FWDTEN_OFF
config __FICD, ICS_PGD2 & JTAGEN_OFF
   
.global __reset ;kötelezoen exportálandó címke, ettol kerül a reset vektor helyére a kódunk és nem lesz semmi más a memóriában
.global __T1Interrupt
    
.bss
    szamlalo: .space 1 ;1 bájtos számláló a kijelzohöz 
    szin:     .space 1 ;1 bájt az rgb led szineinek
    nyomva:   .space 1 ;allapotvaltozo a gombnyomashoz
.text 
     
    
__T1Interrupt:
    push w0
    push w1
    bclr IFS0,#T1IF
    mov.b szamlalo,WREG ;lép a számláló
    inc w0,w0
    daw.b w0	;bcd-ben
    mov.b WREG,szamlalo
    
 
    btst nyomva,#1  ;novelni kell-e?
    bra Z, nemnov
    bclr.b nyomva,#1
    inc.b szin
nemnov:   
    btst nyomva,#2  ;novelni kell-e?
    bra Z, nemcsokk
    bclr.b nyomva,#2
    dec.b szin
nemcsokk:
    
    pop w1
    pop w0
    retfie     
     
__reset:
    ;kötelezo startup kód, ha stack hivatkozás történik ezelott, az reset
    mov #__SP_init, w15 ; Stack pointer inicializalas
    mov #__SPLIM_init, w0 ;
    mov w0, _SPLIM ; stack limit inicializalas
    
    bset LATC,#9; kijelzo cs alapból 1;
    bclr TRISC,#9 ;kijelzo CS kimenet
    bclr TRISC,#3 ;kijelzo PWM kimenet
    clr  ANSELA
    mov #0x1000,w0
    mov w0,ANSELB ;poti az AN8=RB12-n analóg
    clr  ANSELC
    
    bclr TRISC,#7
    bclr TRISA,#0
    bclr TRISA,#1
    bclr TRISA,#8
    bclr TRISA,#9
    
    ;SPI1 init
    mov #0x0807, W0 
    mov W0, RPOR7 ;RPOR7 alsó bájt = 0x0007, azaz  RB14->SPI1:SDO1
		  ;RPOR7 felso bájt = 0x0008, azaz RB15->SPI1:SCK1OUT

    mov	#13, W0 
    mov.b WREG,RPINR20L ;RPINR20 alsó bájt = 0x0D=13, azaz RB13->SPI1:SDI1
		     ;ugyanennek a regiszternek a felso bajtja valami mas, azt ne bántsuk
		     
    mov #8, W0
    mov W0, SPI1BRGL ;SPI1 órajele FOSC/2/2/8=1MHz
    
    mov #0x8120,W0 ;SPI1 bekapcsol, master módban
    mov W0, SPI1CON1L
    
    ;AD init
    bset AD1CON3,#ADRC ;AZ AD belso órajelét használja (4MHz)
    bset AD1CON3,#SAMC0 ;1db AD órajelenként mérés indul
    mov #8,w0
    mov w0,AD1CHS ;8-as bemenet kiválasztás
    mov #0x8474,w0 ;autosample, jobbra igazított 12 bites mód, bekapcsol
    mov w0,AD1CON1
        ;innent?l AD1 magától mér, ADC1BUF0-ban lesz a poti értéke
    
    ;PWM init
    
    mov #0x0D, W0 
    mov.b WREG, RPOR9H ;RPOR9 felso bajtja a 19-es láb funkciója, 0x0d a pwm OC1
        
    ;pwm mód, Fosc/2 órajel, minden hibajelzés letiltva (periódus végén kér csak megszakítást, de azt a DMA fogja elkapni)
    mov #0x001f,w0
    mov w0,OC1CON2
    
    mov #0x1C06,w0
    mov w0,OC1CON1
     
    mov #0x0fff,w0
    mov w0,OC1RS   ;a periódus legyen 4096, mert ez a maximum amit a poti is ad, így 
    
    ;innenol a PWM megy, az OC1R-be beírt szám a kitöltés
    
    
    ;DMA init
    mov #0x205,w0 ;CH0 beállítás: Címmódosítás nincs, Repeated one shot mód, 16 bit, autoreload (igazából mindegy mert nem módosít a címeken)
    mov w0,DMACH0
    
    mov #0x1600,w0 ;a 0x16-os IT vonalra indul, ami az OC1 (pwm generátor)
    mov w0,DMAINT0
    
    mov #ADC1BUF0,w0 ;itt a # nagyon kell, mert nem az AD buffert hanem a címét másoljuk
    mov w0,DMASRC0  ;a DMA CH0 forráscímre
    
    mov #OC1R,w0 ;itt a # nagyon kell, mert nem az OC1R-t hanem a címét másoljuk
    mov w0,DMADST0  ;a DMA CH0 célcímre
    
    mov #1,w0
    mov w0,DMACNT0 ;csak 1 wordör másolunk
    
    
    bset DMACON,#DMAEN_DMACON ;DMA controller bekapcsol (ez kell el?bb, mert ha ez 0 a csatornák enable-je nem m?ködik)
    bset DMACH0,#CHEN ;DMA CH0 is bekapcsol
     
    ;innentol DMA megy a poti állítja a fényerot
    
    mov #0x8030 , w0  ;timer on, 256-os eloosztó,belso orajel, nincs gate
    mov w0, T1CON
    mov #62499,w0  ;256*62500=16000000, így lesz másodperc bel?le
    mov w0,PR1
    clr TMR1
    
    bclr IFS0,#T1IF
    bset IEC0,#T1IE
    
    clr.b szamlalo
    clr.b szin
  
vegtelen:
    clr W0	    ;töröljük le W0-t ne legyen a fels? 16 biten semmi
    mov.b szamlalo,WREG  ;hozzuk be a bájtot W0-ba (itt csak WREG-ként írhatjuk)
    lsr W0,#4,W1    ;a szám fels? számjegye W1-ben lesz, toljuk el és tegyük oda
    and #0x0F,W0  ;a szám alsó számjegye w0-ben lesz, csak maszkoljuk le
    
    ;alsó számjegy már mehet is a kijelz?re
    ;CS le
    bclr LATC,#9

    call NumTo7SEG_const ;W0-ban már benne az alsó számjegy
    mov  w0,SPI1BUFL
kuldesrevar_also:
    btst SPI1STATL,#SRMT  ;kivesszük a Z-be a bitet
    bra  Z,kuldesrevar_also

    mov  w1,w0	    ;a fels?t is w0-ba kell tenni hogy átalakítsuk
    call NumTo7SEG_const ;W0-ban már benne az alsó számjegy
    mov  w0,SPI1BUFL
kuldesrevar_felso:
    btst SPI1STATL,#SRMT  
    bra  Z,kuldesrevar_felso
    
    bset LATC,#9 ;cs fel
   
    bclr LATA,#8
    
    
    
    btst PORTA,#11  ;szinkeveres
    bra NZ, nemnyoms1
    bset.b nyomva,#1
    bset LATA,#8
    bset nyomva,#1
nemnyoms1:
    
    bclr LATA,#9
    btst PORTA,#12
    bra NZ, nemnyoms2
    bset.b nyomva,#2
    bset LATA,#9
    
nemnyoms2:

    
    mov.b szin,WREG  ;szín a szines ledre
    and.b w0,#0x03,w0
    mov LATA,w1
    mov #0xfffc,w3
    and w1,w3,w1 ;el?ször lemaszkoljuk
    ior w0,w1,w0 ;utána belemásoljuk
    mov w0,LATA  
    
    bclr LATC,#7
    btsc.b szin,#2
    bset LATC,#7
    
    
 
    
    call Delay20ms
    
    goto vegtelen
   
    
    
.section .const 
SEGtabla:  .byte 0x7E,0x0A,0xB6,0x9E,0xCA,0xDC,0xFC,0x0E,0xFE,0xDE,0xEE,0xF8,0x74,0xBA,0xF4,0xE4

.text    
NumTo7SEG_const:
    push.d w2  ;w0-ban kapunk eredményt, azt el is rontjuk w2 és w3-at pedig elmentjük
    and #0x0F, w0
    mov #edspage(SEGtabla),w2
    mov w2, DSRPAG
    mov #edsoffset(SEGtabla),w2
    mov.b [w2+w0], w0

    pop.d w2
    return
    
    

;Fosc=32MHz => Fcy=16MHz => 1 Tcy = 62.5ns
;20 ms = 20 000 000 ns = 320 000 Tcy ez egy regiszter csökkentgetésébe nem fér be
; az egész függvény 1-szer lefutó része ebbol lejön, az 2+2+1+1+2+3-1=10
; nem lesz 4-el osztható ezért kell 2 nop
; 1 iteráció 4 Tcy => 79997-ig kell számolni, az  13387dh
    
Delay20ms:         ;a függvény meghívása 2Tcy lesz
    push.d w0      ;2Tcy    mentsük el W0-t és W1-et is, mert elrontjuk (lehetne két sima push is)
    mov #0x387D,w0  ;1Tcy
    mov #1, w1      ;1Tcy
dcikl:	    
    sub  w0,#1,w0   ;1 Tcy
    subb w1,#0,w1  ;1 Tcy  subb, subtract with borrow, C-t is kivonja ezért mi már csak 0-t vonunk ki, a Z-t csak törli nem állítja
    bra NZ,dcikl  ;2 Tcy  a Z flag "sticky", ha egyszer beáll úgy marad a carry használatakor, ígynem kell tesztelni külön
    nop		  ;1 Tcy + utolsó bra csak 1 ciklus ezért itt -1 Tcy
    nop           ;1 Tcy
    pop.d w0      ;2Tcy
    return        ;3Tcy
    

    
.end


