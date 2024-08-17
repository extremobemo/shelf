import SwiftUI
import SceneKit

struct CoverKitView: UIViewRepresentable {
  
  @State private var currentAngleY: Float = 0.0
    
  var front: UIImage
  var back: UIImage
  
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        let scene = SCNScene()
      
      // Calculate the aspect ratio of the image
       let aspectRatio = front.size.width / front.size.height
       
       // Set the width and height of the cube's front face based on the image's aspect ratio
       let cubeWidth: CGFloat = 4.5
       let cubeHeight: CGFloat = cubeWidth / aspectRatio
       let cubeLength: CGFloat = 0.25
        
        // Create a cube geometry
      let cube = SCNBox(width: cubeWidth, height: cubeHeight, length: cubeLength, chamferRadius: 0.0)
        
        // Create a node with the cube geometry
        let cubeNode = SCNNode(geometry: cube)
        cubeNode.position = SCNVector3(0, 0, 0)
      cubeNode.name = "cubeNode"
        
        // Add the cube node to the scene
        scene.rootNode.addChildNode(cubeNode)
        
        // Add a camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 7)
        scene.rootNode.addChildNode(cameraNode)
        
        // Create a material with an image for one face
        let material = SCNMaterial()
        material.diffuse.contents = front // Replace with your image name
      
        let backmat = SCNMaterial()
        backmat.diffuse.contents = back
      
        let spinemat = SCNMaterial()
        // spinemat.diffuse.contents = UIImage(named: "halo_spine")

        // Create an array of materials, one for each face
        let defaultMaterial = SCNMaterial()
      defaultMaterial.diffuse.contents = UIColor.darkGray // Default color for other faces
        
        cube.materials = [
            material,  // Front (0)
            defaultMaterial,  // Right (1)
            backmat,  // Back (2)
            defaultMaterial,  // Left (3)
            material,         // Top (4)
            defaultMaterial   // Bottom (5)
        ]
        
        // Set the scene to the sceneView
        sceneView.scene = scene
        sceneView.backgroundColor = UIColor.clear
      
        let rotateAction = SCNAction.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: 10)
        let repeatAction = SCNAction.repeatForever(rotateAction)
         cubeNode.runAction(repeatAction)
      
      let panGesture = UIPanGestureRecognizer(target: context.coordinator, action:  #selector(Coordinator.handlePanGesture(_:)))
    
              sceneView.addGestureRecognizer(panGesture)
      
        return sceneView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
      if let cubeNode = uiView.scene?.rootNode.childNode(withName: "cubeNode", recursively: true) {
                  cubeNode.eulerAngles.y = currentAngleY
              }
    }
  
  func makeCoordinator() -> Coordinator {
          Coordinator(self)
      }

  class Coordinator: NSObject {
    var parent: CoverKitView
    private var lastPanX: CGFloat = 0.0
    
    init(_ parent: CoverKitView) {
      self.parent = parent
    }
    
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
      let translation = gesture.translation(in: gesture.view)
      let width = gesture.view?.frame.width ?? 1
      let relativeTranslation = Float(translation.x / width) * .pi // Convert to radians
      
      switch gesture.state {
      case .began:
        lastPanX = translation.x
      case .changed:
        let delta = Float(translation.x - lastPanX) / Float(40)
        parent.currentAngleY += delta
        lastPanX = translation.x
      default:
        break
      }
    }
  }
}



//struct CoverContentView: View {
////  var body: some View {
////    // CoverKitView().edgesIgnoringSafeArea(.all)
////  }
//}
