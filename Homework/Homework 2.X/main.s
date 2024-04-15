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
    
    ;put every byte specified in homework in memory
    
    mov.b #0x00, w0
    mov.b wreg, 0x800
    
    mov.b #0x11, w0
    mov.b wreg, 0x801    
    
    mov.b #0x22, w0
    mov.b wreg, 0x802
    
    mov.b #0x33, w0
    mov.b wreg, 0x803
    
    mov.b #0x44, w0
    mov.b wreg, 0x804
    
    mov.b #0x55, w0
    mov.b wreg, 0x805
    
    ;clear wregs and C flag just in case
    clr w0
    clr w1
    clr w2
    clr C
    
    ;you can access special flags (C, Z, OV, N, RA...) as bits of SR
    ;just add SR to the watch window
    ;bits from LSB to MSB correspond to flags in the following order:
    ;(bit0) C, Z, OV, N (bit 3)
    ;more specifics: https://ww1.microchip.com/downloads/en/DeviceDoc/70000157g.pdf
    
    ;*YOUR CODE STARTS HERE*
    mov #0x800, w0
    mov w0, w1
    dec w1, w1
    mov [w0++], w2
    add w2, [w0++], w2
    add.b w2, [w0++], w2
    and.b w2, [w0--], w2
    xor w1, [w0], w2
    ;*YOUR CODE ENDS HERE*
    
.end
