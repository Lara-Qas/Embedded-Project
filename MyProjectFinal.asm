
_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;MyProjectFinal.c,54 :: 		void interrupt(void){
;MyProjectFinal.c,55 :: 		if(INTCON.T0IF){
	BTFSS      INTCON+0, 2
	GOTO       L_interrupt0
;MyProjectFinal.c,56 :: 		TMR0 = TMR0_PRELOAD;
	MOVLW      248
	MOVWF      TMR0+0
;MyProjectFinal.c,57 :: 		g_ms++;
	MOVF       _g_ms+0, 0
	ADDLW      1
	MOVWF      R0+0
	MOVLW      0
	BTFSC      STATUS+0, 0
	ADDLW      1
	ADDWF      _g_ms+1, 0
	MOVWF      R0+1
	MOVF       R0+0, 0
	MOVWF      _g_ms+0
	MOVF       R0+1, 0
	MOVWF      _g_ms+1
;MyProjectFinal.c,58 :: 		INTCON.T0IF = 0;
	BCF        INTCON+0, 2
;MyProjectFinal.c,59 :: 		}
L_interrupt0:
;MyProjectFinal.c,60 :: 		}
L_end_interrupt:
L__interrupt100:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_mymsDelay:

;MyProjectFinal.c,62 :: 		void mymsDelay(unsigned int ms){
;MyProjectFinal.c,63 :: 		unsigned int start = g_ms;
	MOVF       _g_ms+0, 0
	MOVWF      R3+0
	MOVF       _g_ms+1, 0
	MOVWF      R3+1
;MyProjectFinal.c,64 :: 		while((unsigned int)(g_ms - start) < ms);
L_mymsDelay1:
	MOVF       R3+0, 0
	SUBWF      _g_ms+0, 0
	MOVWF      R1+0
	MOVF       R3+1, 0
	BTFSS      STATUS+0, 0
	ADDLW      1
	SUBWF      _g_ms+1, 0
	MOVWF      R1+1
	MOVF       FARG_mymsDelay_ms+1, 0
	SUBWF      R1+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__mymsDelay102
	MOVF       FARG_mymsDelay_ms+0, 0
	SUBWF      R1+0, 0
L__mymsDelay102:
	BTFSC      STATUS+0, 0
	GOTO       L_mymsDelay2
	GOTO       L_mymsDelay1
L_mymsDelay2:
;MyProjectFinal.c,65 :: 		}
L_end_mymsDelay:
	RETURN
; end of _mymsDelay

_myusDelay:

;MyProjectFinal.c,67 :: 		void myusDelay(unsigned int us){
;MyProjectFinal.c,68 :: 		unsigned int target_ticks = us * 2;
	MOVF       FARG_myusDelay_us+0, 0
	MOVWF      R5+0
	MOVF       FARG_myusDelay_us+1, 0
	MOVWF      R5+1
	RLF        R5+0, 1
	RLF        R5+1, 1
	BCF        R5+0, 0
;MyProjectFinal.c,71 :: 		T1CON = 0x00;
	CLRF       T1CON+0
;MyProjectFinal.c,72 :: 		TMR1H = 0;
	CLRF       TMR1H+0
;MyProjectFinal.c,73 :: 		TMR1L = 0;
	CLRF       TMR1L+0
;MyProjectFinal.c,74 :: 		T1CON.TMR1ON = 1;
	BSF        T1CON+0, 0
;MyProjectFinal.c,76 :: 		while(1){
L_myusDelay3:
;MyProjectFinal.c,77 :: 		t = ((unsigned int)TMR1H << 8) | TMR1L;
	MOVF       TMR1H+0, 0
	MOVWF      R3+0
	CLRF       R3+1
	MOVF       R3+0, 0
	MOVWF      R0+1
	CLRF       R0+0
	MOVF       TMR1L+0, 0
	IORWF      R0+0, 0
	MOVWF      R2+0
	MOVF       R0+1, 0
	MOVWF      R2+1
	MOVLW      0
	IORWF      R2+1, 1
;MyProjectFinal.c,78 :: 		if(t >= target_ticks) break;
	MOVF       R5+1, 0
	SUBWF      R2+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__myusDelay104
	MOVF       R5+0, 0
	SUBWF      R2+0, 0
L__myusDelay104:
	BTFSS      STATUS+0, 0
	GOTO       L_myusDelay5
	GOTO       L_myusDelay4
L_myusDelay5:
;MyProjectFinal.c,79 :: 		}
	GOTO       L_myusDelay3
L_myusDelay4:
;MyProjectFinal.c,81 :: 		T1CON.TMR1ON = 0;
	BCF        T1CON+0, 0
;MyProjectFinal.c,82 :: 		}
L_end_myusDelay:
	RETURN
; end of _myusDelay

_PWM1_SetDuty:

;MyProjectFinal.c,85 :: 		void PWM1_SetDuty(unsigned int duty) {
;MyProjectFinal.c,86 :: 		if(duty > 1023) duty = 1023;
	MOVF       FARG_PWM1_SetDuty_duty+1, 0
	SUBLW      3
	BTFSS      STATUS+0, 2
	GOTO       L__PWM1_SetDuty106
	MOVF       FARG_PWM1_SetDuty_duty+0, 0
	SUBLW      255
L__PWM1_SetDuty106:
	BTFSC      STATUS+0, 0
	GOTO       L_PWM1_SetDuty6
	MOVLW      255
	MOVWF      FARG_PWM1_SetDuty_duty+0
	MOVLW      3
	MOVWF      FARG_PWM1_SetDuty_duty+1
L_PWM1_SetDuty6:
;MyProjectFinal.c,87 :: 		CCPR1L = duty >> 2;
	MOVF       FARG_PWM1_SetDuty_duty+0, 0
	MOVWF      R0+0
	MOVF       FARG_PWM1_SetDuty_duty+1, 0
	MOVWF      R0+1
	RRF        R0+1, 1
	RRF        R0+0, 1
	BCF        R0+1, 7
	RRF        R0+1, 1
	RRF        R0+0, 1
	BCF        R0+1, 7
	MOVF       R0+0, 0
	MOVWF      CCPR1L+0
;MyProjectFinal.c,88 :: 		CCP1CON = (CCP1CON & 0xCF) | ((duty & 0x03) << 4);
	MOVLW      207
	ANDWF      CCP1CON+0, 0
	MOVWF      R3+0
	MOVLW      3
	ANDWF      FARG_PWM1_SetDuty_duty+0, 0
	MOVWF      R2+0
	MOVF       R2+0, 0
	MOVWF      R0+0
	RLF        R0+0, 1
	BCF        R0+0, 0
	RLF        R0+0, 1
	BCF        R0+0, 0
	RLF        R0+0, 1
	BCF        R0+0, 0
	RLF        R0+0, 1
	BCF        R0+0, 0
	MOVF       R0+0, 0
	IORWF      R3+0, 0
	MOVWF      CCP1CON+0
;MyProjectFinal.c,89 :: 		}
L_end_PWM1_SetDuty:
	RETURN
; end of _PWM1_SetDuty

_PWM2_SetDuty:

;MyProjectFinal.c,91 :: 		void PWM2_SetDuty(unsigned int duty) {
;MyProjectFinal.c,92 :: 		if(duty > 1023) duty = 1023;
	MOVF       FARG_PWM2_SetDuty_duty+1, 0
	SUBLW      3
	BTFSS      STATUS+0, 2
	GOTO       L__PWM2_SetDuty108
	MOVF       FARG_PWM2_SetDuty_duty+0, 0
	SUBLW      255
L__PWM2_SetDuty108:
	BTFSC      STATUS+0, 0
	GOTO       L_PWM2_SetDuty7
	MOVLW      255
	MOVWF      FARG_PWM2_SetDuty_duty+0
	MOVLW      3
	MOVWF      FARG_PWM2_SetDuty_duty+1
L_PWM2_SetDuty7:
;MyProjectFinal.c,93 :: 		CCPR2L = duty >> 2;
	MOVF       FARG_PWM2_SetDuty_duty+0, 0
	MOVWF      R0+0
	MOVF       FARG_PWM2_SetDuty_duty+1, 0
	MOVWF      R0+1
	RRF        R0+1, 1
	RRF        R0+0, 1
	BCF        R0+1, 7
	RRF        R0+1, 1
	RRF        R0+0, 1
	BCF        R0+1, 7
	MOVF       R0+0, 0
	MOVWF      CCPR2L+0
;MyProjectFinal.c,94 :: 		CCP2CON = (CCP2CON & 0xCF) | ((duty & 0x03) << 4);
	MOVLW      207
	ANDWF      CCP2CON+0, 0
	MOVWF      R3+0
	MOVLW      3
	ANDWF      FARG_PWM2_SetDuty_duty+0, 0
	MOVWF      R2+0
	MOVF       R2+0, 0
	MOVWF      R0+0
	RLF        R0+0, 1
	BCF        R0+0, 0
	RLF        R0+0, 1
	BCF        R0+0, 0
	RLF        R0+0, 1
	BCF        R0+0, 0
	RLF        R0+0, 1
	BCF        R0+0, 0
	MOVF       R0+0, 0
	IORWF      R3+0, 0
	MOVWF      CCP2CON+0
;MyProjectFinal.c,95 :: 		}
L_end_PWM2_SetDuty:
	RETURN
; end of _PWM2_SetDuty

_motors_stop:

;MyProjectFinal.c,97 :: 		void motors_stop(void){
;MyProjectFinal.c,98 :: 		L_IN1 = L_IN2 = R_IN1 = R_IN2 = 0;
	BCF        RD1_bit+0, BitPos(RD1_bit+0)
	BTFSC      RD1_bit+0, BitPos(RD1_bit+0)
	GOTO       L__motors_stop110
	BCF        RD0_bit+0, BitPos(RD0_bit+0)
	GOTO       L__motors_stop111
L__motors_stop110:
	BSF        RD0_bit+0, BitPos(RD0_bit+0)
L__motors_stop111:
	BTFSC      RD0_bit+0, BitPos(RD0_bit+0)
	GOTO       L__motors_stop112
	BCF        RD3_bit+0, BitPos(RD3_bit+0)
	GOTO       L__motors_stop113
L__motors_stop112:
	BSF        RD3_bit+0, BitPos(RD3_bit+0)
L__motors_stop113:
	BTFSC      RD3_bit+0, BitPos(RD3_bit+0)
	GOTO       L__motors_stop114
	BCF        RD2_bit+0, BitPos(RD2_bit+0)
	GOTO       L__motors_stop115
L__motors_stop114:
	BSF        RD2_bit+0, BitPos(RD2_bit+0)
L__motors_stop115:
;MyProjectFinal.c,99 :: 		PWM1_SetDuty(0);
	CLRF       FARG_PWM1_SetDuty_duty+0
	CLRF       FARG_PWM1_SetDuty_duty+1
	CALL       _PWM1_SetDuty+0
;MyProjectFinal.c,100 :: 		PWM2_SetDuty(0);
	CLRF       FARG_PWM2_SetDuty_duty+0
	CLRF       FARG_PWM2_SetDuty_duty+1
	CALL       _PWM2_SetDuty+0
;MyProjectFinal.c,101 :: 		}
L_end_motors_stop:
	RETURN
; end of _motors_stop

_motors_forward:

;MyProjectFinal.c,103 :: 		void motors_forward(unsigned int l, unsigned int r){
;MyProjectFinal.c,104 :: 		L_IN1 = 1; L_IN2 = 0;
	BSF        RD2_bit+0, BitPos(RD2_bit+0)
	BCF        RD3_bit+0, BitPos(RD3_bit+0)
;MyProjectFinal.c,105 :: 		R_IN1 = 1; R_IN2 = 0;
	BSF        RD0_bit+0, BitPos(RD0_bit+0)
	BCF        RD1_bit+0, BitPos(RD1_bit+0)
;MyProjectFinal.c,106 :: 		PWM1_SetDuty(l);
	MOVF       FARG_motors_forward_l+0, 0
	MOVWF      FARG_PWM1_SetDuty_duty+0
	MOVF       FARG_motors_forward_l+1, 0
	MOVWF      FARG_PWM1_SetDuty_duty+1
	CALL       _PWM1_SetDuty+0
;MyProjectFinal.c,107 :: 		PWM2_SetDuty(r);
	MOVF       FARG_motors_forward_r+0, 0
	MOVWF      FARG_PWM2_SetDuty_duty+0
	MOVF       FARG_motors_forward_r+1, 0
	MOVWF      FARG_PWM2_SetDuty_duty+1
	CALL       _PWM2_SetDuty+0
;MyProjectFinal.c,108 :: 		}
L_end_motors_forward:
	RETURN
; end of _motors_forward

_motors_forward_tunnel:

;MyProjectFinal.c,110 :: 		void motors_forward_tunnel(unsigned int l, unsigned int r, unsigned char in_tunnel){
;MyProjectFinal.c,112 :: 		if(in_tunnel){
	MOVF       FARG_motors_forward_tunnel_in_tunnel+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_motors_forward_tunnel8
;MyProjectFinal.c,113 :: 		ls = (unsigned long)l * TUNNEL_SCALE_PERCENT;
	MOVF       FARG_motors_forward_tunnel_l+0, 0
	MOVWF      R0+0
	MOVF       FARG_motors_forward_tunnel_l+1, 0
	MOVWF      R0+1
	CLRF       R0+2
	CLRF       R0+3
	MOVLW      88
	MOVWF      R4+0
	CLRF       R4+1
	CLRF       R4+2
	CLRF       R4+3
	CALL       _Mul_32x32_U+0
	MOVF       R0+0, 0
	MOVWF      FLOC__motors_forward_tunnel+0
	MOVF       R0+1, 0
	MOVWF      FLOC__motors_forward_tunnel+1
	MOVF       R0+2, 0
	MOVWF      FLOC__motors_forward_tunnel+2
	MOVF       R0+3, 0
	MOVWF      FLOC__motors_forward_tunnel+3
	MOVF       FARG_motors_forward_tunnel_r+0, 0
	MOVWF      R0+0
	MOVF       FARG_motors_forward_tunnel_r+1, 0
	MOVWF      R0+1
	CLRF       R0+2
	CLRF       R0+3
;MyProjectFinal.c,114 :: 		rs = (unsigned long)r * TUNNEL_SCALE_PERCENT;
	MOVLW      88
	MOVWF      R4+0
	CLRF       R4+1
	CLRF       R4+2
	CLRF       R4+3
	CALL       _Mul_32x32_U+0
	MOVF       R0+0, 0
	MOVWF      FLOC__motors_forward_tunnel+4
	MOVF       R0+1, 0
	MOVWF      FLOC__motors_forward_tunnel+5
	MOVF       R0+2, 0
	MOVWF      FLOC__motors_forward_tunnel+6
	MOVF       R0+3, 0
	MOVWF      FLOC__motors_forward_tunnel+7
	MOVLW      100
	MOVWF      R4+0
	CLRF       R4+1
	CLRF       R4+2
	CLRF       R4+3
	MOVF       FLOC__motors_forward_tunnel+0, 0
	MOVWF      R0+0
	MOVF       FLOC__motors_forward_tunnel+1, 0
	MOVWF      R0+1
	MOVF       FLOC__motors_forward_tunnel+2, 0
	MOVWF      R0+2
	MOVF       FLOC__motors_forward_tunnel+3, 0
	MOVWF      R0+3
	CALL       _Div_32x32_U+0
	MOVF       R0+0, 0
	MOVWF      FLOC__motors_forward_tunnel+0
	MOVF       R0+1, 0
	MOVWF      FLOC__motors_forward_tunnel+1
	MOVF       R0+2, 0
	MOVWF      FLOC__motors_forward_tunnel+2
	MOVF       R0+3, 0
	MOVWF      FLOC__motors_forward_tunnel+3
	MOVF       FLOC__motors_forward_tunnel+0, 0
	MOVWF      FARG_motors_forward_tunnel_l+0
	MOVF       FLOC__motors_forward_tunnel+1, 0
	MOVWF      FARG_motors_forward_tunnel_l+1
;MyProjectFinal.c,116 :: 		r  = (unsigned int)(rs / 100);
	MOVLW      100
	MOVWF      R4+0
	CLRF       R4+1
	CLRF       R4+2
	CLRF       R4+3
	MOVF       FLOC__motors_forward_tunnel+4, 0
	MOVWF      R0+0
	MOVF       FLOC__motors_forward_tunnel+5, 0
	MOVWF      R0+1
	MOVF       FLOC__motors_forward_tunnel+6, 0
	MOVWF      R0+2
	MOVF       FLOC__motors_forward_tunnel+7, 0
	MOVWF      R0+3
	CALL       _Div_32x32_U+0
	MOVF       R0+0, 0
	MOVWF      FARG_motors_forward_tunnel_r+0
	MOVF       R0+1, 0
	MOVWF      FARG_motors_forward_tunnel_r+1
;MyProjectFinal.c,118 :: 		if(l == r && r > TUNNEL_TRIM_RIGHT) r -= TUNNEL_TRIM_RIGHT;
	MOVF       FLOC__motors_forward_tunnel+1, 0
	XORWF      R0+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__motors_forward_tunnel118
	MOVF       R0+0, 0
	XORWF      FLOC__motors_forward_tunnel+0, 0
L__motors_forward_tunnel118:
	BTFSS      STATUS+0, 2
	GOTO       L_motors_forward_tunnel11
	MOVF       FARG_motors_forward_tunnel_r+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__motors_forward_tunnel119
	MOVF       FARG_motors_forward_tunnel_r+0, 0
	SUBLW      25
L__motors_forward_tunnel119:
	BTFSC      STATUS+0, 0
	GOTO       L_motors_forward_tunnel11
L__motors_forward_tunnel86:
	MOVLW      25
	SUBWF      FARG_motors_forward_tunnel_r+0, 1
	BTFSS      STATUS+0, 0
	DECF       FARG_motors_forward_tunnel_r+1, 1
L_motors_forward_tunnel11:
;MyProjectFinal.c,119 :: 		}
L_motors_forward_tunnel8:
;MyProjectFinal.c,120 :: 		motors_forward(l, r);
	MOVF       FARG_motors_forward_tunnel_l+0, 0
	MOVWF      FARG_motors_forward_l+0
	MOVF       FARG_motors_forward_tunnel_l+1, 0
	MOVWF      FARG_motors_forward_l+1
	MOVF       FARG_motors_forward_tunnel_r+0, 0
	MOVWF      FARG_motors_forward_r+0
	MOVF       FARG_motors_forward_tunnel_r+1, 0
	MOVWF      FARG_motors_forward_r+1
	CALL       _motors_forward+0
;MyProjectFinal.c,121 :: 		}
L_end_motors_forward_tunnel:
	RETURN
; end of _motors_forward_tunnel

_motors_hard_left:

;MyProjectFinal.c,123 :: 		void motors_hard_left(void){
;MyProjectFinal.c,124 :: 		R_IN1 = 0; R_IN2 = 1;
	BCF        RD0_bit+0, BitPos(RD0_bit+0)
	BSF        RD1_bit+0, BitPos(RD1_bit+0)
;MyProjectFinal.c,125 :: 		L_IN1 = 1; L_IN2 = 0;
	BSF        RD2_bit+0, BitPos(RD2_bit+0)
	BCF        RD3_bit+0, BitPos(RD3_bit+0)
;MyProjectFinal.c,126 :: 		PWM1_SetDuty(TURN_SPEED);
	MOVLW      195
	MOVWF      FARG_PWM1_SetDuty_duty+0
	MOVLW      0
	MOVWF      FARG_PWM1_SetDuty_duty+1
	CALL       _PWM1_SetDuty+0
;MyProjectFinal.c,127 :: 		PWM2_SetDuty(TURN_SPEED);
	MOVLW      195
	MOVWF      FARG_PWM2_SetDuty_duty+0
	MOVLW      0
	MOVWF      FARG_PWM2_SetDuty_duty+1
	CALL       _PWM2_SetDuty+0
;MyProjectFinal.c,128 :: 		}
L_end_motors_hard_left:
	RETURN
; end of _motors_hard_left

_motors_hard_right:

;MyProjectFinal.c,130 :: 		void motors_hard_right(void){
;MyProjectFinal.c,131 :: 		R_IN1 = 1; R_IN2 = 0;
	BSF        RD0_bit+0, BitPos(RD0_bit+0)
	BCF        RD1_bit+0, BitPos(RD1_bit+0)
;MyProjectFinal.c,132 :: 		L_IN1 = 0; L_IN2 = 1;
	BCF        RD2_bit+0, BitPos(RD2_bit+0)
	BSF        RD3_bit+0, BitPos(RD3_bit+0)
;MyProjectFinal.c,133 :: 		PWM1_SetDuty(TURN_SPEED);
	MOVLW      195
	MOVWF      FARG_PWM1_SetDuty_duty+0
	MOVLW      0
	MOVWF      FARG_PWM1_SetDuty_duty+1
	CALL       _PWM1_SetDuty+0
;MyProjectFinal.c,134 :: 		PWM2_SetDuty(TURN_SPEED);
	MOVLW      195
	MOVWF      FARG_PWM2_SetDuty_duty+0
	MOVLW      0
	MOVWF      FARG_PWM2_SetDuty_duty+1
	CALL       _PWM2_SetDuty+0
;MyProjectFinal.c,135 :: 		}
L_end_motors_hard_right:
	RETURN
; end of _motors_hard_right

_raise_servo:

;MyProjectFinal.c,137 :: 		void raise_servo(){
;MyProjectFinal.c,141 :: 		for(i = 0; i < 50; i++){
	CLRF       raise_servo_i_L0+0
	CLRF       raise_servo_i_L0+1
L_raise_servo12:
	MOVLW      0
	SUBWF      raise_servo_i_L0+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__raise_servo123
	MOVLW      50
	SUBWF      raise_servo_i_L0+0, 0
L__raise_servo123:
	BTFSC      STATUS+0, 0
	GOTO       L_raise_servo13
;MyProjectFinal.c,142 :: 		PORTD |= SERVO_MASK;
	BSF        PORTD+0, 4
;MyProjectFinal.c,143 :: 		myusDelay(2200);
	MOVLW      152
	MOVWF      FARG_myusDelay_us+0
	MOVLW      8
	MOVWF      FARG_myusDelay_us+1
	CALL       _myusDelay+0
;MyProjectFinal.c,144 :: 		PORTD &= ~SERVO_MASK;
	BCF        PORTD+0, 4
;MyProjectFinal.c,145 :: 		myusDelay(18000);
	MOVLW      80
	MOVWF      FARG_myusDelay_us+0
	MOVLW      70
	MOVWF      FARG_myusDelay_us+1
	CALL       _myusDelay+0
;MyProjectFinal.c,141 :: 		for(i = 0; i < 50; i++){
	INCF       raise_servo_i_L0+0, 1
	BTFSC      STATUS+0, 2
	INCF       raise_servo_i_L0+1, 1
;MyProjectFinal.c,146 :: 		}
	GOTO       L_raise_servo12
L_raise_servo13:
;MyProjectFinal.c,147 :: 		}
L_end_raise_servo:
	RETURN
; end of _raise_servo

_adc_read_an5:

;MyProjectFinal.c,150 :: 		unsigned int adc_read_an5(void){
;MyProjectFinal.c,151 :: 		ADCON0 &= 0b11000101;
	MOVLW      197
	ANDWF      ADCON0+0, 1
;MyProjectFinal.c,152 :: 		ADCON0 |= 0b00101000;
	MOVLW      40
	IORWF      ADCON0+0, 1
;MyProjectFinal.c,153 :: 		myusDelay(30);
	MOVLW      30
	MOVWF      FARG_myusDelay_us+0
	MOVLW      0
	MOVWF      FARG_myusDelay_us+1
	CALL       _myusDelay+0
;MyProjectFinal.c,154 :: 		GO_DONE_bit = 1;
	BSF        GO_DONE_bit+0, BitPos(GO_DONE_bit+0)
;MyProjectFinal.c,155 :: 		while(GO_DONE_bit);
L_adc_read_an515:
	BTFSS      GO_DONE_bit+0, BitPos(GO_DONE_bit+0)
	GOTO       L_adc_read_an516
	GOTO       L_adc_read_an515
L_adc_read_an516:
;MyProjectFinal.c,156 :: 		return (((unsigned int)ADRESH << 8) | ADRESL);
	MOVF       ADRESH+0, 0
	MOVWF      R3+0
	CLRF       R3+1
	MOVF       R3+0, 0
	MOVWF      R0+1
	CLRF       R0+0
	MOVF       ADRESL+0, 0
	IORWF      R0+0, 1
	MOVLW      0
	IORWF      R0+1, 1
;MyProjectFinal.c,157 :: 		}
L_end_adc_read_an5:
	RETURN
; end of _adc_read_an5

_ultrasonic_read_cm:

;MyProjectFinal.c,159 :: 		unsigned int ultrasonic_read_cm(void){
;MyProjectFinal.c,163 :: 		US_TRIG = 0; myusDelay(2);
	BCF        RB0_bit+0, BitPos(RB0_bit+0)
	MOVLW      2
	MOVWF      FARG_myusDelay_us+0
	MOVLW      0
	MOVWF      FARG_myusDelay_us+1
	CALL       _myusDelay+0
;MyProjectFinal.c,164 :: 		US_TRIG = 1; myusDelay(10);
	BSF        RB0_bit+0, BitPos(RB0_bit+0)
	MOVLW      10
	MOVWF      FARG_myusDelay_us+0
	MOVLW      0
	MOVWF      FARG_myusDelay_us+1
	CALL       _myusDelay+0
;MyProjectFinal.c,165 :: 		US_TRIG = 0;
	BCF        RB0_bit+0, BitPos(RB0_bit+0)
;MyProjectFinal.c,167 :: 		timeout = 60000;
	MOVLW      96
	MOVWF      ultrasonic_read_cm_timeout_L0+0
	MOVLW      234
	MOVWF      ultrasonic_read_cm_timeout_L0+1
	CLRF       ultrasonic_read_cm_timeout_L0+2
	CLRF       ultrasonic_read_cm_timeout_L0+3
;MyProjectFinal.c,168 :: 		while(!US_ECHO && timeout--);
L_ultrasonic_read_cm17:
	BTFSC      RB1_bit+0, BitPos(RB1_bit+0)
	GOTO       L_ultrasonic_read_cm18
	MOVF       ultrasonic_read_cm_timeout_L0+0, 0
	MOVWF      R0+0
	MOVF       ultrasonic_read_cm_timeout_L0+1, 0
	MOVWF      R0+1
	MOVF       ultrasonic_read_cm_timeout_L0+2, 0
	MOVWF      R0+2
	MOVF       ultrasonic_read_cm_timeout_L0+3, 0
	MOVWF      R0+3
	MOVLW      1
	SUBWF      ultrasonic_read_cm_timeout_L0+0, 1
	BTFSS      STATUS+0, 0
	SUBWF      ultrasonic_read_cm_timeout_L0+1, 1
	BTFSS      STATUS+0, 0
	SUBWF      ultrasonic_read_cm_timeout_L0+2, 1
	BTFSS      STATUS+0, 0
	SUBWF      ultrasonic_read_cm_timeout_L0+3, 1
	MOVF       R0+0, 0
	IORWF      R0+1, 0
	IORWF      R0+2, 0
	IORWF      R0+3, 0
	BTFSC      STATUS+0, 2
	GOTO       L_ultrasonic_read_cm18
L__ultrasonic_read_cm88:
	GOTO       L_ultrasonic_read_cm17
L_ultrasonic_read_cm18:
;MyProjectFinal.c,169 :: 		if(timeout == 0) return 0;
	MOVLW      0
	MOVWF      R0+0
	XORWF      ultrasonic_read_cm_timeout_L0+3, 0
	BTFSS      STATUS+0, 2
	GOTO       L__ultrasonic_read_cm126
	MOVF       R0+0, 0
	XORWF      ultrasonic_read_cm_timeout_L0+2, 0
	BTFSS      STATUS+0, 2
	GOTO       L__ultrasonic_read_cm126
	MOVF       R0+0, 0
	XORWF      ultrasonic_read_cm_timeout_L0+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__ultrasonic_read_cm126
	MOVF       ultrasonic_read_cm_timeout_L0+0, 0
	XORLW      0
L__ultrasonic_read_cm126:
	BTFSS      STATUS+0, 2
	GOTO       L_ultrasonic_read_cm21
	CLRF       R0+0
	CLRF       R0+1
	GOTO       L_end_ultrasonic_read_cm
L_ultrasonic_read_cm21:
;MyProjectFinal.c,171 :: 		TMR1H = 0; TMR1L = 0;
	CLRF       TMR1H+0
	CLRF       TMR1L+0
;MyProjectFinal.c,172 :: 		T1CON = 0x00;
	CLRF       T1CON+0
;MyProjectFinal.c,173 :: 		T1CON.TMR1ON = 1;
	BSF        T1CON+0, 0
;MyProjectFinal.c,175 :: 		timeout = 60000;
	MOVLW      96
	MOVWF      ultrasonic_read_cm_timeout_L0+0
	MOVLW      234
	MOVWF      ultrasonic_read_cm_timeout_L0+1
	CLRF       ultrasonic_read_cm_timeout_L0+2
	CLRF       ultrasonic_read_cm_timeout_L0+3
;MyProjectFinal.c,176 :: 		while(US_ECHO && timeout--);
L_ultrasonic_read_cm22:
	BTFSS      RB1_bit+0, BitPos(RB1_bit+0)
	GOTO       L_ultrasonic_read_cm23
	MOVF       ultrasonic_read_cm_timeout_L0+0, 0
	MOVWF      R0+0
	MOVF       ultrasonic_read_cm_timeout_L0+1, 0
	MOVWF      R0+1
	MOVF       ultrasonic_read_cm_timeout_L0+2, 0
	MOVWF      R0+2
	MOVF       ultrasonic_read_cm_timeout_L0+3, 0
	MOVWF      R0+3
	MOVLW      1
	SUBWF      ultrasonic_read_cm_timeout_L0+0, 1
	BTFSS      STATUS+0, 0
	SUBWF      ultrasonic_read_cm_timeout_L0+1, 1
	BTFSS      STATUS+0, 0
	SUBWF      ultrasonic_read_cm_timeout_L0+2, 1
	BTFSS      STATUS+0, 0
	SUBWF      ultrasonic_read_cm_timeout_L0+3, 1
	MOVF       R0+0, 0
	IORWF      R0+1, 0
	IORWF      R0+2, 0
	IORWF      R0+3, 0
	BTFSC      STATUS+0, 2
	GOTO       L_ultrasonic_read_cm23
L__ultrasonic_read_cm87:
	GOTO       L_ultrasonic_read_cm22
L_ultrasonic_read_cm23:
;MyProjectFinal.c,178 :: 		T1CON.TMR1ON = 0;
	BCF        T1CON+0, 0
;MyProjectFinal.c,179 :: 		if(timeout == 0) return 0;
	MOVLW      0
	MOVWF      R0+0
	XORWF      ultrasonic_read_cm_timeout_L0+3, 0
	BTFSS      STATUS+0, 2
	GOTO       L__ultrasonic_read_cm127
	MOVF       R0+0, 0
	XORWF      ultrasonic_read_cm_timeout_L0+2, 0
	BTFSS      STATUS+0, 2
	GOTO       L__ultrasonic_read_cm127
	MOVF       R0+0, 0
	XORWF      ultrasonic_read_cm_timeout_L0+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__ultrasonic_read_cm127
	MOVF       ultrasonic_read_cm_timeout_L0+0, 0
	XORLW      0
L__ultrasonic_read_cm127:
	BTFSS      STATUS+0, 2
	GOTO       L_ultrasonic_read_cm26
	CLRF       R0+0
	CLRF       R0+1
	GOTO       L_end_ultrasonic_read_cm
L_ultrasonic_read_cm26:
;MyProjectFinal.c,181 :: 		ticks = ((unsigned int)TMR1H << 8) | TMR1L;
	MOVF       TMR1H+0, 0
	MOVWF      R3+0
	CLRF       R3+1
	MOVF       R3+0, 0
	MOVWF      R0+1
	CLRF       R0+0
	MOVF       TMR1L+0, 0
	IORWF      R0+0, 1
	MOVLW      0
	IORWF      R0+1, 1
;MyProjectFinal.c,182 :: 		return ticks / 116;
	MOVLW      116
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	CALL       _Div_16X16_U+0
;MyProjectFinal.c,183 :: 		}
L_end_ultrasonic_read_cm:
	RETURN
; end of _ultrasonic_read_cm

_init_hw:

;MyProjectFinal.c,185 :: 		void init_hw(void){
;MyProjectFinal.c,186 :: 		OPTION_REG = 0b00000111;
	MOVLW      7
	MOVWF      OPTION_REG+0
;MyProjectFinal.c,187 :: 		TMR0 = TMR0_PRELOAD;
	MOVLW      248
	MOVWF      TMR0+0
;MyProjectFinal.c,188 :: 		INTCON = 0b10100000;
	MOVLW      160
	MOVWF      INTCON+0
;MyProjectFinal.c,189 :: 		INTCON.T0IF = 0;
	BCF        INTCON+0, 2
;MyProjectFinal.c,191 :: 		ADCON1 = 0x80;
	MOVLW      128
	MOVWF      ADCON1+0
;MyProjectFinal.c,193 :: 		TRISB0_bit = 0; // trig
	BCF        TRISB0_bit+0, BitPos(TRISB0_bit+0)
;MyProjectFinal.c,194 :: 		TRISB1_bit = 1; // echo
	BSF        TRISB1_bit+0, BitPos(TRISB1_bit+0)
;MyProjectFinal.c,195 :: 		TRISB2_bit = 1; // left IR
	BSF        TRISB2_bit+0, BitPos(TRISB2_bit+0)
;MyProjectFinal.c,196 :: 		TRISB3_bit = 1; // right IR
	BSF        TRISB3_bit+0, BitPos(TRISB3_bit+0)
;MyProjectFinal.c,197 :: 		TRISB4_bit = 1; // left sensor
	BSF        TRISB4_bit+0, BitPos(TRISB4_bit+0)
;MyProjectFinal.c,198 :: 		TRISB5_bit = 1; // right sensor
	BSF        TRISB5_bit+0, BitPos(TRISB5_bit+0)
;MyProjectFinal.c,199 :: 		TRISB7_bit = 1; // MIDLLE SENSOR
	BSF        TRISB7_bit+0, BitPos(TRISB7_bit+0)
;MyProjectFinal.c,201 :: 		TRISE0_bit = 1;
	BSF        TRISE0_bit+0, BitPos(TRISE0_bit+0)
;MyProjectFinal.c,203 :: 		TRISD = 0x00;
	CLRF       TRISD+0
;MyProjectFinal.c,204 :: 		TRISC = 0x00;
	CLRF       TRISC+0
;MyProjectFinal.c,207 :: 		PORTD &= ~SERVO_MASK;  //servo starts at zero position
	BCF        PORTD+0, 4
;MyProjectFinal.c,209 :: 		PR2  = 99;
	MOVLW      99
	MOVWF      PR2+0
;MyProjectFinal.c,210 :: 		T2CON = 0b00000101;
	MOVLW      5
	MOVWF      T2CON+0
;MyProjectFinal.c,211 :: 		CCP1CON = 0b00001100;
	MOVLW      12
	MOVWF      CCP1CON+0
;MyProjectFinal.c,212 :: 		CCP2CON = 0b00001100;
	MOVLW      12
	MOVWF      CCP2CON+0
;MyProjectFinal.c,214 :: 		ADCON0 = 0b10000001;
	MOVLW      129
	MOVWF      ADCON0+0
;MyProjectFinal.c,216 :: 		BUZZER = 1;
	BSF        RC0_bit+0, BitPos(RC0_bit+0)
;MyProjectFinal.c,217 :: 		ACTIVE_LED = 0; // LED starts off then on
	BCF        RC3_bit+0, BitPos(RC3_bit+0)
;MyProjectFinal.c,218 :: 		motors_stop();
	CALL       _motors_stop+0
;MyProjectFinal.c,219 :: 		mymsDelay(10);
	MOVLW      10
	MOVWF      FARG_mymsDelay_ms+0
	MOVLW      0
	MOVWF      FARG_mymsDelay_ms+1
	CALL       _mymsDelay+0
;MyProjectFinal.c,220 :: 		}
L_end_init_hw:
	RETURN
; end of _init_hw

_main:

;MyProjectFinal.c,222 :: 		void main(){
;MyProjectFinal.c,226 :: 		unsigned char both_count = 0;
	CLRF       main_both_count_L0+0
	CLRF       main_in_tunnel_L0+0
	CLRF       main_dark_cnt_L0+0
	CLRF       main_light_cnt_L0+0
	CLRF       main_prev_tunnel_L0+0
	CLRF       main_post_tunnel_L0+0
	CLRF       main_post_tunnel_just_entered_L0+0
	CLRF       main_post_timer_L0+0
	CLRF       main_post_timer_L0+1
	CLRF       main_wall_ir_active_L0+0
	CLRF       main_ir_cooldown_L0+0
	CLRF       main_t_cnt_L0+0
;MyProjectFinal.c,242 :: 		init_hw();
	CALL       _init_hw+0
;MyProjectFinal.c,245 :: 		unsigned int t0 = g_ms;
	MOVF       _g_ms+0, 0
	MOVWF      main_t0_L1+0
	MOVF       _g_ms+1, 0
	MOVWF      main_t0_L1+1
;MyProjectFinal.c,246 :: 		while((unsigned int)(g_ms - t0) < 2333);
L_main27:
	MOVF       main_t0_L1+0, 0
	SUBWF      _g_ms+0, 0
	MOVWF      R1+0
	MOVF       main_t0_L1+1, 0
	BTFSS      STATUS+0, 0
	ADDLW      1
	SUBWF      _g_ms+1, 0
	MOVWF      R1+1
	MOVLW      9
	SUBWF      R1+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main130
	MOVLW      29
	SUBWF      R1+0, 0
L__main130:
	BTFSC      STATUS+0, 0
	GOTO       L_main28
	GOTO       L_main27
L_main28:
;MyProjectFinal.c,248 :: 		ACTIVE_LED = 1;
	BSF        RC3_bit+0, BitPos(RC3_bit+0)
;MyProjectFinal.c,250 :: 		while(1){
L_main29:
;MyProjectFinal.c,252 :: 		if(LEFT_SENSOR == !SENSOR_ON_LINE && RIGHT_SENSOR == !SENSOR_ON_LINE && MID_SENSOR == !SENSOR_ON_LINE){
	BTFSS      RB4_bit+0, BitPos(RB4_bit+0)
	GOTO       L_main33
	BTFSS      RB5_bit+0, BitPos(RB5_bit+0)
	GOTO       L_main33
	BTFSS      RB7_bit+0, BitPos(RB7_bit+0)
	GOTO       L_main33
L__main98:
;MyProjectFinal.c,253 :: 		if(all_black_start == 0)
	MOVLW      0
	XORWF      _all_black_start+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main131
	MOVLW      0
	XORWF      _all_black_start+0, 0
L__main131:
	BTFSS      STATUS+0, 2
	GOTO       L_main34
;MyProjectFinal.c,254 :: 		all_black_start = g_ms;
	MOVF       _g_ms+0, 0
	MOVWF      _all_black_start+0
	MOVF       _g_ms+1, 0
	MOVWF      _all_black_start+1
L_main34:
;MyProjectFinal.c,255 :: 		if((unsigned int)(g_ms - all_black_start) >= 3500){
	MOVF       _all_black_start+0, 0
	SUBWF      _g_ms+0, 0
	MOVWF      R1+0
	MOVF       _all_black_start+1, 0
	BTFSS      STATUS+0, 0
	ADDLW      1
	SUBWF      _g_ms+1, 0
	MOVWF      R1+1
	MOVLW      13
	SUBWF      R1+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main132
	MOVLW      172
	SUBWF      R1+0, 0
L__main132:
	BTFSS      STATUS+0, 0
	GOTO       L_main35
;MyProjectFinal.c,256 :: 		motors_forward(SPEED_FORWARD, SPEED_FORWARD);
	MOVLW      79
	MOVWF      FARG_motors_forward_l+0
	MOVLW      1
	MOVWF      FARG_motors_forward_l+1
	MOVLW      79
	MOVWF      FARG_motors_forward_r+0
	MOVLW      1
	MOVWF      FARG_motors_forward_r+1
	CALL       _motors_forward+0
;MyProjectFinal.c,257 :: 		mymsDelay(300);
	MOVLW      44
	MOVWF      FARG_mymsDelay_ms+0
	MOVLW      1
	MOVWF      FARG_mymsDelay_ms+1
	CALL       _mymsDelay+0
;MyProjectFinal.c,258 :: 		motors_stop();
	CALL       _motors_stop+0
;MyProjectFinal.c,259 :: 		ACTIVE_LED = 0;
	BCF        RC3_bit+0, BitPos(RC3_bit+0)
;MyProjectFinal.c,261 :: 		raise_servo();
	CALL       _raise_servo+0
;MyProjectFinal.c,263 :: 		BUZZER = 1;
	BSF        RC0_bit+0, BitPos(RC0_bit+0)
;MyProjectFinal.c,265 :: 		while(1);
L_main36:
	GOTO       L_main36
;MyProjectFinal.c,266 :: 		}
L_main35:
;MyProjectFinal.c,267 :: 		}
L_main33:
;MyProjectFinal.c,268 :: 		if(ir_cooldown > 0) ir_cooldown--;
	MOVF       main_ir_cooldown_L0+0, 0
	SUBLW      0
	BTFSC      STATUS+0, 0
	GOTO       L_main38
	DECF       main_ir_cooldown_L0+0, 1
L_main38:
;MyProjectFinal.c,271 :: 		ldr_val = adc_read_an5();
	CALL       _adc_read_an5+0
;MyProjectFinal.c,274 :: 		if(raw_tunnel){ dark_cnt++; light_cnt = 0; }
	MOVLW      2
	SUBWF      R0+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main133
	MOVLW      38
	SUBWF      R0+0, 0
L__main133:
	BTFSC      STATUS+0, 0
	GOTO       L_main39
	INCF       main_dark_cnt_L0+0, 1
	CLRF       main_light_cnt_L0+0
	GOTO       L_main40
L_main39:
;MyProjectFinal.c,275 :: 		else         { light_cnt++; dark_cnt = 0; }
	INCF       main_light_cnt_L0+0, 1
	CLRF       main_dark_cnt_L0+0
L_main40:
;MyProjectFinal.c,277 :: 		if(dark_cnt >= DARK_CONFIRM_COUNT)  in_tunnel = 1;
	MOVLW      8
	SUBWF      main_dark_cnt_L0+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_main41
	MOVLW      1
	MOVWF      main_in_tunnel_L0+0
L_main41:
;MyProjectFinal.c,278 :: 		if(light_cnt >= LIGHT_CONFIRM_COUNT) in_tunnel = 0;
	MOVLW      20
	SUBWF      main_light_cnt_L0+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_main42
	CLRF       main_in_tunnel_L0+0
L_main42:
;MyProjectFinal.c,280 :: 		BUZZER = in_tunnel ? 0 : 1;
	MOVF       main_in_tunnel_L0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main43
	CLRF       ?FLOC___mainT89+0
	GOTO       L_main44
L_main43:
	MOVLW      1
	MOVWF      ?FLOC___mainT89+0
L_main44:
	BTFSC      ?FLOC___mainT89+0, 0
	GOTO       L__main134
	BCF        RC0_bit+0, BitPos(RC0_bit+0)
	GOTO       L__main135
L__main134:
	BSF        RC0_bit+0, BitPos(RC0_bit+0)
L__main135:
;MyProjectFinal.c,283 :: 		if(prev_tunnel && !in_tunnel){
	MOVF       main_prev_tunnel_L0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main47
	MOVF       main_in_tunnel_L0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_main47
L__main97:
;MyProjectFinal.c,284 :: 		post_tunnel = 1;
	MOVLW      1
	MOVWF      main_post_tunnel_L0+0
;MyProjectFinal.c,285 :: 		post_tunnel_just_entered = 1;
	MOVLW      1
	MOVWF      main_post_tunnel_just_entered_L0+0
;MyProjectFinal.c,286 :: 		}
L_main47:
;MyProjectFinal.c,287 :: 		prev_tunnel = in_tunnel;
	MOVF       main_in_tunnel_L0+0, 0
	MOVWF      main_prev_tunnel_L0+0
;MyProjectFinal.c,290 :: 		if(post_tunnel){
	MOVF       main_post_tunnel_L0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main48
;MyProjectFinal.c,292 :: 		if(post_tunnel_just_entered){
	MOVF       main_post_tunnel_just_entered_L0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main49
;MyProjectFinal.c,293 :: 		post_timer = 0;
	CLRF       main_post_timer_L0+0
	CLRF       main_post_timer_L0+1
;MyProjectFinal.c,294 :: 		wall_ir_active = 0;
	CLRF       main_wall_ir_active_L0+0
;MyProjectFinal.c,295 :: 		post_tunnel_just_entered = 0;
	CLRF       main_post_tunnel_just_entered_L0+0
;MyProjectFinal.c,296 :: 		}
L_main49:
;MyProjectFinal.c,298 :: 		if(post_timer < WALL_IR_DELAY_COUNT) post_timer++;
	MOVLW      1
	SUBWF      main_post_timer_L0+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main136
	MOVLW      119
	SUBWF      main_post_timer_L0+0, 0
L__main136:
	BTFSC      STATUS+0, 0
	GOTO       L_main50
	INCF       main_post_timer_L0+0, 1
	BTFSC      STATUS+0, 2
	INCF       main_post_timer_L0+1, 1
	GOTO       L_main51
L_main50:
;MyProjectFinal.c,299 :: 		else wall_ir_active = 1;
	MOVLW      1
	MOVWF      main_wall_ir_active_L0+0
L_main51:
;MyProjectFinal.c,302 :: 		if(wall_ir_active && ir_cooldown == 0){
	MOVF       main_wall_ir_active_L0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main54
	MOVF       main_ir_cooldown_L0+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_main54
L__main96:
;MyProjectFinal.c,304 :: 		if(WALL_LEFT_IR == 0 && WALL_RIGHT_IR == 1){
	BTFSC      RB2_bit+0, BitPos(RB2_bit+0)
	GOTO       L_main57
	BTFSS      RB3_bit+0, BitPos(RB3_bit+0)
	GOTO       L_main57
L__main95:
;MyProjectFinal.c,305 :: 		motors_hard_right(); mymsDelay(WALL_ROTATE_MS);
	CALL       _motors_hard_right+0
	MOVLW      55
	MOVWF      FARG_mymsDelay_ms+0
	MOVLW      0
	MOVWF      FARG_mymsDelay_ms+1
	CALL       _mymsDelay+0
;MyProjectFinal.c,306 :: 		motors_stop();       mymsDelay(WALL_CHECK_MS);
	CALL       _motors_stop+0
	MOVLW      20
	MOVWF      FARG_mymsDelay_ms+0
	MOVLW      0
	MOVWF      FARG_mymsDelay_ms+1
	CALL       _mymsDelay+0
;MyProjectFinal.c,308 :: 		motors_forward(SPEED_OBS_FORWARD, SPEED_OBS_FORWARD);
	MOVLW      104
	MOVWF      FARG_motors_forward_l+0
	MOVLW      1
	MOVWF      FARG_motors_forward_l+1
	MOVLW      104
	MOVWF      FARG_motors_forward_r+0
	MOVLW      1
	MOVWF      FARG_motors_forward_r+1
	CALL       _motors_forward+0
;MyProjectFinal.c,309 :: 		mymsDelay(IR_PUSH_MS);
	MOVLW      90
	MOVWF      FARG_mymsDelay_ms+0
	MOVLW      0
	MOVWF      FARG_mymsDelay_ms+1
	CALL       _mymsDelay+0
;MyProjectFinal.c,311 :: 		ir_cooldown = IR_COOLDOWN_COUNT;
	MOVLW      25
	MOVWF      main_ir_cooldown_L0+0
;MyProjectFinal.c,312 :: 		continue;
	GOTO       L_main29
;MyProjectFinal.c,313 :: 		}
L_main57:
;MyProjectFinal.c,315 :: 		if(WALL_RIGHT_IR == 0 && WALL_LEFT_IR == 1){
	BTFSC      RB3_bit+0, BitPos(RB3_bit+0)
	GOTO       L_main60
	BTFSS      RB2_bit+0, BitPos(RB2_bit+0)
	GOTO       L_main60
L__main94:
;MyProjectFinal.c,316 :: 		motors_hard_left();  mymsDelay(WALL_ROTATE_MS);
	CALL       _motors_hard_left+0
	MOVLW      55
	MOVWF      FARG_mymsDelay_ms+0
	MOVLW      0
	MOVWF      FARG_mymsDelay_ms+1
	CALL       _mymsDelay+0
;MyProjectFinal.c,317 :: 		motors_stop();       mymsDelay(WALL_CHECK_MS);
	CALL       _motors_stop+0
	MOVLW      20
	MOVWF      FARG_mymsDelay_ms+0
	MOVLW      0
	MOVWF      FARG_mymsDelay_ms+1
	CALL       _mymsDelay+0
;MyProjectFinal.c,319 :: 		motors_forward(SPEED_OBS_FORWARD, SPEED_OBS_FORWARD);
	MOVLW      104
	MOVWF      FARG_motors_forward_l+0
	MOVLW      1
	MOVWF      FARG_motors_forward_l+1
	MOVLW      104
	MOVWF      FARG_motors_forward_r+0
	MOVLW      1
	MOVWF      FARG_motors_forward_r+1
	CALL       _motors_forward+0
;MyProjectFinal.c,320 :: 		mymsDelay(IR_PUSH_MS);
	MOVLW      90
	MOVWF      FARG_mymsDelay_ms+0
	MOVLW      0
	MOVWF      FARG_mymsDelay_ms+1
	CALL       _mymsDelay+0
;MyProjectFinal.c,322 :: 		ir_cooldown = IR_COOLDOWN_COUNT;
	MOVLW      25
	MOVWF      main_ir_cooldown_L0+0
;MyProjectFinal.c,323 :: 		continue;
	GOTO       L_main29
;MyProjectFinal.c,324 :: 		}
L_main60:
;MyProjectFinal.c,325 :: 		}
L_main54:
;MyProjectFinal.c,328 :: 		d = ultrasonic_read_cm();
	CALL       _ultrasonic_read_cm+0
	MOVF       R0+0, 0
	MOVWF      main_d_L0+0
	MOVF       R0+1, 0
	MOVWF      main_d_L0+1
;MyProjectFinal.c,329 :: 		if(d != 0 && d <= WALL_DIST_CM){
	MOVLW      0
	XORWF      R0+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main137
	MOVLW      0
	XORWF      R0+0, 0
L__main137:
	BTFSC      STATUS+0, 2
	GOTO       L_main63
	MOVF       main_d_L0+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__main138
	MOVF       main_d_L0+0, 0
	SUBLW      22
L__main138:
	BTFSS      STATUS+0, 0
	GOTO       L_main63
L__main93:
;MyProjectFinal.c,331 :: 		motors_stop();
	CALL       _motors_stop+0
;MyProjectFinal.c,332 :: 		mymsDelay(25);
	MOVLW      25
	MOVWF      FARG_mymsDelay_ms+0
	MOVLW      0
	MOVWF      FARG_mymsDelay_ms+1
	CALL       _mymsDelay+0
;MyProjectFinal.c,333 :: 		motors_hard_right();
	CALL       _motors_hard_right+0
;MyProjectFinal.c,334 :: 		mymsDelay(TURN_RIGHT_MS);
	MOVLW      44
	MOVWF      FARG_mymsDelay_ms+0
	MOVLW      1
	MOVWF      FARG_mymsDelay_ms+1
	CALL       _mymsDelay+0
;MyProjectFinal.c,335 :: 		motors_stop();
	CALL       _motors_stop+0
;MyProjectFinal.c,336 :: 		mymsDelay(20);
	MOVLW      20
	MOVWF      FARG_mymsDelay_ms+0
	MOVLW      0
	MOVWF      FARG_mymsDelay_ms+1
	CALL       _mymsDelay+0
;MyProjectFinal.c,338 :: 		motors_forward(SPEED_OBS_FORWARD, SPEED_OBS_FORWARD);
	MOVLW      104
	MOVWF      FARG_motors_forward_l+0
	MOVLW      1
	MOVWF      FARG_motors_forward_l+1
	MOVLW      104
	MOVWF      FARG_motors_forward_r+0
	MOVLW      1
	MOVWF      FARG_motors_forward_r+1
	CALL       _motors_forward+0
;MyProjectFinal.c,339 :: 		mymsDelay(AFTER_TURN_FWD_MS);
	MOVLW      100
	MOVWF      FARG_mymsDelay_ms+0
	MOVLW      0
	MOVWF      FARG_mymsDelay_ms+1
	CALL       _mymsDelay+0
;MyProjectFinal.c,341 :: 		continue;
	GOTO       L_main29
;MyProjectFinal.c,342 :: 		}
L_main63:
;MyProjectFinal.c,343 :: 		}
L_main48:
;MyProjectFinal.c,346 :: 		left_raw  = LEFT_SENSOR;
	MOVLW      0
	BTFSC      RB4_bit+0, BitPos(RB4_bit+0)
	MOVLW      1
	MOVWF      main_left_raw_L0+0
;MyProjectFinal.c,347 :: 		right_raw = RIGHT_SENSOR;
	MOVLW      0
	BTFSC      RB5_bit+0, BitPos(RB5_bit+0)
	MOVLW      1
	MOVWF      main_right_raw_L0+0
;MyProjectFinal.c,349 :: 		left_on  = (left_raw  == SENSOR_ON_LINE);
	MOVF       main_left_raw_L0+0, 0
	XORLW      0
	MOVLW      1
	BTFSS      STATUS+0, 2
	MOVLW      0
	MOVWF      R0+0
	BTFSC      R0+0, 0
	GOTO       L__main139
	BCF        main_left_on_L0+0, BitPos(main_left_on_L0+0)
	GOTO       L__main140
L__main139:
	BSF        main_left_on_L0+0, BitPos(main_left_on_L0+0)
L__main140:
;MyProjectFinal.c,350 :: 		right_on = (right_raw == SENSOR_ON_LINE);
	MOVF       main_right_raw_L0+0, 0
	XORLW      0
	MOVLW      1
	BTFSS      STATUS+0, 2
	MOVLW      0
	MOVWF      R0+0
	BTFSC      R0+0, 0
	GOTO       L__main141
	BCF        main_right_on_L0+0, BitPos(main_right_on_L0+0)
	GOTO       L__main142
L__main141:
	BSF        main_right_on_L0+0, BitPos(main_right_on_L0+0)
L__main142:
;MyProjectFinal.c,353 :: 		if(left_on && right_on){
	BTFSS      main_left_on_L0+0, BitPos(main_left_on_L0+0)
	GOTO       L_main66
	BTFSS      main_right_on_L0+0, BitPos(main_right_on_L0+0)
	GOTO       L_main66
L__main92:
;MyProjectFinal.c,355 :: 		if(t_cnt < T_CONFIRM) t_cnt++;
	MOVLW      3
	SUBWF      main_t_cnt_L0+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_main67
	INCF       main_t_cnt_L0+0, 1
L_main67:
;MyProjectFinal.c,357 :: 		if(t_cnt >= T_CONFIRM)
	MOVLW      3
	SUBWF      main_t_cnt_L0+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_main68
;MyProjectFinal.c,358 :: 		motors_forward_tunnel(SPEED_T_JUNC, SPEED_T_JUNC, in_tunnel);
	MOVLW      215
	MOVWF      FARG_motors_forward_tunnel_l+0
	MOVLW      0
	MOVWF      FARG_motors_forward_tunnel_l+1
	MOVLW      215
	MOVWF      FARG_motors_forward_tunnel_r+0
	MOVLW      0
	MOVWF      FARG_motors_forward_tunnel_r+1
	MOVF       main_in_tunnel_L0+0, 0
	MOVWF      FARG_motors_forward_tunnel_in_tunnel+0
	CALL       _motors_forward_tunnel+0
	GOTO       L_main69
L_main68:
;MyProjectFinal.c,360 :: 		motors_forward_tunnel(SPEED_FORWARD, SPEED_FORWARD, in_tunnel);
	MOVLW      79
	MOVWF      FARG_motors_forward_tunnel_l+0
	MOVLW      1
	MOVWF      FARG_motors_forward_tunnel_l+1
	MOVLW      79
	MOVWF      FARG_motors_forward_tunnel_r+0
	MOVLW      1
	MOVWF      FARG_motors_forward_tunnel_r+1
	MOVF       main_in_tunnel_L0+0, 0
	MOVWF      FARG_motors_forward_tunnel_in_tunnel+0
	CALL       _motors_forward_tunnel+0
L_main69:
;MyProjectFinal.c,362 :: 		both_count = 0;
	CLRF       main_both_count_L0+0
;MyProjectFinal.c,363 :: 		}
	GOTO       L_main70
L_main66:
;MyProjectFinal.c,365 :: 		t_cnt = 0; // reset when not both black
	CLRF       main_t_cnt_L0+0
;MyProjectFinal.c,367 :: 		if(left_on && !right_on){
	BTFSS      main_left_on_L0+0, BitPos(main_left_on_L0+0)
	GOTO       L_main73
	BTFSC      main_right_on_L0+0, BitPos(main_right_on_L0+0)
	GOTO       L_main73
L__main91:
;MyProjectFinal.c,368 :: 		motors_forward_tunnel(CURVE_SLOW_S, CURVE_FAST_S, in_tunnel);
	MOVLW      155
	MOVWF      FARG_motors_forward_tunnel_l+0
	MOVLW      0
	MOVWF      FARG_motors_forward_tunnel_l+1
	MOVLW      245
	MOVWF      FARG_motors_forward_tunnel_r+0
	MOVLW      0
	MOVWF      FARG_motors_forward_tunnel_r+1
	MOVF       main_in_tunnel_L0+0, 0
	MOVWF      FARG_motors_forward_tunnel_in_tunnel+0
	CALL       _motors_forward_tunnel+0
;MyProjectFinal.c,369 :: 		both_count = 0;
	CLRF       main_both_count_L0+0
;MyProjectFinal.c,370 :: 		}
	GOTO       L_main74
L_main73:
;MyProjectFinal.c,371 :: 		else if(!left_on && right_on){
	BTFSC      main_left_on_L0+0, BitPos(main_left_on_L0+0)
	GOTO       L_main77
	BTFSS      main_right_on_L0+0, BitPos(main_right_on_L0+0)
	GOTO       L_main77
L__main90:
;MyProjectFinal.c,372 :: 		motors_forward_tunnel(CURVE_FAST_S, CURVE_SLOW_S, in_tunnel);
	MOVLW      245
	MOVWF      FARG_motors_forward_tunnel_l+0
	MOVLW      0
	MOVWF      FARG_motors_forward_tunnel_l+1
	MOVLW      155
	MOVWF      FARG_motors_forward_tunnel_r+0
	MOVLW      0
	MOVWF      FARG_motors_forward_tunnel_r+1
	MOVF       main_in_tunnel_L0+0, 0
	MOVWF      FARG_motors_forward_tunnel_in_tunnel+0
	CALL       _motors_forward_tunnel+0
;MyProjectFinal.c,373 :: 		both_count = 0;
	CLRF       main_both_count_L0+0
;MyProjectFinal.c,374 :: 		}
	GOTO       L_main78
L_main77:
;MyProjectFinal.c,376 :: 		both_count++;
	INCF       main_both_count_L0+0, 1
;MyProjectFinal.c,377 :: 		if(both_count < 5){
	MOVLW      5
	SUBWF      main_both_count_L0+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_main79
;MyProjectFinal.c,378 :: 		motors_forward_tunnel(SPEED_FORWARD, SPEED_FORWARD, in_tunnel);
	MOVLW      79
	MOVWF      FARG_motors_forward_tunnel_l+0
	MOVLW      1
	MOVWF      FARG_motors_forward_tunnel_l+1
	MOVLW      79
	MOVWF      FARG_motors_forward_tunnel_r+0
	MOVLW      1
	MOVWF      FARG_motors_forward_tunnel_r+1
	MOVF       main_in_tunnel_L0+0, 0
	MOVWF      FARG_motors_forward_tunnel_in_tunnel+0
	CALL       _motors_forward_tunnel+0
;MyProjectFinal.c,379 :: 		}else{
	GOTO       L_main80
L_main79:
;MyProjectFinal.c,380 :: 		motors_stop(); mymsDelay(40);
	CALL       _motors_stop+0
	MOVLW      40
	MOVWF      FARG_mymsDelay_ms+0
	MOVLW      0
	MOVWF      FARG_mymsDelay_ms+1
	CALL       _mymsDelay+0
;MyProjectFinal.c,381 :: 		while(1){
L_main81:
;MyProjectFinal.c,382 :: 		motors_hard_left();
	CALL       _motors_hard_left+0
;MyProjectFinal.c,383 :: 		if((LEFT_SENSOR == SENSOR_ON_LINE) || (RIGHT_SENSOR == SENSOR_ON_LINE))
	BTFSS      RB4_bit+0, BitPos(RB4_bit+0)
	GOTO       L__main89
	BTFSS      RB5_bit+0, BitPos(RB5_bit+0)
	GOTO       L__main89
	GOTO       L_main85
L__main89:
;MyProjectFinal.c,384 :: 		break;
	GOTO       L_main82
L_main85:
;MyProjectFinal.c,385 :: 		myusDelay(200);
	MOVLW      200
	MOVWF      FARG_myusDelay_us+0
	CLRF       FARG_myusDelay_us+1
	CALL       _myusDelay+0
;MyProjectFinal.c,386 :: 		}
	GOTO       L_main81
L_main82:
;MyProjectFinal.c,387 :: 		both_count = 0;
	CLRF       main_both_count_L0+0
;MyProjectFinal.c,388 :: 		}
L_main80:
;MyProjectFinal.c,389 :: 		}
L_main78:
L_main74:
;MyProjectFinal.c,390 :: 		}
L_main70:
;MyProjectFinal.c,392 :: 		mymsDelay(8);
	MOVLW      8
	MOVWF      FARG_mymsDelay_ms+0
	MOVLW      0
	MOVWF      FARG_mymsDelay_ms+1
	CALL       _mymsDelay+0
;MyProjectFinal.c,393 :: 		}
	GOTO       L_main29
;MyProjectFinal.c,394 :: 		}
L_end_main:
	GOTO       $+0
; end of _main
