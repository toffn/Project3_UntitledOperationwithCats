// Importing the serial library to communicate with the Arduino 
import processing.serial.*;  
  
import processing.sound.*;
SoundFile file;

// Initializing a vairable named 'myPort' for serial communication
Serial myPort;      
String [] data;

int switchValue = 0;
int potValue = 0;
int ldrValue=0;
int backgroundColor = 255;

int score=0;
float timeLeft;

// Variables for dragging
float bx=390;
float by=100;
float cx1=400;
float cx2=50;
float cy1=300;
float cy2=350;
float fx1=150;
float fx2=200;
float fy1=400;
float fy2=350;

boolean showHeart1 = true;
boolean showHeart2 = true;
boolean showHeart3 = true;

boolean showCan1=true;
boolean showCan2=true;
boolean showFood1=true;
boolean showFood2=true;
boolean showBat=true;

float bxOffset = 0.0; 
float byOffset = 0.0;
float cx1Offset = 0.0; 
float cy1Offset = 0.0; 
float cx2Offset = 0.0; 
float cy2Offset = 0.0;
float fx1Offset = 0.0; 
float fy1Offset = 0.0;
float fx2Offset = 0.0; 
float fy2Offset = 0.0;

boolean locked = false;

boolean overBat = false;
boolean overCan1 = false;
boolean overCan2 = false;
boolean overFood1 = false;
boolean overFood2 = false;

// mapping pot values
float minPotValue = 0;
float maxPotValue = 4095;

// Initialize timer
Timer displayTimer;
float slideTime=0;
float minslideTime= 10000;
float maxslideTime= 100000;
float defaultslideTime=25000;

// Change to appropriate index in the serial list
int serialIndex = 7;

//Initialize images
PImage [] imageListDraggable;
PImage [] imageListFixed;

void setup  () {
  size (900,  600);    

  // List all the available serial ports
  printArray(Serial.list());
    
  // Set the com port and the baud rate according to the Arduino IDE
  myPort  =  new Serial (this, "/dev/cu.SLAB_USBtoUART",  115200);
  
  // Creating timers
  displayTimer = new Timer(100000);
  
  // Start the timer
  displayTimer.start();
  
  file = new SoundFile(this, "music.mp3");
  file.play();
  
  timeLeft=displayTimer.getRemainingTime();
  
  //Setting up image lists and loading images
  imageListDraggable = new PImage[5];
  imageListFixed = new PImage[16];
  
  imageListDraggable[0] = loadImage("food.png");
  imageListDraggable[1] = loadImage("food0.png");
  imageListDraggable[2] = loadImage("soda.png");
  imageListDraggable[3] = loadImage("soda0.png");
  imageListDraggable[4] = loadImage("batteries.png");
  
  imageListFixed[0] = loadImage("soil.jpg");
  imageListFixed[1] = loadImage("healthheart.png");
  imageListFixed[2] = loadImage("healthheart0.png");
  imageListFixed[3] = loadImage("healthheart1.png");
  imageListFixed[4] = loadImage("cat.png"); //Yellow
  imageListFixed[5] = loadImage("cat0.png"); //Black
  imageListFixed[6] = loadImage("cat1.png"); //Gray
  imageListFixed[7] = loadImage("biohazard.png");
  imageListFixed[8] = loadImage("trash.png");
  imageListFixed[9] = loadImage("recycle.png");
  imageListFixed[10] = loadImage("veg.png");
  imageListFixed[11] = loadImage("veg0.png");
  imageListFixed[12] = loadImage("veg1.png");
  imageListFixed[13] = loadImage("veg2.png");
  imageListFixed[14] = loadImage("veg3.png");
  imageListFixed[15] = loadImage("veg4.png");
  
  textAlign(CENTER);
  fill(255);
  textSize(20);
  
}

// We call this to get the data 
void checkSerial() {
  while (myPort.available() > 0) {
    String inBuffer = myPort.readString();  
    
    print(inBuffer);
    
    // This removes the end-of-line from the string 
    inBuffer = (trim(inBuffer));
    
    // This function will make an array of TWO items, 1st item = switch value, 2nd item = potValue
    data = split(inBuffer, ',');
   
   // ERROR-CHECK HERE
   if( data.length >= 2 ) {
      switchValue = int(data[0]);           // first index = switch value 
      potValue = int(data[1]);               // second index = pot value
      ldrValue = int(data[2]);               // third index = LDR value
      
    // Change the timer
    slideTime= map(potValue, maxPotValue, minPotValue, minslideTime, maxslideTime);
    displayTimer.setTimer(int(slideTime));
   }
  }
}

void draw(){
  checkSerial();
  background(255);
  stateGame();
  checkTimer();  
}

void stateGame()
{ 
  image(imageListFixed[0], 35, 70);
  // Place fixed images
  // Health
  if (showHeart1)
  image(imageListFixed[1], 40, 520);
  if (showHeart2)
  image(imageListFixed[2], 110, 520);
  if (showHeart3)
  image(imageListFixed[3], 180, 520);
  
  // Bins
  image(imageListFixed[7], 725, 25);
  image(imageListFixed[8], 725, 205);
  image(imageListFixed[9], 725, 410);
  
  //Bg
  
  image(imageListFixed[10], 35, 70);
  image(imageListFixed[11], 100, 270);
  image(imageListFixed[12], 500, 180);
  image(imageListFixed[13], 350, 400);
  image(imageListFixed[13], 400, 90);
  
  //Cat
  image(imageListFixed[4], 100, 90); //Yellow
  image(imageListFixed[5], 200, 190); //Black
  image(imageListFixed[6], 380, 330); //Grey
  
  //Items
  if (showBat)
  image(imageListDraggable[4], bx, by);
  if (showCan1)
  image(imageListDraggable[2], cx1, cy1);
  if(showCan2)
  image(imageListDraggable[3], cx2, cy2);
  if (showFood1)
  image(imageListDraggable[0], fx1, fy1);
  if (showFood2)
  image(imageListDraggable[1], fx2, fy2);
  
  fill(0);
  text(displayTimer.getRemainingTime(),350,550);
  
}

void mousePressed()
{
  if (mouseX >= bx && mouseX <= bx+70 && mouseY >= by && mouseY <= by+62)
  { 
    locked = true; 
    bxOffset = mouseX-bx; 
    byOffset = mouseY-by; 
  }
  
  else if (mouseX >= fx1 && mouseX <= fx1+110 && mouseY >= fy1 && mouseY <= fy1+110)
  { 
    locked = true; 
    fx1Offset = mouseX-fx1; 
    fy1Offset = mouseY-fy1; 
  }

  else if (mouseX >= fx2 && mouseX <= fx2+110 && mouseY >= fy2 && mouseY <= fy2+110)
  { 
    locked = true; 
    fx2Offset = mouseX-fx2; 
    fy2Offset = mouseY-fy2; 
  }

  else if (mouseX >= cx2 && mouseX <= cx2+40 && mouseY >= cy2 && mouseY <= cy2+92)
  { 
    locked = true;
    cx2Offset = mouseX-cx2; 
    cy2Offset = mouseY-cy2; 
  }

  else if (mouseX >= cx1 && mouseX <= cx1+40 && mouseY >= cy1 && mouseY <= cy1+92)
  { 
    locked = true; 
    cx1Offset = mouseX-cx1; 
    cy1Offset = mouseY-cy1; 
  }
  else
  {
    locked = false;
  }
}

void checkScore()
{
  if (bx>=725 && by>=25)
  {
    showBat=false;
  }
  if (cx1>=725&& cy1>=410)
  {
    showCan1=false;
  }
  if (cx2>=725 && cy2>=410)
  {
    showCan2=false;
  }
  if (fx2>=725 && fy2>=205)
  {
    showFood2=false;
  }
  if (fx1>=725 && fy1>=205)
  {
    showFood1=false;
  }
  
  //Trying to increment score once
  for (int i=0;i<1;i++)
  {
    if (showBat==false)
       score++;
       noLoop();
    if (showFood1==false)
       score++;
       noLoop();
    if (showFood2==false)
       score++;
       noLoop();
    if (showCan1==false)
       score++;
       noLoop();
    if (showCan2==false)
       score++;
       noLoop();
  }
}

void mouseDragged()
{ 
  //Code for changing coordinates of images as they're dragged
  if (mouseX >= bx && mouseX <= bx+70 && mouseY >= by && mouseY <= by+62 && locked)
  {
    bx = mouseX-bxOffset;
    by = mouseY-byOffset;
  }
  
   if (mouseX >= cx1 && mouseX <= cx1+40 && mouseY >= cy1 && mouseY <= cy1+92 && locked)
  {
    cx1 = mouseX-cx1Offset;
    cy1 = mouseY-cy1Offset;
  }
  
  else if (mouseX >= cx2 && mouseX <= cx2+40 && mouseY >= cy2 && mouseY <= cy2+92 && locked)
  {
    cx2 = mouseX-cx2Offset;
    cy2 = mouseY-cy2Offset;
  }
  
  else if (mouseX >= fx2 && mouseX <= fx2+110 && mouseY >= fy2 && mouseY <= fy2+110 && locked)
  {
    fx2 = mouseX-fx2Offset;
    fy2 = mouseY-fy2Offset;
  }
  
  else if (mouseX >= fx1 && mouseX <= fx1+110 && mouseY >= fy1 && mouseY <= fy1+110 && locked)
  {
    fx1 = mouseX-fx1Offset;
    fy1 = mouseY-fy1Offset;
  }
  
  //Make hearts disappear in order when contact is made with a certain image
  if (mouseX >= 100 && mouseX <= 100+140 && mouseY >= 90 && mouseY <= 90+153)
  {
    if (showHeart3)
      showHeart3=false;
    else if (showHeart3==false && showHeart2)
      showHeart2=false;
    else if (showHeart2==false)
      showHeart1=false;
  }
  
  if (mouseX >= 200 && mouseX <= 200+200 && mouseY >= 190 && mouseY <= 190+116)
  {
    if (showHeart3)
      showHeart3=false;
    else if (showHeart3==false && showHeart2)
      showHeart2=false;
    else if (showHeart2==false)
      showHeart1=false;
  }
  
  if (mouseX >= 380 && mouseX <= 380+200 && mouseY >= 330 && mouseY <= 330+139)
  {
    if (showHeart3)
      showHeart3=false;
    else if (showHeart3==false && showHeart2)
      showHeart2=false;
    else if (showHeart2==false)
      showHeart1=false;
  }
  
}

void checkTimer() {
  
 // Check to see if timer is expired, do something and then restart
  if (displayTimer.expired()){
    checkScore();
    text("Correct moves: "+score,550,550);
    if (showHeart1==false)
      text("You ran out of health points!", 150, 550);
    else if (showHeart3)
      text("You survived somehow!", 150, 550);
      if (score==0)
      {
        textSize(10);
        text("Although you didn't score any points...", 150, 575);
      }
     }
     
  checkSerial();
  
  if (switchValue == 1)
  {
    score=0;
    showHeart1=true;
    showHeart2=true;
    showHeart3=true;
    displayTimer.setTimer(int(slideTime));
    draw();
    displayTimer.start();
  }
}
