//
//  HandView.swift
//  Theremin
//
//  Created by Elena Hertel on 5/21/24.
//

import AudioKit
import AudioKitUI
import SoundpipeAudioKit
import SwiftUI
import Tonic

class HandConductor: ObservableObject, HasAudioEngine {
    let engine = AudioEngine()
    var osc = DynamicOscillator()
    
    @Published var frequency: Float = 0.0 {
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

    func start() {
        do {
            try engine.start()
        } catch {
            Log("AudioKit did not start!")
        }
    }

    func stop() {
        engine.stop()
    }
}

struct HandView: View {
    @StateObject var conductor = HandConductor()
    @StateObject var cameraController = CameraController()
    @State private var isCameraSetup = false

    @StateObject var watchConnector = WatchConnector()
    
    @State private var normalizedFrequency: Double = 0.0
    @State private var frequency: Double = 250
    @State private var amplitude: Float = 0.1
    
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
            
            ThereminView(frequency: $frequency, amplitude: $amplitude)
                .frame(width: 200, height: 100)
                .padding()
            
            VStack {
                HStack {
                    Spacer()
                    CustomSliderAmplitude(value: $amplitude, range: 0...1, isVertical: true)
                }
                CustomSliderFrequency(frequency: $frequency, range: 250...1050)
            }
            NodeOutputView(conductor.osc)
        }
        .onAppear {
            if (!isCameraSetup && !cameraController.session.isRunning) {
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
            self.amplitude = newVolume
            conductor.amplitude = amplitude
        }
        .onReceive(watchConnector.$receivedMessage) { receivedMessage in
            if let message = receivedMessage,
               let normalizedFrequency = message["frequency"] as? Double {
                self.normalizedFrequency = max(min(normalizedFrequency, 1), -1)
                let frequencyRange = maxFrequency - minFrequency
                self.frequency = minFrequency + (normalizedFrequency + 1) * (frequencyRange / 2.0)
                conductor.frequency = Float(frequency)
                conductor.isPlaying = true
            }
        }
    }
}


struct CustomSliderFrequency: View {
    @Binding var frequency: Double
    var range: ClosedRange<Double>
    var isVertical: Bool = false

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Slider(value: $frequency, in: range)
                    .opacity(0) // Hide the original slider

                // Hand Image
                Image("red_hand")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .offset(x: thumbPosition(in: geometry.size), // Adjusted x-offset
                            y: -1) // Adjusted y-offset
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                let newValue = range.lowerBound + Double(gesture.location.x / (geometry.size.width - 50)) * (range.upperBound - range.lowerBound)
                                frequency = min(max(range.lowerBound, newValue), range.upperBound)
                            }
                    )
            }
        }
        .frame(height: 50) // Horizontal slider
    }

    private func thumbPosition(in size: CGSize) -> CGFloat {
        let availableSize = size.width - 50 // Adjusted available size to prevent overflow
        let thumbOffset = CGFloat((frequency - range.lowerBound) / (range.upperBound - range.lowerBound)) * availableSize
        return thumbOffset
    }
}


struct CustomSliderAmplitude: View {
    @Binding var value: Float
    var range: ClosedRange<Float>
    var isVertical: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                Slider(value: $value, in: range)
                    .opacity(0) // Hide the original slider
                
                // Hand Image
                Image("blue_hand")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .offset(x: isVertical ? -30 : thumbPosition(in: geometry.size), // Adjusted x-offset
                            y: isVertical ? thumbPosition(in: geometry.size) - -6 : 50) // Adjusted y-offset
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                updateAmplitude(with: gesture, in: geometry.size)
                            }
                    )
            }
        }
        .frame(width: isVertical ? 20 : nil, height: isVertical ? nil : 0)
    }
    
    private func thumbPosition(in size: CGSize) -> CGFloat {
        let availableSize = isVertical ? size.height : size.width
        let thumbOffset = (1.0 - CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound))) * availableSize
        return thumbOffset
    }
    
    private func updateAmplitude(with gesture: DragGesture.Value, in size: CGSize) {
        let availableSize = isVertical ? size.height : size.width
        let gestureLocation = isVertical ? gesture.location.y : gesture.location.x
        let invertedLocation = availableSize - gestureLocation
        let newValue = range.lowerBound + Float(invertedLocation / availableSize) * (range.upperBound - range.lowerBound)
        value = min(max(range.lowerBound, newValue), range.upperBound)
    }
}

public struct ThereminView: View {
    @Binding var frequency: Double
    @Binding var amplitude: Float
    
    public var body: some View {
        VStack {
            Spacer()
            HStack {
                VStack {
                    Text("Frequency")
                        .foregroundColor(.red)
                        .font(.headline)
                    Text("\(String(format: "%.2f", frequency))")
                        .foregroundColor(.red)
                        .font(.subheadline)
                }
                .padding()
                .frame(width: 150)
                .background(Color.white)
                .cornerRadius(5)
                .shadow(radius: 5)
                
                VStack {
                    Text("Amplitude")
                        .foregroundColor(.blue)
                        .font(.headline)
                    Text("\(String(format: "%.2f", amplitude))")
                        .foregroundColor(.blue)
                        .font(.subheadline)
                }
                .padding()
                .frame(width: 150)
                .background(Color.white)
                .cornerRadius(5)
                .shadow(radius: 5)
                
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
