import processing.serial.*;    // Importing the serial library to communicate with the Arduino 
Serial myPort;      // Initializing a vairable named 'myPort' for serial communication
float background_color ;   // Variable for changing the background color

void setup ( ) {

  size (500, 500);     // Size of the serial window, you can increase or decrease as you want
  myPort  =  new Serial (this, "/dev/ttyACM0", 9600); // Set the com port and the baud rate according to the Arduino IDE
  myPort.bufferUntil ( '\n' );   // Receiving the data from the Arduino IDE
} 

void serialEvent  (Serial myPort) {
  background_color  =  float (myPort.readStringUntil ( '\n' ) ) ;  // Changing the background color according to received data
} 

void draw ( ) {
  //background ( 150, 50, background_color );   // Initial background color, when we will open the serial window
  //fill(150,50,background_color/4);
  //noStroke();
  ellipse(width/2, height/2, background_color, background_color);
}
