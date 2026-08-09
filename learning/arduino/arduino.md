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

Capacitor can store some charge, they're useful when there are some dips in voltage (e.g. when servo start moving).
When voltage is lower than what's stored in capacitor, then capacitor releases charge, smoothing out voltage dips.

Transistor has 3 parts: gate, collector, emitter.
When gate is closed, then there's no connection between collector & emitter.
When gate is opened (when it's getting some electricity), then connection opens.
Nice properties are:
* gate can be opened by applying small voltage, and voltage between collector and emitter can be large: so transistor operates as an amplifier.
* since we can control gates electronically and we can combine transistors, this allows building complex logical circuits that can
  be controlled electronically (without vacuum tubes)
Obviously transistors which are foundations of modern electronics are super tiny (nanometers), 
but the principle stays the same.

### Resistors Coloring Scheme
There are 4-band and 5-band registers.
Details are described here: https://en.wikipedia.org/wiki/Electronic_color_code.
The gist of it:
* each digit is encoded by some color (0 - black, 1 - brown, 2 - red, 5 - green)
* Last band is tolerance (precision), e.g. if last band is brown, this means tolerance is ±1%
* This last band is usually located at a larger distance from the rest of the bands: that's how you determine 
  the orientation of a resistor so you can decode the value (because it's essentially positional system based on colors)
* So, you've determined last band, it should be on the right end. Now read colors left to right:
* For 4-band resistors (background color is usually beige) first two bands are first two digits
  3rd band is 10^x, where x is band digit, 4th band is tolerance, we can ignore it.
  so `[red, red, brown, brown]` is `[red-red-10^brown]` ==  22 * 10^1 == 220 Ohm with ±1% tolerance
* For 5-band resistors (background color is usually light-blue) it's the same just we have digit, digit, digit, multiplier, tolerance.
* So e.g. `[brown, black, black, red, brown]`is `[brown-black-black-10^red]` == 100 * 10^2 == 10kOhm with ±1% tolerance. 

## Components
Arduino UNO R3 has 16Mhz 8-bit CPU, 2kb of SRAM.
Arduino UNO R4 has 48Mhz 32-bit CPU, 32kb of SRAM.

Digital pins are essentially bits, you can read/write them with digitalRead/digitalWrite.
There are 13 pins. Pins have two states: HIGH (voltage) & LOW (voltage).
You can have an appearance of analog input using PWM (explained later in [Piezo Bang Sketch](#piezo-bang-sketch))

There are also analog pins (A0, A1, ...), you can read from them with `analogRead`.

AREF pin allows you to calibrate output of analog outputs. 
Let's say your sensor provides output in a range `[0V; 1V]`, this means that in `analogRead` you will
see just the first 20% of the possible values (because analogRead is calibrated on 5V).
With AREF you can still get the full spectrum of values.

## Temperature Project

Here's a sketch to display the current temperature on an LCD screen:
```C
// LiquidCrystal is a helper library to work with the LCD display
// Documentation is here: https://docs.arduino.cc/libraries/liquidcrystal/
#include <LiquidCrystal.h>

/*
How LCD display works:
we connect bunch of LCD pins to power/ground (some through resistor, some not)

To put LCD in a write mode connect RW pin to the ground
V0 pin on LCD allows to configure contrast
*/
// using 4 data lines mode
// pin 12 is RS pin on LCD: it determines where the characters will appear
// pin 11 EN pin on LCD: it tells LCD that it'll be receiving command
// pins 5, 4, 3, 2 are connected to data registers on LCD
LiquidCrystal lcd(12, 11, 5, 4, 3, 2);

// our temperature sensor is physically connected (with a wire) to A0 pin
// temperature sensor has three legs: power, sensor, and ground. Sensor is in the middle.
const int sensorPin = A0;

// runs once, when arduino starts
void setup() {
  Serial.begin(9600); // open connection to serial port. Connection speed is 9600 bits/second
  // Serial port is an aptly named port: bits are read/write sequentially (hence serial).
  // 9600 is the rate we've set up
  // LCD has 16 columns and 2 rows, it can display 32 characters
  lcd.begin(16, 2);
  // LiquidCrystal hides all complexity of interacting with the LCD from us
  lcd.print("temperature");
}

// runs continuously
void loop() {
  int sensorVal = analogRead(sensorPin); // value in range [0; 1023];
  float voltage = sensorVal * 5.0 / 1024.0;  // map sensor value to a voltage, 5.0 is maximum voltage
  // spec of TMP36 sensor is this:
  // for 0C it ouputs 0.5V
  // change of 10mV equals change of 1C
  // it's a linear dependency:
  // V = C/100 + 0.5
  // or doing very sophisticated and complicated algebraic transformation
  // C = (V - 0.5) * 100
  float temperature = (voltage - 0.5) * 100;
  Serial.print("temperature ");
  Serial.println(temperature);
  // set cursor to column 0, row 1
  lcd.setCursor(0, 1);
  lcd.print(temperature);
  delay(1000); // delay 1000ms
}
```

## Loops/second Sketch

This measures how many loops we can execute per second
```C
#include <LiquidCrystal.h>

LiquidCrystal lcd(12, 11, 5, 4, 3, 2);

unsigned long loops = 0;
unsigned long mhz = ((unsigned long)1) << 20;
unsigned long lastMillis = 0;
unsigned long ones = (mhz << 1) - 1;


void setup() {
  Serial.begin(9600);
  lcd.begin(16, 2);
  lcd.print("loops/sec");
}

void loop() {
  loops++;
  if ((loops & ones) == mhz) {
    Serial.print("loops = ");
    Serial.println(loops);
    unsigned long curMillis = millis();
    unsigned long duration = curMillis - lastMillis;
    float loopsPerSecond = 2000.0 * mhz / duration;  // multiply by 2000.0, because we hit the condition once every 2mhz
    lastMillis = curMillis;
    lcd.setCursor(0, 1);
    lcd.print(loopsPerSecond);
  }
}
```

Surprisingly, we're getting ~360k loops/s. That's because Arduino R3 has 8-bit CPU, so even simple operations
on a 32-bit integers are slow.


## Servo Sketch

```C
#include <Servo.h>

Servo myServo;

void setup() {
  myServo.attach(9); // we physically connected servo to the 9th pin
  Serial.begin(9600);
}

void loop() {
  int val = analogRead(A0); // read some sensor, range is [0; 1023]
  // A0 can be connected to phototransistor, potentiometer etc
  int angle = map(val, 0, 1023, 0, 179); // map [0; 1023] -> [0; 179], which is the angle on a servo
  myServo.write(angle);
  delay(15);
}
```

## Simple Piezo Sketch

Piezo + some analog input
```C
void setup() {
  
}

void loop() {
  int analog = analogRead(A0); // phototransistor
  int frequency = map(analog, 0, 1023, 50, 4000);
  tone(
    8, // pin8 is input to piezo
    frequency,
    20 // duration in ms
  );
  delay(10);
}
```

## Keyboard Piezo Sketch

Piezo + resistor ladder
```C
void setup() {
  Serial.begin(9600); // so we can print to serial port for debugging puproses
}

void loop() {
  // each switch is connected to a different resistor (range is 0Ohm to 1MOhm)
  // the more resistance the lower is value and we can pick different tone based on this value
  int value = analogRead(A0);
  if (value == 1023) {
    // No resistor
    tone(8, 262); // 262 is note C
  } else if (value >= 990 && value < 1010) {
    // 220 Ohm
    tone(8, 294); // 294 is note D
  } else if (value >= 505 && value < 515) {
    // 10k Ohm
    tone(8, 330); // 330 is note E
  } else if (value >= 5 && value < 10) {
    // 10M Ohm
    tone(8, 349); // 349 is note F
  } else {
    noTone(8); // no button is pressed, let's be silent
  }
}
```

## Piezo Bang Sketch

This sketch lightens up a LED when you bang the table. 
Brightness of the LED is proportional to the intensity of the bang.

```C
void setup() {
  Serial.begin(9600); // so we can print to serial port for debugging puproses
  pinMode(11, OUTPUT); // so we can write to the pin later
}

void loop() {
  // piezo is connected to A0 via resistor
  // piezo works in both directions: it can vibrate when electricity passes through it
  // (it's made out of a special material that can vibrate when electricity passes through it) - sound depends on a frequency
  // that we pass through the piezo
  // but piezo can also detect vibrations and emit power
  // vibrations should be pretty hard: like a bang on the table where arduino is sitting (value=100)
  // loud talking _really_ near the piezo gives value 1-2, so it can be triggered even with the voice
  // here we read value from piezo and turn on the LED if piezo determined a vibration
  // LED brightness is proportional to the power of the bang
  int value = analogRead(A0);
  if (value > 0) {
    // LED is connected to power via digital pin 11
    // pin 11 is marked as `-11` - meaning it can use Pulse Width Modulation:
    // to make use of it we pass second argument to analogWrite (range [0; 255]) which allows us
    // to control duty cycle: 255 is 100% duty cycle - the pin is HIGH 100% of the time
    // 0 is 0% duty cycle - the pin is LOW 100% of the time
    // and in-between values are interpolated
    // the effect is that LED will get higher/lower power and will be lighter/dimmer
    // value ~= 120 is a bang!
    analogWrite(11, map(value, 0, 150, 0, 255)); 
    // digitalWrite(11, HIGH);  // digitalWrite is the same as analogWrite(11, 255) - it's always HIGH
    Serial.print("value = ");
    Serial.println(value);
  }
}
```