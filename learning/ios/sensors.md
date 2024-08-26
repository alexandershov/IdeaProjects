## Sensors

### Start

Xcode -> "New Project" -> "App". 
Use SwiftUI; it's a nice way to describe user interface.


### Accelerometer

This code will show some accelerometer data:
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