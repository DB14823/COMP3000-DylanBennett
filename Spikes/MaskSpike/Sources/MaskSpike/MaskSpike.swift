import Foundation
import Vision
import CoreImage

@main
struct MaskSpike {
    static func main() throws {
        guard let imagePath = CommandLine.arguments.dropFirst().first
                else {
            print ("Image path required")
            return
        }
        let imageURL = URL (
            filePath: imagePath,
            directoryHint: .notDirectory
        )
        let request = VNGenerateForegroundInstanceMaskRequest()
        let handler = VNImageRequestHandler(url: imageURL, options: [:])
        
        try handler.perform([request])
        print(imageURL)
        
        guard let observation = request.results?.first
                else {
            print ("Vision returned no observation")
            return
        }
        print(observation.allInstances.count)
        
        let context = CIContext()
        let dishID = imageURL.deletingPathExtension().lastPathComponent
        
        
        for instanceID in observation.allInstances{
            
            let maskedImage = try observation.generateMaskedImage(ofInstances: IndexSet(integer: instanceID),
                                                                  from: handler,
                                                                  croppedToInstancesExtent: false
            )
            let outputImage = CIImage(cvPixelBuffer: maskedImage)
            
            let outputFilename = "\(dishID).instance-\(instanceID).png"
            
            let outputURL = imageURL.deletingLastPathComponent().appending(path: outputFilename, directoryHint: .notDirectory)
            
            try context.writePNGRepresentation(of: outputImage,
                                               to: outputURL,
                                               format: .RGBA8,
                                               colorSpace: CGColorSpaceCreateDeviceRGB(),
                                               options: [:]
            )
        }
    }
    
}

