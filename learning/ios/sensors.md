## Sensors

### Start

Xcode -> "New Project" -> "App". 
Use SwiftUI; it's a nice way to describe user interface.


### Accelerometer

This code will show some raw accelerometer data (unit of acceleration is G):
```swift
//
//  ContentView.swift
//  Sensors
//
//  Created by Alexander Ershov on 26.08.2024.
//

import CoreMotion
import SwiftUI

struct ContentView: View {
@State private var text = "time is ..."
private var isFirst = true

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    let motionManager = CMMotionManager()
    
    var body: some View {
        VStack {
            Text(text)
        }
        .padding()
        .onReceive(timer) { _ in
            var accData: CMAccelerometerData? = nil
            if motionManager.isAccelerometerAvailable {
                // Start the accelerometer (optional to configure update interval)
                // we need start accelerometer only once
                // we can't do it on every iteration, because accelerometer data
                // is not available immediately
                if isFirst {
                    motionManager.startAccelerometerUpdates()
                }

                // Get the current accelerometer data
                if let data = motionManager.accelerometerData {
                    // Store the accelerometer data
                    accData = data
                } else {
                    print("Unable to get accelerometer data")
                }

            } else {
                print("Accelerometer not available")
            }
            
            let formatter = DateFormatter()
            formatter.timeStyle = .medium
            text = """
time is \(formatter.string(from: Date()))
gyro:
accelerometer: x = \(accData?.acceleration.x ?? -666)
y = \(accData?.acceleration.y ?? -666)
z = \(accData?.acceleration.z ?? -666)
barometer:
ambient light:
"""
}
}

    }

#Preview {
ContentView()
}
```

Accelerometer data is actually acceleration compared to a acceleration of object in a free fall.
We can use DeviceMotion to exclude gravity and just get an intuitive acceleration.
We also need to add data to Info.plist (Choose your project in left pane -> "Targets" -> "Info" -> 
"+" -> "Privacy Motion Usage Description" and add some description), 
so app can use DeviceMotion.

We can also get some barometer data and gyroscope.
Gyroscope data in rotation speed in radians/s for every axis.

```swift
//
//  ContentView.swift
//  Sensors
//
//  Created by Alexander Ershov on 26.08.2024.
//

import AudioToolbox
import CoreMotion
import SwiftUI

struct ContentView: View {
    @State private var text = "time is ..."
    @State private var isFirst = true
    @State private var pressure: Double?
    @State private var gyroscope: CMGyroData?
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    let motionManager = CMMotionManager()
    let altimeter = CMAltimeter()
    
    var body: some View {
        VStack {
            Text(text)
        }
        .padding()
        .onReceive(timer) { _ in
            var accData: CMDeviceMotion? = nil
            if motionManager.isDeviceMotionAvailable {
                // Start the accelerometer (optional to configure update interval)
                if isFirst {
                    motionManager.startDeviceMotionUpdates()
                }

                // Get the current accelerometer data
                if let data = motionManager.deviceMotion {
                    // Store the accelerometer data
                    accData = data
                } else {
                    print("Unable to get motion data")
                }

            } else {
                print("Motion is not available")
            }
            
            if CMAltimeter.isRelativeAltitudeAvailable()  {
                if isFirst {
                    altimeter.startRelativeAltitudeUpdates(to: OperationQueue.main) { data, error in
                        if data != nil {
                            pressure = data?.pressure.doubleValue
                        } else {
                            print("nil!")
                        }
                    }
                }
            } else {
                print("altimeter not available")
            }
            
            if motionManager.isGyroAvailable {
                if isFirst {
                    motionManager.gyroUpdateInterval = 0.1
                    motionManager.startGyroUpdates(to: OperationQueue.main) { gyroData, error in
                        if gyroData != nil {
                            gyroscope = gyroData
                        }
                        
                    }
                }
            } else {
                print("gyroscope is not available")
            }
            
            if isFirst {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            }
            
            isFirst = false
            
            let formatter = DateFormatter()
            formatter.timeStyle = .medium
            text = """
time is \(formatter.string(from: Date()))
gyroscope: x = \(gyroscope?.rotationRate.x ?? -666)
           y = \(gyroscope?.rotationRate.y ?? -666)
           z = \(gyroscope?.rotationRate.z ?? -666)
accelerometer: x = \(accData?.userAcceleration.x ?? -666)
               y = \(accData?.userAcceleration.y ?? -666)
               z = \(accData?.userAcceleration.z ?? -666)
barometer:     pressure \(pressure ?? -666) kPA
"""
        }
    }
    
    }

#Preview {
    ContentView()
}


```
