;  Important - In PBlaze IDE, in "Settings"
;  ensure that "PicoBlaze I" is checked.
;  This does not simulate correctly for
;  other options -- Dr. Katkoori

 a_lsb EQU s0 	; rename register s0 as “a_lsb”
 a_msb EQU s1 	; rename register s1 as “a_msb”
 b_lsb EQU s2 	; rename register s2 as “b_lsb”
 b_msb EQU s3 	; rename register s3 as “b_lsb”
 counter_port        DSOUT     4
 interrupt_counter   EQU       s4

 ORG 0 			; Programs always start at reset vector 0

 EINT   		; If using interrupts, be sure to enable
 				; the INTERRUPT input
 BEGIN:

 LOAD a_msb, $AA   	   ; 1010 1010
 LOAD a_lsb, $FF 	   ; 1111 1111

 LOAD b_msb, 01	   ; 0000 0001
 LOAD b_lsb, 01	   ; 0000 0001

 ADD a_lsb, b_lsb  	   ; add LSBs, keep result in a_lsb
 ADDC a_msb, b_msb 	   ; add MSBs, keep result in a_msb

 JUMP BEGIN  	   ; Embedded applications never end

ISR:
 ADD interrupt_counter, 1 		; increment counter
 OUT interrupt_counter, counter_port	; display counter	
  		  ; An Interrupt Service Routine (ISR) is required if using interrupts
  		  ; Interrupts are automatically disabled when an interrupt is recognized
  		  ; Never re-enable interrupts during the ISR
RETI ENABLE 	  ; Return from interrupt service routine
		  ; Use RETURNI DISABLE to leave interrupts disabled
ORG $0FF  ; Interrupt vector is located at highest  instruction address
JUMP ISR  ; Jump to interrupt service routine, ISR

