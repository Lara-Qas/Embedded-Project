#define LEFT_SENSOR   RB4_bit
#define RIGHT_SENSOR  RB5_bit
#define WALL_LEFT_IR  RB2_bit
#define WALL_RIGHT_IR RB3_bit
#define US_TRIG       RB0_bit
#define US_ECHO       RB1_bit
#define BUZZER        RC0_bit
#define ACTIVE_LED    RC3_bit
#define L_IN1 RD2_bit
#define L_IN2 RD3_bit
#define R_IN1 RD0_bit
#define R_IN2 RD1_bit
#define SENSOR_ON_LINE 0   // 0=blackkk

// ULTRASONIC
#define WALL_DIST_CM      22
#define TURN_RIGHT_MS     300
#define US_CHECK_MS       30
#define AFTER_TURN_FWD_MS 100

//WALL IR obstacle avoidence
#define WALL_ROTATE_MS 55
#define WALL_CHECK_MS  20
#define WALL_IR_DELAY_COUNT 375   // 3sec delay
 unsigned int all_black_start = 0;

#define IR_PUSH_MS        90    //for IR does not get stuckkk
#define IR_COOLDOWN_COUNT 25

const unsigned int SPEED_FORWARD = 335;
const unsigned int TURN_SPEED    = 195;
const unsigned int CURVE_FAST    = 295;
const unsigned int CURVE_SLOW    = 175;
const unsigned int SPEED_T_JUNC  = 215;
const unsigned int CURVE_FAST_S  = 245;
const unsigned int CURVE_SLOW_S  = 155;

#define T_CONFIRM 3   // 24ms ensureee t intersection at right time
const unsigned int SPEED_OBS_FORWARD = 360;

#define LDR_THRESHOLD 550
#define TUNNEL_SCALE_PERCENT  88
#define TUNNEL_TRIM_RIGHT     25   // trim just to make it more straight inside tunnel
#define MID_SENSOR RB7_bit

#define SERVO_MASK 0x10   // RD4 servo flagg

#define DARK_CONFIRM_COUNT   8
#define LIGHT_CONFIRM_COUNT  20

volatile unsigned int g_ms = 0;
#define TMR0_PRELOAD 248

void interrupt(void){
   if(INTCON.T0IF){
      TMR0 = TMR0_PRELOAD;
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
   L_IN1 = L_IN2 = R_IN1 = R_IN2 = 0;
   PWM1_SetDuty(0);
   PWM2_SetDuty(0);
}

void motors_forward(unsigned int l, unsigned int r){
   L_IN1 = 1; L_IN2 = 0;
   R_IN1 = 1; R_IN2 = 0;
   PWM1_SetDuty(l);
   PWM2_SetDuty(r);
}

void motors_forward_tunnel(unsigned int l, unsigned int r, unsigned char in_tunnel){
   unsigned long ls, rs;
   if(in_tunnel){
      ls = (unsigned long)l * TUNNEL_SCALE_PERCENT;
      rs = (unsigned long)r * TUNNEL_SCALE_PERCENT;
      l  = (unsigned int)(ls / 100);
      r  = (unsigned int)(rs / 100);

      if(l == r && r > TUNNEL_TRIM_RIGHT) r -= TUNNEL_TRIM_RIGHT;
   }
   motors_forward(l, r);
}

void motors_hard_left(void){
   R_IN1 = 0; R_IN2 = 1;
   L_IN1 = 1; L_IN2 = 0;
   PWM1_SetDuty(TURN_SPEED);
   PWM2_SetDuty(TURN_SPEED);
}

void motors_hard_right(void){
   R_IN1 = 1; R_IN2 = 0;
   L_IN1 = 0; L_IN2 = 1;
   PWM1_SetDuty(TURN_SPEED);
   PWM2_SetDuty(TURN_SPEED);
}

void raise_servo(){
    unsigned int i;


    for(i = 0; i < 50; i++){
        PORTD |= SERVO_MASK;
        myusDelay(2200);
        PORTD &= ~SERVO_MASK;
        myusDelay(18000);
    }
}

// analoug to digital convertor
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

   US_TRIG = 0; myusDelay(2);
   US_TRIG = 1; myusDelay(10);
   US_TRIG = 0;

   timeout = 60000;
   while(!US_ECHO && timeout--);
   if(timeout == 0) return 0;

   TMR1H = 0; TMR1L = 0;
   T1CON = 0x00;
   T1CON.TMR1ON = 1;

   timeout = 60000;
   while(US_ECHO && timeout--);

   T1CON.TMR1ON = 0;
   if(timeout == 0) return 0;

   ticks = ((unsigned int)TMR1H << 8) | TMR1L;
   return ticks / 116;
}

void init_hw(void){
   OPTION_REG = 0b00000111;
   TMR0 = TMR0_PRELOAD;
   INTCON = 0b10100000;
   INTCON.T0IF = 0;

   ADCON1 = 0x80;

   TRISB0_bit = 0; // trig
   TRISB1_bit = 1; // echo
   TRISB2_bit = 1; // left IR
   TRISB3_bit = 1; // right IR
   TRISB4_bit = 1; // left sensor
   TRISB5_bit = 1; // right sensor
   TRISB7_bit = 1; // MIDLLE SENSOR

   TRISE0_bit = 1;

   TRISD = 0x00;
   TRISC = 0x00;


   PORTD &= ~SERVO_MASK;  //servo starts at zero position

   PR2  = 99;
   T2CON = 0b00000101;
   CCP1CON = 0b00001100;
   CCP2CON = 0b00001100;

   ADCON0 = 0b10000001;

   BUZZER = 1;
   ACTIVE_LED = 0; // LED starts off then on
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
   ACTIVE_LED = 1;

   while(1){
      // when the 3 sensors read blackk it will stop and park
      if(LEFT_SENSOR == !SENSOR_ON_LINE && RIGHT_SENSOR == !SENSOR_ON_LINE && MID_SENSOR == !SENSOR_ON_LINE){
      if(all_black_start == 0)
        all_black_start = g_ms;
         if((unsigned int)(g_ms - all_black_start) >= 3500){
          motors_forward(SPEED_FORWARD, SPEED_FORWARD);
          mymsDelay(300);
          motors_stop();
          ACTIVE_LED = 0;

          raise_servo();

          BUZZER = 1;

          while(1);
      }
      }
      if(ir_cooldown > 0) ir_cooldown--;


      ldr_val = adc_read_an5();
                raw_tunnel = (ldr_val < LDR_THRESHOLD);

      if(raw_tunnel){ dark_cnt++; light_cnt = 0; }
      else         { light_cnt++; dark_cnt = 0; }

      if(dark_cnt >= DARK_CONFIRM_COUNT)  in_tunnel = 1;
      if(light_cnt >= LIGHT_CONFIRM_COUNT) in_tunnel = 0;

      BUZZER = in_tunnel ? 0 : 1;

      // detect tunnel exit
      if(prev_tunnel && !in_tunnel){
         post_tunnel = 1;
         post_tunnel_just_entered = 1;
      }
      prev_tunnel = in_tunnel;

      // the state after the tunnel
      if(post_tunnel){

         if(post_tunnel_just_entered){
            post_timer = 0;
            wall_ir_active = 0;
            post_tunnel_just_entered = 0;
         }

         if(post_timer < WALL_IR_DELAY_COUNT) post_timer++;
         else wall_ir_active = 1;

         // obstacle avoidence IRs
         if(wall_ir_active && ir_cooldown == 0){

            if(WALL_LEFT_IR == 0 && WALL_RIGHT_IR == 1){
               motors_hard_right(); mymsDelay(WALL_ROTATE_MS);
               motors_stop();       mymsDelay(WALL_CHECK_MS);

               motors_forward(SPEED_OBS_FORWARD, SPEED_OBS_FORWARD);
               mymsDelay(IR_PUSH_MS);

               ir_cooldown = IR_COOLDOWN_COUNT;
               continue;
            }

            if(WALL_RIGHT_IR == 0 && WALL_LEFT_IR == 1){
               motors_hard_left();  mymsDelay(WALL_ROTATE_MS);
               motors_stop();       mymsDelay(WALL_CHECK_MS);

               motors_forward(SPEED_OBS_FORWARD, SPEED_OBS_FORWARD);
               mymsDelay(IR_PUSH_MS);

               ir_cooldown = IR_COOLDOWN_COUNT;
               continue;
            }
         }

         // obstacle avoidence ultrasonic
         d = ultrasonic_read_cm();
         if(d != 0 && d <= WALL_DIST_CM){

            motors_stop();       
            mymsDelay(25);
            motors_hard_right(); 
            mymsDelay(TURN_RIGHT_MS);
            motors_stop();      
            mymsDelay(20);

            motors_forward(SPEED_OBS_FORWARD, SPEED_OBS_FORWARD);
            mymsDelay(AFTER_TURN_FWD_MS);

            continue;
         }
      }

      // line following
      left_raw  = LEFT_SENSOR;
      right_raw = RIGHT_SENSOR;

      left_on  = (left_raw  == SENSOR_ON_LINE);
      right_on = (right_raw == SENSOR_ON_LINE);

      //T intersection
      if(left_on && right_on){

         if(t_cnt < T_CONFIRM) t_cnt++;

         if(t_cnt >= T_CONFIRM)
            motors_forward_tunnel(SPEED_T_JUNC, SPEED_T_JUNC, in_tunnel);
         else
            motors_forward_tunnel(SPEED_FORWARD, SPEED_FORWARD, in_tunnel);

         both_count = 0;
      }
      else{
         t_cnt = 0; // reset when not both black

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
                  if((LEFT_SENSOR == SENSOR_ON_LINE) || (RIGHT_SENSOR == SENSOR_ON_LINE))
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