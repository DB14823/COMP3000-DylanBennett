import SwiftUI
import Playgrounds
import TensorFlowLite

struct ContentView: View {
    var body: some View {
        Text("Hello")
            .padding()
            .onAppear {
                print("Screen opened")
            }
    }
}

#Preview {
    ContentView()
}

#Playground {
    _ = 1 + 2
}
