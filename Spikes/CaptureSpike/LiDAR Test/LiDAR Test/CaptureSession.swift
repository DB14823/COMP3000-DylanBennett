import ARKit
import CoreImage

@MainActor
final class CaptureSession {
    let session = ARSession()
    func start() {
        guard ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth)
        else {
            print("Depth feature not supported")
            return
        }
        let configuration = ARWorldTrackingConfiguration()
        configuration.frameSemantics = [.sceneDepth]
        configuration.planeDetection = [.horizontal]
        session.run(configuration)
    }

    func stop() {
        session.pause()
    }

    func inspectDepth() {
        guard let frame = session.currentFrame
        else {
            print("No camera frame yet")
            return
        }
        guard let depth = frame.sceneDepth
        else {
            print("No depth data yet")
            return
        }
        let depthMap = depth.depthMap

        let planes = frame.anchors.compactMap { $0 as? ARPlaneAnchor }

        for plane in planes {
            print(plane.classification)
            print(plane.transform.columns.3.y)
            print(plane.identifier)
        }

        guard
            let tablePlane = planes.first(where: {
                $0.__classification == .table
            })
        else {
            print("No table identified")
            return
        }
        print("Selected table:", tablePlane.identifier)

        let lockResult = CVPixelBufferLockBaseAddress(depthMap, .readOnly)

        guard lockResult == kCVReturnSuccess else {
            print("Unable to lock depth buffer")
            return
        }

        defer {
            CVPixelBufferUnlockBaseAddress(depthMap, .readOnly)
        }

        guard let baseAddress = CVPixelBufferGetBaseAddress(depthMap)
        else {
            print("Depth buffer has no memory address")
            return
        }

        let depthWidth = CVPixelBufferGetWidth(depthMap)
        let depthHeight = CVPixelBufferGetHeight(depthMap)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(depthMap)

        let centreX = depthWidth / 2
        let centreY = depthHeight / 2

        guard let confidenceMap = depth.confidenceMap
        else {
            print("no confidence map available")
            return
        }

        let confidenceLock = CVPixelBufferLockBaseAddress(
            confidenceMap,
            .readOnly
        )

        guard confidenceLock == kCVReturnSuccess else {
            print("Unable to lock confidence map")
            return
        }

        defer {
            CVPixelBufferUnlockBaseAddress(confidenceMap, .readOnly)
        }

        guard let confidenceAddress = CVPixelBufferGetBaseAddress(confidenceMap)
        else {
            print("No confidence address available")
            return
        }

        let confidenceBytesPerRow = CVPixelBufferGetBytesPerRow(confidenceMap)

        let byteOffset =
            centreY * bytesPerRow
            + centreX * MemoryLayout<Float32>.size

        let centreOffset =
            centreY * confidenceBytesPerRow
            + centreX

        let centreDepth = baseAddress.load(
            fromByteOffset: byteOffset,
            as: Float32.self
        )

        let centreConfidence = confidenceAddress.load(
            fromByteOffset: centreOffset,
            as: UInt8.self
        )

        guard centreDepth.isFinite, centreDepth > 0
        else {
            print("centre depth is wrong? idk")
            return
        }

        let intrinsics = frame.camera.intrinsics
        let scaleX =
            Float(depthWidth) / Float(frame.camera.imageResolution.width)
        let scaleY =
            Float(depthHeight) / Float(frame.camera.imageResolution.height)
        let fx = intrinsics.columns.0.x * scaleX
        let fy = intrinsics.columns.1.y * scaleY
        let cx = intrinsics.columns.2.x * scaleX
        let cy = intrinsics.columns.2.y * scaleY

        let cameraX = (Float(centreX) - cx) * centreDepth / fx
        let cameraY = -(Float(centreY) - cy) * centreDepth / fy
        let cameraZ = -centreDepth

        let cameraPoint = SIMD4<Float>(cameraX, cameraY, cameraZ, 1)
        let worldPoint = frame.camera.transform * cameraPoint

        let tablePoint = tablePlane.transform.inverse * worldPoint

        print(centreDepth)
        print(centreConfidence)
        print(frame.camera.trackingState)
        print("fx, fy, cx, cy =", fx, fy, cx, cy)
        print("Camera coords:", cameraX, ",", cameraY, ",", cameraZ)
        print(tablePoint.y * 1000)
    }

    func capture() {
        guard let frame = session.currentFrame
        else {
            print("No camera frame yet")
            return
        }
        guard let depth = frame.sceneDepth
        else {
            print("No depth data yet")
            return
        }
        let depthMap = depth.depthMap

        guard let confidenceMap = depth.confidenceMap
        else {
            print("no confidence map available")
            return
        }
        let planes = frame.anchors.compactMap { $0 as? ARPlaneAnchor }

        for plane in planes {
            print(plane.classification)
            print(plane.transform.columns.3.y)
            print(plane.identifier)
        }

        guard
            let tablePlane = planes.first(where: {
                $0.__classification == .table
            })
        else {
            print("No table identified")
            return
        }

        do {
            let captureID = UUID().uuidString
            let capturesFolder = URL.documentsDirectory.appending(
                path: "Captures",
                directoryHint: .isDirectory
            )

            let captureFolder = capturesFolder.appending(
                path: captureID,
                directoryHint: .isDirectory
            )
            try FileManager.default.createDirectory(
                at: captureFolder,
                withIntermediateDirectories: true,
                attributes: nil
            )
            let lockResult = CVPixelBufferLockBaseAddress(depthMap, .readOnly)

            guard lockResult == kCVReturnSuccess else {
                print("Unable to lock depth buffer")
                return
            }

            defer {
                CVPixelBufferUnlockBaseAddress(depthMap, .readOnly)
            }

            guard let baseAddress = CVPixelBufferGetBaseAddress(depthMap)
            else {
                print("Depth buffer has no memory address")
                return
            }
            let depthWidth = CVPixelBufferGetWidth(depthMap)
            let depthHeight = CVPixelBufferGetHeight(depthMap)
            let bytesPerRow = CVPixelBufferGetBytesPerRow(depthMap)
            let packedBytesPerRow = depthWidth * MemoryLayout<Float32>.size

            print(bytesPerRow)
            print(packedBytesPerRow)

            var depthData = Data()
            for row in 0..<depthHeight {
                let rowOffset = row * bytesPerRow
                let rowAddress = baseAddress.advanced(by: rowOffset)
                depthData.append(
                    rowAddress.assumingMemoryBound(to: UInt8.self),
                    count: packedBytesPerRow
                )
            }
            let depthFolder = captureFolder.appending(components: "depth.f32")
            try depthData.write(to: depthFolder)

            let confidenceLock = CVPixelBufferLockBaseAddress(
                confidenceMap,
                .readOnly
            )

            guard confidenceLock == kCVReturnSuccess else {
                print("Unable to lock confidence map")
                return
            }

            defer {
                CVPixelBufferUnlockBaseAddress(confidenceMap, .readOnly)
            }

            guard
                let confidenceAddress = CVPixelBufferGetBaseAddress(
                    confidenceMap
                )
            else {
                print("No confidence address available")
                return
            }

            let confidenceHeight = CVPixelBufferGetHeight(confidenceMap)
            let confidenceWidth = CVPixelBufferGetWidth(confidenceMap)
            let confidenceBytesPerRow = CVPixelBufferGetBytesPerRow(
                confidenceMap
            )
            print(confidenceWidth)
            print(confidenceHeight)
            print(confidenceBytesPerRow)

            var confidenceData = Data()
            for row in 0..<confidenceHeight {
                let rowOffset = row * confidenceBytesPerRow
                let confidenceAddress = confidenceAddress.advanced(
                    by: rowOffset
                )
                confidenceData.append(
                    confidenceAddress.assumingMemoryBound(to: UInt8.self),
                    count: confidenceBytesPerRow
                )
            }
            print(confidenceData.count)

            let confidenceFolder = captureFolder.appending(
                components: "confidence.u8"
            )
            try confidenceData.write(to: confidenceFolder)

            let intrinsics = frame.camera.intrinsics

            let cameraIntrinsics: [Float] = [
                intrinsics.columns.0.x,
                intrinsics.columns.1.x,
                intrinsics.columns.2.x,
                intrinsics.columns.0.y,
                intrinsics.columns.1.y,
                intrinsics.columns.2.y,
                intrinsics.columns.0.z,
                intrinsics.columns.1.z,
                intrinsics.columns.2.z,
            ]

            let transform = frame.camera.transform

            let cameraTransform: [Float] = [
                transform.columns.0.x,
                transform.columns.1.x,
                transform.columns.2.x,
                transform.columns.3.x,
                transform.columns.0.y,
                transform.columns.1.y,
                transform.columns.2.y,
                transform.columns.3.y,
                transform.columns.0.z,
                transform.columns.1.z,
                transform.columns.2.z,
                transform.columns.3.z,
                transform.columns.0.w,
                transform.columns.1.w,
                transform.columns.2.w,
                transform.columns.3.w,
            ]

            let tableTransform = tablePlane.transform

            let planeTransform: [Float] = [
                tableTransform.columns.0.x,
                tableTransform.columns.1.x,
                tableTransform.columns.2.x,
                tableTransform.columns.3.x,
                tableTransform.columns.0.y,
                tableTransform.columns.1.y,
                tableTransform.columns.2.y,
                tableTransform.columns.3.y,
                tableTransform.columns.0.z,
                tableTransform.columns.1.z,
                tableTransform.columns.2.z,
                tableTransform.columns.3.z,
                tableTransform.columns.0.w,
                tableTransform.columns.1.w,
                tableTransform.columns.2.w,
                tableTransform.columns.3.w,
            ]

            print(planeTransform)

            let metadata = CaptureMetadata(
                depthWidth: depthWidth,
                depthHeight: depthHeight,
                confidenceWidth: confidenceWidth,
                confidenceHeight: confidenceHeight,
                frameTimestamp: frame.timestamp,
                imageHeight: Int(frame.camera.imageResolution.height),
                imageWidth: Int(frame.camera.imageResolution.width),
                cameraIntrinsics: cameraIntrinsics,
                cameraTransform: cameraTransform,
                planeTransform: planeTransform
            )
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let metadataData = try encoder.encode(metadata)

            let metadataFolder = captureFolder.appending(
                component: "meta.json"
            )

            try metadataData.write(to: metadataFolder)

            let cameraImage = frame.capturedImage

            let ciImage = CIImage(cvPixelBuffer: cameraImage)
            let imageContext = CIContext()

            let imageURL = captureFolder.appending(
                component: "rgb.heic"
            )
            guard let colourSpace = CGColorSpace(name: CGColorSpace.sRGB)
            else {
                print("colour space not available")
                return
            }

            try imageContext.writeHEIFRepresentation(
                of: ciImage,
                to: imageURL,
                format: .RGBA8,
                colorSpace: colourSpace
            )
            print("image written successfully")

            try FileManager.default.contentsOfDirectory(
                at: captureFolder,
                includingPropertiesForKeys: nil
            )

            print(depthFolder.lastPathComponent)
            print(confidenceFolder.lastPathComponent)
            print(metadataFolder.lastPathComponent)
            print(imageURL.lastPathComponent)

        } catch {
            print(error)
        }

    }
}

struct CaptureMetadata: Codable {
    let depthWidth: Int
    let depthHeight: Int
    let confidenceWidth: Int
    let confidenceHeight: Int
    let frameTimestamp: Double
    let imageHeight: Int
    let imageWidth: Int
    let cameraIntrinsics: [Float]
    let cameraTransform: [Float]
    let planeTransform: [Float]
}
