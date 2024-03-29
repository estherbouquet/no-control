import hivis.common.*;
import hivis.data.*;
import hivis.data.reader.*;
import hivis.data.view.*;
import hivis.example.*;

import processing.dxf.*;
boolean record = false;

//on importe la bibliothèque dont on a besoin -> openkinect
import org.openkinect.freenect.*;
import org.openkinect.freenect2.*;
import org.openkinect.processing.*;

import processing.serial.*;    // Importing the serial library to communicate with the Arduino
Serial myPort;      // Initializing a vairable named 'myPort' for serial communication

//on crée un nouvel objet kinect2 de type Kinect2
Kinect2 kinect2;
int kinectIndex = 0;
int openClIndex = 1;

//variable skip -> permet de "sauter" des pixels et afficher une résolution plus basse
int skip = 8;


int depthMean = 4000;
int depthStandardDeviation = 4000;
int depthStdDevDivisor = 1;

int frameIndex = 0;
int meanCalculationRate = 30; // depeth mean and std dev are calculate each x image
PImage img;

PImage mask;

void setup() {

  //size(740, 1336, P3D);
  fullScreen(P3D);
  //size(100, 300, P3D<
  kinect2 = new Kinect2(this); //on initialise dans kinect2 un nouvel objet Kinect2
  kinect2.initDepth(); //initialise la profondeur
  //kinect2.initDevice(0, 0); //initialise la kinect
  kinect2.initDevice(kinectIndex, openClIndex);
  img = createImage(kinect2.depthWidth, kinect2.depthHeight, RGB);
  mask = loadImage("mask-2.png");

  myPort  =  new Serial (this, "/dev/ttyACM1", 9600); // Set the com port and the baud rate according to the Arduino IDE
  myPort.bufferUntil ( '\n' );   // Receiving the data from the Arduino IDE
}

void serialEvent  (Serial myPort) {
  skip  =  int(float (myPort.readStringUntil ( '\n' ) ));  // Changing the background color according to received data
} 

void draw() {
  imageMode(CORNERS);
  lights();
  background(0);

  translate(width/2, height/2, 0);
  translate(-width/2, -height/2, 0);

  img.loadPixels();  

  if (record == true) {
    beginRaw(DXF, "output.dxf"); // Start recording to the file
  }

  pushMatrix();

  translate(width/2, height/2, -1100);


  //get the raw depth as array of integers
  int[] depth = kinect2.getRawDepth();

  if (frameIndex%meanCalculationRate == 0) {
    frameIndex = 0;
    computeDepthTreshold(depth);
  }

  strokeWeight(1);


  for (int x = 0; x<kinect2.depthWidth; x+=skip) { //sur toute la largeur et pour tous les skip pixels
    for (int y =0; y<kinect2.depthHeight; y+=skip) { //sur toute la hauteur et pour tous les skip pixels

      //calculate the x, y, z camera position based on the depth info      
      PVector point = depthToPointCloudPos(x, y, depth[x + y * kinect2.depthWidth]);
      PVector pointRight = depthToPointCloudPos(x + skip, y, depth[min(x + skip, kinect2.depthWidth - 1) + y * kinect2.depthWidth]);
      PVector pointDown = depthToPointCloudPos(x, y + skip, depth[x + min(y + skip, kinect2.depthHeight - 1) * kinect2.depthWidth]);
      PVector pointRightDown = depthToPointCloudPos(x + skip, y + skip, depth[min(x + skip, kinect2.depthWidth - 1) + min(y + skip, kinect2.depthHeight - 1) * kinect2.depthWidth]);

      beginShape(TRIANGLES);
      if (!(pointRight.z > depthMean - depthStandardDeviation && pointRight.z< depthMean + depthStandardDeviation)) {
        continue;
      } else if (!(pointDown.z > depthMean - depthStandardDeviation && pointDown.z< depthMean + depthStandardDeviation)) {
        continue;
      } else if (!(pointRightDown.z > depthMean - depthStandardDeviation && pointRightDown.z< depthMean + depthStandardDeviation)) {
        continue;
      } else if (!(point.z > depthMean - depthStandardDeviation && point.z< depthMean + depthStandardDeviation)) {
        continue;
      } else {
        if (point.z > 0.1 && pointRight.z > 0.1 && pointDown.z > 0.1) {
          vertex(point.x, point.y, point.z);
          vertex(pointRight.x, pointRight.y, pointRight.z);
          vertex(pointDown.x, pointDown.y, pointDown.z);
        }
        if (pointRight.z > 0.1 && pointRightDown.z > 0.1 && pointDown.z > 0.1) {
          vertex(pointRight.x, pointRight.y, pointRight.z);
          vertex(pointRightDown.x, pointRightDown.y, pointRightDown.z);
          vertex(pointDown.x, pointDown.y, pointDown.z);
        }
        endShape();
      }
    }
  }


  popMatrix();

  text(frameRate, 50, 50);
  text(skip, 50, 70);
  text(depthMean, 50, 90);
  text(depthStandardDeviation, 50, 110);
  text(depthStdDevDivisor, 50, 130);

  if (record == true) {
    endRaw();
    record = false; // Stop recording to the file
  }

  frameIndex++;



  //image(img,0,0);
  pushMatrix();

  translate(0, 0, 00);

  image(mask, 0, 0, 1366, 768);

  popMatrix();

  text(frameRate, 50, 50);
  text(skip, 50, 70);
  text(depthMean, 50, 90);
  text(depthStandardDeviation, 50, 110);
  text(depthStdDevDivisor, 50, 130);
}

//calculte the xyz camera position based on the depth data
PVector depthToPointCloudPos(int x, int y, float depthValue) {
  PVector point = new PVector();
  point.z = (depthValue);// / (1.0f); // Convert from mm to meters
  point.x = (x - CameraParams.cx) * point.z / CameraParams.fx;
  point.y = (y - CameraParams.cy) * point.z / CameraParams.fy;
  return point;
}

void computeDepthTreshold (int[] depth) {

  DataSeries<Integer> dataSeries =  HV.newIntegerSeries(depth);

  DataValue<Double> intNumbersMean =  dataSeries.mean(); // Returns a DataValue<Double> because the mean may be fractional.
  DataValue<Double> intNumbersStdDev = dataSeries.stdDev();
  ; // Returns a DataValue<Double> because the variance may be fractional.

  depthMean = intNumbersMean.asInt().get();
  depthStandardDeviation =  intNumbersStdDev.asInt().get()/depthStdDevDivisor;
}



void changeSkipValue(int change) {

  if (change <0) {
    skip = max(2, skip+change);
    print("skip value : "+skip);
  } else {
    skip = skip +change;
  }
}

void keyPressed() {
  if (key == 'R' || key == 'r') { // Press R to save the file
    record = true;
  }

  if (keyCode == UP) {
    changeSkipValue(1);
  } 
  if (keyCode == DOWN) {
    changeSkipValue(-1);
  }
  if (keyCode == LEFT) {
    depthStdDevDivisor = max(0, depthStdDevDivisor-1);
  }
  if (keyCode == RIGHT) {
    depthStdDevDivisor++;
  }
}
