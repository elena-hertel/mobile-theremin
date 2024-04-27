//
//  ContentView.swift
//  mobileTheremin
//
//  Created by Elena Hertel on 4/25/24.
//

import SwiftUI
import AVFoundation

struct CameraView: UIViewRepresentable {
    var cameraController: CameraController
    
    func makeUIView(context: Context) -> UIView {
        let cameraView = UIView()
        let previewLayer = AVCaptureVideoPreviewLayer(session: cameraController.session)
        cameraView.layer.addSublayer(previewLayer)
        previewLayer.frame = cameraView.bounds // Set previewLayer's frame to match cameraView's bounds
        cameraController.session.startRunning() // Start the camera session
        return cameraView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Update the view if needed
        let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer
        previewLayer?.frame = uiView.bounds
    }
}

struct DepthStreamerView: View {
    @StateObject var cameraController = CameraController()
    @State private var isCameraSetup = false

    var body: some View {
        VStack {
            Text(cameraController.closestObjectDistance)
                .padding()
                .foregroundColor(.white)
                .font(.title)
        }
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            if !isCameraSetup && !cameraController.session.isRunning {
                cameraController.setupCamera() // Start capturing depth data
                isCameraSetup = true
                print("Depth streamer view appeared.")
            }
        }
        .onDisappear {
            print("Depth streamer view disappeared.")
        }
    }
}

struct ContentView: View {
    var body: some View {
        TabView {
            DepthStreamerView()
        }
        .edgesIgnoringSafeArea(.top)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
