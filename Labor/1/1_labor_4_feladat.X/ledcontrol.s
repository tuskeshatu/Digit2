.include "p24FJ256GA705.inc"  ;Processzor t�pus kiv�laszt�sa

.global Ledinit


.text    
Ledinit:
    clr  ANSELA
    mov #0x1000,w0
    mov w0,ANSELB ;poti az AN8=RB12-n anal�g
    clr  ANSELC
    
    ;PWM init
    ;RP23 Rc7 k�k
    mov #0x0F, W0 
    mov.b WREG, RPOR11H ;RPOR11 felso bajtja a 23-as l�b funkci�ja, 0x0F a pwm OC3
    ;RP27 RA1 Zold
    ;RP26 RA0 piros
    mov #0x0E0D, W0 
    mov W0, RPOR13 ;RPOR13 felso bajtja a 27-es �s als� a 26-os l�b funkci�ja, 0x0d a pwm OC1 0e a pwm OC2
     
    ;OC1-es, OC2-es �s OC3-as pwm indul
    ;pwm m�d, Fosc/2 �rajel, minden hibajelz�s letiltva 
    mov #0x001f,w0
    mov w0,OC1CON2
    mov w0,OC2CON2
    mov w0,OC3CON2
    
    mov #0x1C06,w0
    mov w0,OC1CON1
    mov w0,OC2CON1
    mov w0,OC3CON1
    
    mov #0x03ff,w0
    mov w0,OC1RS   ;a peri�dus legyen 1024
    mov w0,OC2RS
    mov w0,OC3RS
    ;innenol a PWM megy, az OCxR-be be�rt sz�m a kit�lt�s
  
    ;AD init
    bset AD1CON3,#ADRC ;AZ AD belso �rajel�t haszn�lja (4MHz)
    bset AD1CON3,#SAMC0 ;1db AD �rajelenk�nt m�r�s indul
    mov #8,w0
    mov w0,AD1CHS ;8-as bemenet kiv�laszt�s
    mov #0x8474,w0 ;autosample, jobbra igaz�tott 12 bites m�d, bekapcsol
    mov w0,AD1CON1
        ;innentol AD1 mag�t�l m�r, ADC1BUF0-ban lesz a poti �rt�ke
    
    
    return
    
  

.end
    