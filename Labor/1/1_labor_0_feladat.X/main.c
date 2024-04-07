/*
 * File:   main.c
 * Author: RGY
 *
 * Created on 2022. február 15., 14:59
 */


#include "xc.h"

int a,b,c,d;

int main(void) {
    a=1;
    b=2;
    c=3;
    d=10;
    d=(a+(b<<3))*c+(d>>2);
    
    while(1);
    return 0;
}
