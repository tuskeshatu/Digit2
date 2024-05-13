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
    call INIT_PORT
    call READ_DATA
    bra main
    
INIT_PORT:
    ;clear output bits
    bclr LATB, #1
    bclr LATB, #2
    ;set input ports
    bset TRISA, #2
    bset TRISA, #3
    ;set output ports
    bclr TRISB, #1
    bclr TRISB, #2
    return
READ_DATA:
    ;w0: loop counter
    mov #16, w0
    ;w1: revieving register
    ;clear because last bit could interfere
    mov #0, w1
    ;w2: number to compare with
    mov #10000, w2
    
;recieving loop
recieving:
    ;wait for positive edge
    ;wait until previous positive edge is predent (clk=1)
clk_lo:
    btst LATA, #3
    bra NZ, clk_lo
    ;wait for positive edge
clk_hi:
    btst LATA, #3
    bra Z, clk_hi
    ;read data
    mov LATA, w3
    btst.c w3, #2
    ;set last bit of w1 to read data bit
    addc w1, #0, w1
    ;shift left, because msb arrives first
    sl w1, #1, w1
    ;decrement loop counter
    dec w0, w0
    ;jump out if all 16 bits recieved
    cp w0, #0
    bra NZ, recieving
    ;compare with w2
    cp w1, w2
    ;jump to correct label
    bra GTU, greater
    bra LTU, smaller
    bra Z, equal
;set RB1, RB2 accordingly
greater:
    ;01
    bset LATB, #1
    bclr LATB, #2
    bra recieve_end
smaller:
    ;11
    bset LATB, #1
    bset LATB, #2
    bra recieve_end    
equal:
    ;01
    bclr LATB, #1
    bset LATB, #2
    bra recieve_end
recieve_end:
    ;return
    return