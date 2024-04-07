.include "p24FJ256GA705.inc"  ;Processzor t�pus kiv�laszt�sa

;config bitek    
#pragma config __FOSCSEL, FNOSC_FRCPLL & PLLMODE_PLL4X & IESO_OFF
#pragma config __FOSC, POSCMD_NONE & OSCIOFCN_ON & SOSCSEL_OFF & PLLSS_PLL_FRC & IOL1WAY_OFF
#pragma config __FWDT, FWDTEN_OFF
#pragma config __FICD, ICS_PGD2 & JTAGEN_OFF
    
.global __reset ;k�telezoen export�land� c�mke, ettol ker�l a reset vektor hely�re a k�dunk �s nem lesz semmi m�s a mem�ri�ban

.bss 
    a: .space 2
    b: .space 2
    c: .space 2
    d: .space 2
 
.text 
__reset:
    ;k�telezo startup k�d, ha stack hivatkoz�s t�rt�nik ezelott, az reset
    mov #__SP_init,w15 ; Stack pointer inicializalas
    mov #__SPLIM_init,w0 ;
    mov w0,_SPLIM ; stack limit inicializalas
 
main:
    ;feladat: tal�ljuk meg mi a hiba az al�bbi k�dban:
    ;A k�vetkez? k�dr�szlet 3 elojel n�lk�li eg�sz v�ltoz�b�l sz�mol valamit
    ;�rjuk fel a k�pletet, pr�b�ljuk ki ha pl a=100, b=200, c=5, 12-t kellene adjon, vajon mi�rt nem annyit ad?
    
    mov b, W0
    mov a, W1
    add W1, W0, W0
    sl W0, #2, W1
    mov #800, W0
    sub W1, W0, W0
    mov W0, W1
    mov c, W0
    asr W1, W0, W0
    mov W0, d
    
vegtelen:    
    bra vegtelen
.end
