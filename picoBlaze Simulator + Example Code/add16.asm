 a_lsb EQU s0 	; rename register s0 as “a_lsb”
 a_msb EQU s1	; rename register s1 as “a_msb”
 b_lsb EQU s2 	; rename register s2 as “b_lsb”
 b_msb EQU s3 	; rename register s3 as “b_lsb”

 LOAD a_msb, $AA  	; 1010 1010
 LOAD a_lsb, $FF 	; 1111 1111

 LOAD b_msb, 01	   	; 0000 0001
 LOAD b_lsb, 01	   	; 0000 0001

 ADD a_lsb, b_lsb 		 ; add LSBs, keep result in a_lsb
 ADDC a_msb, b_msb 	 ; keep result in a_msb; Note ADDC is same as ADDCY

; We are adding  these two numbers:
; a = 1010 1010 1111 1111
; b = 0000 0001 0000 0001
;       1010 1100 0000 0000  expected result
;     a_msb (register s1) = AC
;     a_lsb   (register s0) = 00


