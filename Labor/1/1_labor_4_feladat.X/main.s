.include "p24FJ256GA705.inc"  ;Processzor típus kiválasztása

;config bitek    
config __FOSCSEL, FNOSC_FRCPLL & PLLMODE_PLL4X & IESO_OFF
config __FOSC, POSCMD_NONE & OSCIOFCN_ON & SOSCSEL_OFF & PLLSS_PLL_FRC & IOL1WAY_OFF
config __FWDT, FWDTEN_OFF
config __FICD, ICS_PGD2 & JTAGEN_OFF

    
.global __reset ;kötelezoen exportálandó címke, ettol kerül a reset vektor 
		;helyére a kódunk és nem lesz semmi más a memóriában

.extern Ledinit
    
.text 
__reset:
    ;kötelezo startup kód, ha stack hivatkozás történik ezelott, az reset
    mov #__SP_init,w15 ; Stack pointer inicializalas
    mov #__SPLIM_init,w0 ;
    mov w0,_SPLIM ; stack limit inicializalas
 
main:
  
    mov #0, w0
    mov #0, w1
    mov #0, w2
   
    call Ledinit

    
vegtelen:  
    
    mov 0x712,w0 ;ez a tekero poti erteke (12 bites, 0..4095 tartományon)
   
    asr w0,#2,w0 ;osszuk el 4-el a bejövo értéket, 
		 ;hogy a teljes tartományt használjuk
    
    ;R=poti  értéke
    mov #1023,w1
    sub w1,w0,w1 
    ;G=1023-poti
       
    mov w0,0x236  ;piros szín fényereje 10 biten (0: sötét, 1023: maximum)
    mov w1,0x240  ;zöld szín fényereje 10 biten (0: sötét, 1023: maximum)
    mov w2,0x24A  ;kék szín fényereje 10 biten (0: sötét, 1023: maximum)
  
    bra vegtelen
    
.end
    





