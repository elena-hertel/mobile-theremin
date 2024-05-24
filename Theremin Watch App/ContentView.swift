//
//  ContentView.swift
//  Theremin Watch App
//
//  Created by Elena Hertel on 5/21/24.
//

import SwiftUI
import CoreMotion
import HealthKit

extension Notification.Name {
    static let pitchUpdated = Notification.Name("pitchUpdated")
}

struct SendFrequency: View {
    let motionManager = CMMotionManager()
    let healthStore = HKHealthStore()
    
    @State private var session: HKWorkoutSession?
    
    @State private var isRecording = false
    
    @State private var pitch: Double = 0.0
    
    @StateObject var watchToiOSConnector = WatchToiOSConnector()
    
    var body: some View {
        VStack {
            Button(action: {
                if isRecording {
                    stopRecording()
                } else {
                    startRecording()
                }
            }) {
                Text(isRecording ? "Stop Recording" : "Start Recording")
            }
            .padding()
        }
        .onReceive(NotificationCenter.default.publisher(for: .pitchUpdated)) { _ in
            // This block is executed every time the pitch value is updated
            watchToiOSConnector.sendFrequency(frequency: pitch)
        }
    }
    
    func startRecording() {
        if session != nil {
            return
        }
        
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .other
        
        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: workoutConfiguration)
            session?.startActivity(with: Date())
        } catch {
            fatalError("Unable to create the workout session!")
        }
        
        isRecording = true
        
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 1.0/10.0
            motionManager.startDeviceMotionUpdates(to: .main) { data, error in
                guard let data = data else { return }
                
                self.pitch = data.attitude.pitch
                
                NotificationCenter.default.post(name: .pitchUpdated, object: nil)
                
            }
        }
        else {
            print("motion data not available")
        }
    }
    
    func stopRecording() {
        guard let session = session else {
            return
        }
        
        isRecording = false
        motionManager.stopDeviceMotionUpdates()
        session.stopActivity(with: Date())
        self.session = nil
    }
}

struct ContentView: View {
    var body: some View {
        TabView {
            SendFrequency()
        }
        .edgesIgnoringSafeArea(.top)
    }
}

#Preview {
    ContentView()
}
