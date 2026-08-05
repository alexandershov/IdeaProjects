# Arduino

## What is it?
Arduino is a microcontroller kit for building hardware devices.

## Install
For macOS: download Arduino from https://arduino.cc/download and install it as your run-of-the-mill app. 
Start it (it's called "Arduino IDE")

## Usage
Connect Arduino to your Mac with the USB cable. It'll turn on automatically.

In IDE: File -> Examples -> Basics -> Blink.
Then select your board ("Arduino UNO") in the editor and press "Upload".
This will upload "sketch" (== "program" in Arduino lingo) to your Arduino.
TX and RX LEDS will start blinking (this means your computer is communicating with the Arduino) and then
output LED will start blinking (it's yellow). It's working.

output LED is the only actuator (== thingy that can do stuff) built-in into Arduino.

## Circuit
Electricity in a circuit flows from a higher voltage to a lower voltage.
Fundamental things are:
* Voltage (R)
* Current (I)
* Resistance (R)

They're connected with the Ohm equation: `V = I * R` or (by doing complicated algebraic conversion) `I = V / R`
This means when resistance decreases, current increases.
If voltage increases, current increases.

Think of voltage as "potential energy", current as "energy", and resistance as "decrease of energy".

Like a bunch rock sliding from a hill with the bushes: 
* bushes are resistance, they decrease number of rocks that reach the bottom
* voltage is the height of hill, the higher, the more energy we'll get at the end
* number of rocks is current


For practical Arduino usage all of it means that current flows from 5V to the ground.

You complete a circuit on a breadboard. 

Breadboard looks like this (only with more pins):
```
+     -                                +     -
│     │                                │     │
o     o   o o o o o   ││   o o o o o   o     o
o     o   o o o o o   ││   o o o o o   o     o
o     o   o o o o o   ││   o o o o o   o     o
o     o   o o o o o   ││   o o o o o   o     o
o     o   o o o o o   ││   o o o o o   o     o
o     o   o o o o o   ││   o o o o o   o     o
o     o   o o o o o   ││   o o o o o   o     o
o     o   o o o o o   ││   o o o o o   o     o
o     o   o o o o o   ││   o o o o o   o     o
```
+/- vertical rows are connected.
horizontal rows of length 5 are connected. `||` breaks connection in the middle.
There's no connection between vertical +/- and horizontal rows of length 5.
But you can make these connections with the wires! That's how you build circuits: 
you provide a path from 5V to the ground, this path can contain interesting things (buttons, LEDs, etc)
and these interesting things make circuit do, ahem, interesting things. 

LED is Light-Emitting-Diode. It has two legs:
* anode (longer) is connected to the energy.
* cathode (shorter) is connected to the ground.

## Reading sensors

Here's a sketch of a program to print current temperature:
```C
// our temperature sensor is physically connected (with a wire) to A0 pin
// temperature sensor has three legs: power, sensor, and ground. Sensor is in the middle.
const int sensorPin = A0;

// runs once, when arduino starts
void setup() {
  Serial.begin(9600); // open connection to serial port. Connection speed is 9600 bits/second
}


// runs continuously
void loop() {
  int sensorVal = analogRead(sensorPin); // value in range [0; 1023];
  float voltage = sensorVal * 5.0 / 1024.0;  // map sensor value to a voltage, 5.0 is maximum voltage
  float temperature = (voltage - 0.5) * 100;
  Serial.print("temperature ");
  Serial.println(temperature);
  delay(1000); // delay 1000ms
}
```