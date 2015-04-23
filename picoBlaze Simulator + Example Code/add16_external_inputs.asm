a_msb_in DSIN $00
 a_lsb_in   DSIN $01

 a_msb_out DSOUT $02
 a_lsb_out   DSOUT $03

 a_lsb EQU   s0 ; rename register s0 as “a_lsb”
 a_msb EQU s1 ; rename register s1 as “a_msb”
 b_lsb EQU   s2 ; rename register s2 as “b_lsb”
 b_msb EQU s3 ; rename register s3 as “b_lsb”

; LOAD a_msb, $AA      ; 1010 1010
; LOAD a_lsb, $FF 	   ; 1111 1111

 IN a_msb, a_msb_in
 IN a_lsb, a_lsb_in

 LOAD b_msb, 01		   ; 0000 0001
 LOAD b_lsb, 01		   ; 0000 0001

 ADD a_lsb, b_lsb        ; add LSBs, keep result in a_lsb
 ADDC a_msb, b_msb ; add MSBs, keep result in a_msb

 OUT a_msb, a_msb_out
 OUT a_lsb, a_lsb_out


