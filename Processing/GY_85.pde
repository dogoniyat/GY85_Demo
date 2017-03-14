import processing.serial.*;

Serial myPort;
String S;
int Cur = 0;

float Pitch,Roll;
final float alpha = 0.8;

PImage imgCompass,imgRoll, imgPitch;

class GY85Data {
  PVector Accel,Compass,Gyro;
  float Temp;
  float Yaw, Pitch,Roll,Heading;
  
  GY85Data(String Line) {
    float [] dat = float(split(Line,','));
    float fXg,fYg,fZg;
    
    if(dat.length == 10) {
      Accel   = new PVector(dat[0],dat[1],dat[2]);
      if(Accel.z == 4096) Accel.z = 0;
      Accel.x = Accel.x * height / 2048;
      Accel.y = Accel.y * height / 2048;
      Accel.z = Accel.z * height / 2048;
      // filtering with alpha ratio to avoid atan2(0)
      if(OldPoint!=null) {
        fXg = Accel.x * alpha + (OldPoint.Accel.x * (1.0 - alpha));
        fYg = Accel.y * alpha + (OldPoint.Accel.y * (1.0 - alpha));
        fZg = Accel.z * alpha + (OldPoint.Accel.z * (1.0 - alpha));
      } else fXg = fYg = fZg = 0;
      
      //Roll  = (atan2(-fYg, fZg) + PI) % TWO_PI;
      //Pitch = (atan2(fXg, sqrt((fYg * fYg) + (fZg * fZg)))) % TWO_PI;
      
      Pitch  = - atan2(fXg,sqrt(fYg*fYg +fZg*fZg)) % TWO_PI;
      Roll = atan2(fYg,sqrt(fXg*fXg +fZg*fZg)) % TWO_PI; 
      Yaw   = atan2(sqrt(fXg*fXg +fYg*fYg),fZg) % TWO_PI;
      
      Compass = new PVector(dat[3],dat[4],dat[5]);
      Heading = atan2(Compass.y, Compass.x);
    if(Heading < 0) Heading += 2*PI;
    if(Heading > 2*PI) Heading -= 2*PI;
    
      Gyro    = new PVector(dat[6],dat[7],dat[8]);
      Gyro.x = Gyro.x * height / 512;
      Gyro.y = Gyro.y * height / 512;
      Gyro.z = Gyro.z * height / 512;
      
      Temp = dat[9];
    } else {
      Accel = OldPoint.Accel;
      Compass = OldPoint.Compass;
      Gyro = OldPoint.Gyro;
    }
  }
};

GY85Data OldPoint,NewPoint;

void setup() {
  imgCompass = loadImage("Compass_GY85.png");
  imgRoll    = loadImage("Roll_GY85.png"   );
  imgPitch   = loadImage("Pitch_GY85.png"  );
  Pitch = 0;
  Roll = 0;
  
  println(Serial.list()[1]);
  size(1280,720,P3D);
  background(64);
    myPort = new Serial(this,Serial.list()[1],115200);
    OldPoint = new GY85Data("0,0,0,0,0,0,0,0,0,0");
}

void draw() {
  if(myPort.available() > 0) {
    S = myPort.readStringUntil('\n');
    if(S!= null && S.length() > 0) {
      println(S);
      stroke(64); strokeWeight(2);
      line(Cur,0,Cur,height);
      NewPoint = new GY85Data(S);
  clear();

      pushMatrix();
      translate(imgCompass.width/2,imgCompass.height/2);
      rotate(NewPoint.Heading);
      image(imgCompass,-imgCompass.width/2,-imgCompass.height/2);
      popMatrix();
      
      pushMatrix();
      translate(300 + imgRoll.width/2,imgRoll.height/2);
      rotate(NewPoint.Roll);
      image(imgRoll,-imgRoll.width/2,-imgRoll.height/2);
      popMatrix();

      pushMatrix();
      translate(600 + imgPitch.width/2,imgPitch.height/2);
      rotate(NewPoint.Pitch);
      image(imgPitch,-imgPitch.width/2,-imgPitch.height/2);
      popMatrix();
      
// plane in 3D
pushMatrix();
translate(200,400, 0);
  rotateX(NewPoint.Pitch);
  rotateZ(-NewPoint.Roll);

  fill(128);
  stroke(96);
  sphere(60);
  
  beginShape(TRIANGLE_STRIP);
  vertex(   0, 0,-200);
  vertex(-100, 00, 100);
  vertex( 100, 00, 100);
  endShape();
popMatrix();

/*
      strokeWeight(1);

      
      stroke(255,128,128); line(Cur-1,height/2 - OldPoint.Accel.x,Cur,height/2 - NewPoint.Accel.x);
      stroke(128,128,255); line(Cur-1,height/2 - OldPoint.Accel.y,Cur,height/2 - NewPoint.Accel.y);
      stroke(128,255,128); line(Cur-1,height/2 - OldPoint.Accel.z,Cur,height/2 - NewPoint.Accel.z);

      stroke(255,255,0); line(Cur-1,height/2 + (OldPoint.Compass.x * height/2048),Cur,height/2 + (NewPoint.Compass.x*height/2048));
      stroke(0,255,255); line(Cur-1,height/2 - OldPoint.Compass.y,Cur,height/2 - NewPoint.Compass.y);
      stroke(255,0,255); line(Cur-1,height/2 - OldPoint.Compass.z,Cur,height/2 - NewPoint.Compass.z);

      stroke(255,255,255); line(Cur-1,height/2 - OldPoint.Gyro.x,Cur,height/2 - NewPoint.Gyro.x);
      stroke(96,96,96); line(Cur-1,height/2 - OldPoint.Gyro.y,Cur,height/2 - NewPoint.Gyro.y);
      stroke(160,160,160); line(Cur-1,height/2 - OldPoint.Gyro.z,Cur,height/2 - NewPoint.Gyro.z);
*/      
      
      OldPoint = NewPoint;
      if(++Cur > width) Cur = 0;
    }
  }
}