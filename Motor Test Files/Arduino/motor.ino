#include <AccelStepper.h>

#define FULLSTEP 5
#define HALFSTEP 8

//declare variables for the motor pins
// The sequence 1-3-2-4 required for proper sequencing of 28BYJ48
AccelStepper stepper1(FULLSTEP, 2,3,4,5);
AccelStepper stepper2(FULLSTEP, 6,7,8,9);

int lsteps = 0;
int rsteps = 0;
int lspeed = 200;
int rspeed = 200;
bool newData = false;
void setup()
{    
  // initialize serial:
  Serial.begin(9600);
  stepper1.setMaxSpeed(900.0);
  stepper1.setAcceleration(400.0);
  stepper1.setSpeed(200);
  
  stepper2.setMaxSpeed(900.0);
  stepper2.setAcceleration(400.0);
  stepper2.setSpeed(200);
}

void loop()
{
  //Change direction at the limits
  if (stepper1.distanceToGo() == 0) {
    if(newData == true) {        
        stepper1.setCurrentPosition(0);
        stepper1.setSpeed(lspeed);
        stepper1.moveTo(lsteps);
        Serial.println(lspeed);
    }
  }
  stepper1.run();
  if (stepper2.distanceToGo() == 0) {
      if(newData == true) {        
        stepper2.setCurrentPosition(0);
        stepper2.setSpeed(rspeed);
        stepper2.moveTo(rsteps);
        newData = false;
    }
  }
  stepper2.run();

}

void serialEvent() {
  // An int is 2 bytes. We send 8 bytes everytime representing
  // (lpos,lspeed, rpos,rspeed).
  // However, we need to ensure the beginning and ending of transmission.
  // so at the beginning we use a as start and b as end.
  // For each transmission. We assume speed is either 0 or 200. 
  // So we receive either 0 or 2. 
  // For position, we use all character. There are 4chars for each motor.
  if (Serial.available()>12) {
    // get the new byte:
    if((char)Serial.read() == 'a') {
      lsteps = Serial.parseInt();
      lspeed = Serial.parseInt();
      rsteps = Serial.parseInt();
      rspeed = Serial.parseInt();
      newData = true;
    } else {
      Serial.flush(); //data is invalid.
    } 
  }
}

