.include "p24FJ256GA705.inc"  ;Processzor típus kiválasztása

;config bitek    
#pragma config __FOSCSEL, FNOSC_FRCPLL & PLLMODE_PLL4X & IESO_OFF
#pragma config __FOSC, POSCMD_NONE & OSCIOFCN_ON & SOSCSEL_OFF & PLLSS_PLL_FRC & IOL1WAY_OFF
#pragma config __FWDT, FWDTEN_OFF
#pragma config __FICD, ICS_PGD2 & JTAGEN_OFF
    
.global __reset ;kötelezoen exportálandó címke, ettol kerül a reset vektor helyére a kódunk és nem lesz semmi más a memóriában

.bss 
    a: .space 2
    b: .space 2
    c: .space 2
    d: .space 2
 
.text 
__reset:
    ;kötelezo startup kód, ha stack hivatkozás történik ezelott, az reset
    mov #__SP_init,w15 ; Stack pointer inicializalas
    mov #__SPLIM_init,w0 ;
    mov w0,_SPLIM ; stack limit inicializalas
 
main:
    ;feladat: találjuk meg mi a hiba az alábbi kódban:
    ;A következ? kódrészlet 3 elojel nélküli egész változóból számol valamit
    ;írjuk fel a képletet, próbáljuk ki ha pl a=100, b=200, c=5, 12-t kellene adjon, vajon miért nem annyit ad?
    
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
