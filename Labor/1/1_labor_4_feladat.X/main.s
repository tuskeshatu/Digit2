.include "p24FJ256GA705.inc"  ;Processzor t�pus kiv�laszt�sa

;config bitek    
config __FOSCSEL, FNOSC_FRCPLL & PLLMODE_PLL4X & IESO_OFF
config __FOSC, POSCMD_NONE & OSCIOFCN_ON & SOSCSEL_OFF & PLLSS_PLL_FRC & IOL1WAY_OFF
config __FWDT, FWDTEN_OFF
config __FICD, ICS_PGD2 & JTAGEN_OFF

    
.global __reset ;k�telezoen export�land� c�mke, ettol ker�l a reset vektor 
		;hely�re a k�dunk �s nem lesz semmi m�s a mem�ri�ban

.extern Ledinit
    
.text 
__reset:
    ;k�telezo startup k�d, ha stack hivatkoz�s t�rt�nik ezelott, az reset
    mov #__SP_init,w15 ; Stack pointer inicializalas
    mov #__SPLIM_init,w0 ;
    mov w0,_SPLIM ; stack limit inicializalas
 
main:
  
    mov #0, w0
    mov #0, w1
    mov #0, w2
   
    call Ledinit

    
vegtelen:  
    
    mov 0x712,w0 ;ez a tekero poti erteke (12 bites, 0..4095 tartom�nyon)
   
    asr w0,#2,w0 ;osszuk el 4-el a bej�vo �rt�ket, 
		 ;hogy a teljes tartom�nyt haszn�ljuk
    
    ;R=poti  �rt�ke
    mov #1023,w1
    sub w1,w0,w1 
    ;G=1023-poti
       
    mov w0,0x236  ;piros sz�n f�nyereje 10 biten (0: s�t�t, 1023: maximum)
    mov w1,0x240  ;z�ld sz�n f�nyereje 10 biten (0: s�t�t, 1023: maximum)
    mov w2,0x24A  ;k�k sz�n f�nyereje 10 biten (0: s�t�t, 1023: maximum)
  
    bra vegtelen
    
.end
    





