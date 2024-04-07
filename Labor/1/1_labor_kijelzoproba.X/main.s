.include "p24FJ256GA705.inc"  ;Processzor t�pus kiv�laszt�sa

;config bitek    
config __FOSCSEL, FNOSC_FRCPLL & PLLMODE_PLL4X & IESO_OFF
config __FOSC, POSCMD_NONE & OSCIOFCN_ON & SOSCSEL_OFF & PLLSS_PLL_FRC & IOL1WAY_OFF
config __FWDT, FWDTEN_OFF
config __FICD, ICS_PGD2 & JTAGEN_OFF
   
.global __reset ;k�telezoen export�land� c�mke, ettol ker�l a reset vektor hely�re a k�dunk �s nem lesz semmi m�s a mem�ri�ban
.global __T1Interrupt
    
.bss
    szamlalo: .space 1 ;1 b�jtos sz�ml�l� a kijelzoh�z 
    szin:     .space 1 ;1 b�jt az rgb led szineinek
    nyomva:   .space 1 ;allapotvaltozo a gombnyomashoz
.text 
     
    
__T1Interrupt:
    push w0
    push w1
    bclr IFS0,#T1IF
    mov.b szamlalo,WREG ;l�p a sz�ml�l�
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
    ;k�telezo startup k�d, ha stack hivatkoz�s t�rt�nik ezelott, az reset
    mov #__SP_init, w15 ; Stack pointer inicializalas
    mov #__SPLIM_init, w0 ;
    mov w0, _SPLIM ; stack limit inicializalas
    
    bset LATC,#9; kijelzo cs alapb�l 1;
    bclr TRISC,#9 ;kijelzo CS kimenet
    bclr TRISC,#3 ;kijelzo PWM kimenet
    clr  ANSELA
    mov #0x1000,w0
    mov w0,ANSELB ;poti az AN8=RB12-n anal�g
    clr  ANSELC
    
    bclr TRISC,#7
    bclr TRISA,#0
    bclr TRISA,#1
    bclr TRISA,#8
    bclr TRISA,#9
    
    ;SPI1 init
    mov #0x0807, W0 
    mov W0, RPOR7 ;RPOR7 als� b�jt = 0x0007, azaz  RB14->SPI1:SDO1
		  ;RPOR7 felso b�jt = 0x0008, azaz RB15->SPI1:SCK1OUT

    mov	#13, W0 
    mov.b WREG,RPINR20L ;RPINR20 als� b�jt = 0x0D=13, azaz RB13->SPI1:SDI1
		     ;ugyanennek a regiszternek a felso bajtja valami mas, azt ne b�ntsuk
		     
    mov #8, W0
    mov W0, SPI1BRGL ;SPI1 �rajele FOSC/2/2/8=1MHz
    
    mov #0x8120,W0 ;SPI1 bekapcsol, master m�dban
    mov W0, SPI1CON1L
    
    ;AD init
    bset AD1CON3,#ADRC ;AZ AD belso �rajel�t haszn�lja (4MHz)
    bset AD1CON3,#SAMC0 ;1db AD �rajelenk�nt m�r�s indul
    mov #8,w0
    mov w0,AD1CHS ;8-as bemenet kiv�laszt�s
    mov #0x8474,w0 ;autosample, jobbra igaz�tott 12 bites m�d, bekapcsol
    mov w0,AD1CON1
        ;innent?l AD1 mag�t�l m�r, ADC1BUF0-ban lesz a poti �rt�ke
    
    ;PWM init
    
    mov #0x0D, W0 
    mov.b WREG, RPOR9H ;RPOR9 felso bajtja a 19-es l�b funkci�ja, 0x0d a pwm OC1
        
    ;pwm m�d, Fosc/2 �rajel, minden hibajelz�s letiltva (peri�dus v�g�n k�r csak megszak�t�st, de azt a DMA fogja elkapni)
    mov #0x001f,w0
    mov w0,OC1CON2
    
    mov #0x1C06,w0
    mov w0,OC1CON1
     
    mov #0x0fff,w0
    mov w0,OC1RS   ;a peri�dus legyen 4096, mert ez a maximum amit a poti is ad, �gy 
    
    ;innenol a PWM megy, az OC1R-be be�rt sz�m a kit�lt�s
    
    
    ;DMA init
    mov #0x205,w0 ;CH0 be�ll�t�s: C�mm�dos�t�s nincs, Repeated one shot m�d, 16 bit, autoreload (igaz�b�l mindegy mert nem m�dos�t a c�meken)
    mov w0,DMACH0
    
    mov #0x1600,w0 ;a 0x16-os IT vonalra indul, ami az OC1 (pwm gener�tor)
    mov w0,DMAINT0
    
    mov #ADC1BUF0,w0 ;itt a # nagyon kell, mert nem az AD buffert hanem a c�m�t m�soljuk
    mov w0,DMASRC0  ;a DMA CH0 forr�sc�mre
    
    mov #OC1R,w0 ;itt a # nagyon kell, mert nem az OC1R-t hanem a c�m�t m�soljuk
    mov w0,DMADST0  ;a DMA CH0 c�lc�mre
    
    mov #1,w0
    mov w0,DMACNT0 ;csak 1 word�r m�solunk
    
    
    bset DMACON,#DMAEN_DMACON ;DMA controller bekapcsol (ez kell el?bb, mert ha ez 0 a csatorn�k enable-je nem m?k�dik)
    bset DMACH0,#CHEN ;DMA CH0 is bekapcsol
     
    ;innentol DMA megy a poti �ll�tja a f�nyerot
    
    mov #0x8030 , w0  ;timer on, 256-os elooszt�,belso orajel, nincs gate
    mov w0, T1CON
    mov #62499,w0  ;256*62500=16000000, �gy lesz m�sodperc bel?le
    mov w0,PR1
    clr TMR1
    
    bclr IFS0,#T1IF
    bset IEC0,#T1IE
    
    clr.b szamlalo
    clr.b szin
  
vegtelen:
    clr W0	    ;t�r�lj�k le W0-t ne legyen a fels? 16 biten semmi
    mov.b szamlalo,WREG  ;hozzuk be a b�jtot W0-ba (itt csak WREG-k�nt �rhatjuk)
    lsr W0,#4,W1    ;a sz�m fels? sz�mjegye W1-ben lesz, toljuk el �s tegy�k oda
    and #0x0F,W0  ;a sz�m als� sz�mjegye w0-ben lesz, csak maszkoljuk le
    
    ;als� sz�mjegy m�r mehet is a kijelz?re
    ;CS le
    bclr LATC,#9

    call NumTo7SEG_const ;W0-ban m�r benne az als� sz�mjegy
    mov  w0,SPI1BUFL
kuldesrevar_also:
    btst SPI1STATL,#SRMT  ;kivessz�k a Z-be a bitet
    bra  Z,kuldesrevar_also

    mov  w1,w0	    ;a fels?t is w0-ba kell tenni hogy �talak�tsuk
    call NumTo7SEG_const ;W0-ban m�r benne az als� sz�mjegy
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

    
    mov.b szin,WREG  ;sz�n a szines ledre
    and.b w0,#0x03,w0
    mov LATA,w1
    mov #0xfffc,w3
    and w1,w3,w1 ;el?sz�r lemaszkoljuk
    ior w0,w1,w0 ;ut�na belem�soljuk
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
    push.d w2  ;w0-ban kapunk eredm�nyt, azt el is rontjuk w2 �s w3-at pedig elmentj�k
    and #0x0F, w0
    mov #edspage(SEGtabla),w2
    mov w2, DSRPAG
    mov #edsoffset(SEGtabla),w2
    mov.b [w2+w0], w0

    pop.d w2
    return
    
    

;Fosc=32MHz => Fcy=16MHz => 1 Tcy = 62.5ns
;20 ms = 20 000 000 ns = 320 000 Tcy ez egy regiszter cs�kkentget�s�be nem f�r be
; az eg�sz f�ggv�ny 1-szer lefut� r�sze ebbol lej�n, az 2+2+1+1+2+3-1=10
; nem lesz 4-el oszthat� ez�rt kell 2 nop
; 1 iter�ci� 4 Tcy => 79997-ig kell sz�molni, az  13387dh
    
Delay20ms:         ;a f�ggv�ny megh�v�sa 2Tcy lesz
    push.d w0      ;2Tcy    ments�k el W0-t �s W1-et is, mert elrontjuk (lehetne k�t sima push is)
    mov #0x387D,w0  ;1Tcy
    mov #1, w1      ;1Tcy
dcikl:	    
    sub  w0,#1,w0   ;1 Tcy
    subb w1,#0,w1  ;1 Tcy  subb, subtract with borrow, C-t is kivonja ez�rt mi m�r csak 0-t vonunk ki, a Z-t csak t�rli nem �ll�tja
    bra NZ,dcikl  ;2 Tcy  a Z flag "sticky", ha egyszer be�ll �gy marad a carry haszn�latakor, �gynem kell tesztelni k�l�n
    nop		  ;1 Tcy + utols� bra csak 1 ciklus ez�rt itt -1 Tcy
    nop           ;1 Tcy
    pop.d w0      ;2Tcy
    return        ;3Tcy
    

    
.end


