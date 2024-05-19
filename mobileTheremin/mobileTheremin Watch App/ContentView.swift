//
//  ContentView.swift
//  mobileTheremin Watch App
//
//  Created by Elena Hertel on 4/25/24.
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
            
            Button(action: {
                watchToiOSConnector.sendFrequency(frequency: pitch)
            }) {
                Text("Send Frequency")
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

struct GyroscopeView: View{
    let motionManager = CMMotionManager()
    let healthStore = HKHealthStore()
    
    @State private var session: HKWorkoutSession?
    
    @State private var isRecording = false
    
    @State private var roll: Double = 0.0
    @State private var pitch: Double = 0.0
    @State private var yaw: Double = 0.0
    
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
            
            Text("Roll: \(roll, specifier: "%.2f")")
            Text("Pitch: \(pitch, specifier: "%.2f")")
            Text("Yaw: \(yaw, specifier: "%.2f")")
        }
        .padding()
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
            motionManager.deviceMotionUpdateInterval = 1.0/50.0
            motionManager.startDeviceMotionUpdates(to: .main) { data, error in
                guard let data = data else { return }
                
                self.roll = data.attitude.roll
                self.pitch = data.attitude.pitch
                self.yaw = data.attitude.yaw
                
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
            GyroscopeView()
            SendFrequency()
        }
        .edgesIgnoringSafeArea(.top)
    }
}

#Preview {
    ContentView()
}
