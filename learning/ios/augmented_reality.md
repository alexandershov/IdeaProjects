## Augmented reality


### Quick start
Start XCode, "New Project" -> "AR application", create Apple Developer Account.

There are several choices for the AR framework:
* SceneKit uses ARKit data to render AR objects in a real world.
* RealityKit is more high level, provides support for gestures etc.

Both SceneKit and RealityKit are based on ARKit - foundational AR framework.

It'll ask to download iOS for simulator (it's about 7GB).
But AR apps won't run in simulator, because you need camera, accelerometer etc.

You need to connect your iPhone, enable "Settings" -> "Privacy and Security" -> "Developer Mode".
It'll require restart

### Concepts

ARView is a view where scene is rendered.

Scene contains entities.

AnchorEntity allows to pin virtual content to real world objects.

Entity is some kind of renderable geometry, that is attached to AnchorEntity.


### Build
First we need to set destination, so a build will work.

"Product" -> "Destination" -> <Your device>.

Then "Product" -> "Run".

You'll need to trust your developer account in "Settings" -> "General".

When you run an application it'll show you a AR cube.
Source code is here (it's just an initial AR project code)
```swift
//
//  ContentView.swift
//  ARExample
//
//

import SwiftUI
import RealityKit

struct ContentView : View {
    var body: some View {
        ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)

        // Create a cube model
        let mesh = MeshResource.generateBox(size: 0.1, cornerRadius: 0.005)
        let material = SimpleMaterial(color: .gray, roughness: 0.15, isMetallic: true)
        let model = ModelEntity(mesh: mesh, materials: [material])
        model.transform.translation.y = 0.05

        // Create horizontal plane anchor for the content
        let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
        anchor.children.append(model)

        // Add the horizontal plane anchor to the scene
        arView.scene.anchors.append(anchor)

        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
}

#Preview {
    ContentView()
}

```

