int pot_pin = A0;   // Initializing the Potentiometer pin
int pot_output; // Declaring a variable for potentiometer output

void setup() {
  Serial.begin(9600);       // Starting the serial communication at 9600 baud rate
}

void loop() {
  pot_output = analogRead (pot_pin); // Reading from the potentiometer
  int mapped_output = map (pot_output, 0, 1023, 2, 30); // Mapping the output of potentiometer 
  Serial.println (mapped_output);     // Sending the output to Processing IDE
  delay(50);

}
