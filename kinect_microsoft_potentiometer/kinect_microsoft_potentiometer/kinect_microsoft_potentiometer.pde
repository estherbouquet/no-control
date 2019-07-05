import KinectPV2.KJoint;
import KinectPV2.*;

import processing.serial.*;    // Importing the serial library to communicate with the Arduino
Serial myPort;      // Initializing a vairable named 'myPort' for serial communication


KinectPV2 kinect;

int skip = 2;
int headCircleRadius = 2000;

void setup() {
  size(1920, 1080, P3D);

  kinect = new KinectPV2(this);

  kinect.enableSkeletonColorMap(true);
  kinect.enableDepthImg(true);

  kinect.init();

  myPort  =  new Serial (this, "COM7", 9600); // Set the com port and the baud rate according to the Arduino IDE /dev/ttyACM1
  myPort.bufferUntil ( '\n' );   // Receiving the data from the Arduino IDE
}


void serialEvent  (Serial myPort) {
  
  
  skip  =  int(float (myPort.readStringUntil ( '\n' ) ));  // Changing the background color according to received data
}

void draw() {
  lights();
  background(0);
  //stocke des squelettes / 1 squelette/personne
  ArrayList<KSkeleton> skeletonArray =  kinect.getSkeletonColorMap();

  //individual JOINTS
  for (int i = 0; i < skeletonArray.size() && i <1; i++) { // i<1 -> un seul squelette à la fois
    KSkeleton skeleton = (KSkeleton) skeletonArray.get(0); //et on prend celui qui est en 0 du coup
    if (skeleton.isTracked()) { //si un squelette est repéré
      //KJoint[] joints = skeleton.getJoints();

      color col = color(255); //pour afficher en blanc
      stroke(col);
      noFill();
      strokeWeight(1);
      //pour afficher le squelette
      //drawBody(joints);
      // 3 tête
      // 2 cou
      // 20 ??
      // 4 épaule gauche
      // 8 épaule droite

      int [] depth = kinect.getRawDepthData(); 
      print("spotted");  

      //On commence à afficher les triangles ici :
      pushMatrix();
      translate(width/2, height/2, -1000);
      //strokeWeight(1);

      for (int x = 0; x<kinect.WIDTHDepth; x+=skip) { //sur toute la largeur et pour tous les skip pixels
        for (int y =0; y<kinect.HEIGHTDepth; y+=skip) { //sur toute la hauteur et pour tous les skip pixels

          //calculate the x, y, z camera position based on the depth info      
          PVector point = depthToPointCloudPos(x, y, depth[x + y * kinect.WIDTHDepth]);
          PVector pointRight = depthToPointCloudPos(x + skip, y, depth[min(x + skip, kinect.WIDTHDepth - 1) + y * kinect.WIDTHDepth]);
          PVector pointDown = depthToPointCloudPos(x, y + skip, depth[x + min(y + skip, kinect.HEIGHTDepth - 1) * kinect.WIDTHDepth]);
          PVector pointRightDown = depthToPointCloudPos(x + skip, y + skip, depth[min(x + skip, kinect.WIDTHDepth - 1) + min(y + skip, kinect.HEIGHTDepth - 1) * kinect.WIDTHDepth]);

          //Si le point est en dehors du cercle, on ne l'affiche pas :
          if (isOutOfHeadCircle(skeleton.getJoints()[3], point) || isOutOfHeadCircle(skeleton.getJoints()[3], pointRight) || isOutOfHeadCircle(skeleton.getJoints()[3], pointDown )||isOutOfHeadCircle(skeleton.getJoints()[3], pointRightDown)) {
            //            println("skipped");
            continue;
          } else {
            beginShape(TRIANGLES);
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
    }
  }
  //affichage texte
  //fill(255, 0, 0);
  text(frameRate, 50, 50);
  text(headCircleRadius, 50, 70);
  text(skip, 50, 90);
}

public boolean isOutOfHeadCircle(KJoint head, PVector point) {

  float center_x = (head.getPosition().x - CameraParams.cx) /CameraParams.fx;
  float center_y = (head.getPosition().y  - CameraParams.cy) / CameraParams.fy;

  return Math.pow(point.x - center_x, 2) + Math.pow(point.y - center_y, 2) > Math.pow(headCircleRadius, 2);
}

//DRAW BODY
void drawBody(KJoint[] joints) {


  drawBone(joints, KinectPV2.JointType_Head, KinectPV2.JointType_Neck);
  drawBone(joints, KinectPV2.JointType_Neck, KinectPV2.JointType_SpineShoulder);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_SpineMid);

  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_ShoulderRight);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_ShoulderLeft);


  // Right Arm
  drawBone(joints, KinectPV2.JointType_ShoulderRight, KinectPV2.JointType_ElbowRight);

  // Left Arm
  drawBone(joints, KinectPV2.JointType_ShoulderLeft, KinectPV2.JointType_ElbowLeft);

  drawJoint(joints, KinectPV2.JointType_Head);
}

//draw joint
void drawJoint(KJoint[] joints, int jointType) {
  pushMatrix();
  translate(joints[jointType].getX(), joints[jointType].getY(), joints[jointType].getZ());
  ellipse(0, 0, 25, 25);
  popMatrix();
}

//draw bone
void drawBone(KJoint[] joints, int jointType1, int jointType2) {
  pushMatrix();
  translate(joints[jointType1].getX(), joints[jointType1].getY(), joints[jointType1].getZ());
  ellipse(0, 0, 25, 25);
  popMatrix();
  line(joints[jointType1].getX(), joints[jointType1].getY(), joints[jointType1].getZ(), joints[jointType2].getX(), joints[jointType2].getY(), joints[jointType2].getZ());
}


//calculte the xyz camera position based on the depth data
PVector depthToPointCloudPos(int x, int y, float depthValue) {
  PVector point = new PVector();
  point.z = (depthValue);// / (1.0f); // Convert from mm to meters
  point.x = (x - CameraParams.cx) * point.z / CameraParams.fx;
  point.y = (y - CameraParams.cy) * point.z / CameraParams.fy;


  return point;
}

void keyPressed() {

  if (keyCode == UP) {
    skip++;
  } 
  if (keyCode == DOWN) {
    skip = max(1, skip -1);
  } //pour régler le rayon du cercle
  if (keyCode == LEFT) {
    headCircleRadius -= 100;
  }
  if (keyCode == RIGHT) {
    headCircleRadius += 100;
  }
}
