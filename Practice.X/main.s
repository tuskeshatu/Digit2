
.include "p24FJ256GA705.inc"  ;select processor type

;config bits    
#pragma config __FOSCSEL, FNOSC_FRCPLL & PLLMODE_PLL4X & IESO_OFF
#pragma config __FOSC, POSCMD_NONE & OSCIOFCN_ON & SOSCSEL_OFF & PLLSS_PLL_FRC & IOL1WAY_OFF
#pragma config __FWDT, FWDTEN_OFF
#pragma config __FICD, ICS_PGD2 & JTAGEN_OFF
    
.global __reset ;obligatory exported tag, this configs reset vector and clears memory

;field for memory mapping
.bss
;*YOUR VARIABLES GO HERE*
 
;field for actual code to be executed (in main)
.text 
__reset:
    ;obligatory startup code
    ;code execution before results in reset
    mov #__SP_init,w15 ; Stack pointer initialize
    mov #__SPLIM_init,w0 ;
    mov w0,_SPLIM ; Stack limit init
 
;entry point for program
main:
    
mov #0b1111111111111111, w0
mov w0, LATB 
    
loop:
    bra loop
.end


