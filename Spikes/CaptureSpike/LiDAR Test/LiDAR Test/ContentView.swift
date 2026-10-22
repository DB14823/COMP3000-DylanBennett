import ARKit
import SwiftUI

struct ContentView: View {
    @State private var captureSession = CaptureSession()
    var body: some View {
        VStack {
            Text("LiDAR suitability check")

            CameraPreview(session: captureSession.session)
                .aspectRatio(3.0 / 4.0, contentMode: .fit)

            Button(action: captureSession.inspectDepth) {
                Text("Inspect depth")
            }

            Button(action: captureSession.capture) {
                Text("Capture")
            }
        }
        .onAppear {
            print(
                ARWorldTrackingConfiguration.supportsFrameSemantics(
                    .sceneDepth
                )
            )
            captureSession.start()
        }
        .onDisappear {
            captureSession.stop()
        }
    }
}
