import ARKit
import RealityKit
import SwiftUI

struct CameraPreview: UIViewRepresentable {
    let session: ARSession

    func makeUIView(context: Context) -> ARView {
        let view = ARView(
            frame: .zero,
            cameraMode: .ar,
            automaticallyConfigureSession: false
        )
        view.session = session
        return view
    }

    func updateUIView(_ uiView: ARView, context: Context) {

    }
}
