#line 1 "C:/Users/Administrator/Desktop/EmbProj Final/MyProjectFinal.c"
#line 25 "C:/Users/Administrator/Desktop/EmbProj Final/MyProjectFinal.c"
 unsigned int all_black_start = 0;




const unsigned int SPEED_FORWARD = 335;
const unsigned int TURN_SPEED = 195;
const unsigned int CURVE_FAST = 295;
const unsigned int CURVE_SLOW = 175;
const unsigned int SPEED_T_JUNC = 215;
const unsigned int CURVE_FAST_S = 245;
const unsigned int CURVE_SLOW_S = 155;


const unsigned int SPEED_OBS_FORWARD = 360;
#line 51 "C:/Users/Administrator/Desktop/EmbProj Final/MyProjectFinal.c"
volatile unsigned int g_ms = 0;


void interrupt(void){
 if(INTCON.T0IF){
 TMR0 =  248 ;
 g_ms++;
 INTCON.T0IF = 0;
 }
}

void mymsDelay(unsigned int ms){
 unsigned int start = g_ms;
 while((unsigned int)(g_ms - start) < ms);
}

void myusDelay(unsigned int us){
 unsigned int target_ticks = us * 2;
 unsigned int t;

 T1CON = 0x00;
 TMR1H = 0;
 TMR1L = 0;
 T1CON.TMR1ON = 1;

 while(1){
 t = ((unsigned int)TMR1H << 8) | TMR1L;
 if(t >= target_ticks) break;
 }

 T1CON.TMR1ON = 0;
}


void PWM1_SetDuty(unsigned int duty) {
 if(duty > 1023) duty = 1023;
 CCPR1L = duty >> 2;
 CCP1CON = (CCP1CON & 0xCF) | ((duty & 0x03) << 4);
}

void PWM2_SetDuty(unsigned int duty) {
 if(duty > 1023) duty = 1023;
 CCPR2L = duty >> 2;
 CCP2CON = (CCP2CON & 0xCF) | ((duty & 0x03) << 4);
}

void motors_stop(void){
  RD2_bit  =  RD3_bit  =  RD0_bit  =  RD1_bit  = 0;
 PWM1_SetDuty(0);
 PWM2_SetDuty(0);
}

void motors_forward(unsigned int l, unsigned int r){
  RD2_bit  = 1;  RD3_bit  = 0;
  RD0_bit  = 1;  RD1_bit  = 0;
 PWM1_SetDuty(l);
 PWM2_SetDuty(r);
}

void motors_forward_tunnel(unsigned int l, unsigned int r, unsigned char in_tunnel){
 unsigned long ls, rs;
 if(in_tunnel){
 ls = (unsigned long)l *  88 ;
 rs = (unsigned long)r *  88 ;
 l = (unsigned int)(ls / 100);
 r = (unsigned int)(rs / 100);

 if(l == r && r >  25 ) r -=  25 ;
 }
 motors_forward(l, r);
}

void motors_hard_left(void){
  RD0_bit  = 0;  RD1_bit  = 1;
  RD2_bit  = 1;  RD3_bit  = 0;
 PWM1_SetDuty(TURN_SPEED);
 PWM2_SetDuty(TURN_SPEED);
}

void motors_hard_right(void){
  RD0_bit  = 1;  RD1_bit  = 0;
  RD2_bit  = 0;  RD3_bit  = 1;
 PWM1_SetDuty(TURN_SPEED);
 PWM2_SetDuty(TURN_SPEED);
}

void raise_servo(){
 unsigned int i;


 for(i = 0; i < 50; i++){
 PORTD |=  0x10 ;
 myusDelay(2200);
 PORTD &= ~ 0x10 ;
 myusDelay(18000);
 }
}


unsigned int adc_read_an5(void){
 ADCON0 &= 0b11000101;
 ADCON0 |= 0b00101000;
 myusDelay(30);
 GO_DONE_bit = 1;
 while(GO_DONE_bit);
 return (((unsigned int)ADRESH << 8) | ADRESL);
}

unsigned int ultrasonic_read_cm(void){
 unsigned int ticks;
 unsigned long timeout;

  RB0_bit  = 0; myusDelay(2);
  RB0_bit  = 1; myusDelay(10);
  RB0_bit  = 0;

 timeout = 60000;
 while(! RB1_bit  && timeout--);
 if(timeout == 0) return 0;

 TMR1H = 0; TMR1L = 0;
 T1CON = 0x00;
 T1CON.TMR1ON = 1;

 timeout = 60000;
 while( RB1_bit  && timeout--);

 T1CON.TMR1ON = 0;
 if(timeout == 0) return 0;

 ticks = ((unsigned int)TMR1H << 8) | TMR1L;
 return ticks / 116;
}

void init_hw(void){
 OPTION_REG = 0b00000111;
 TMR0 =  248 ;
 INTCON = 0b10100000;
 INTCON.T0IF = 0;

 ADCON1 = 0x80;

 TRISB0_bit = 0;
 TRISB1_bit = 1;
 TRISB2_bit = 1;
 TRISB3_bit = 1;
 TRISB4_bit = 1;
 TRISB5_bit = 1;
 TRISB7_bit = 1;

 TRISE0_bit = 1;

 TRISD = 0x00;
 TRISC = 0x00;


 PORTD &= ~ 0x10 ;

 PR2 = 99;
 T2CON = 0b00000101;
 CCP1CON = 0b00001100;
 CCP2CON = 0b00001100;

 ADCON0 = 0b10000001;

  RC0_bit  = 1;
  RC3_bit  = 0;
 motors_stop();
 mymsDelay(10);
}

void main(){

 unsigned char left_raw, right_raw;
 bit left_on, right_on;
 unsigned char both_count = 0;

 unsigned int ldr_val;
 unsigned char raw_tunnel, in_tunnel = 0;
 unsigned char dark_cnt = 0, light_cnt = 0;

 unsigned char prev_tunnel = 0, post_tunnel = 0, post_tunnel_just_entered = 0;
 unsigned int post_timer = 0;
 unsigned char wall_ir_active = 0;

 unsigned char ir_cooldown = 0;

 unsigned int d;

 unsigned char t_cnt = 0;

 init_hw();

 {
 unsigned int t0 = g_ms;
 while((unsigned int)(g_ms - t0) < 2333);
 }
  RC3_bit  = 1;

 while(1){

 if( RB4_bit  == ! 0  &&  RB5_bit  == ! 0  &&  RB7_bit  == ! 0 ){
 if(all_black_start == 0)
 all_black_start = g_ms;
 if((unsigned int)(g_ms - all_black_start) >= 3500){
 motors_forward(SPEED_FORWARD, SPEED_FORWARD);
 mymsDelay(300);
 motors_stop();
  RC3_bit  = 0;

 raise_servo();

  RC0_bit  = 1;

 while(1);
 }
 }
 if(ir_cooldown > 0) ir_cooldown--;


 ldr_val = adc_read_an5();
 raw_tunnel = (ldr_val <  550 );

 if(raw_tunnel){ dark_cnt++; light_cnt = 0; }
 else { light_cnt++; dark_cnt = 0; }

 if(dark_cnt >=  8 ) in_tunnel = 1;
 if(light_cnt >=  20 ) in_tunnel = 0;

  RC0_bit  = in_tunnel ? 0 : 1;


 if(prev_tunnel && !in_tunnel){
 post_tunnel = 1;
 post_tunnel_just_entered = 1;
 }
 prev_tunnel = in_tunnel;


 if(post_tunnel){

 if(post_tunnel_just_entered){
 post_timer = 0;
 wall_ir_active = 0;
 post_tunnel_just_entered = 0;
 }

 if(post_timer <  375 ) post_timer++;
 else wall_ir_active = 1;


 if(wall_ir_active && ir_cooldown == 0){

 if( RB2_bit  == 0 &&  RB3_bit  == 1){
 motors_hard_right(); mymsDelay( 55 );
 motors_stop(); mymsDelay( 20 );

 motors_forward(SPEED_OBS_FORWARD, SPEED_OBS_FORWARD);
 mymsDelay( 90 );

 ir_cooldown =  25 ;
 continue;
 }

 if( RB3_bit  == 0 &&  RB2_bit  == 1){
 motors_hard_left(); mymsDelay( 55 );
 motors_stop(); mymsDelay( 20 );

 motors_forward(SPEED_OBS_FORWARD, SPEED_OBS_FORWARD);
 mymsDelay( 90 );

 ir_cooldown =  25 ;
 continue;
 }
 }


 d = ultrasonic_read_cm();
 if(d != 0 && d <=  22 ){

 motors_stop();
 mymsDelay(25);
 motors_hard_right();
 mymsDelay( 300 );
 motors_stop();
 mymsDelay(20);

 motors_forward(SPEED_OBS_FORWARD, SPEED_OBS_FORWARD);
 mymsDelay( 100 );

 continue;
 }
 }


 left_raw =  RB4_bit ;
 right_raw =  RB5_bit ;

 left_on = (left_raw ==  0 );
 right_on = (right_raw ==  0 );


 if(left_on && right_on){

 if(t_cnt <  3 ) t_cnt++;

 if(t_cnt >=  3 )
 motors_forward_tunnel(SPEED_T_JUNC, SPEED_T_JUNC, in_tunnel);
 else
 motors_forward_tunnel(SPEED_FORWARD, SPEED_FORWARD, in_tunnel);

 both_count = 0;
 }
 else{
 t_cnt = 0;

 if(left_on && !right_on){
 motors_forward_tunnel(CURVE_SLOW_S, CURVE_FAST_S, in_tunnel);
 both_count = 0;
 }
 else if(!left_on && right_on){
 motors_forward_tunnel(CURVE_FAST_S, CURVE_SLOW_S, in_tunnel);
 both_count = 0;
 }
 else{
 both_count++;
 if(both_count < 5){
 motors_forward_tunnel(SPEED_FORWARD, SPEED_FORWARD, in_tunnel);
 }else{
 motors_stop(); mymsDelay(40);
 while(1){
 motors_hard_left();
 if(( RB4_bit  ==  0 ) || ( RB5_bit  ==  0 ))
 break;
 myusDelay(200);
 }
 both_count = 0;
 }
 }
 }

 mymsDelay(8);
 }
}
