import SwiftUI
import SceneKit

struct CoverKitView: UIViewRepresentable {
  
  @State private var currentAngleY: Float = 0.0
  
  var front: UIImage
  var back: UIImage
  
  func makeUIView(context: Context) -> SCNView {
    let sceneView = SCNView()
    let scene = SCNScene()
    
    let aspectRatio = front.size.width / front.size.height
    
    let cubeWidth: CGFloat = 4.5
    let cubeHeight: CGFloat = cubeWidth / aspectRatio
    let cubeLength: CGFloat = 0.25
    
    let cube = SCNBox(width: cubeWidth, height: cubeHeight, length: cubeLength, chamferRadius: 0.0)
    
    let cubeNode = SCNNode(geometry: cube)
    cubeNode.position = SCNVector3(0, 0, 0)
    cubeNode.name = "cubeNode"
    
    scene.rootNode.addChildNode(cubeNode)
    
    let cameraNode = SCNNode()
    cameraNode.camera = SCNCamera()
    cameraNode.position = SCNVector3(x: 0, y: 0, z: 8)
    scene.rootNode.addChildNode(cameraNode)
    
    let material = SCNMaterial()
    material.diffuse.contents = front
    
    let backmat = SCNMaterial()
    backmat.diffuse.contents = back
    
    let defaultMaterial = SCNMaterial()
    defaultMaterial.diffuse.contents = UIColor.darkGray
    
    cube.materials = [
      material,         // Front (0)
      defaultMaterial,  // Right (1)
      backmat,          // Back (2)
      defaultMaterial,  // Left (3)
      material,         // Top (4)
      defaultMaterial   // Bottom (5)
    ]
    
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
