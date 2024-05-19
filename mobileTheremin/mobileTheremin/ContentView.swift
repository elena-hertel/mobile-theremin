//
//  ContentView.swift
//  mobileTheremin
//
//  Created by Elena Hertel on 4/25/24.
//

import SwiftUI
import AVFoundation
import WatchConnectivity

//struct PlayFrequencyView: View {
//    @State private var frequency: Double = 440.0 // Default frequency
//    let player = SoundControl()
//    
//    @State private var isPlaying = false
//    
//    var body: some View {
//        VStack {
//            Text("Frequency: \(Int(frequency)) Hz")
//            
//            Slider(value: $frequency, in: 20...5000, step: 1)
//            .padding()
//            .onChange(of: frequency) {
//                if isPlaying { // Stop current sound
//                    player.play(frequency: Float(frequency)) // Play with new frequency
//                }
//            }
//            
//            Button(action: {
//                if !isPlaying {
//                    player.play(frequency: Float(frequency))
//                    isPlaying = true
//                } else {
//                    player.stop()
//                    isPlaying = false
//                }
//            }) {
//                Text(!isPlaying ? "Play Frequency" : "Stop")
//            }
//            .padding()
//            
//        }
//    }
//}

struct GetFrequencyView: View {
    @StateObject var watchConnector = WatchConnector()
    @State private var frequency: Double?
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            
            if let frequency = frequency {
                Text("Frequency: \(frequency)")
                    .foregroundColor(.green)
                    .padding()
            } else {
                Text("No Frequency Received")
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .onReceive(watchConnector.$receivedMessage) { message in
            if let frequency = message?["frequency"] as? Double {
                self.frequency = frequency
            }
        }
    }
}

//struct DepthStreamerView: View {
//    @StateObject var cameraController = CameraController()
//    @State private var isCameraSetup = false
//
//    var body: some View {
//        VStack {
//            Text(cameraController.closestObjectDistance)
//                .padding()
//                .foregroundColor(.white)
//                .font(.title)
//        }
//        .background(Color.black)
//        .edgesIgnoringSafeArea(.all)
//        .onAppear {
//            if !isCameraSetup && !cameraController.session.isRunning {
//                cameraController.setupCamera() // Start capturing depth data
//                isCameraSetup = true
//                print("Depth streamer view appeared.")
//            }
//        }
//        .onDisappear {
//            print("Depth streamer view disappeared.")
//        }
//    }
//}

struct ContentView: View {
    var body: some View {
        TabView {
//            DepthStreamerView()
//            GetFrequencyView()
//            PlayFrequencyView()
//            CompleteView()
        }
        .edgesIgnoringSafeArea(.top)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
