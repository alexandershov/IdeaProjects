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

output LED is the only actuator (thingy that can do stuff) built-in into Arduino.
