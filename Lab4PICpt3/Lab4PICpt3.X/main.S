// Ashton Tolman
// RCET3373
// Lab4PICpt3
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
    MOVLW 0xFF	    ; Put all high literal into W
    MOVWF 0x95	    ; WPUB
    BCF  0x81, 7    ; OPTION_REG
		    
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
    CALL Test4x4	    ;2 TCY Goes to testing dip status
    
    BTFSC tableAddress, 7   ;1 (2) 2 TCY if it is 0 it skips 
    goto Main		    ;2 TCY
    
    CALL LookupTable	    ;2 TCY Goes to get the address from the lookupTable
    MOVWF outCount	    ;1 TCY puts the address into the outerloop count
    
    CALL Delay		    ;2 TCY Goes to delay
    
    MOVLW 0x01	    ;Put a 1 in W
    XORWF PORTA,1   ;Toggle PortA
    
    goto Main
    
    
LookupTable:
    MOVF tableAddress, 0    ;1 TCY put known address into W
    ADDWF PCL, 1	    ;2 TCY Add known W with the Programm Counter
    
    RETLW 0xEE		    ;2 TCY selects 130.81Hz
    RETLW 0xD4		    ;2 TCY selects 146.83Hz
    RETLW 0xBD		    ;2 TCY selects 164.81Hz
    RETLW 0xB2		    ;2 TCY selects 174.61Hz
    RETLW 0x9F		    ;2 TCY selects 196.00Hz
    RETLW 0x8E		    ;2 TCY selects 220.00Hz
    RETLW 0x7E		    ;2 TCY selects 246.94Hz
    RETLW 0x77		    ;2 TCY selects 261.63Hz
    RETLW 0x6A		    ;2 TCY selects 293.66Hz
    RETLW 0x5E		    ;2 TCY selects 329.63Hz
    RETLW 0x59		    ;2 TCY selects 349.23Hz
    RETLW 0x4F		    ;2 TCY selects 392.00Hz
    RETLW 0x47		    ;2 TCY selects 440.00Hz
    RETLW 0x3F		    ;2 TCY selects 493.88Hz
    RETLW 0x3B		    ;2 TCY selects 523.25Hz
    RETLW 0x35		    ;2 TCY selects 587.33Hz
      
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
    
Test4x4:
    // main goes here
    ScanRow1:
    BCF 0x03, 6		;
    BSF 0x03, 5		; Set bank 1 active
    
    MOVLW 0xFE		; Put 11111110 on the TrisB register making RB0 an output
    MOVWF 0x86		; Configure RB0 as an output
    
    BCF  0x03, 6	;
    BCF  0x03, 5	; Set bank 0 active
    
    TestD:
	BTFSC 0x06,4	    ;Skip next instruction if RB4 is Low
	GOTO TestPnd	    ;If RB4 high move to next test
	GOTO SetAddress16   ;If RB4 low make tableAddress 16
    
    TestPnd:
	BTFSC 0x06,5	    ;Skip next instruction if RB5 is Low
	GOTO Test0	    ;If RB5 high move to next test
	GOTO SetAddress15   ;If RB5 low make tableAddress 15
	
    Test0:
	BTFSC 0x06,6	    ;Skip next instruction if RB6 is Low
	GOTO TestStar	    ;If RB6 high move to next test
	GOTO SetAddress14   ;If RB6 low make tableAddress 14
	
    TestStar:
	BTFSC 0x06,7	    ;Skip next instruction if RB7 is Low
	GOTO ScanRow2	    ;If RB7 high move to next test
	GOTO SetAddress13   ;If RB7 low make tableAddress 13

	
    ScanRow2:
    BCF 0x03, 6		;
    BSF 0x03, 5		; Set bank 1 active

    MOVLW 0xFD		; Put 11111101 on the TrisB register making RB1 an output
    MOVWF 0x86		; Configure RB1 as an output
    
    BCF  0x03, 6	;
    BCF  0x03, 5	; Set bank 0 active
    
    TestC:
	BTFSC 0x06,4	    ;Skip next instruction if RB4 is Low
	GOTO Test9	    ;If RB4 high move to next test
	GOTO SetAddress12   ;If RB4 low make tableAddress 12
    
    Test9:
	BTFSC 0x06,5	    ;Skip next instruction if RB5 is Low
	GOTO Test8	    ;If RB5 high move to next test
	GOTO SetAddress11   ;If RB5 low make tableAddress 11
    
    Test8:
	BTFSC 0x06,6	    ;Skip next instruction if RB6 is Low
	GOTO Test7	    ;If RB6 high move to next test
	GOTO SetAddress10   ;If RB6 low make tableAddress 10
    
    Test7:
	BTFSC 0x06,7	    ;Skip next instruction if RB7 is Low
	GOTO ScanRow3	    ;If RB7 high move to next test
	GOTO SetAddress9    ;If RB7 low make tableAddress 9
    
	
    ScanRow3:
    BCF 0x03, 6		;
    BSF 0x03, 5		; Set bank 1 active
    
    MOVLW 0xFB		; Put 11111011 on the TrisB register making RB2 an output
    MOVWF 0x86		; Configure RB2 as an output
    
    BCF  0x03, 6	;
    BCF  0x03, 5	; Set bank 0 active
    
    TestB:
	BTFSC 0x06,4	    ;Skip next instruction if RB4 is Low
	GOTO Test6	    ;If RB4 high move to next test
	GOTO SetAddress8    ;If RB4 low make tableAddress 8
    
    Test6:
	BTFSC 0x06,5	    ;Skip next instruction if RB5 is Low
	GOTO Test5	    ;If RB5 high move to next test
	GOTO SetAddress7    ;If RB5 low make tableAddress 7
    
    Test5:
	BTFSC 0x06,6	    ;Skip next instruction if RB6 is Low
	GOTO Test4	    ;If RB6 high move to next test
	GOTO SetAddress6    ;If RB6 low make tableAddress 6
    
    Test4:
	BTFSC 0x06,7	    ;Skip next instruction if RB7 is Low
	GOTO ScanRow4	    ;If RB7 high move to next test
	GOTO SetAddress5    ;If RB7 low make tableAddress 5
    
    ScanRow4:
    BCF 0x03, 6		;
    BSF 0x03, 5		; Set bank 1 active
    
    MOVLW 0xF7		; Put 11110111 on the TrisB register making RB3 an output
    MOVWF 0x86		; Configure RB3 as an output
    
    BCF  0x03, 6	;
    BCF  0x03, 5	; Set bank 0 active
    
    TestA:
	BTFSC 0x06,4	    ;Skip next instruction if RB4 is Low
	GOTO Test3	    ;If RB4 high move to next test
	GOTO SetAddress4    ;If RB4 low make tableAddress 4
    
    Test3:
	BTFSC 0x06,5	    ;Skip next instruction if RB5 is Low
	GOTO Test2	    ;If RB5 high move to next test
	GOTO SetAddress3    ;If RB5 low make tableAddress 3
    
    Test2:
	BTFSC 0x06,6	    ;Skip next instruction if RB6 is Low
	GOTO Test1	    ;If RB6 high move to next test
	GOTO SetAddress2    ;If RB6 low make tableAddress 2
    
    Test1:
	BTFSC 0x06,7	    ;Skip next instruction if RB7 is Low
	GOTO NoNoise	    ;If RB7 high move NoNoise setting
	GOTO SetAddress1    ;If RB7 low make tableAddress 1
	
    SetAddress1:
	MOVLW 0x00	    ; Select address for freq 1
	MOVWF tableAddress  ; Send W to table Address
	RETURN
	
    SetAddress2:
	MOVLW 0x01	    ; Select address for freq 2
	MOVWF tableAddress  ; Send W to table Address
	RETURN
	
    SetAddress3:
	MOVLW 0x02	    ; Select address for freq 3
	MOVWF tableAddress  ; Send W to table Address
	RETURN
	
    SetAddress4:
	MOVLW 0x03	    ; Select address for freq 4
	MOVWF tableAddress  ; Send W to table Address
	RETURN
	
    SetAddress5:
	MOVLW 0x04	    ; Select address for freq 5
	MOVWF tableAddress  ; Send W to table Address
	RETURN
	
    SetAddress6:
	MOVLW 0x05	    ; Select address for freq 6
	MOVWF tableAddress  ; Send W to table Address
	RETURN
	
    SetAddress7:
	MOVLW 0x06	    ; Select address for freq 7
	MOVWF tableAddress  ; Send W to table Address
	RETURN
	
    SetAddress8:
	MOVLW 0x07	    ; Select address for freq 8
	MOVWF tableAddress  ; Send W to table Address
	RETURN
	
    SetAddress9:
	MOVLW 0x08	    ; Select address for freq 9
	MOVWF tableAddress  ; Send W to table Address
	RETURN
	
    SetAddress10:
	MOVLW 0x09	    ; Select address for freq 10
	MOVWF tableAddress  ; Send W to table Address
	RETURN
	
    SetAddress11:
	MOVLW 0x0A	    ; Select address for freq 11
	MOVWF tableAddress  ; Send W to table Address
	RETURN
	
    SetAddress12:
	MOVLW 0x0B	    ; Select address for freq 12
	MOVWF tableAddress  ; Send W to table Address
	RETURN
	
    SetAddress13:
	MOVLW 0x0C	    ; Select address for freq 13
	MOVWF tableAddress  ; Send W to table Address
	RETURN
	
    SetAddress14:
	MOVLW 0x0D	    ; Select address for freq 14
	MOVWF tableAddress  ; Send W to table Address
	RETURN
	
    SetAddress15:
	MOVLW 0x0E	    ; Select address for freq 15
	MOVWF tableAddress  ; Send W to table Address
	RETURN
	
    SetAddress16:
	MOVLW 0x0F	    ; Select address for freq 16
	MOVWF tableAddress  ; Send W to table Address
	RETURN
	
    NoNoise:
	MOVLW 0x80		;Select the No noise condition
	MOVWF tableAddress	;Send W to tableAddress
	RETURN
End