//
//  CameraController.swift
//  mobileTheremin
//
//  Created by Elena Hertel on 4/26/24.
//

import UIKit
import AVFoundation
import CoreMedia
import Combine
import SwiftUI

class CameraController: NSObject, ObservableObject, AVCaptureDepthDataOutputDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // MARK: - Properties
    var volume: Float = 0.0
    var session = AVCaptureSession()
    private var videoOutput = AVCaptureVideoDataOutput()
    private var depthOutput = AVCaptureDepthDataOutput()
    private let distanceLabel = UILabel()
//    @Published var closestObjectDistance: String = ""
    @Published var closestObjectDistance: Float = 0.0
    
    // MARK: - View Lifecycle
    
    override init() {
        super.init()
        setupCamera()
    }
    
    func view() -> UIView {
        let cameraView = UIView()
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = cameraView.bounds // Set previewLayer's frame to match cameraView's bounds
        previewLayer.videoGravity = .resizeAspectFill
        cameraView.layer.addSublayer(previewLayer)
        return cameraView
    }
    
    // MARK: - Setup
    
    func setupCamera() {
        guard let frontCamera = AVCaptureDevice.default(.builtInTrueDepthCamera, for: .video, position: .front) else {
            print("TrueDepth camera is not available.")
            return
        }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: frontCamera)
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
                print("Video input added successfully.")
            } else {
                print("Failed to add video input.")
            }
            
            if session.canAddOutput(videoOutput) {
                session.addOutput(videoOutput)
                print("Video output added successfully.")
            } else {
                print("Failed to add video output.")
            }
            
            if session.canAddOutput(depthOutput) {
                session.addOutput(depthOutput)
                print("Depth output added successfully.")
            } else {
                print("Failed to add depth output.")
            }
            
            let videoQueue = DispatchQueue(label: "com.example.videoQueue")
            videoOutput.setSampleBufferDelegate(self, queue: videoQueue)
            
            let depthQueue = DispatchQueue(label: "com.example.depthQueue")
            depthOutput.setDelegate(self, callbackQueue: depthQueue)
            
            session.startRunning()
            print("Capture session started.")
        } catch {
            print("Error setting up capture session: \(error.localizedDescription)")
        }
        
        // Print the current configuration of the capture session
        print("Current capture session configuration:")
        print("Inputs: \(session.inputs)")
        print("Outputs: \(session.outputs)")
    }
    
    // MARK: - AVCaptureDepthDataOutputDelegate
    
    func depthDataOutput(_ output: AVCaptureDepthDataOutput, didOutput depthData: AVDepthData, timestamp: CMTime, connection: AVCaptureConnection) {
//        print("Depth data received.")
        
        // Retrieve depth data map
        let depthPixelBuffer = depthData.depthDataMap
        
        // Lock the base address of the pixel buffer
        if CVPixelBufferLockBaseAddress(depthPixelBuffer, .readOnly) == kCVReturnSuccess {
            // Proceed with processing depth data
            defer { CVPixelBufferUnlockBaseAddress(depthPixelBuffer, .readOnly) }
            
            let width = CVPixelBufferGetWidth(depthPixelBuffer)
            let height = CVPixelBufferGetHeight(depthPixelBuffer)
            let baseAddress = CVPixelBufferGetBaseAddress(depthPixelBuffer)
            let bytesPerRow = CVPixelBufferGetBytesPerRow(depthPixelBuffer)
            
            var averageDepth: Float = 0.0 // Declare as variable
            
            // Assuming depth data format is Float32
            let bufferPointer = baseAddress?.assumingMemoryBound(to: Float32.self)
            
            // Processing depth data
            if let bufferPointer = bufferPointer {
                var totalDepth: Float = 0.0
                var pixelCount = 0
                
//                print("start")
                for y in 0..<height {
                    for x in 0..<width {
                        let depthValue = bufferPointer[y * bytesPerRow / MemoryLayout<Float32>.stride + x]
                        if depthValue <= 6000 && depthValue >= 250 {
//                            print("\(x),\(y),\(depthValue)")
                            totalDepth += depthValue
                            pixelCount += 1
                        }
                    }
                }
//                print("end")
                
                // Compute average depth
                // ignore if not enough pixels in the correct range
                if pixelCount < 20000 {
                    averageDepth = -1
                } else {
                    // Compute average depth
                    averageDepth = totalDepth / Float(pixelCount)
                    averageDepth = max(min(3600, averageDepth), 600)
//                    self.volume = ((3600 - averageDepth) / 300)
                    self.volume = 1 - ((averageDepth - 600)/3000)
                }
                
                // Update closestObjectDistance property with average distance
                DispatchQueue.main.async {
//                    self.closestObjectDistance = String(format: "Volume: %.2f", self.volume)
                    self.closestObjectDistance = self.volume
                }
            } else {
                print("Failed to access depth data buffer.")
            }
        } else {
            print("Depth data buffer is invalid.")
        }
    }
}
