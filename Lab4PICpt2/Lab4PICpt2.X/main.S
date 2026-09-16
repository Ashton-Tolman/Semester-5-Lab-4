// Ashton Tolman
// RCET3373
// Lab4PICpt2
// https://github.com/Ashton-Tolman/Semester-5-Lab-4.git
// linker code:-Wl,-presetVect=0000h,-pcode=0008h

; PIC16F883 Configuration Bit Settings

; Assembly source line config statements

; CONFIG1
  CONFIG  FOSC = XT             ; Oscillator Selection bits (XT oscillator: Crystal/resonator on RA6/OSC2/CLKOUT and RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  MCLRE = ON            ; RE3/MCLR pin function select bit (RE3/MCLR pin function is MCLR)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  CONFIG  BOREN = OFF           ; Brown Out Reset Selection bits (BOR disabled)
  CONFIG  IESO = OFF            ; Internal External Switchover bit (Internal/External Switchover mode is disabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
  CONFIG  LVP = OFF             ; Low Voltage Programming Enable bit (RB3 pin has digital I/O, HV on MCLR must be used for programming)

; CONFIG2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)

// config statements should precede project file includes.
#include <xc.inc>

outCount    EQU 0x20	;use data memory address 0x20 as an 8-bit loop counter 
inCount	    EQU 0x21	;use data memory address 0x21 as an 8-bit loop counter
tableAddress EQU 0x22   ;use data memory address 0x21 as a location for lookup 

; Reset Vector at 000h. Execution starts here after reset 
PSECT resetVect,class=CODE,delta=2
ResetVector:
    goto Setup
    
    
; Main code section starts at 0008h. User code goes here
PSECT code,class=CODE,delta=2

Setup:
    ; add device setup here
    BSF  0x03, 06    ;
    BSF  0x03, 05    ; Set bank 3 active
    CLRF 0x189	    ; ANSELH analog/digital select portB pins as digital
    CLRF 0x188	    ; ANSEL analog/digital select portA pins as digital
    
    BSF  0x03, 06    ;
    BCF  0x03, 5    ; Set bank 2 active
    BSF  0x09, 1    ; Turn T1G-not function off
    
    BCF  0x03, 06    ;
    BSF  0x03, 05    ; Set bank 1 active 
    CLRF 0x85	    ; TrisA sets all portA pins as outputs
    MOVLW 0x01	    ; Make W all highs
    MOVWF 0x86	    ; Move W to TrisB
		    
    BCF  0x03, 06    ;
    BCF  0x03, 05    ; Set bank 0 active
    CLRF 0x06	    ; clear port B
    CLRF 0x05	    ; clear port A
    
		    ; OPTION_REG RBPU-not is default high meaning disabled
		    ; WPUB weak pull ups default disabled
		    ; IOCB portB interrupt-on-change disabled default
    goto Main
    

Main:
    // main goes here
    CALL TestDIP	    ;2 TCY Goes to testing dip status
    
    BTFSC tableAddress, 7   ;1 (2) 2 TCY if it is 0 it skips 
    goto Main		    ;2 TCY
    
    CALL LookupTable	    ;2 TCY Goes to get the address from the lookupTable
    MOVWF outCount	    ;1 TCY puts the address into the outerloop count
    
    CALL Delay		    ;2 TCY Goes to delay
    
    MOVLW 0x01	    ;Put a 1 in W
    XORWF PORTA,1   ;Toggle PortA
    
    goto Main
    
TestDIP:
    Test7:
    BTFSS 0x06,7    ;Skip next instruction if RB7 is high
    goto Test6      ;If RB7 low move to next bit
    goto SetAddress7;If RB7 high display 7
	
    Test6:
    BTFSS 0x06,6    ;Skip next instruction if RB6 is high
    goto Test5      ;If RB6 low move to next bit
    goto SetAddress6;If RB6 high display 6
	
    Test5:
    BTFSS 0x06,5    ;Skip next instruction if RB5 is high
    goto Test4      ;If RB5 low move to next bit
    goto SetAddress5;If RB5 high display 5
	
    Test4:
    BTFSS 0x06,4    ;Skip next instruction if RB4 is high 
    goto Test3      ;If RB4 low move to next bit
    goto SetAddress4;If RB4 high display 4
	
    Test3:
    BTFSS 0x06,3    ;Skip next instruction if RB3 is high 
    goto Test2      ;If RB3 low move to next bit
    goto SetAddress3;If RB3 high display 3
	
    Test2:
    BTFSS 0x06,2    ;Skip next instruction if RB2 is high
    goto Test1      ;If RB2 low move to next bit
    goto SetAddress2;If RB2 high display 2
	
    Test1:
    BTFSS 0x06,1    ;Skip next instruction if RB1 is high 
    goto Test0      ;If RB1 low move to next bit
    goto SetAddress1;If RB1 high display 1
	
    Test0:
    BTFSS 0x06,0    ;Skip next instruction if RB0 is high
    goto NoNoise    ;If RB0 is low, display $
    goto SetAddress0;If RB0 high display 0
	
    SetAddress7:
    MOVLW 0x01		;Select the address for freq 1
    MOVWF tableAddress	;Send W to PortC
    RETURN
	
    SetAddress6:
    MOVLW 0x02		;Select the address for freq 2
    MOVWF tableAddress  ;Send W to PortC
    RETURN
	
    SetAddress5:
    MOVLW 0x03		;Select the address for freq 3
    MOVWF tableAddress	;Send W to PortC
    RETURN
	
    SetAddress4:
    MOVLW 0x04		;Select the address for freq 4
    MOVWF tableAddress	;Send W to PortC
    RETURN
	
    SetAddress3:
    MOVLW 0x05		;Select the address for freq 5
    MOVWF tableAddress	;Send W to PortC
    RETURN
	
    SetAddress2:
    MOVLW 0x06		;Select the address for freq 6
    MOVWF tableAddress	;Send W to PortC
    RETURN
	
    SetAddress1:    
    MOVLW 0x07		;Select the address for freq 7
    MOVWF tableAddress	;Send W to PortC
    RETURN
	
    SetAddress0:
    MOVLW 0x08		;Select the address for freq 8
    MOVWF tableAddress	;Send W to PortC
    RETURN
	
    NoNoise:
    MOVLW 0x80		;Select the no noise condition
    MOVWF tableAddress	;Send W to PortC
    RETURN
    
LookupTable:
    MOVF tableAddress, 0    ;1 TCY put known address into W
    ADDWF PCL, 1	    ;2 TCY Add known W with the Programm Counter
    
    NOP
    RETLW 0x77		    ;2 TCY selects 261.63Hz
    RETLW 0x7E		    ;2 TCY selects 246.94Hz
    RETLW 0x8E		    ;2 TCY selects 220.00Hz
    RETLW 0x9F		    ;2 TCY selects 196.00Hz
    RETLW 0xB2		    ;2 TCY selects 174.61Hz
    RETLW 0xBD		    ;2 TCY selects 164.81Hz
    RETLW 0xD4		    ;2 TCY selects 146.83Hz
    RETLW 0xEE		    ;2 TCY selects 130.81Hz
    
Delay:
    OutDelay:
    MOVLW 0x04		    ;1 TCY
    MOVWF inCount	    ;1 TCY
    
    InDelay:
    DECFSZ inCount	    ;1(2) TCY
    goto InDelay	    ;2 TCY
    
    DECFSZ outCount	    ;1(2) TCY
    goto OutDelay	    ;2 TCY
    
    RETURN		    ;2 TCY
End