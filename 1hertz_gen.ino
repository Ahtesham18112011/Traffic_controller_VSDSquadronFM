// Define the output pin for the clock signal
const int clockPin = 13; // You can change this to any digital pin

void setup() {
  // Set the clock pin as output
  pinMode(clockPin, OUTPUT);
}

void loop() {
  digitalWrite(clockPin, HIGH); // Set pin HIGH
  delay(500);                   // Wait for 500ms
  digitalWrite(clockPin, LOW);  // Set pin LOW
  delay(500);                   // Wait for 500ms
}
