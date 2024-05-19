//
//  SoundControl.swift
//  Testing
//
//  Created by Alicia Chun on 5/15/24.
//

import AudioKit
import AudioKitUI
import SoundpipeAudioKit
import SwiftUI
import Tonic

class DynamicOscillatorConductor: ObservableObject, HasAudioEngine {
    let engine = AudioEngine()
    var osc = DynamicOscillator()
    
    @Published var frequency: Double = 0.0 {
        didSet {
            osc.frequency = AUValue(frequency)
        }
    }
    
    @Published var amplitude: Float = 0.5 {
        didSet {
            osc.amplitude = amplitude
        }
    }
    
    @Published var isPlaying: Bool = false {
        didSet {
            isPlaying ? osc.start() : osc.stop()
        }
    }

    init() {
        engine.output = osc
    }
}

struct DynamicOscillatorView: View {
    @StateObject var conductor = DynamicOscillatorConductor()
    
    @StateObject var cameraController = CameraController()
    @State private var isCameraSetup = false

    @StateObject var watchConnector = WatchConnector()
    
    @State private var normalizedFrequency: Double = 0.0
    @State private var frequency: Double = 200
    @State private var volume: Float = 0.1
    
    let minFrequency = 250.0 // Minimum frequency in Hz
    let maxFrequency = 1050.0 // Maximum frequency in Hz
    
    @State private var previousMIDINote: Int8? = nil
    
    var body: some View {
        VStack {
            Text(conductor.isPlaying ? "STOP" : "START")
                .foregroundColor(.blue)
                .onTapGesture {
                    conductor.isPlaying.toggle()
                }
            HStack {
                FrequencyView(frequency: $frequency)
                AmplitudeView(volume: $volume)
            }
            NodeOutputView(conductor.osc)
        }
        .onAppear {
            if !isCameraSetup && !cameraController.session.isRunning {
                cameraController.setupCamera() // Start capturing depth data
                isCameraSetup = true
                print("Depth streamer view appeared.")
            }
            conductor.start()
        }
        .onDisappear {
            print("Depth streamer view disappeared.")
            conductor.stop()
        }
        .onReceive(cameraController.$closestObjectDistance) { newVolume in
            // Update the volume state when closestObjectDistance changes
            self.volume = newVolume
            conductor.amplitude = volume
        }
        .onReceive(watchConnector.$receivedMessage) { receivedMessage in
            if let message = receivedMessage,
               let normalizedFrequency = message["frequency"] as? Double {
                self.normalizedFrequency = max(min(normalizedFrequency, 1), -1)
                let frequencyRange = maxFrequency - minFrequency
                self.frequency = minFrequency + (normalizedFrequency + 1) * (frequencyRange / 2.0)
                conductor.frequency = frequency
                conductor.isPlaying = true
            }
        }
    }
}
