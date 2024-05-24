//
//  TechnicalView.swift
//  Theremin
//
//  Created by Elena Hertel on 5/21/24.
//

import AudioKit
import AudioKitUI
import SoundpipeAudioKit
import SwiftUI
import Tonic
import Controls

public struct ModularFrequencyView: View {
    @Binding var frequency: Double
    
    public var body: some View {
        VStack(alignment: .center) {
            VStack {
                Text("Frequency [Hz]")
                    .minimumScaleFactor(0.2)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                Text(String(format: "%0.2f", frequency)).lineLimit(1)
            }
            .frame(height: 50)
            // Use ArcKnob to represent frequency visually
            ArcKnob("", value: Binding<Float>(
                get: { Float(frequency) },
                set: { frequency = Double($0) }
            ), range: 30...1250)
        }
    }
}

public struct LinearAmplitudeView: View {
    @Binding var volume: Float
    
    public var body: some View {
        VStack(alignment: .center) {
            VStack {
                Text("Amplitude")
                    .minimumScaleFactor(0.2)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                Text(String(format: "%0.2f", volume)).lineLimit(1)
            }
            .frame(height: 50)
            ModWheel(value: $volume)
        }
    }
}

class TechnicalConductor: ObservableObject, HasAudioEngine {
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

struct TechnicalView: View {
    @StateObject var conductor = TechnicalConductor()
    
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
                ModularFrequencyView(frequency: $frequency)
                LinearAmplitudeView(volume: $volume)
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
               let normalizedFrequency = message["frequency"] as? Double,
               let timestamp = message["timestamp"] as? Double {
//                print("Gyroscope Latency: \(Date().timeIntervalSince1970-timestamp)") // uncomment for gyroscope data latency
                self.normalizedFrequency = max(min(normalizedFrequency, 1), -1)
                let frequencyRange = maxFrequency - minFrequency
                self.frequency = minFrequency + (normalizedFrequency + 1) * (frequencyRange / 2.0)
                conductor.frequency = frequency
                conductor.isPlaying = true
            }
        }
    }
}
