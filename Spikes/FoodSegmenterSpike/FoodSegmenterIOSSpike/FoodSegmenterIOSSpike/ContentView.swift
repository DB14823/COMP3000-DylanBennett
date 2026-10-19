import SwiftUI
import TensorFlowLite
import UIKit

struct ContentView: View {
    @State private var maskImage: UIImage?
    @State private var sourceImage: UIImage?
    var body: some View {
        VStack {
            if let sourceImage {
                Text("Resized source photo")
                Image(uiImage: sourceImage)
                    .resizable()
                    .scaledToFit()
            }
            if let maskImage {
                Text("Fruit mask — category 5")
                Image(uiImage: maskImage)
                    .resizable()
                    .scaledToFit()
            }
        }
        .onAppear {
            guard
                let modelUrl = Bundle.main.url(
                    forResource: "1",
                    withExtension: "tflite"
                )
            else {
                print("modelUrl missing")
                return
            }

            guard
                let imageURL = Bundle.main.url(
                    forResource: "dish_1563555563",
                    withExtension: "png"
                )
            else {
                print("image not found")
                return
            }
            print(imageURL)

            guard let image = UIImage(contentsOfFile: imageURL.path)
            else {
                print("Could not load image")
                return

            }
            print(image.size)

            let format = UIGraphicsImageRendererFormat()
            format.scale = 1

            let renderer = UIGraphicsImageRenderer(
                size: (CGSize(width: 513, height: 513)),
                format: format
            )

            let resizedImage = renderer.image { context in
                image.draw(in: CGRect(x: 0, y: 0, width: 513, height: 513))
            }
            self.sourceImage = resizedImage

            guard let cgImage = resizedImage.cgImage
            else {
                print("image")
                return
            }
            print(cgImage.width)
            print(cgImage.height)

            let width = cgImage.width
            let height = cgImage.height
            let bytesPerRow = width * 4
            var rgbaPixels = [UInt8](
                repeating: 0,
                count: height * bytesPerRow
            )

            guard let colourSpace = CGColorSpace(name: CGColorSpace.sRGB)
            else {
                print("could not load colourspace")
                return
            }

            rgbaPixels.withUnsafeMutableBytes { buffer in

                guard
                    let context = CGContext(
                        data: buffer.baseAddress,
                        width: width,
                        height: height,
                        bitsPerComponent: 8,
                        bytesPerRow: bytesPerRow,
                        space: colourSpace,
                        bitmapInfo: CGImageAlphaInfo.premultipliedLast
                            .rawValue
                            | CGImageByteOrderInfo.order32Big.rawValue
                    )
                else {
                    print("error")
                    return
                }

                context.draw(
                    _: cgImage,
                    in: CGRect(x: 0, y: 0, width: 513, height: 513)
                )
            }

            var rgbPixels: [UInt8] = []

            for index in stride(from: 0, to: rgbaPixels.count, by: 4) {
                rgbPixels.append(rgbaPixels[index])
                rgbPixels.append(rgbaPixels[index + 1])
                rgbPixels.append(rgbaPixels[index + 2])
            }

            let inputData = Data(rgbPixels)
            do {
                let interpreter = try Interpreter(modelPath: modelUrl.path)
                try interpreter.allocateTensors()
                try interpreter.copy(inputData, toInputAt: 0)
                try interpreter.invoke()
                let output = try interpreter.output(at: 0)
                let scoreCount =
                    output.data.count / MemoryLayout<Float32>.size

                var scores = [Float32](
                    repeating: 0,
                    count: scoreCount
                )
                _ = scores.withUnsafeMutableBytes { buffer in
                    output.data.copyBytes(to: buffer)
                }

                var classMap = [Int]()

                for pixelIndex in 0..<(width * height) {
                    let offset = pixelIndex * 26
                    var bestClass = 0
                    var bestScore = scores[offset]
                    for classID in 1..<26 {
                        if scores[offset + classID] > bestScore {
                            bestScore = scores[offset + classID]
                            bestClass = classID
                        }

                    }
                    classMap.append(bestClass)
                }
                var maskPixels = [UInt8]()
                for classID in classMap {
                    if classID == 5 {
                        maskPixels.append(contentsOf: [255, 255, 255])
                    } else {
                        maskPixels.append(contentsOf: [0, 0, 0])
                    }
                }

                let maskData = Data(maskPixels)
                guard
                    let provider = CGDataProvider(data: maskData as CFData)
                else {
                    print("could not create mask provider")
                    return
                }

                guard
                    let maskCGImage = CGImage(
                        width: width,
                        height: height,
                        bitsPerComponent: 8,
                        bitsPerPixel: 24,
                        bytesPerRow: width * 3,
                        space: colourSpace,
                        bitmapInfo: CGBitmapInfo(
                            rawValue: CGImageAlphaInfo.none.rawValue
                        ),
                        provider: provider,
                        decode: nil,
                        shouldInterpolate: false,
                        intent: .defaultIntent
                    )
                else {
                    print("could not create mask image")
                    return
                }

                self.maskImage = UIImage(cgImage: maskCGImage)
                print(maskCGImage.width)
                print(maskCGImage.height)
            } catch {
                print("Model loading failed", error)
            }

        }
    }
}
#Preview {
    ContentView()
}
